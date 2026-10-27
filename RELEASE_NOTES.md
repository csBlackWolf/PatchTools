# PatchTools 0.9.0-alpha.15 — 2026-10-27

- Add `/patchtools debug`: a copyable diagnostic report with game build, language, UI scale, addon versions and load states.
- Separate loaded, enabled but not loaded, and disabled addons to help investigate addon combinations. Nothing is submitted automatically.
- Retain the tested quest reward selection, appearance options and confirmation shortcuts.

# PatchTools 0.9.0-alpha.14 — 2026-10-26

Public alpha test: bugs are possible. Please report problems on GitHub. The stable release remains available.

- Combine the quest and appearance alpha with the new optional confirmation shortcuts.
- Add a Confirmations category with separate options for BoE roll, loot-binding and equip-binding confirmations. These shortcuts start disabled; hold Shift to keep confirmations manual.
- Improve Pawn quest reward selection: choose the largest improvement for the selected specialization when several rewards are upgrades. Ties and missing information remain manual.
- Remember the settings window's position and size separately for each character. Background transparency remains shared.

Use PatchToolsMaps 0.3.0-alpha.14 and PatchToolsBags 0.1.2-alpha.1 for the matching companion versions.

Tested locally in Classic Era, with automated checks for Classic Era and Forever. Forever gameplay and the new per-character layouts still need further in-game testing.

# PatchTools 0.9.0-alpha.13 — 2026-10-25

**Public alpha test: this version is likely to contain bugs. Please report problems and feedback on GitHub. Use the stable releases if you prefer the established feature set.**

Alpha preview for Classic Era and Forever. **Use together with PatchToolsMaps 0.3.0-alpha.13 for all new map controls.** Stable PatchTools 0.8.0 and PatchToolsMaps 0.2.1 remain available and unchanged.

- Optional quest acceptance and turn-in, with Shift for manual dialogue and optional Pawn reward selection for one chosen scale. Quest automation starts disabled.
- A compact dark bronze settings window with saved scale and background transparency; recover its position and scale with `/patchtools reset`.
- An Appearance category for menu and main-bar styling. Choose no side figures, Blizzard figures or seated silver dragons; a small workshop easter egg unlocks silver foxes.
- Independent display layers for side figures: Standard, Background, Low, Normal, High and Dialog. Native action buttons and page controls stay unchanged; cosmetic changes wait until combat ends.
- Updated addon-list icon and credits. The optional Map section appears only with the enabled companion module.

Validation: automated Era/Forever tests in English, German and English fallback; local Classic Era gameplay and visual testing. Forever gameplay retest is unavailable while Beta is closed. This is a prerelease; feedback is welcome.

# PatchTools 0.9.0-alpha.12 — 2026-10-25

- Add the missing Dialog display layer for side figures. Keep all five explicit strata plus the independent Default (unchanged) option, which retains the original parent layer.
- Preserve saved layer choices and native restoration.

Validation: Dialog rendering for custom/native figures, dropdown persistence and existing Era/Forever regressions. In-game overlap confirmation pending.

# PatchTools 0.9.0-alpha.11 — 2026-10-25

- Add a display-layer dropdown beside the side-decoration selector: Standard, Background, Low, Normal and High. Apply it to Blizzard figures, dragons and unlocked foxes without moving or re-layering secure action bars or their controls.
- Use visual copies for native figures when another layer is selected; restore originals on Standard. Cosmetic changes remain deferred during combat.
- Keep the existing General / Appearance / Quests / Vendor / Tooltips organization. Show the separate Map section only after an enabled PatchToolsMaps module registers it; remove the absent-module placeholder.

Validation: native/custom layering, restoration, combat deferral, saved dropdown selection and absent/late-loaded Maps navigation plus existing Era/Forever regressions. In-game overlap and layout confirmation pending.

# PatchTools 0.9.0-alpha.10 — 2026-10-25

- Replace the side-decoration checkbox with a dropdown: None, Blizzard figures and Silver dragons, independent of the main bar background style. Preserve earlier checkbox/style combinations on upgrade.
- Add a small fox in the settings window's lower-left corner. Clicking it permanently unlocks and selects Silver foxes in the dropdown. Reuse the same transparent fox sprite for both the secret button and the mirrored side figures.
- Preserve native page controls, visibility and combat deferral.

Validation: dropdown discovery and persistence, migration, all ornament choices, texture switching and combat deferral plus Era/Forever regressions. In-game appearance confirmation pending.

# PatchTools 0.9.0-alpha.9 — 2026-10-25

- Group menu transparency, scaling guidance and action bar options under Appearance; remove the separate Action bars page.
- Replace the narrow curled dragon ornament with a compact seated dragon statue with legs and folded wings, mirrored at the bar ends.
- Preserve saved options, combat deferral and the plain bar when side decorations are hidden.

Validation: existing locale/UI/action bar regression tests; in-game proportions and layout confirmation pending.

# PatchTools 0.9.0-alpha.8 — 2026-10-25

- Replace Blizzard's side figures with a compact mirrored silver dragon pair when the PatchTools main bar style is enabled and side decorations are visible.
- Use an original transparent sprite inspired by the rare elite dragon. Keep the plain style when decorations are hidden and restore the native figures when the style is disabled.
- Preserve combat deferral and Blizzard's compact end-cap visibility, with room for page controls.

Validation: option combinations, mirrored sprite, compact/legacy layouts, restoration and combat deferral; in-game appearance confirmation pending.

# PatchTools 0.9.0-alpha.7 — 2026-10-25

- Add separate opt-in controls under Action bars for hiding the gryphon / Horde figures and using the dark bronze PatchTools background.
- Cover the legacy main bar and Era's compact figures after editing its layout. Keep buttons, page controls, experience bars and visibility under Blizzard's control.
- Restore original texture opacity when disabled; defer cosmetic changes during combat.

