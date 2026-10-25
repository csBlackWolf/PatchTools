# PatchTools developer guide

## Supported client and layout

The published 0.6.0 alpha targets WoW: Forever 1.60.1, Interface 16001. Other WoW editions are not currently declared supported. Forever Beta may still use the `_classic_beta_` installation directory.

The runtime addon is in `PatchTools/`. `Locales.lua` loads first, then `Core.lua`, followed by the feature modules in `PatchTools.toc`. Modules register through `PT:RegisterModule(name, module)`. Account-wide settings are stored in `PatchToolsDB`.

Use UTF-8 for source and localization files. Check the actual bytes when editing on Windows; Lua syntax checks alone do not catch legacy text encoding.

## Behaviour and safeguards

- Vendor automation processes carried bags, including the extra profession/reagent bag when enabled, never bank storage or equipped items. It skips quest items, locked items and items without a positive vendor value. Holding Shift or closing the merchant cancels processing. Requests are bounded and delayed to allow updates from the game.
- Repair uses personal money only and requires enough for the entire repair cost.
- Previous auto-loot and cooldown-number values are backed up per character. Restoration avoids replacing a setting changed by another addon. Disabling extended zoom restores the client default; scroll out manually after enabling it.
- Faster loot respects the client's loot mode and modifier key. It does not confirm binding, distribute group loot, bypass ownership or server restrictions, or force-close the loot window.
- The minimap button is named `PatchToolsMinimapButton`. Collectors may reparent it; PatchTools does not force its minimap position while another container owns it. Ctrl-right-click is left for collectors.

## World refresh detection

The Forever client provides `SHARD_TRANSFER_IMMINENT`, `SHARD_TRANSFER_CANCELLED`, `SHARD_TRANSFER` and `GetEvictionTimeRemaining()`. Detection follows Blizzard's SocialToast behaviour and does not parse translated UI text.

The countdown is queried while active. Zero means a transfer is pending, not that it has completed. Late announcements produce a single urgent warning. Cancellation and completion reset the state; world entry can recover a positive pending countdown. Unannounced transfers cannot be predicted.

Warning lead: 1–600 seconds, default 60. Display duration: 1–60 seconds, default 10. Initial and imminent warnings default to off. Sound uses the Master channel. Optional chat output uses normal chat history, not a separate file.

## Languages

German (`deDE`) uses German strings. Other locales use English. Missing keys fall back to English. Keep format arguments consistent across languages.

## Tests

Run from the repository root with Python 3. The test runner supports the `lupa` Python package with Lua 5.4 on Windows, or the system `liblua5.4.so.0` shared library on Linux.

```sh
python PatchTools/tests/run_tests.py
```

Set `PATCHTOOLS_TEST_LOCALE=deDE` and repeat, then use `frFR` to check English fallback. Tests simulate the game APIs; they cannot verify actual UI rendering, server timing or compatibility with every other addon.

In-game checks have confirmed announced world refresh warnings on German Forever build 70532. Keep client observations separate from simulated test results; do not describe partial testing as complete compatibility.

## Publishing

CurseForge project: 1758728. The packager processes version tags only. An ordinary commit, including a documentation update, does not publish an addon file.

1. Run tests and review the intended changes. Check the interface version against the target client.
2. Update release notes and the dated user-facing changelog.
3. Create an immutable version tag on the reviewed commit:
   - `v0.5.0-alpha.5`: Alpha
   - `v0.5.0-beta.1`: Beta
   - `v0.5.0`: Release
4. Inspect the CurseForge build and download its generated ZIP. Confirm `PatchTools/PatchTools.toc`, all listed Lua modules, license and version substitution. Exclude tests and repository-only files. Moderation may still apply.

The native packager replaces `@project-version@` in `Core.lua` and `PatchTools.toc`. Install the packaged ZIP rather than raw development templates. `.pkgmeta` flattens the inner addon directory and excludes development files.

The next build must include `PatchTools/Media/Icon.tga` (128x128, 32-bit TGA),
referenced by `IconTexture` in both addons' TOCs. PatchToolsMaps uses the icon
from its required PatchTools dependency. Preserve the `Media/` directory in
manual ZIP builds too; do not limit packaging to root-level Lua and TOC files.

Do not reuse tags for different commits. For a local-only build, do not create or push a release tag.

## Webhook

Follow the [official CurseForge Automatic Packaging guide](https://support.curseforge.com/support/solutions/articles/9000197281-automatic-packaging). Use the project package endpoint with a dedicated token, GitHub push events, JSON content type and SSL verification. The project setting limits packaging to tags.

Never commit tokens or put them in screenshots, logs, issue reports or release notes. Revoke the token when retiring the integration.

## Selling lists and tooltips (0.6.0)

`ItemRules.lua` handles ID validation and rule precedence. `sellBlocklist` always wins over `sellAllowlist`. Whitelist selling requires `sellWhitelist`; the additional bag requires `sellProfessionBag` (default true). Settings are checked on each sale pass. Quest items, locks and non-positive prices are still checked by Vendor. Rules use base item IDs, not individual copies or variants.

`Tooltips.lua` uses the item tooltip processor when available, with an older tooltip-script fallback. Vendor prices are per item; uncached item data may require another hover. The source/test runner validates UTF-8. Automated tests cover extra-bag selling and toggling; visual checks remain in-game.

## Required idea review before a build push

Follow [the build planning rules](AGENTS.md). Review current GitHub ideas and the [shared board](https://github.com/users/csBlackWolf/projects/9), report accepted/planned items with counts, titles and links, and highlight the next-release items. List deferred ideas separately. Wait for confirmation before pushing a build or release, so another idea can still be included. This is a planning checkpoint, not automatic implementation of feature requests.

## Optional confirmation shortcuts (development alpha.14)

`LootConfirmations.lua` handles CONFIRM_LOOT_ROLL, LOOT_BIND_CONFIRM and
EQUIP_BIND_CONFIRM independently of fast loot. Defaults: boeRollConfirm="off",
confirmLootBind=false, confirmEquipBind=false. A roll must already have been
chosen. For rolls, cached item bind type must be OnEquip (2), with no BoP flag;
unknown data and other roll types remain manual. The general loot/equip options
intentionally allow binding after explicit opt-in.

The event listener waits one frame for UIParent to finish populating the popup,
then validates the option, Shift/combat state, popup type, native data and roll
choice again. It invokes the matching native OnAccept and hides that dialog.
No popup definitions or UIParent handlers are replaced. Refund/trade warnings
and disenchant are never automatically accepted. In-game testing must cover
Greed/Need on BoE and BoP, Shift bypass, loot binding and equipment binding.
Reference: Blizzard UI source mirror, classic_era branch, UIParent/Vanilla/UIParent.lua,
StaticPopup_Game/Classic/GameDialogDefs.lua and ItemConstantsDocumentation.lua.
