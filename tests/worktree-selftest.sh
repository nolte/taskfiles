#!/usr/bin/env bash
# Regression guard for `worktree:add` (nolte/taskfiles#50, #53).
#
# Exercises `worktree:add` against a throwaway origin/clone pair for every
# branch prefix the module allows, plus negative cases that must be rejected
# (missing/unknown/substring prefix, empty branch name, whitespace in the
# branch, a name git refuses as a branch, unsafe slug including `.`, existing
# destination, running outside a repository, missing arguments). The module
# is driven both directly (`task -t <module> add`) and through a
# consumer-style Taskfile that includes it (`task worktree:add`).
# A second clone whose only remote is `upstream` checks that `add` and
# `remove` derive <repo> from WORKTREE_FETCH_REMOTE, never from `origin` (#54),
# and a third clone with rewritten remote URLs checks the URL normalisation.
#
# The prefix list is the value Task itself resolves for
# WORKTREE_ALLOWED_PREFIXES (read from a `--dry --verbose` render of the
# task), so the guard can never drift from the source of truth — whether the
# module declares it as a plain literal or as a `| default "…"` template.
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

work="$(mktemp -d "${TMPDIR:-/tmp}/worktree-selftest.XXXXXX")"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

# Hermetic git: ignore the caller's global/system config (signing, hooks,
# templates) and supply a fixed identity. Module overrides that may arrive
# through the environment are dropped so only the module's own values count.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.invalid
export GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.invalid
export GIT_TERMINAL_PROMPT=0
unset NOLTE_WORKTREE_ROOT WORKTREE_ALLOWED_PREFIXES WORKTREE_ROOT_DEFAULT \
  WORKTREE_BASE_REF WORKTREE_FETCH_REMOTE WORKTREE_FETCH_BRANCH

# Source of truth: the value Task resolves for WORKTREE_ALLOWED_PREFIXES. A
# dry, verbose run renders the templated script without executing it; the
# rendered `allowed_prefixes="…"` assignment carries the resolved value.
mkdir -p "$work/probe"
allowed="$(cd "$work/probe" && task -t "$module" add --dry --verbose -- probe/probe 2>&1 </dev/null |
  sed -n 's/^\(task: \[[^]]*\] \)\{0,1\}[[:space:]]*allowed_prefixes="\([^"]*\)"[[:space:]]*$/\2/p' |
  head -n 1)" || true
if [ -z "${allowed// /}" ]; then
  echo "✖ Could not resolve WORKTREE_ALLOWED_PREFIXES from $module" >&2
  exit 2
fi
read -r -a prefixes <<<"$allowed"

# Bare origin with a `develop` branch carrying one commit, plus a clone of it.
# `git init` + `symbolic-ref` instead of `git init -b` keeps git < 2.28 working.
git init -q "$work/seed"
git -C "$work/seed" symbolic-ref HEAD refs/heads/develop
git -C "$work/seed" commit -q --allow-empty -m "selftest seed"
git init -q --bare "$work/origin.git"
git -C "$work/seed" push -q "$work/origin.git" develop
git -C "$work/origin.git" symbolic-ref HEAD refs/heads/develop
git clone -q "$work/origin.git" "$work/clone"

# Consumer-style wrapper: how downstream projects wire the module in.
cat >"$work/clone/Taskfile.yml" <<EOF
version: '3'

includes:
  worktree: $module
EOF

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

# run_add <root-id> <direct|consumer> [args...]: runs `worktree:add` in the
# clone with the worktree root $work/roots/<root-id> (reused across calls with
# the same id). The module under test is $run_module when set, else $module;
# the checkout it runs in is $run_clone when set, else $work/clone.
# `task -x` passes the script's own exit status through instead
# of go-task's generic 201. Sets rc, out, err, root.
runs=0
run_add() {
  local id="$1" mode="$2"
  shift 2
  root="$work/roots/$id"
  runs=$((runs + 1))
  local log="$work/logs/$runs"
  mkdir -p "$root" "$work/logs"
  set +e
  if [ "$mode" = consumer ]; then
    (cd "$work/clone" && NOLTE_WORKTREE_ROOT="$root" \
      task -x worktree:add -- "$@" >"$log.out" 2>"$log.err" </dev/null)
  else
    (cd "${run_clone:-$work/clone}" && NOLTE_WORKTREE_ROOT="$root" \
      task -x -t "${run_module:-$module}" add -- "$@" >"$log.out" 2>"$log.err" </dev/null)
  fi
  rc=$?
  set -e
  out="$(cat "$log.out")"
  err="$(cat "$log.err")"
}

