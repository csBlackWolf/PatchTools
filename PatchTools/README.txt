# PatchTools

Modular quality-of-life tools for **World of Warcraft: Forever**, with built-in **English and German**. No external libraries required.

**Version 0.5.0-alpha.2 — alpha test build.** Target: Forever 1.60.1, Interface 16001; originally developed against build 70124. The settings UI has also been exercised on German Forever build 70532. In-game testing confirmed announced world-refresh warnings on build 70532; full feature compatibility still needs further verification.

## Features

| Feature | Behaviour |
| --- | --- |
| Auto junk selling | Sells sellable grey regular-bag items; skips quest items and equipped gear. |
| Auto repair | Repairs at suitable vendors using your own money, if you can afford the full cost. Never uses guild funds. |
| Extended zoom | Sets factor 4. Turning it off restores the client default. Scroll out manually. |
| Ghost colours | Removes the death greyscale filter, without changing your ghost form. |
| Cooldown numbers | Enables Blizzard's native countdown on ability icons. |
| Login auto-loot | Enables native auto-loot on login/world entry, including new characters. |
| Faster auto-loot | Requests available loot earlier; respects manual looting, locked slots and confirmations. |
| Minimap icon | Click to open settings, drag to reposition, or hide it in settings. |
| Chat messages | Optional feedback for sale and repair requests. |

Automation and visual options default to **off**; minimap icon and chat messages default to **on**. Settings are account-wide and preserved on updates. Previous auto-loot/cooldown values are backed up per character. Disabling those options restores the previous value unless another change was detected; zoom specifically restores the client default.

## Installation

1. Fully exit WoW.
2. Download the installable `PatchTools-0.5.0-alpha.2.zip` from the project files.
3. Extract its `PatchTools` folder into `World of Warcraft\_forever_\Interface\AddOns\` (current Forever installation, also retained after the stress test was renamed in Battle.net). Beta alternative: `World of Warcraft\_classic_beta_\Interface\AddOns\`. Use Battle.net > Show in Explorer to locate your selected installation.
4. On updates, replace addon files but keep SavedVariables.
5. Start WoW, enable PatchTools and enter `/patchtools`.

The final path must end in `AddOns\PatchTools\PatchTools.toc`, without an extra nested folder. If using GitHub's source archive, install only its inner `PatchTools` folder.

## Controls and languages

- `/patchtools` or `/ptools`: open settings, even when the minimap button is hidden.
- `/patchtools status`: diagnostics including addon version, client build/interface, locales, feature flags and CVar values.
- Hold **Shift when opening a vendor** to bypass vendor automation.
- Faster loot follows the client's auto-loot mode and configured **AUTOLOOTTOGGLE** modifier; it does not force automatic looting when manual looting was selected.
- German (`deDE`) clients automatically use German. All other locales use English. Missing translation keys fall back to English. No translation addon is needed.

## Compatibility and limitations

The minimap icon is a normal named button (`PatchToolsMinimapButton`). It allows collectors to reparent it and does not restore its minimap position while inside another container. Ctrl-right-click stays available to collectors such as MBB. Specific collector versions still need in-game testing.

Fast loot does not confirm binding, distribute group loot, force-close loot windows or bypass ownership/network/server limits. Full bags and confirmations remain under normal client control. Avoid running another vendor or fast-loot automation at the same time. Beta API and SavedVariables changes may affect functionality and persistence.

## Validation status

Initial in-game checks confirmed loading, options, junk selling and ghost colours. The native cooldown setting was separately confirmed. Automatic repair and the new localization, minimap and fast-loot features still need full in-game validation.

Lua syntax and simulated API tests pass for migration, safe sales, repair affordability, CVar restoration, minimap interaction/reparenting, loot modes/cancellation, English/German translation parity and English fallback. Mocks do not replace client tests.

## Reporting issues

Use the structured **Bug report**, **Feature request** or **Translation issue** forms. Bug reports request `/patchtools status`, game edition, OS, client build/locale, affected feature, reproduction steps, expected/actual results, full Lua error (or 'none'), and relevant other addons/isolation results.

Redact private chat and account information. Never attach credentials or an entire WTF/SavedVariables folder.

## Development

`Locales.lua` loads before `Core.lua`; feature modules are registered with `PT:RegisterModule(name, module)`. Tests require Python 3 on Linux and the system library `liblua5.4.so.0`:

```sh
python3 PatchTools/tests/run_tests.py
PATCHTOOLS_TEST_LOCALE=deDE python3 PatchTools/tests/run_tests.py
PATCHTOOLS_TEST_LOCALE=frFR python3 PatchTools/tests/run_tests.py
```

Package from the repository root:

```sh
zip -r PatchTools-0.5.0-alpha.2.zip PatchTools
```

Community project; not affiliated with or endorsed by Blizzard Entertainment.

## Phasing / world refresh warnings (0.5.0 alpha)

Open `/patchtools`, then **Phasing / world refresh alerts**. Enable the announcement warning and/or the second warning (1–600 seconds beforehand, default 60). Both default to off; optional sound uses the Master channel. Screen messages last 1–60 seconds (default 10). The independent phasing chat switch defaults to on and writes warnings to the normal chat history; it does not create a log file. The test button previews the warning without scheduling a transfer.

Uses Forever's `SHARD_TRANSFER_IMMINENT`, `SHARD_TRANSFER_CANCELLED`, `SHARD_TRANSFER` and `GetEvictionTimeRemaining()`, as used by Blizzard's SocialToast UI. Cancellation/completion clears pending alerts; the countdown is queried again while active to follow changes. Zero means the transfer may happen at any moment, not that it has completed. A late announcement produces one urgent warning rather than two overlapping alerts. Reload/world entry recovers a pending positive countdown. Unannounced transfers cannot be predicted. Announced world-refresh warnings were confirmed in-game on German Forever build 70532. The configurable display duration and chat toggle are new in alpha.2 and have mock coverage; their new UI still needs an in-game check.

## License

MIT License. Copyright (c) 2026 Fabian (csBlackWolf). See LICENSE.
