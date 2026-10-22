# Publishing PatchTools

CurseForge project: 1758728. Publish tagged commits only; ordinary commits must not trigger uploads.

## Release steps

1. Run the Lua syntax and mock tests for enUS, deDE and a fallback locale. Record in-game testing separately.
2. Update RELEASE_NOTES.md for the intended version and commit all changes.
3. Create an immutable version tag on the reviewed commit and push that tag:
   - v0.5.0-alpha.3: alpha
   - v0.5.0-beta.1: beta
   - v0.5.0: release
4. Verify the CurseForge build and inspect its generated ZIP. Project/file moderation may still apply.

The native packager replaces @project-version@ in Core.lua and PatchTools.toc with the tag name. Do not copy these source templates straight into a game install; use the packaged ZIP. The raw template version in a development checkout is intentional.

.pkgmeta flattens the repository's inner PatchTools directory, excludes tests and repository-only docs, and retains the runtime licence and changelog. The resulting install path must be PatchTools/PatchTools.toc, with no extra directory nesting.

## GitHub webhook

Follow the official CurseForge Automatic Packaging guide. Use the project's package endpoint with a dedicated CurseForge token. Configure GitHub push events, JSON content type and SSL verification. The CurseForge project setting limits packaging to tagged commits.

Keep tokens out of this repository, screenshots, release notes, logs and chat. Revoke the token if the integration is retired. Never reuse a version tag for a different commit.

Official guide: https://support.curseforge.com/support/solutions/articles/9000197281-automatic-packaging
