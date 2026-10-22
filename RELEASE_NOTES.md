# PatchTools 0.7.0-local.1 — local preparation, not published

- Display world-refresh countdowns in minutes and seconds in screen messages, chat and previews.
- Add versioned optional-addon settings page registration.
- Prepare the base interface for the separate PatchToolsMaps preview.
- No installed files are replaced by this preparation. Map UI and complete reveal coverage still need client work; see the companion addon README.

# PatchTools 0.6.0 — 2026-10-22

First regular release for World of Warcraft: Forever. No feature changes compared with 0.6.0-alpha.1.

- Automatic junk selling and repairs, with blacklist and whitelist item rules.
- Item-ID entry and drag-and-drop for selling lists; blacklist protection always wins.
- Support for the extra profession bag, with an option to exclude it from automatic selling.
- Optional item IDs and vendor prices per item in tooltips.
- Settings grouped into General, Vendor, Tooltips, World Refresh and About PatchTools.
- World refresh warnings, camera zoom, ghost colours, cooldown numbers, auto-loot and faster looting.
- Built-in English and German, plus credits and a link for new feature ideas.

Existing settings and item lists are preserved. Whitelist selling and tooltip additions start turned off for new installations.

Validation: same runtime code as 0.6.0-alpha.1. The preceding alpha passed syntax, UTF-8 and simulated tests for English, German and English fallback. In-game checks on Forever Beta confirmed selling lists, tooltips, the revised interface, profession bag sales and its on/off option.

# PatchTools 0.6.0-alpha.1 — 2026-10-22

- Protect items from automatic selling with a blacklist.
- Add items of any quality to an optional selling whitelist. Enter an item ID or drag an item from your bags. Blacklist protection always wins.
- Sell from the extra profession bag, or exclude it with the new vendor option.
- Optionally show item IDs and vendor prices per item in tooltips.
- Find settings in five sections: General, Vendor, Tooltips, World Refresh and About PatchTools.
- Credits now include a GitHub link and an invitation to share ideas, with a simple English/German feature form.
- Correct UTF-8 encoding for umlauts and special characters.

Whitelist selling and tooltip additions start turned off. Existing settings and lists are preserved.

Validation: syntax, UTF-8 and simulated API tests for enUS, deDE and English fallback. In-game checks on Forever Beta confirmed the revised UI, selling lists, tooltip additions, profession bag sales and its on/off setting. The new credits invitation still needs a visual in-game check.

# 0.5.0-alpha.4

- Exclude test files from the native CurseForge package after directory flattening.
- No gameplay changes compared with 0.5.0-alpha.2.

# PatchTools 0.5.0-alpha.3

- Prepare tag-driven CurseForge packaging and version substitution.
- Ensure the generated ZIP contains the installable PatchTools folder, licence and changelog, without tests or repository metadata.
- No gameplay behaviour changes from alpha.2.

# PatchTools 0.5.0-alpha.2

- Adds a numeric screen-message duration (1–60 seconds; default 10).
- Adds an independent phasing chat-output toggle (default on).
- Records confirmed announced-transfer warnings on German Forever build 70532.
- Documents the continued use of _forever_ after Battle.net renamed the installation.
- MIT licensed. New duration/chat controls pass mock tests; new layout needs client verification.

# PatchTools 0.5.0-alpha.2 — phasing alerts

First CurseForge alpha submission; awaiting project/file moderation. Released under the MIT License.

- Separate announcement and near-transfer warnings, off by default.
- Numeric input for a configurable 1–600 second lead (new default: 60 seconds; existing settings preserved), optional Master-channel sound, test button.
- English/German messages; cancellation/completion handling and pending countdown recovery.
- Native Forever shard-transfer events and countdown query; no localized text scraping.
- Installation instructions now include `_forever_` and the beta alternative.

Simulated tests cover countdown changes, late notices, duplicate events, cancellation,
completion, settings, recovery and both languages. Actual transfers still need in-game testing.

# PatchTools 0.4.0 — English and German support

First public pre-release for WoW Forever 1.60.1, Interface 16001.

- Built-in English/German settings, minimap tooltips, chat feedback and warnings.
- Automatic German selection for deDE clients, English fallback for other locales and missing translations.
- Stable English diagnostic labels, including client locale and UI language.
- English documentation and structured bug, feature and translation issue forms.

Includes auto junk selling/repair, zoom factor 4, normal ghost colours, cooldown numbers, login auto-loot, faster auto-loot and an optional draggable minimap icon.

Exit WoW and extract the attached installable ZIP into `World of Warcraft\_classic_beta_\Interface\AddOns\`. Replace addon files on updates and keep SavedVariables. Open `/patchtools`.

Syntax and mock tests pass for English, German and an unsupported locale's English fallback. New functions and auto repair still need full in-game verification; this is a beta pre-release.
