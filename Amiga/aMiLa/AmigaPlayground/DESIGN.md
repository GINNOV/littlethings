# Amiga Playground surface contract

## Purpose

The Playground is a dark, tool-like macOS workspace for editing and running Amiga programs. New teaching surfaces should make the editor and emulator feel like one instrument without hiding the source.

## Visual tokens

- Surface: system window/control backgrounds with black or deep navy output wells.
- Primary accent: cyan for active learning and emulator connection state.
- Secondary accent: orange for execution, warnings, and live activity.
- Success: green; failure: red; supporting text: system secondary color.
- Type: system text for teaching copy; monospaced system text for source, commands, registers, and traces.
- Rhythm: 8-point spacing; compact bordered controls; rounded rectangles for grouped teaching/debug content.

## Debug panel grammar

- Header identifies the backend and current session state.
- Primary controls stay visible above the trace history.
- The editor remains the source of truth; starting a new session rebuilds the current source.
- Responses remain readable as command/response cards, with errors visually distinct and raw output preserved.
- Controls use visible labels and system icons so keyboard, VoiceOver, and reduced-vision users can follow the execution state.

## Interaction rules

- Do not route debugger output through the compiler Console.
- Do not silently replace student source when changing lessons or restarting a session.
- Serialize commands and disable execution controls while a command is in flight.
- Disconnect leaves the emulator running; stopping an emulator must be an explicit separate action.
