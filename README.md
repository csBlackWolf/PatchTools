# PatchTools

Quality-of-life tools for **World of Warcraft: Forever**, with built-in **English and German** language support. No external libraries required.

Made by **Patch & Zen**.

## Features

- **Automatic junk selling:** sell grey items when you visit a vendor. Quest items are protected.
- **Automatic repairs:** repair your equipment using your own money when you can afford it.
- **More camera distance:** zoom out further for a wider view.
- **Normal colours as a ghost:** keep the world in colour while you are dead.
- **Cooldown numbers:** see how long your abilities need to recharge.
- **Auto-loot on login:** keep automatic looting enabled for your characters.
- **Faster looting:** collect available loot sooner when auto-loot is active.
- **World refresh warnings:** get a warning when a phase change is announced, and another before it may happen. Choose the warning time, sound, message duration and chat output.
- **Minimap button:** open your settings with a click, move the button or hide it.

Choose the features you want in the settings. Automatic selling, repairs and world refresh warnings start turned off. Your settings are kept when you update.

World refresh warnings work only when the game announces a change.

## Installation

1. Close World of Warcraft.
2. Download the PatchTools ZIP from [CurseForge](https://www.curseforge.com/wow/addons/patchtools/files).
3. Extract the **PatchTools** folder into your game's **Interface\AddOns** folder.
4. Start the game and enable PatchTools in the AddOns menu.

Example: `World of Warcraft\_forever_\Interface\AddOns\PatchTools`

Current Forever installation folders:

| Game version | AddOns folder |
| --- | --- |
| WoW: Forever | `World of Warcraft\_forever_\Interface\AddOns\` |
| WoW: Forever Beta | `World of Warcraft\_classic_beta_\Interface\AddOns\` |

If you are unsure which folder to use, open the game's options in Battle.net and choose **Show in Explorer**. Folder names may differ between installations.

## Controls and languages

- **Minimap button:** click to open settings; drag to move it.
- **`/patchtools`** or **`/ptools`:** open settings.
- **`/patchtools status`:** show information that can help with a bug report.
- **Hold Shift when opening a vendor:** pause automatic selling and repairs for that visit.
- **Language:** German game clients use German automatically. Other game languages use English.

## Reporting issues

Found a problem or have an idea? [Open a GitHub issue](https://github.com/csBlackWolf/PatchTools/issues/new/choose). **English and German are both welcome.**

Please tell us:

- Which WoW version and PatchTools version you use.
- What you did and what happened.
- What you expected instead.

A screenshot or an error message is helpful, if available. You can also copy the output of `/patchtools status`. Please hide private chat or account details in screenshots.

## License

[MIT License](https://github.com/csBlackWolf/PatchTools/blob/main/LICENSE). You may use, change and share PatchTools. Keep the original copyright and license notice with your copy.

Community project. Not affiliated with or endorsed by Blizzard Entertainment.

## Changelog

### 0.5.0-alpha.4 — 2026-10-22

- Removed development test files from the download. Features are unchanged.

### 0.5.0-alpha.3 — 2026-10-22

- Set up automatic CurseForge downloads for future version tags. Features are unchanged.

### 0.5.0-alpha.2 — 2026-10-22

- Added a choice of how long world refresh warnings stay on screen.
- Added an option to show world refresh warnings in chat.
- Added the MIT license.

### 0.5.0-alpha.1 — 2026-10-22

- Added world refresh warnings with a choice of warning time and sound.
- Added a button to try the warning.

### 0.4.0 — 2026-10-21

- Added built-in English and German support.
- Includes junk selling, repairs, camera zoom, ghost colours, cooldown numbers, auto-loot, faster looting and a minimap button.

---

For contributors: [developer information and release instructions](https://github.com/csBlackWolf/PatchTools/blob/main/RELEASING.md).
