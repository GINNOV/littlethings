# Assembly Structure Mutation Workspace

This workspace is for the next mutation phase: changing real setup logic instead of only the Copper data block.

It starts from the passing inline-assembly source, but several display/window constants are stepped back on purpose:

- `SCREEN_RES`
- `RASTER_X_START`
- `RASTER_Y_START`

The current safe knob list is recorded in `structure_knobs.json`.
