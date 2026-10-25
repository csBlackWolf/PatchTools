# Developing PatchTools

PatchTools supports Classic Era and Forever, with version-specific features kept separate. World-refresh detection and the extra profession bag belong to Forever; do not expose them as Era features. The [user guide](GUIDE.md) describes controls, defaults and alpha availability.

## Source and settings

Runtime files live in `PatchTools/`. `Locales.lua` loads first, then `Core.lua`, followed by modules in the TOC. Register built-in modules with `PT:RegisterModule(name, module)`. Account-wide settings use `PatchToolsDB`; character-specific choices stay separate where appropriate. Apply defaults only to missing/invalid values and preserve saved `false`.

Keep UTF-8 source and consistent format arguments across translations. German uses `deDE`; other locales fall back to English. Check bytes as well as Lua syntax after Windows edits.

Optional modules own their settings pages and lifecycle. Do not insert them into `PT.modules` after initialization. The versioned public settings API is documented in [EXTENSIONS.md](EXTENSIONS.md). Keeping settings in their module lets an older Maps release display its own supported controls with a newer base addon.

## Vendor, tooltip and loot behavior

`ItemRules.lua` validates item IDs and gives `sellBlocklist` priority over `sellAllowlist`. Whitelist sales require `sellWhitelist`. Rules apply to base IDs, including all copies/variants. Vendor processing skips quest items, locked items and nonpositive vendor values, excludes bank/equipped items, and checks the additional profession bag only on the appropriate client. Recheck settings on each pass. Shift or closing the merchant cancels processing; bound and delay requests to allow game updates.

Repairs use personal money and require the whole repair cost. Preserve previous auto-loot and cooldown-number values per character without overwriting a later change by another addon. Extended camera zoom restores the client default when disabled.

`Tooltips.lua` uses the item-tooltip processor where available and a script fallback otherwise. Vendor values are per item; uncached data may need a later hover. Faster loot follows native loot mode/modifiers and does not confirm binding or distribute loot by itself.

## World-refresh detection

The Forever client exposes `SHARD_TRANSFER_IMMINENT`, `SHARD_TRANSFER_CANCELLED`, `SHARD_TRANSFER` and `GetEvictionTimeRemaining()`. Follow those signals rather than parsing translated UI text. Query the countdown while active. Zero means pending, not completed. Late announcements produce one urgent warning; cancellation/completion clear the state and world entry may recover a positive countdown.

Warning lead is 1–600 seconds (default 60); display duration is 1–60 seconds (default 10). Alerts start off. Sound uses the Master channel and optional chat output uses normal history. `PT:FormatTime(seconds)` produces localized countdown text. Observations from Forever beta build 70532 do not establish support in a future client or prediction of unannounced changes.

## Alpha development

`alpha/quest-automation` now combines the quest/appearance alpha with the confirmation work from `alpha/loot-confirmations`. The combined alpha.14 build is awaiting an in-game check before publication. Stable `main` remains separate. Keep alpha controls opt-in where they automate dialogue or accept warnings.

Quest reward selection must use the selected active class scale and require exactly one Pawn upgrade. Keep missing data, ambiguous rewards and Shift bypass manual. Cosmetic main-bar changes must respect combat restrictions and preserve native action buttons/page controls.

In the loot-confirmations branch, `LootConfirmations.lua` treats `CONFIRM_LOOT_ROLL`, `LOOT_BIND_CONFIRM` and `EQUIP_BIND_CONFIRM` independently. Defaults are `boeRollConfirm="off"`, `confirmLootBind=false` and `confirmEquipBind=false`. For rolls, require a previously selected roll and cached OnEquip bind type (2), with no BoP flag. Unknown items and unsupported roll types stay manual.

Wait one frame for UIParent to populate the dialog, then revalidate settings, Shift/combat state, popup type, native data and roll choice before using the matching native acceptance handler. Do not replace popup definitions or UIParent handlers. Refund, temporary trade and disenchant warnings stay manual. These files/features are branch-specific; consult the branch TOC before assuming their presence.

## UI integration

`PatchToolsMinimapButton` may be reparented by collectors; do not force its minimap anchor while another container owns it. Leave Ctrl-right-click available to collectors. Keep background transparency separate from text/control opacity and from map transparency. Check scaled settings pages, dropdowns and absent/older optional modules in game.

## Testing and publishing

Run `python PatchTools/tests/run_tests.py` from the repository root. The runner uses Python with `lupa` (Lua 5.4) on Windows or system `liblua5.4.so.0` on Linux. Repeat with `PATCHTOOLS_TEST_LOCALE=deDE` and another locale such as `frFR` for English fallback. Mocks cannot establish rendering, server timing or third-party compatibility; record actual client/build observations separately.

[RELEASING.md](RELEASING.md) covers branches, packaging and CurseForge publication. Keep the README as the short player presentation, [GUIDE.md](GUIDE.md) for practical detail and this file for implementation. Use direct descriptions of changes and decisions in guides, notes and commit messages.

[MIT license](LICENSE). This is a community project, not affiliated with Blizzard Entertainment.
