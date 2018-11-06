# RaidSetup
[![Join the chat at https://gitter.im/openshift/openshift-ansible](https://github.com/thekk1/RaidSetup/blob/master/Screenshots/UI.jpg)](https://github.com/thekk1/RaidSetup/blob/master/Screenshots/UI.jpg)

Datenbank(Nach Loggout): "\WTF\Account\%LOGIN%\SavedVariables\RaidSetup.lua"

### Funktionen:

- Aufrufen und schließen der UI mit /RaidSetup (Öffnet zugleich den Ingame RaidFrame)
- Auswahlmöglichkeiten und Gestaltung siehe Screenshots
- Samelt die Spieler aus eurem Raid in einer Datenbank
- Laden und Speichern der Setups (Naxxramas Templates fest eingepflegt)
- DB resetten (Naxxtemplates bleiben erhalten)
- Sperren von Slots (keine Beachtung beim Bauen)
- Slotbelegung nach den Filtern: Rolle->Klasse->Spieler. (Alle Optional und einzeln nutzbar.)
- Bauen des Raids nach angezeigtem Schema
- Auto Build - aktualisiert die Raidaufstellung bei: Hinzufügen/Entfernen eines Spielers, Laden eines Setups, Ändern der Aufstellung


### Erläuterung zur Bedienung:

Die Spalten "Role", "Class" und "Player" sind Filter, durch die entschieden wird welcher Spieler aus eurem Raid für diesen Slot geeignet ist.
Gleichzeitig schränkt jeder Filter die Auswahl zu seiner Rechten ein, um eine bessere Übersicht du gewährleisten.
Beim Bauen werden entsprechende Spieler für die Slots ausgewählt und dorthin verschoben.

| Role | Class | Player | Bedeutung/Ergebnis |
|------|-------|--------|--------------------|
| MEELE | ANY | ANY | Alle Meeles (Schurke, Krieger, Dudu, Pala und Schamane) |
| ANY | PRIEST | ANY | Alle Priester (Heal und Range) |
| HEAL | PALADIN | ANY | Alle Heal Palas |
| ANY | ANY | Thekk | Das ist mein Slot |

Bitte beachtet, dass die Reihenfolge der Spieler innerhalb der einzelenen Gruppen im Raid nach dem Sortieren anders sein kann als in dem BossLayout.
Das ist eine Eigenart des Spiels und lässt sich nicht ändern


### Geplante/nicht implementierte Funktionen:

- Eingabefeld bei den Bossen um mehrere eigene Schema anzulegen
- Weitere Reiter für MT Targets und Heilerzuordnung bezogen auf das Schema (Inkl. setzten der MT Targets über Ora2 und Posten der Heilereinteilung)
- Weiterer Reiter für die Anzeige der Spieler-Datenbank mit Einstellungsmöglichkeiten
- Autoupdate der Spieler-Rollen nach aktueller Skillung (BigWigs vorrausgesetzt)
- Ingame Verteilung der Spieler- und Schema-Datenbanken
- Einbeziehung einer Ersatzbank in das Schema mit automatischem entfernen/einladen der Spieler
- Nach Bauen Whisper an jeden Spieler mit seiner Rolle und Gruppe (Für evtl. Umskillen) (Spamfilter Serverseitig)
