#!/usr/bin/env bash
set -euo pipefail

PYC_ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

pyc_log() {
  echo "[pyc] $*"
}

pyc_warn() {
  echo "[pyc][warn] $*" >&2
}

pyc_die() {
  echo "[pyc][error] $*" >&2
  exit 1
}

pyc_toolchain_root() {
  if [[ -n "${PYC_TOOLCHAIN_ROOT:-}" && -d "${PYC_TOOLCHAIN_ROOT}" ]]; then
    echo "${PYC_TOOLCHAIN_ROOT}"
    return 0
  fi

  if [[ -n "${PYCC:-}" && -x "${PYCC}" ]]; then
    local pycc_dir
    pycc_dir="$(cd -- "$(dirname -- "${PYCC}")" && pwd)"
    if [[ "$(basename -- "${pycc_dir}")" == "bin" ]]; then
      echo "$(cd -- "${pycc_dir}/.." && pwd)"
      return 0
    fi
  fi

  local root=""
  while IFS= read -r root; do
    [[ -n "${root}" ]] || continue
    local candidates=(
      "${root}/.pycircuit_out/toolchain/install"
      "${root}/dist/pycircuit"
    )
    local c=""
    for c in "${candidates[@]}"; do
      if [[ -x "${c}/bin/pycc" || -x "${c}/bin/pycc.exe" ]]; then
        echo "${c}"
        return 0
      fi
    done
  done < <(pyc_candidate_roots)

  return 1
}

pyc_candidate_roots() {
  # Prefer the current checkout.  Team workers run from per-worker git
  # worktrees, so also accept explicit or derived leader checkout roots for
  # prebuilt tool lookup without copying artifacts between trees.
  local roots=("${PYC_ROOT_DIR}")

  if [[ -n "${PYC_REPO_ROOT:-}" ]]; then
    roots+=("${PYC_REPO_ROOT}")
  fi
  if [[ -n "${OMX_TEAM_LEADER_CWD:-}" ]]; then
    roots+=("${OMX_TEAM_LEADER_CWD}")
  fi

  case "${PYC_ROOT_DIR}" in
    */.omx/team/*/worktrees/*)
      roots+=("${PYC_ROOT_DIR%%/.omx/team/*}")
      ;;
  esac

  local seen=":"
  local r=""
  for r in "${roots[@]}"; do
    [[ -n "${r}" && -d "${r}" ]] || continue
    r="$(cd -- "${r}" && pwd)"
    case "${seen}" in
      *:"${r}":*) continue ;;
    esac
    seen="${seen}${r}:"
    echo "${r}"
  done
}

pyc_find_toolchain_pycc_candidates() {
  local exe_suffix="${1:-}"
  local root=""
  while IFS= read -r root; do
    [[ -n "${root}" ]] || continue
    cat <<EOF
${root}/.pycircuit_out/toolchain/install/bin/pycc${exe_suffix}
${root}/dist/pycircuit/bin/pycc${exe_suffix}
${root}/compiler/mlir/build2/bin/pycc${exe_suffix}
${root}/build/bin/pycc${exe_suffix}
${root}/compiler/mlir/build/bin/pycc${exe_suffix}
${root}/build-top/bin/pycc${exe_suffix}
${root}/.pycircuit_out/toolchain/install/bin/pycc
${root}/dist/pycircuit/bin/pycc
${root}/compiler/mlir/build2/bin/pycc
${root}/build/bin/pycc
${root}/compiler/mlir/build/bin/pycc
${root}/build-top/bin/pycc
EOF
  done < <(pyc_candidate_roots)
}

pyc_export_toolchain_root_for_pycc() {
  local root=""
  if root="$(pyc_toolchain_root 2>/dev/null)"; then
    export PYC_TOOLCHAIN_ROOT="${root}"
  else
    local pycc_dir
    pycc_dir="$(cd -- "$(dirname -- "${PYCC}")" && pwd)"
    if [[ "$(basename -- "${pycc_dir}")" == "bin" ]]; then
      export PYC_TOOLCHAIN_ROOT
      PYC_TOOLCHAIN_ROOT="$(cd -- "${pycc_dir}/.." && pwd)"
    fi
  fi
}

pyc_record_best_pycc() {
  local candidate="${1}"
  local mtime=0
  [[ -x "${candidate}" ]] || return 0
  if mtime="$(stat -f %m "${candidate}" 2>/dev/null)"; then
    :
  elif mtime="$(stat -c %Y "${candidate}" 2>/dev/null)"; then
    :
  else
    mtime=0
  fi
  if (( mtime > best_mtime )); then
    best="${candidate}"
    best_mtime="${mtime}"
  fi
}

pyc_find_pycc() {
  if [[ -n "${PYCC:-}" && -x "${PYCC}" ]]; then
    pyc_export_toolchain_root_for_pycc
    return 0
  fi

  local exe_suffix=""
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*) exe_suffix=".exe";;
  esac

  local toolchain_root=""
  if toolchain_root="$(pyc_toolchain_root 2>/dev/null)"; then
    if [[ -x "${toolchain_root}/bin/pycc${exe_suffix}" ]]; then
      export PYC_TOOLCHAIN_ROOT="${toolchain_root}"
      export PYCC="${toolchain_root}/bin/pycc${exe_suffix}"
      return 0
    fi
    if [[ -x "${toolchain_root}/bin/pycc" ]]; then
      export PYC_TOOLCHAIN_ROOT="${toolchain_root}"
      export PYCC="${toolchain_root}/bin/pycc"
      return 0
    fi
  fi

  # Pick the newest executable among the common build locations. This avoids
  # accidentally grabbing an older `pycc` from a stale build directory.
  local best=""
  local best_mtime=0
  local c=""
  while IFS= read -r c; do
    pyc_record_best_pycc "${c}"
  done < <(pyc_find_toolchain_pycc_candidates "${exe_suffix}")
  if [[ -n "${best}" ]]; then
    export PYCC="${best}"
    pyc_export_toolchain_root_for_pycc
    return 0
  fi

  if command -v pycc >/dev/null 2>&1; then
    export PYCC
    PYCC="$(command -v pycc)"
    pyc_export_toolchain_root_for_pycc
    return 0
  fi

  if command -v pycc.exe >/dev/null 2>&1; then
    export PYCC
    PYCC="$(command -v pycc.exe)"
    pyc_export_toolchain_root_for_pycc
    return 0
  fi

  pyc_die "missing pycc (set PYCC=... or build it with: flows/scripts/pyc build)"
}

pyc_pythonpath() {
  if [[ "${PYC_USE_INSTALLED_PYTHON_PACKAGE:-0}" == "1" ]]; then
    echo "${PYC_PYTHONPATH:-}"
    return 0
  fi

  if [[ -n "${PYC_PYTHONPATH:-}" ]]; then
    echo "${PYC_PYTHONPATH}"
    return 0
  fi

  # Prefer editable install (`pip install -e .`), but fall back to PYTHONPATH for
  # repo-local runs.  iplib/ is the standard IP library (RegFile, FIFO, Cache, …).
  echo "${PYC_ROOT_DIR}/compiler/frontend:${PYC_ROOT_DIR}/designs:${PYC_ROOT_DIR}"
}

pyc_out_root() {
  echo "${PYC_ROOT_DIR}/.pycircuit_out"
}
