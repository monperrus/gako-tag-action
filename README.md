# auto-tag-action

A reusable GitHub Action that automatically creates a version tag for each commit pushed to `main`. The version number is computed by incrementing the previous tag, according to bump_type.

## How It Works

1. All existing tags are fetched.
2. The latest tag matching `<prefix>X.Y.Z` is identified as the previous version.
3. The next version is computed by incrementing the chosen component (`major`, `minor`, or `micro`).
4. A new tag is pushed to the repository.

**First-tag edge case:** if no matching version tag exists, the tag specified by `initial_version` (default `0.0.1`) is created.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `bump_type` | no | `minor` | Version component to increment: `major`, `minor`, or `micro` |
| `initial_version` | no | `0.0.1` | Version to use when no previous tag exists |
| `prefix` | no | `v` | Tag prefix (e.g. `v` produces tags like `v1.2.3`) |

## Outputs

| Output | Description |
|---|---|
| `new_tag` | The new tag that was created |
| `previous_tag` | The previous tag (empty if this is the first tag) |

## Usage

```yaml
name: Auto tag on push to main

on:
  push:
    branches:
      - main

jobs:
  tag:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Create version tag
        id: tag
        uses: monperrus/auto-tag-action@main
        with:
          bump_type: minor   # or major / micro
```

## License

MIT
