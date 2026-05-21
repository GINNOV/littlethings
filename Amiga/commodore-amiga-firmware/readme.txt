Local Amiga firmware and ROM files
==================================

Place your legally obtained, local-only Amiga firmware and ROM files in this
directory when an emulator, validator, or conversion workflow needs them.

Typical examples:

- Kickstart ROM images for machines you are licensed to emulate
- CDTV/CD32 extended ROMs
- encrypted ROM archives and matching local key files
- hardware cartridge ROMs used by local emulator tests

Do not commit those files to this repository. They are copyrighted and may be
license-restricted. The repository ignore rules intentionally ignore everything
in this directory except this readme.txt file.

Suggested local layout
----------------------

Unpack archives and keep firmware files in category folders. Do not keep the
original ZIP archives once the firmware file has been extracted.

The current local convention is:

- kickstart/<version>/<machine>/<variant>/<original-details>.rom
- kickstart/<version>/<machine>/<variant>/<original-details>.adf
- extended-rom/cdtv/<version>/<variant>/<original-details>.rom
- extended-rom/cd32/<revision>/<variant>/<original-details>.rom
- extended-rom/a570/<version>/<variant>/<original-details>.rom
- boot-rom/a3000/<version>/<variant>/<original-details>.rom
- bootstrap/a1000/<variant>/<original-details>.rom
- cartridges/<cartridge-family>/<version>/<variant>/<original-details>.rom

Use normalized lowercase folder names and preserve the original archive details
in the filename. Examples:

- kickstart/v1-3-r34-005/a500-a1000-a2000-cdtv/good/kickstart-v1-3-r34-005-1987-12-commodore-a500-a1000-a2000-cdtv-good.rom
- kickstart/v3-1-r40-068/a1200/good/kickstart-v3-1-r40-068-1993-12-commodore-a1200-good.rom
- extended-rom/cdtv/v1-0/good/cdtv-extended-rom-v1-0-1991-commodore-cdtv-good-u34.rom
- boot-rom/a3000/v1-4-r36-16/good/amiga-3000-boot-rom-v1-4-r36-16-1990-commodore-a3000-good-rom0.rom
- cartridges/action-replay/mk-iii/v3-17/modified/action-replay-mk-iii-v3-17-1991-datel-electronics-m.rom

A local manifest.tsv may be generated in this directory to record source
archive names and final destinations. It is ignored by Git.

Recommended local conventions:

- Keep original archive names only in the local manifest, not as file names.
- Prefer one firmware collection per local machine, not per project.
- Do not copy ROM files into source, tool, tutorial, or test folders.
- If a project needs a specific ROM, document the expected filename and path
  instead of committing the ROM.
