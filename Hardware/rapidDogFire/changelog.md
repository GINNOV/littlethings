# Changelog

Notable changes to DogBotOne, newest first. Packet encodings remain client-side maps until a live dog confirms them. See `deveinfo.md` for the protocol notes.

## 2026-08-14

1. **Official action grid.** Sit Down, Greetings, Get Down, Act Cute, Handshake, Attack, Surrender, Urinate, Handstand, Patrol, Kung Fu, Push-up, plus Swimming. Mid-grid and Swimming use inferred `2A 00` stride-3 slots; Dance stays on family `12`.
2. **Disconnect stays disconnected.** Disconnect no longer starts a new scan. Reconnect is explicit.
3. **Jog wheel layout.** Ring is centered, compass labels sit outside it, and drag-down sends Stop.
4. **Stay awake.** Optional keep-alive every 3 seconds. Blocks Stop, which otherwise puts this dog to sleep.
5. **App sounds.** Connect, disconnect, send, and error cues, with a mute control.
6. **Developer notes.** Developer mode opens the local `deveinfo.md` without the sandbox blocking the file.
7. **DogBotOne remote.** Consumer remote is the launch surface. Legacy `dogAttack` test UI is no longer the app name or entry point.
8. **Developer command log.** Raw hex and service discovery sit in two columns. Sent commands show millisecond timestamps, search, and newest-first sort.

## 2026-05-14

9. **Project tree restored.** `dogAttack` Xcode project, BLE test UI, and `plan.md` landed again after the repo cleanup.

## 2026-01-13

10. **First controller.** Initial macOS BLE app (`dogAttack`) to find `Rapidpower-dog-fire` and write commands.
