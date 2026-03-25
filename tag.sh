#!/usr/bin/env bash
set -euo pipefail

BUMP_TYPE="${BUMP_TYPE:-micro}"
INITIAL_VERSION="${INITIAL_VERSION:-0.0.1}"
PREFIX="${PREFIX:-v}"

# Validate bump_type
if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "micro" ]]; then
  echo "Error: bump_type must be one of: major, minor, micro" >&2
  exit 1
fi

# Find the latest version tag of the form <PREFIX>X.Y.Z
# Fetch all tags first
git fetch --tags --quiet

PREVIOUS_TAG=""
PREVIOUS_VERSION=""

# List tags matching the version pattern, sort by version, pick the latest
VERSION_PATTERN="^${PREFIX}[0-9]+\.[0-9]+\.[0-9]+$"
LATEST_TAG=$(git tag --list "${PREFIX}*" \
  | grep -E "$VERSION_PATTERN" \
  | sort -V \
  | tail -1 \
  || true)

if [[ -n "$LATEST_TAG" ]]; then
  PREVIOUS_TAG="$LATEST_TAG"
  PREVIOUS_VERSION="${LATEST_TAG#"$PREFIX"}"
  echo "Previous tag: $PREVIOUS_TAG (version $PREVIOUS_VERSION)"
else
  echo "No previous version tag found. Using initial version: $INITIAL_VERSION"
  PREVIOUS_VERSION=""
fi

# Compute next version
next_version() {
  local version="$1"
  local bump="$2"
  local major minor micro
  IFS='.' read -r major minor micro <<< "$version"
  case "$bump" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    micro) echo "${major}.${minor}.$((micro + 1))" ;;
  esac
}

if [[ -z "$PREVIOUS_VERSION" ]]; then
  NEW_VERSION="$INITIAL_VERSION"
else
  NEW_VERSION=$(next_version "$PREVIOUS_VERSION" "$BUMP_TYPE")
fi

NEW_TAG="${PREFIX}${NEW_VERSION}"
echo "Creating tag: $NEW_TAG"

# Configure git identity if not already set
if ! git config user.email > /dev/null 2>&1; then
  git config user.email "auto-tag-action@github.com"
fi
if ! git config user.name > /dev/null 2>&1; then
  git config user.name "auto-tag-action"
fi

git tag "$NEW_TAG"
git push origin "$NEW_TAG"

echo "new_tag=$NEW_TAG" >> "$GITHUB_OUTPUT"
echo "previous_tag=$PREVIOUS_TAG" >> "$GITHUB_OUTPUT"
