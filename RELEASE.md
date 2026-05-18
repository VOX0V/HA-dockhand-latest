# Release Strategy

This document describes the current release behavior for this repository.

## Problem

Without a clear release flow, these can drift out of sync:

- Add-on version in `dockhand/config.yaml`
- Release notes in `dockhand/CHANGELOG.md`
- Published image tags in GHCR
- GitHub Releases

## Source of Truth

Official releases are tag-driven. Git tag `vX.Y.Z` is the release source of truth.

The release workflow in `.github/workflows/release.yaml` runs on tag push and:

- validates tag version matches `dockhand/config.yaml`
- validates `dockhand/CHANGELOG.md` contains a matching section header
- publishes GHCR image tags `X.Y.Z` and `latest`
- creates the GitHub Release with notes extracted from the changelog

### Pros

- Strong consistency: one tag maps to one release and one image version.
- Auditable and repeatable through CI.
- Better traceability and rollback confidence.
- Less chance of accidental overwrite of stable tags.

### Cons

- More initial workflow setup.
- Requires disciplined tagging process.
- Slower than ad-hoc local publishing for quick tests.

## Development Builds (Non-Release)

Pushes to `main` run `.github/workflows/builder.yaml` and publish development-only tags:

- `main`
- `sha-<commit>`

This avoids overwriting stable release tags on normal development pushes.

## Suggested Release Flow

1. Update `dockhand/config.yaml` version.
2. Add matching notes in `dockhand/CHANGELOG.md`.
3. Commit to `main`.
4. Create and push tag (for example `v1.0.1`).
5. Let CI publish official GHCR image tags and create the GitHub Release.

## Guardrails (Implemented)

- Fail release workflow if tag version and `dockhand/config.yaml` version differ.
- Fail release workflow if `dockhand/CHANGELOG.md` has no entry for the tag version.
- Publish `latest` only from official release workflow (not from non-release builds).

## Workflow Mapping

- `.github/workflows/builder.yaml`: main/PR build orchestration
- `.github/workflows/build-app.yaml`: reusable build/publish workflow
- `.github/workflows/release.yaml`: official release workflow (tag-triggered)

## Release Checklist (Copy/Paste)

Use this checklist for an official release.

1. Ensure local branch is up to date and clean.
2. Bump `dockhand/config.yaml` version (example: `1.0.1`).
3. Add matching notes under `dockhand/CHANGELOG.md`.
4. Commit and push to `main`.
5. Create and push git tag `vX.Y.Z`.
6. Verify release workflow succeeded.
7. Verify GHCR contains both version and `latest` tags.
8. Verify GitHub Release exists with changelog-derived notes.

### Commands

Example release version: `1.0.1`

```bash
# 1) Commit version + changelog changes
git add dockhand/config.yaml dockhand/CHANGELOG.md
git commit -m "release: v1.0.1"
git push origin main

# 2) Tag the release
git tag -a v1.0.1 -m "Dockhand v1.0.1"
git push origin v1.0.1
```

### One-Command Shortcut

If your version/changelog updates are already committed on `main`, this one-liner pushes a release tag and CI handles image publish + GitHub Release creation:

```bash
git tag -a v1.0.1 -m "Dockhand v1.0.1" && git push origin v1.0.1
```

Note: this shortcut does not edit `dockhand/config.yaml` or `dockhand/CHANGELOG.md`; keep those aligned before running it.

### Repository Helper Script

This repository includes a helper script that validates version alignment and performs commit, push, and tag creation (CI creates the GitHub Release):

```bash
./scripts/release.sh 1.0.1
```

What it validates before tagging:

- `dockhand/config.yaml` version matches the provided version
- `dockhand/CHANGELOG.md` has a heading for that version (`## 1.0.1`)
- branch is `main`
- tag does not already exist locally or on `origin`

Requirements:

- permission to push to `main` and push tags
