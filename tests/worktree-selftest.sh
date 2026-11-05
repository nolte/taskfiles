#!/usr/bin/env bash
# Regression guard for `worktree:add` (nolte/taskfiles#50).
#
# Exercises `task worktree:add` against a throwaway origin/clone pair for
# every branch prefix the module allows, plus negative cases that must be
# rejected. The prefix list is read from the module under test, so the guard
# can never drift from the source of truth.
#
# Usage: tests/worktree-selftest.sh [path/to/taskfile-include-worktree.yaml]
#   Defaults to src/taskfile-include-worktree.yaml in this repository. Pass
#   another file to check a different revision, e.g.:
#     git show origin/develop:src/taskfile-include-worktree.yaml > /tmp/old.yaml
#     tests/worktree-selftest.sh /tmp/old.yaml
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
module="${1:-$script_dir/../src/taskfile-include-worktree.yaml}"

if [ ! -f "$module" ]; then
  echo "✖ Module under test not found: $module" >&2
  exit 2
fi
module="$(cd "$(dirname "$module")" && pwd)/$(basename "$module")"

command -v task >/dev/null || { echo "✖ go-task CLI not on PATH" >&2; exit 2; }
command -v git >/dev/null || { echo "✖ git not on PATH" >&2; exit 2; }

# Source of truth: the WORKTREE_ALLOWED_PREFIXES line of the module itself.
allowed="$(sed -n 's/^[[:space:]]*WORKTREE_ALLOWED_PREFIXES:[[:space:]]*["'\'']\{0,1\}\([^"'\'']*\)["'\'']\{0,1\}[[:space:]]*$/\1/p' "$module" | head -n 1)"
if [ -z "${allowed// /}" ]; then
  echo "✖ Could not read WORKTREE_ALLOWED_PREFIXES from $module" >&2
  exit 2
fi
read -r -a prefixes <<<"$allowed"

work="$(mktemp -d "${TMPDIR:-/tmp}/worktree-selftest.XXXXXX")"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

# Hermetic git: ignore the caller's global/system config (signing, hooks,
# templates) and supply a fixed identity.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.invalid
export GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.invalid
export GIT_TERMINAL_PROMPT=0
unset NOLTE_WORKTREE_ROOT

# Bare origin with a `develop` branch carrying one commit, plus a clone of it.
git init -q -b develop "$work/seed"
git -C "$work/seed" commit -q --allow-empty -m "selftest seed"
git init -q --bare "$work/origin.git"
git -C "$work/seed" push -q "$work/origin.git" develop
git -C "$work/origin.git" symbolic-ref HEAD refs/heads/develop
git clone -q "$work/origin.git" "$work/clone"

pass=0
fail=0
report() { # <status> <case> [detail]
  if [ "$1" = PASS ]; then
    pass=$((pass + 1))
    echo "PASS  $2"
  else
    fail=$((fail + 1))
    echo "FAIL  $2${3:+ — $3}"
  fi
}

# run_add <case-id> <branch>: runs `worktree:add` in the clone with a fresh,
# case-unique worktree root. Sets rc, out, err, root.
run_add() {
  root="$work/roots/$1"
  mkdir -p "$root"
  set +e
  (cd "$work/clone" && NOLTE_WORKTREE_ROOT="$root" \
    task -t "$module" add -- "$2" >"$root.out" 2>"$root.err" </dev/null)
  rc=$?
  set -e
  out="$(cat "$root.out")"
  err="$(cat "$root.err")"
}

i=0
for p in "${prefixes[@]}"; do
  i=$((i + 1))
  name="positive: $p/selftest"
  run_add "pos-$i" "$p/selftest"
  dest="$root/origin/selftest"
  if [ "$rc" -ne 0 ]; then
    report FAIL "$name" "exit $rc${err:+, stderr: $err}"
  elif [[ "$out" != *"→ Worktree root"* ]]; then
    report FAIL "$name" "output lacks '→ Worktree root'"
  elif [ ! -d "$dest" ]; then
    report FAIL "$name" "worktree dir missing: $dest"
  elif [ ! -f "$dest/.resume/selftest/plan.md" ]; then
    report FAIL "$name" "plan stub missing: $dest/.resume/selftest/plan.md"
  else
    report PASS "$name"
  fi
done

i=0
for branch in nope/selftest "${prefixes[0]}"; do
  i=$((i + 1))
  name="negative: $branch"
  run_add "neg-$i" "$branch"
  if [ "$rc" -eq 0 ]; then
    report FAIL "$name" "expected non-zero exit, got 0"
  elif [[ "$err" != *"lacks an allowed prefix"* ]]; then
    report FAIL "$name" "exit $rc but stderr lacks 'lacks an allowed prefix'${err:+: $err}"
  else
    report PASS "$name"
  fi
done

echo
echo "worktree selftest ($module): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
