#!/usr/bin/env bash
# Push an image to the repo's `pr-assets` branch and print the URL to embed it in a PR/MR.
# The branch holds images only, has no history in common with the code and is never merged,
# so screenshots don't end up in the default branch. Existing images on it are kept.
# Usage: upload-image.sh <image> <name-on-branch>   e.g. upload-image.sh shot.png pr-55-maps-link.png
# Run from inside the repo. Prints the image URL on the last line.
set -euo pipefail

image="${1:-}"
name="${2:-}"
branch="pr-assets"
remote="origin"

if [[ ! -f "$image" || ! "$name" =~ ^[A-Za-z0-9._-]+\.(png|jpe?g|gif|webp)$ ]]; then
  echo "Usage: $0 <image> <name-on-branch.png|jpg|gif|webp>" >&2
  exit 1
fi

git fetch -q "$remote" "$branch" 2>/dev/null || true
parent="$(git rev-parse -q --verify "refs/remotes/$remote/$branch" || true)"

# Build the commit in a throwaway index, so the working tree and the current branch are untouched.
index="$(mktemp -u)"
trap 'rm -f "$index"' EXIT
export GIT_INDEX_FILE="$index"
if [[ -n "$parent" ]]; then
  git read-tree "$parent"
  if git cat-file -e "$parent:$name" 2>/dev/null; then
    echo "$name is already on $branch; pick another name" >&2
    exit 1
  fi
else
  git read-tree --empty
fi
blob="$(git hash-object -w "$image")"
git update-index --add --cacheinfo "100644,$blob,$name"
tree="$(git write-tree)"
unset GIT_INDEX_FILE

if [[ -n "$parent" ]]; then
  commit="$(git commit-tree "$tree" -p "$parent" -m "chore: add $name")"
else
  commit="$(git commit-tree "$tree" -m "chore: add $name")"
fi
git push -q "$remote" "${commit}:refs/heads/${branch}"

# Turn the remote into a web URL: git@host:path, ssh://git@host[:port]/path or https://host/path.
url="$(git remote get-url "$remote")"
url="$(echo "${url%.git}" | sed -E -e 's|^git@([^:]+):|https://\1/|' -e 's|^ssh://([^@]+@)?([^:/]+)(:[0-9]+)?/|https://\2/|')"

# blob?raw=true works for private GitHub repos too, since it loads with the viewer's own sign-in.
if [[ "$url" == *github* ]]; then
  echo "$url/blob/$branch/$name?raw=true"
else
  echo "$url/-/raw/$branch/$name"   # GitLab
fi
