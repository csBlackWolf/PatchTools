# Publishing PatchTools

CurseForge project: **1758728** (`patchtools`). Stable releases use `main`. The tested quest, appearance and confirmation alpha work is included in 0.9.0. Preserve existing alpha branches for development history.

## Prepare the change

Run the relevant checks in [DEVELOPMENT.md](DEVELOPMENT.md), review the diff and confirm the target client's interface number. Update the release notes and user-facing changes. Record what was tested in game and what remains unconfirmed. Review GitHub issues/the planning board only when requested; it is not a mandatory step before every push.

Keep short player descriptions in README/CurseForge, practical detail in [GUIDE.md](GUIDE.md), implementation notes in [DEVELOPMENT.md](DEVELOPMENT.md) and the optional-module contract in [EXTENSIONS.md](EXTENSIONS.md).

## Publish

1. Push the branch commit and wait for its webhook delivery to finish.
2. Create a new immutable version tag for the reviewed commit and push that tag separately: `vX.Y.Z` for Release, `vX.Y.Z-alpha.N` for Alpha or `vX.Y.Z-beta.N` for Beta.
3. Create the GitHub release against that tag, using the matching prerelease setting.
4. Check the intended CurseForge build/file and its moderation status. Do not manually upload another copy while automatic packaging is running.

Do not push branch and tag together with `--follow-tags` or `--atomic`: simultaneous push events previously produced duplicate map packages. Do not reuse existing tags. Ordinary documentation commits do not need a version bump or release tag; the project packages tags only.

## Package contents

The packager replaces `@project-version@` in `Core.lua` and the TOC. `.pkgmeta` flattens the runtime folder and excludes repository documentation/tests. Preserve `PatchTools/Media/Icon.tga` and other runtime subdirectories when building manually; PatchToolsMaps references the icon from its required base dependency.

Confirm the ZIP contains `PatchTools/PatchTools.toc`, its listed Lua files, media, license and the intended version. Use a packaged build for installation rather than raw version templates. Approval/moderation is separate from a successful build, so report each accurately.

## Webhook credentials

Use the existing CurseForge packaging integration with JSON push events, SSL verification and tag-only builds. Never commit tokens or expose them in screenshots, logs or release notes. Revoke credentials when retiring an integration. See the [CurseForge packaging guide](https://support.curseforge.com/support/solutions/articles/9000197281-automatic-packaging) for setup details.