# run_remove <root-id> [args...]: runs `worktree:remove` directly against the
# module, honouring $run_module and $run_clone like run_add. Sets rc, out,
# err, root.
run_remove() {
  local id="$1"
  shift
  root="$work/roots/$id"
  runs=$((runs + 1))
  local log="$work/logs/$runs"
  mkdir -p "$root" "$work/logs"
  set +e
  (cd "${run_clone:-$work/clone}" && NOLTE_WORKTREE_ROOT="$root" \
    task -x -t "${run_module:-$module}" remove -- "$@" >"$log.out" 2>"$log.err" </dev/null)
  rc=$?
  set -e
  out="$(cat "$log.out")"
  err="$(cat "$log.err")"
}

# check_created <case> <slug>: asserts the last run_add created a worktree
# with its plan stub under "$root/<repo>/<slug>", where <repo> is $run_repo
# when set, else `origin` (the bare repo the default clone points at).
check_created() {
  local dest="$root/${run_repo:-origin}/$2"
  if [ "$rc" -ne 0 ]; then
    report FAIL "$1" "exit $rc${err:+, stderr: $err}"
  elif [[ "$out" != *"→ Worktree root"* ]]; then
    report FAIL "$1" "output lacks '→ Worktree root'"
  elif [ ! -d "$dest" ]; then
    report FAIL "$1" "worktree dir missing: $dest"
  elif [ ! -f "$dest/.resume/$2/plan.md" ]; then
    report FAIL "$1" "plan stub missing: $dest/.resume/$2/plan.md"
  else
    report PASS "$1"
  fi
}

# check_rejected <case> <expected-stderr-fragment> [expected-exit]: asserts
# the last run_add failed with the given stderr message (and exit status).
check_rejected() {
  if [ "$rc" -eq 0 ]; then
    report FAIL "$1" "expected non-zero exit, got 0"
  elif [ -n "${3:-}" ] && [ "$rc" -ne "$3" ]; then
    report FAIL "$1" "expected exit $3, got $rc${err:+, stderr: $err}"
  elif [[ "$err" != *"$2"* ]]; then
    report FAIL "$1" "exit $rc but stderr lacks '$2'${err:+: $err}"
  else
    report PASS "$1"
  fi
}

# check_untouched <case>: asserts the last run_add left its worktree root
# empty and never printed the pre-fetch banner, i.e. it was rejected before
# any fetch or `git worktree add`.
check_untouched() {
  if [ -n "$(ls -A "$root")" ]; then
    report FAIL "$1" "worktree root not empty: $(ls -A "$root" | tr '\n' ' ')"
  elif [[ "$out" == *"→ Worktree root"* ]]; then
    report FAIL "$1" "reached the fetch stage ('→ Worktree root' printed)"
  elif [[ "$err" == *fatal:* || "$err" == *"Could not"* ]]; then
    report FAIL "$1" "git/fetch output on stderr: $err"
  else
    report PASS "$1"
  fi
}

# check_hint <case> <fragment> <present|absent>: asserts the last run's stderr
# does (or does not) carry <fragment>, e.g. a case-specific hint.
check_hint() {
  if [ "$3" = present ] && [[ "$err" != *"$2"* ]]; then
    report FAIL "$1" "stderr lacks '$2'${err:+: $err}"
  elif [ "$3" = absent ] && [[ "$err" == *"$2"* ]]; then
    report FAIL "$1" "stderr unexpectedly carries '$2': $err"
  else
    report PASS "$1"
  fi
}

slug_hint="the branch MUST NOT"

# --- positive: every allowed prefix, directly and via the consumer wrapper --
i=0
for p in "${prefixes[@]}"; do
  i=$((i + 1))
  run_add "pos-$i" direct "$p/selftest"
  check_created "positive: $p/selftest" selftest
done

# Branches live in the one shared clone, so each further case needs its own name.
run_add pos-consumer consumer "${prefixes[0]}/selftest-consumer"
check_created "positive (consumer): ${prefixes[0]}/selftest-consumer" selftest-consumer

run_add pos-slug direct "${prefixes[0]}/selftest-slug" custom-slug
check_created "positive: ${prefixes[0]}/selftest-slug custom-slug" custom-slug

