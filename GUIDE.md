# PatchTools user guide / Bedienungsanleitung

## English

Install the `PatchTools` folder in your client's `Interface/AddOns` folder and enable it in the AddOns menu. Use the client's folder shown by Battle.net; Classic Era normally uses `_classic_era_`, Forever `_forever_`, and beta folder names may differ. Open settings with `/patchtools`, `/ptools` or the minimap button. German clients use German; other locales use English.

Choose the tools you want. New settings enable junk selling, whitelist selling, repairs and extended camera distance. The selling whitelist starts empty. Updates preserve saved choices. Tooltip additions and world-refresh alerts start off. Move or hide the minimap button in settings; collectors can manage it too.

### Vendors and items

Grey items can be sold automatically, with quest items protected. Add item IDs to the selling whitelist or protection blacklist by entering an ID or dragging an item from your bags. Protection takes precedence. A rule applies to every copy with that item ID. Bank storage and equipped items are excluded; Forever's extra profession bag has its own inclusion setting. Repairs use your own money and only proceed when you can afford the full cost. Hold Shift when opening a vendor to pause selling and repairs for that visit.

Optional tooltip additions show item IDs and vendor prices per item. The simpler deletion option replaces typing DELETE with a Yes/No confirmation outside combat, keeping the item name and quest warning visible. Fast looting follows your loot mode and modifier key.

### Camera, loot and world refresh

Extended camera distance, normal colors as a ghost, cooldown numbers and auto-loot can be chosen independently. On Forever, world-refresh alerts warn about announced possible phase changes. Choose warning lead time, sound, message duration and chat output. Detection was observed in beta/stress testing; availability in the final client remains unconfirmed. Unannounced changes cannot be predicted.

### Alpha options

The quest alpha adds optional quest acceptance/turn-in. Hold Shift for manual dialogue. With Pawn enabled, choose the active class scale to use for rewards; other scales can stay visible in Pawn. Automatic reward choice uses the largest percentage improvement for that scale; equal improvements remain manual. Missing or ambiguous data leaves the choice to you. Quest automation starts off.

Appearance options include settings-window scaling and background transparency, a dark main-bar style, side-decoration choices and display-layer selection. Changes involving protected layout wait until combat ends. `/patchtools reset` restores the settings window. The fox in the settings is an optional little discovery.

The combined alpha.14 test build adds independent opt-in shortcuts for BoE roll warnings, loot binding and equipment binding alongside quest automation. These are not part of the earlier public quest alpha. Shift keeps a confirmation manual; combat, disenchant, refund and temporary loot-trading warnings remain manual.

### Optional modules

Install [PatchToolsMaps](https://www.curseforge.com/wow/addons/patchtoolsmaps) or [PatchToolsBags](https://www.curseforge.com/wow/addons/patchtoolsbags) alongside the base. Each module supplies its own controls. Available options therefore depend on the installed module version. The current alpha shows Map installation information when Maps is absent; older versions may hide the page.

## Deutsch

Lege den Ordner `PatchTools` in `Interface/AddOns` deines Clients und aktiviere das Addon. Öffne die Einstellungen mit `/patchtools`, `/ptools` oder dem Minimap-Button. Deutsche Clients verwenden Deutsch, andere Sprachen Englisch.

Wähle die gewünschten Helfer aus. Bei neuen Einstellungen sind Schrottverkauf, Whitelist-Verkauf, Reparatur und erweiterte Kameradistanz aktiv. Die Verkaufsliste beginnt leer. Updates behalten deine gespeicherten Entscheidungen bei. Tooltip-Ergänzungen und Warnungen vor Welterneuerungen sind zunächst aus.

### Händler und Items

Graue Items können automatisch verkauft werden; Questitems bleiben geschützt. Trage Item-IDs in die Verkaufsliste oder Schutzliste ein oder ziehe Items aus deinen Taschen hinein. Schutz hat Vorrang und eine Regel gilt für alle Exemplare derselben Item-ID. Bank und angelegte Ausrüstung sind ausgeschlossen. Die zusätzliche Berufstasche auf Forever hat eine eigene Einstellung. Reparaturen werden aus deinem Geld bezahlt, wenn es für die gesamten Kosten reicht. Halte beim Öffnen des Händlers Shift, um beides für diesen Besuch zu pausieren.

Tooltip-Optionen zeigen Item-IDs und Händlerpreise pro Stück. Die vereinfachte Löschbestätigung ersetzt außerhalb des Kampfes die Texteingabe durch Ja/Nein; Itemname und Questwarnung bleiben sichtbar. Schnelleres Plündern berücksichtigt deinen Beutemodus und die Modifikatortaste.

### Kamera, Beute und Welterneuerungen

Erweiterte Kameradistanz, Farben als Geist, Abklingzeiten und automatisches Plündern lassen sich einzeln wählen. Auf Forever können Warnungen auf angekündigte mögliche Phasenwechsel hinweisen. Vorlauf, Ton, Anzeigedauer und Chatausgabe sind einstellbar. Die Erkennung wurde in Beta und Stresstest beobachtet; die Verfügbarkeit im endgültigen Client ist noch nicht bestätigt. Unangekündigte Wechsel lassen sich nicht vorhersagen.

### Alpha-Optionen

Die Quest-Alpha bietet optionale automatische Annahme und Abgabe. Mit Shift bedienst du den Dialog selbst. Für Pawn wählst du eine aktive Wertung deiner Klasse; weitere Wertungen dürfen in Pawn sichtbar bleiben. Automatisch gewählt wird die größte prozentuale Verbesserung für die gewählte Wertung; bei Gleichstand wählst du selbst. Fehlende oder mehrdeutige Daten lassen die Auswahl bei dir. Die Questautomatik beginnt ausgeschaltet.

Unter Darstellung findest du Skalierung und Hintergrundtransparenz des Menüs, den dunklen Hauptleistenstil sowie Seitenverzierungen und ihre Anzeigeebene. Geschützte Änderungen warten bis nach dem Kampf. `/patchtools reset` setzt das Einstellungsfenster zurück. Der kleine Fuchs im Menü ist eine optionale Entdeckung.

Der kombinierte Alpha.14-Testbuild bietet neben der Questautomatik zusätzliche einzeln aktivierbare Abkürzungen für BoE-Würfelwarnungen, Bindung beim Plündern und Anlegen. Diese gehören noch nicht zur vorherigen öffentlichen Quest-Alpha. Shift, Kampf, Entzaubern sowie Rückerstattungs- und Beutehandelswarnungen bleiben manuell.

### Zusatzmodule

Installiere PatchToolsMaps und PatchToolsBags bei Bedarf neben dem Hauptaddon. Die Module liefern ihre eigenen Einstellungen; sichtbar sind die Funktionen der tatsächlich installierten Modulversion. Die aktuelle Alpha zeigt ohne Kartenmodul einen Installationshinweis. Ältere Versionen blenden die Kartenseite gegebenenfalls aus.

## Help / Hilfe

Use `/patchtools status` for report details. Include your WoW edition/build, addon versions and reproduction steps; remove private chat/account data from screenshots. English and German are welcome.

[Report a bug / Fehler melden](https://github.com/csBlackWolf/PatchTools/issues/new/choose) · [Developer guide](DEVELOPMENT.md) · [Release notes](RELEASE_NOTES.md) · [Overview / Übersicht](README.md)
