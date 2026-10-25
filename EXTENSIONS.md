# Integrating an optional PatchTools module

PatchTools provides settings API 1 from version 0.7.0. A companion addon declares `## Dependencies: PatchTools` in its TOC and checks the interface before registering a settings page. Keep the module functional or show a clear explanation if a required API is unavailable.

```lua
local PT = _G.PatchTools
if PT and PT.extensionAPI and PT.extensionAPI >= 1 then
    PT:RegisterOptionsPage("example", "Example", function(parent, owner)
        -- Build this module's controls inside parent.
        -- Refresh saved values when the page is shown.
    end)
end
```

Register once per session with a unique ASCII alphanumeric/underscore ID. Built-in IDs are reserved. Localize the title before registration. The builder runs immediately if the window exists, or when PatchTools creates it. A `false` return means registration was rejected. Builder errors go through the normal Lua error handler without taking over another module's page.

The current API reserves a Maps page plus up to two other extension pages. Page dimensions and reserved built-in IDs can vary between stable and alpha layouts: use the supplied parent rather than fixed screen coordinates and check the target branch when sizing controls. The original stable content area is 590×570 UI units.

Each module owns its saved settings, controls and lifecycle. This means a stable Maps module can supply its stable controls while the base runs an alpha. Do not add modules to the internal `PT.modules` table after initialization. Disabling a companion takes effect after the usual UI reload.

## Localized time

`PT:FormatTime(seconds)` rounds upward and returns localized minutes/seconds. German examples: 150 becomes `2 Min. 30 Sek.`, 60 becomes `1 Min.`, and 30 becomes `30 Sek.`. Non-finite input returns nil. Store numeric durations as seconds and format them when displaying text.

## Map controls

For buttons, timers and fixed information around the modern map, use the [PatchToolsMaps integration guide](https://github.com/csBlackWolf/PatchToolsMaps/blob/alpha/custom-map-frame/INTEGRATION.md). Check its API versions and keep a native fallback for stable Maps or an absent module.

[Developer guide](DEVELOPMENT.md) · [User guide](GUIDE.md) · [Overview](README.md)