# --- negative: branch prefix ------------------------------------------------
i=0
for branch in "${prefixes[0]}" /selftest; do
  i=$((i + 1))
  run_add "neg-noprefix-$i" direct "$branch"
  check_rejected "negative: $branch (no prefix)" "has no prefix"
  check_hint "negative: $branch carries the slug hint" "$slug_hint" present
done

run_add neg-badprefix direct nope/selftest
check_rejected "negative: nope/selftest (unknown prefix)" "lacks an allowed prefix"
check_hint "negative: nope/selftest carries the slug hint" "$slug_hint" present

run_add neg-consumer consumer nope/selftest
check_rejected "negative (consumer): nope/selftest (unknown prefix)" "lacks an allowed prefix"

# Substring of the joined list, not a single allowed token: "fix chore" sits
# inside "feat fix chore docs exp" but must not pass the gate.
if [ "${#prefixes[@]}" -ge 3 ]; then
  sub="${prefixes[1]} ${prefixes[2]}/selftest"
elif [ "${#prefixes[@]}" -ge 2 ]; then
  sub="${prefixes[0]} ${prefixes[1]}/selftest"
else
  sub=""
fi
if [ -n "$sub" ]; then
  run_add neg-substring direct "$sub"
  check_rejected "negative: '$sub' (substring prefix)" "lacks an allowed prefix" 1
  check_untouched "negative: '$sub' creates nothing"
fi

# --- negative: empty branch name after the prefix ---------------------------
run_add neg-emptyname direct "${prefixes[0]}/"
check_rejected "negative: ${prefixes[0]}/ (empty name)" "has an empty name after" 1
check_untouched "negative: ${prefixes[0]}/ rejected before fetch"
check_hint "negative: ${prefixes[0]}/ omits the slug hint" "$slug_hint" absent

run_add neg-emptyname-slug direct "${prefixes[0]}/" custom-slug
check_rejected "negative: ${prefixes[0]}/ custom-slug (empty name)" "has an empty name after" 1
check_untouched "negative: ${prefixes[0]}/ custom-slug rejected before fetch"

# --- negative: whitespace inside the branch name ---------------------------
# go-task hands `-- "<a b>"` through as one quoted argument, so the branch
# itself carries the blank/tab and must be rejected before any fetch.
i=0
for branch in "${prefixes[0]}/a b" "${prefixes[0]}/a"$'\t'"b"; do
  i=$((i + 1))
  run_add "neg-space-$i" direct "$branch"
  check_rejected "negative: '$branch' (whitespace)" "must not contain whitespace" 1
  check_untouched "negative: '$branch' rejected before fetch"
  check_hint "negative: '$branch' omits the slug hint" "$slug_hint" absent
done

# --- negative: name git refuses as a branch ---------------------------------
# Passes every prefix/whitespace check, but `git worktree add -b` would die on
# it. It must be rejected before the banner, the fetch, or any write. A
# trailing slash counts as an invalid branch, never as a slug problem.
i=0
for branch in "${prefixes[0]}/x~1" "${prefixes[0]}/x.lock" "${prefixes[0]}/x/" \
  "${prefixes[0]}/x:y" "${prefixes[0]}/a..b"; do
  i=$((i + 1))
  run_add "neg-refname-$i" direct "$branch"
  check_rejected "negative: '$branch' (invalid branch name)" "is not a valid git branch name" 1
  check_untouched "negative: '$branch' rejected before fetch"
done

# --- negative: unsafe slug --------------------------------------------------
i=0
for slug in a/b ..x; do
  i=$((i + 1))
  run_add "neg-slug-$i" direct "${prefixes[0]}/selftest" "$slug"
  check_rejected "negative: ${prefixes[0]}/selftest $slug (unsafe slug)" "must be a single kebab-case path segment"
done

# `.` would turn <root>/<repo> itself into the worktree.
run_add neg-slug-dot direct "${prefixes[0]}/selftest-dot" .
check_rejected "negative: ${prefixes[0]}/selftest-dot . (slug '.')" "must be a single kebab-case path segment" 1
check_untouched "negative: slug '.' creates nothing"

# remove must refuse `.` too, even where <root>/<repo> exists (pos-1 holds a
# worktree), and leave that worktree in place.
run_remove pos-1 .
check_rejected "negative: remove slug '.'" "must be a single path segment" 1
if [ -d "$root/origin/selftest" ]; then
  report PASS "negative: remove slug '.' leaves the existing worktree"
else
  report FAIL "negative: remove slug '.' leaves the existing worktree" "missing: $root/origin/selftest"
