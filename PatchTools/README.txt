PatchTools 0.4.0 — WoW Forever beta (Interface 16001)

INSTALL: Fully exit WoW. Extract PatchTools into
World of Warcraft\_classic_beta_\Interface\AddOns\
The path must end in AddOns\PatchTools\PatchTools.toc.
On updates replace the addon files and keep SavedVariables.

Open /patchtools or /ptools. /patchtools status prints diagnostic information.

LANGUAGES: Built-in English and German. deDE clients use German automatically;
all other clients and missing translations fall back to English.
Deutsch und Englisch integriert. Deutsche Clients verwenden automatisch Deutsch.

FEATURES: Auto grey junk selling; auto repair using own money; camera zoom factor
4 (off restores client default); normal ghost colours; native cooldown numbers;
login auto-loot; faster auto-loot; optional movable minimap icon; chat reports.

Automation/visual options start OFF. Minimap icon and chat messages start ON.
Existing account-wide settings survive updates. Auto-loot/cooldown native values
are backed up per character. Shift at vendors bypasses vendor automation.
Fast loot respects the game's configured auto-loot modifier and confirmations.
No external libraries required. Collector compatibility needs in-game testing.

TEST STATUS: Lua syntax and simulated tests pass in English, German and fallback
locale. Initial in-game checks confirmed loading/options, selling and ghost
colours; native cooldown numbers were confirmed separately. New features and
auto repair still need full client verification. Beta APIs/persistence may change.

BUGS: Include status output, game/client build/interface/locale, OS, affected
feature, reproduction steps, expected/actual results, complete Lua error or
'none', relevant addons and whether it happens with only PatchTools enabled.
Redact private chat/account data; never attach passwords or your full WTF folder.

Development: Locales.lua, Core.lua, Vendor.lua, Loot.lua, Minimap.lua, Options.lua.
Mock tests: python3 tests/run_tests.py (Linux with liblua5.4.so.0).
