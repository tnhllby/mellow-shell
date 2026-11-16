# M2 Status — MELLOW Island

## Implemented
- Island moved to its own surface (`mellow:island`): click-through except the Island,
  which morphs (width/height, emphasized easing) between compact and expanded states.
- Compact media: artwork, title, artist, progress hairline. Compact ambient: CPU, memory,
  temperature (each hidden if unavailable) and a note glyph when a paused player exists.
- Expanded player: source (player + audio output), artwork, title/artist/album, wavy seek
  line with times, previous / play-pause (shape-morphing) / next, disabled states from
  MPRIS capabilities, full keyboard control.
- `MediaService`, `SystemStatsService`; clock moved to the panel's right zone.
- Entry points: `mellow:island`, `mellow:mediaPlayPause`, `mellow:mediaNext`,
  `mellow:mediaPrevious` (global shortcuts + IPC).

## Verified on the development host
- Loads with no QML warnings (besides Qt's benign `textinput` message).
- Compact media state with a real Firefox/Zen MPRIS session (screenshot).
- Expanded player rendered in a non-interactive copy (focus grab disabled) with real
  metadata, artwork, position/length and output name (screenshot).
- Ambient state rendered with live CPU/RAM/temperature values (forced in a copy).
- 8 IPC functions and 7 global shortcuts registered.

## Unverified (test machine; docs/RUNNING.md M2 checklist)
- All pointer/keyboard interaction with the player, seeking, media keys.
- Pause grace → ambient transition; players without position/length/art.

## Known limitations
- Only one player is controlled (the active one); no player switcher yet.
- Output name is PipeWire's sink description and can be long (it elides).
- Volume control belongs to the Control Center (M3).