fi

# --- negative: destination already exists -----------------------------------
# Same branch and slug twice in one root: the destination check runs before
# `git worktree add`, so the second call must fail on the existing directory.
run_add neg-exists direct "${prefixes[0]}/selftest-exists"
if [ "$rc" -ne 0 ]; then
  report FAIL "negative: destination exists (setup)" "first add failed: exit $rc${err:+, stderr: $err}"
else
  run_add neg-exists direct "${prefixes[0]}/selftest-exists"
  check_rejected "negative: destination exists" "Destination already exists"
fi

# --- positive: whitespace-padded, tab-separated prefix list -----------------
# A copy of the module whose WORKTREE_ALLOWED_PREFIXES literal is rewritten to
# a padded, tab/multi-space separated form of the same list: the gate splits
# on any IFS whitespace, so every token must still match exactly.
if [ "${#prefixes[@]}" -ge 2 ]; then
  tab=$'\t'
  padded="  ${prefixes[0]}"
  for p in "${prefixes[@]:1}"; do padded="$padded$tab  $p"; done
  padded="$padded  "
  ws_module="$work/module-ws.yaml"
  sed "s|^\([[:space:]]*WORKTREE_ALLOWED_PREFIXES:\).*|\1 \"$padded\"|" "$module" >"$ws_module"
  if cmp -s "$module" "$ws_module"; then
    report FAIL "positive (padded list): setup" "no WORKTREE_ALLOWED_PREFIXES line to rewrite in $module"
  else
    i=0
    for p in "${prefixes[1]}" "${prefixes[${#prefixes[@]} - 1]}"; do
      i=$((i + 1))
      run_module="$ws_module" run_add "pos-ws-$i" direct "$p/selftest-ws-$i"
      check_created "positive (padded list): $p/selftest-ws-$i" "selftest-ws-$i"
    done
    run_module="$ws_module" run_add neg-ws direct nope/selftest-ws
    check_rejected "negative (padded list): nope/selftest-ws" "lacks an allowed prefix" 1
  fi
fi

# --- <repo> follows WORKTREE_FETCH_REMOTE, not a hard-coded origin (#54) -----
# A second clone whose only remote is `upstream`, pointing at a bare repo named
# `upstream-repo.git`, so the derived <repo> is distinguishable from `origin`.
git clone -q "$work/origin.git" "$work/upstream-repo.git" --bare
git clone -q "$work/upstream-repo.git" "$work/clone-upstream"
git -C "$work/clone-upstream" remote rename origin upstream
up_module="$work/module-upstream.yaml"
sed -e "s|^\([[:space:]]*WORKTREE_FETCH_REMOTE:\).*|\1 \"upstream\"|" \
  -e "s|^\([[:space:]]*WORKTREE_BASE_REF:\).*|\1 \"upstream/develop\"|" \
  "$module" >"$up_module"
if ! grep -q '^[[:space:]]*WORKTREE_FETCH_REMOTE: "upstream"$' "$up_module" ||
  ! grep -q '^[[:space:]]*WORKTREE_BASE_REF: "upstream/develop"$' "$up_module"; then
  report FAIL "fetch remote upstream: setup" "no WORKTREE_FETCH_REMOTE/WORKTREE_BASE_REF line to rewrite in $module"
else
  up_branch="${prefixes[0]}/selftest-upstream"
  run_clone="$work/clone-upstream" run_module="$up_module" run_repo=upstream-repo \
    run_add pos-upstream direct "$up_branch"
  run_repo=upstream-repo check_created "positive (fetch remote upstream): $up_branch" selftest-upstream
  if [ -e "$root/origin" ]; then
    report FAIL "positive (fetch remote upstream): not named after origin" "found $root/origin"
  else
    report PASS "positive (fetch remote upstream): not named after origin"
  fi

  run_clone="$work/clone-upstream" run_module="$up_module" \
    run_remove pos-upstream selftest-upstream force
  if [ "$rc" -ne 0 ]; then
    report FAIL "positive (fetch remote upstream): remove" "exit $rc${err:+, stderr: $err}"
  elif [ -e "$root/upstream-repo/selftest-upstream" ]; then
    report FAIL "positive (fetch remote upstream): remove" "worktree still present"
  else
    report PASS "positive (fetch remote upstream): remove"
  fi
fi

