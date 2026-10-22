# PatchTools optional addon API (local preparation)

Prepared on top of 0.6.0. This is local-only work on `codex/maps-preparation`; do not publish a version tag until the client checks are complete.

`PatchTools.extensionAPI == 1` identifies the first optional-addon interface. The addon must declare `## Dependencies: PatchTools` in its TOC and check the API before registering anything. Older PatchTools builds should produce a friendly message and remain usable.

```lua
local PT = _G.PatchTools
if PT and PT.extensionAPI and PT.extensionAPI >= 1 then
    PT:RegisterOptionsPage("example", "Example", function(parent, owner)
        -- Create widgets as children of parent (590 by 570 UI units).
        -- Attach an OnShow handler to refresh this addon's settings.
    end)
end
```

Register once, using a unique ASCII alphanumeric/underscore ID. Built-in IDs are reserved. The title is already localized by the extension. The builder runs immediately if the settings window exists, or when the base addon creates it. Returning false from registration means the request was rejected. Duplicate IDs and more than three extension pages are rejected because the current sidebar has space for eight entries total. Builder failures are isolated and reported through the normal Lua error handler.

Each extension owns its settings and lifecycle. Do not insert modules into `PT.modules` after initialization: that internal mechanism is not a late-loading addon API. Disabling an addon takes effect after the usual UI reload; its page is then absent.

## Time display

`PT:FormatTime(seconds)` returns localized minutes and seconds, rounding upward so an impending deadline is not understated. Examples: 150 → `2 Min. 30 Sek.`, 60 → `1 Min.`, 30 → `30 Sek.`. Non-finite inputs return nil. Phasing alerts use this in screen messages, chat and test previews. The numeric settings remain seconds, and pending transfers retain their separate message.

## Local previews

- Base addon: `0.7.0-local.1`, including extension registration and readable countdowns.
- Companion addon: `PatchToolsMaps 0.1.0-local.1`, kept in its own directory/repository.

The companion currently has incomplete map-art coverage. It never fabricates explored-area information. See its README for the remaining client and map-data checks.
