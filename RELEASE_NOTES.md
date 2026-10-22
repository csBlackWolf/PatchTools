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
