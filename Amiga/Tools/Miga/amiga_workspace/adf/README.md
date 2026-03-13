# ADF Template Drop Folder

Drop your fully functional bootable ADF here as:

- `amiga_workspace/adf/system_template.adf`

The evaluator will clone this template into `build/amiga/main.adf` on every run,
then overwrite:

- `s/startup-sequence`
- `main`

This allows you to keep your custom `C:`, `L:`, `LIBS:`, assigns, and shell tools
inside the template while still letting autoresearch replace only the test payload.