# Default module (fetch remote `origin`) in the upstream-only clone: <repo>
# cannot be derived, so add and remove must stop with the missing-remote
# message before any fetch or filesystem write.
missing_msg="No remote 'origin' to derive <repo> from (WORKTREE_FETCH_REMOTE)"
run_clone="$work/clone-upstream" run_add neg-noremote direct "${prefixes[0]}/selftest-noremote"
check_rejected "negative: add without the fetch remote" "$missing_msg" 1
check_untouched "negative: add without the fetch remote creates nothing"
# Actionable hint, and the remotes list carries no trailing blank.
check_hint "negative: add without the fetch remote names the fix" "git remote add origin <url>" present
check_hint "negative: add without the fetch remote lists remotes exactly" $'Existing remotes: upstream\n' present

run_clone="$work/clone-upstream" run_remove neg-noremote-rm selftest-noremote
check_rejected "negative: remove without the fetch remote" "$missing_msg" 1

# --- <repo> derivation normalises the remote URL ---------------------------
# A dedicated clone whose `origin` URL is rewritten with `git remote set-url`
# to local paths that still fetch. A trailing slash must not leak into <repo>;
# a `:` in the last segment is treated like scp form (`git@host:repo.git`), so
# <repo> is the part after it; `.` yields no usable name and must stop.
git clone -q "$work/origin.git" "$work/mirror:scp-repo.git" --bare
git clone -q "$work/origin.git" "$work/clone-url"

# url_case <root-id> <url> <branch> <slug> <repo>: points origin at <url>,
# adds <branch>, expects $root/<repo>/<slug>, then removes it again.
url_case() {
  git -C "$work/clone-url" remote set-url origin "$2"
  run_clone="$work/clone-url" run_add "$1" direct "$3" "$4"
  run_repo="$5" check_created "positive (remote URL '$2'): <repo> is '$5'" "$4"
  run_clone="$work/clone-url" run_remove "$1" "$4" force
  if [ "$rc" -ne 0 ]; then
    report FAIL "positive (remote URL '$2'): remove" "exit $rc${err:+, stderr: $err}"
  elif [ -e "$root/$5/$4" ]; then
    report FAIL "positive (remote URL '$2'): remove" "worktree still present"
  else
    report PASS "positive (remote URL '$2'): remove"
  fi
}
url_case url-slash "$work/upstream-repo.git/" "${prefixes[0]}/selftest-url-slash" url-slash upstream-repo
url_case url-scp "$work/mirror:scp-repo.git" "${prefixes[0]}/selftest-url-scp" url-scp scp-repo
url_case url-scp-slash "$work/mirror:scp-repo.git//" "${prefixes[0]}/selftest-url-scp-slash" url-scp-slash scp-repo

# `.` (the clone itself) still fetches, but names no repository: add must stop
# before any fetch or write, and remove must refuse to resolve a path.
git -C "$work/clone-url" remote set-url origin .
bad_url_msg="Cannot derive <repo> from URL '.' of remote 'origin'"
run_clone="$work/clone-url" run_add neg-url-dot direct "${prefixes[0]}/selftest-url-dot"
check_rejected "negative: remote URL '.' (add)" "$bad_url_msg" 1
check_untouched "negative: remote URL '.' creates nothing"
run_clone="$work/clone-url" run_remove neg-url-dot-rm selftest-url-dot
check_rejected "negative: remote URL '.' (remove)" "$bad_url_msg" 1

# --- negative: outside a git repository -------------------------------------
# A plain directory; GIT_CEILING_DIRECTORIES stops git from finding a
# repository above it should $TMPDIR itself sit inside one. Both tasks must
# name the cause (no silent git exit 128) before any fetch or write.
mkdir -p "$work/norepo"
norepo_msg="Not inside a git repository: "
GIT_CEILING_DIRECTORIES="$work" run_clone="$work/norepo" \
  run_add neg-norepo direct "${prefixes[0]}/selftest-norepo"
check_rejected "negative: add outside a repository" "$norepo_msg" 1
check_untouched "negative: add outside a repository creates nothing"

GIT_CEILING_DIRECTORIES="$work" run_clone="$work/norepo" \
  run_remove neg-norepo-rm selftest-norepo
check_rejected "negative: remove outside a repository" "$norepo_msg" 1
check_untouched "negative: remove outside a repository touches nothing"

# --- negative: missing arguments -> usage, exit 2 ---------------------------
run_add neg-usage direct
check_rejected "negative: no arguments (usage)" "Usage: task worktree:add" 2

echo
echo "worktree selftest ($module): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
