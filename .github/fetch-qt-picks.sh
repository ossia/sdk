#!/usr/bin/env bash
# Run on the host, before the build. Only the fetched Git objects are copied
# into the Linux container; no SDK build or dependency needs the Gerrit key.
set -euo pipefail
set +x
if [[ -z ${QT_GERRIT_SSH_KEY:-} ]]; then
  exit 0  # No Actions secrets on fork PRs; clone-qt.sh uses public HTTPS.
fi

umask 077
keydir=$(mktemp -d)
trap 'rm -rf -- "$keydir"' EXIT
printf '%s\n' "$QT_GERRIT_SSH_KEY" > "$keydir/key"
unset QT_GERRIT_SSH_KEY
printf '%s\n' '[codereview.qt-project.org]:29418 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcbdGVM4JlvQbwNonOIHD+XPP6bGUQB5nSIZuh0OcOy' > "$keydir/known_hosts"
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -F /dev/null -o BatchMode=yes -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=yes -o UserKnownHostsFile=\"$keydir/known_hosts\" -i \"$keydir/key\""

for picks in common/qt-picks/*; do
  module=${picks##*/}
  refs=()
  while read -r ref _; do
    case "$ref" in ''|'#'*) continue ;; esac
    refs+=("$ref:$ref")
  done < "$picks"
  repo=common/qt-gerrit-cache/$module
  git init --quiet --bare "$repo"
  # A cherry-pick needs the patch set and its parent, not the full history.
  git -C "$repo" fetch --no-tags --depth=2 \
    "ssh://jcelerier@codereview.qt-project.org:29418/qt/$module" "${refs[@]}"
done