Validation: automated decoration restoration, layout variants and combat deferral plus existing regression checks. In-game appearance and combat confirmation pending; Forever gameplay unavailable while Beta is closed.

# PatchTools 0.9.0-alpha.6 — 2026-10-25

- Move the settings-background transparency slider into General, removing the otherwise sparse Appearance category. Keep its explanation in the slider tooltip.
- Preserve saved transparency, scale and quest settings.

Validation: existing Era/Forever syntax, locale, UI and regression checks; in-game layout confirmation pending.

# PatchTools 0.9.0-alpha.5 — 2026-10-25

- Match the companion map's dark bronze frame style in the settings window, including the navigation buttons.
- Add Appearance settings with a saved background-transparency slider. Text and controls remain opaque; the map has a separate transparency control.
- Retain settings scaling, chat recovery and existing quest behavior.

Validation: automated appearance-slider, saved/invalid transparency and existing Era/Forever regression checks in English, German and English fallback. In-game appearance confirmation pending.

# PatchTools 0.9.0-alpha.4 — 2026-10-25

- Add a selectable, copyable link to Zen's Twitch channel, https://www.twitch.tv/zenlynxley, below the existing About information.

Validation: existing syntax, locale and regression checks. Local test build only.

# PatchTools 0.9.0-alpha.3 — 2026-10-25

- Scale the complete settings window and its contents by dragging the bottom-right corner. Save the chosen scale, keep the top-left corner stable and limit the range to readable sizes that fit the screen.
- Recover the settings window with `/patchtools reset`: restore default scale, center and open the window. No separate reset button or right-click action.
- Stop scaling on mouse release or when the window closes; preserve existing page save handlers.

Validation: automated drag geometry at non-default UI scale, saved scale, screen bounds, invalid values, mouse/hide cleanup and chat reset checks, plus the existing Era/Forever regression suite. In-game appearance confirmation pending.

# PatchTools 0.9.0-alpha.2 — 2026-10-25

- Fix the empty Pawn scale list: Pawn keeps its initialization flag private, so it cannot be read as a global by another addon. Use public character identity and the exported scale API instead.
- Replace the scale cycling arrows with a native dropdown labelled "Use for quest rewards". Active Pawn scales for the current class can be selected independently of the other displayed scales. Show a disabled explanation when none are available.
- Keep automatic mode, saved per-character choices and conservative reward selection unchanged.

Validation: tests reproduce the absence of Pawn's private flag and cover selecting between multiple active scales, menu checked states, late Pawn availability and existing quest/reward safeguards. Era/Forever regression checks pass in English, German and English fallback. In-game confirmation pending.

# PatchTools 0.9.0-alpha.1 — 2026-10-24

- Add optional automatic quest acceptance and turn-in, disabled by default. Hold Shift for manual dialogue; other gossip options are untouched. Quest automation pauses in combat.
- Keep multiple reward choices manual unless optional Pawn integration finds exactly one upgrade for the chosen active class scale. Configure the scale per character; automatic mode requires exactly one active scale. Missing, ambiguous or unavailable Pawn data keeps manual selection.
- Include the fox icon asset and addon-list metadata in the local package, also supplying the icon used by PatchToolsMaps.

Validation: automated quest-event, Pawn-reward, character-selection and existing regression tests. Local alpha only; in-game quest and icon confirmation pending. Forever gameplay testing remains unavailable while the Beta is closed.

# PatchTools 0.8.0 — 2026-10-23

- Support Classic Era 1.15.9 alongside Forever in one addon package.
- Hide Forever world-refresh options and disable that module on Era. Hide the extra profession-bag option there and exclude Era bank bags from automatic selling.
- Enable grey-junk selling, automatic repairs, extended camera zoom and whitelist selling by default for new settings. The whitelist starts empty; existing saved choices remain unchanged.
- Keep the Map section ready for the companion addon on both game versions.

Validation: automated Era/Forever checks in English, German and English fallback cover settings, selling protections, bank exclusion, tooltips, loot and client detection. Classic Era local gameplay testing confirmed vendor behaviour and companion integration. Earlier Forever behaviour was tested on Beta/stress-test clients; the latest changes cannot currently be retested in game because the Beta is closed. Forever release announcements remain unconfirmed.

# PatchTools 0.7.1 — 2026-10-23

- Add an optional Yes/No confirmation for destroying items that normally require typing DELETE. Enable it in General settings; it starts turned off.
- Keep the game's localized item name, destruction prompt and quest warning, along with Blizzard's original accept and cancel actions.
- During combat, keep Blizzard's original confirmation. Gamepad confirmations are unchanged.
- Preserve existing settings and item selling lists.

Validation: automated syntax, UTF-8 and regression checks passed. In-game testing on Forever Beta confirmed the simplified confirmation works. The original Blizzard popup layout is retained.

# PatchTools 0.7.0 — 2026-10-23

- Show world-refresh countdowns in minutes and seconds in screen messages, chat and previews.
- Highlight advance warnings for possible announced phase changes: observed in Beta and the stress test; final-game availability is not yet confirmed. If the same announcements remain, the feature is ready to use.
- Add support for the separate PatchToolsMaps addon.
- Place Map above About PatchTools. Without the module, show its features and a link to install it.
- Preserve existing settings and selling lists.

Validation: syntax, UTF-8 and automated checks for vendor rules, tooltips, phasing, optional-addon loading and the Map placeholder. In-game checks on Forever Beta 1.60.1 build 70532 confirmed minute/second warnings and map movement, resizing and zoom with the companion module.

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
