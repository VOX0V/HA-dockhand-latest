#!/usr/bin/env bash
set -euo pipefail

# One-command release helper for this repository.
# Usage: ./scripts/release.sh 1.0.1

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.0.1"
  exit 1
fi

VERSION_INPUT="$1"
VERSION="${VERSION_INPUT#v}"
TAG="v${VERSION}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "Error: Not inside a git repository."
  exit 1
fi

cd "$REPO_ROOT"

if [[ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
  echo "Error: Release must be run from the main branch."
  exit 1
fi

CONFIG_VERSION="$(sed -nE 's/^version:[[:space:]]*"([^"]+)".*/\1/p' dockhand/config.yaml | head -n1)"
if [[ -z "$CONFIG_VERSION" ]]; then
  echo "Error: Could not parse version from dockhand/config.yaml."
  exit 1
fi

if [[ "$CONFIG_VERSION" != "$VERSION" ]]; then
  echo "Error: Version mismatch."
  echo "  Requested: ${VERSION}"
  echo "  config.yaml: ${CONFIG_VERSION}"
  exit 1
fi

if ! grep -Eq "^##[[:space:]]+${VERSION}([[:space:]]|$)" dockhand/CHANGELOG.md; then
  echo "Error: dockhand/CHANGELOG.md does not contain a heading for ${VERSION}."
  echo "Expected something like: ## ${VERSION}"
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  echo "Error: Local tag ${TAG} already exists."
  exit 1
fi

if git ls-remote --tags origin "refs/tags/${TAG}" | grep -q "${TAG}"; then
  echo "Error: Remote tag ${TAG} already exists on origin."
  exit 1
fi

# Commit only release metadata files if they changed.
git add dockhand/config.yaml dockhand/CHANGELOG.md
if ! git diff --cached --quiet; then
  git commit -m "release: ${TAG}"
fi

git push origin main

git tag -a "${TAG}" -m "Dockhand ${TAG}"
git push origin "${TAG}"

echo "Release tag pushed: ${TAG}"
echo "CI will publish images and create the GitHub Release via .github/workflows/release.yaml"
