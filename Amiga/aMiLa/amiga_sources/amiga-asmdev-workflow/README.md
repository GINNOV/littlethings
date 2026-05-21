# Amiga ASM Development Workflow #

## Introduction ##

This repository provides and demonstrates an automation workflow for certain aspects
of development in 68K assembly for the Commodore Amiga series of computers.
It has been developed for use in a Linux environment using 'freely available' tools.
[FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software) tools are used
as much as possible, but some components (e.g. `vasm` and `vlink`) are distributed
under [their own licenses](./tools/LICENSE.md).

The following features are provided and demonstrated:

* Conversion of [GIMP](https://www.gimp.org/) authored image assets (*`.xcf`) into `.png`, `.iff` and `.raw` (interleaved) formats
* Compression ('packing') or raw assets using the '`zx0`' format
* Generation of palette (`COLORxx` register) data for image assets in copper list format
* Generation of a Workbench 'tool' icon (*.info) for the main executable from a GIMP image (*.xcf)
* Host compilation of assembler (`vasm`) and linker (`vlink`) tools included.
* Building to a [UAE](https://en.wikipedia.org/wiki/UAE_(emulator)) emulated hard drive (`dh0`) folder
* Building of a ***bootable*** AmigaDOS floppy disk format image (`ADF`) file.
* A Unix [Makefile](#makefile) to automate building on the host machine
* A [GitHub Actions (GHA)](https://docs.github.com/en/actions)[workflow](#github-actions-workflow)
for CI/CD automated building in the the cloud.

## Limitations / TODO ##

* Only RAW files with 'interleaved' bitplanes data are generated (no 'back-to-back' support)
* Only images for low resolution (non-EHB) mode apps are supported.
* Only `zx0` compression/packing support.
* No support for attached sprites palette generation
* No special treatment for AGA
* Bare bones 'no frills' bootable AmigaDOS ADFs. i.e. no loading messages etc.
* Only a target executable ('tool' type) icon is generated. No custom disk icon.

## Demo App ##

This repo contains source code for a simple Amiga demo using Bitplanes (playfield), Blitter objects (BOBs) and Sprites.

This demo was made using samples of [example code](https://www.edsa.uk/blog/downloads) from the excellent book
['Bare-Metal Amiga Programming'](https://www.edsa.uk/blog/bare-metal-amiga-programming)
by E. Th. van den Oosterkamp, and used under his permissive license terms.

This demo also includes m68k asm `zx0` decompression code from [`salvador`](https://github.com/emmanuel-marty/salvador) by Emmanuel Marty, also used under permissive license terms.

The app was also developed in the equally excellent
[Amiga Assembly](https://marketplace.visualstudio.com/items?itemName=prb28.amiga-assembly)
extension for [Visual Studio Code](https://code.visualstudio.com/) (VSCode).
VSCode is not required for this workflow but this repo structure matches the example project
and aims to be compatible with its structure. e.g. the emulated hard drive `uae\dh0` is the
destination for the built binary.

## Requirements ##

A host Linux environment is expected. This project has been developed under Debian based Linux x86_64 distros (e.g. Ubuntu)
Other environments may need some modifications to run.

Some additional tools are required to be installed and made available in the `PATH`.
These are automatically installed by the [GHA workflow](#github-actions-workflow)
but will need to be installed manually to run on a local host machine.

### GIMP ###

[GIMP](https://www.gimp.org/) is required to convert GIMP native (`*.xcf`)
[indexed colour](https://en.wikipedia.org/wiki/Indexed_color) mode image asset files into
an intermediary [`PNG`](https://en.wikipedia.org/wiki/PNG) format.

GIMP may already be installed on your Linux distro. If not it can be installed either through
your distro package manager (e.g. Debian `apt`:)

```sh
sudo apt install gimp
```

or as a flatpak from [FlatHub](https://flathub.org/apps/org.gimp.GIMP)

### ipng2iff ###

[ipng2iff](https://github.com/m0ppers/ipng2iff) is used to create [`ILBM`/`IFF`](https://en.wikipedia.org/wiki/ILBM)
image files as used on the Amiga from [`PNG`](https://en.wikipedia.org/wiki/PNG) source files exported from GIMP.

`ipng2iff` has to be built from source. To do so requires you have a working
[RUST](https://www.rust-lang.org/) environment setup.

```sh
git clone https://github.com/m0ppers/ipng2iff.git
cd ipng2iff
cargo build -r
```

Once `ipng2iff` has built, you need to move it to somewhere where it can be found in your `$PATH`. e.g.

```sh
sudo cp target/release/ipng2iff /usr/local/bin
```

### ilbmtoppm ###

`ilbm2ppm` is used to fetch metadata about IFF image files.
It is part of the [`netpbm`](https://netpbm.sourceforge.net/) toolkit.

`netpbm` can be installed using your package manager. e.g. for Debian `apt`:

```sh
sudo apt install netpbm
```

### salvador ###
[salvador](https://github.com/emmanuel-marty/salvador) is used to compress `*.raw` images into `*_raw.zx0` packed files in the `zx0` format to help save space.

`salvador` has to be built from source.
```sh
git clone https://github.com/emmanuel-marty/salvador
cd salvador
make
```

Once `salvador` has built, you need to move it to somewhere where it can be found in your `$PATH`. e.g.

```sh
sudo cp salvador /usr/local/bin
```

### amitools ###

[amitools](https://pypi.org/project/amitools/) is used to create floppy disk (`ADF`) images using
[xdftool](https://amitools.readthedocs.io/en/latest/tools/xdftool.html)

To install amitools, first make sure you have a working [python3](https://www.python.org/) environment.
Then amitools can be installed with these commands:

```sh
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install amitools
```

## GIMP Source Image Requirements ##

Your source (`.xcf`) GIMP files should be using
[indexed color](https://en.wikipedia.org/wiki/Indexed_color) mode, not 'RGB'.
You can convert an RGB image into indexed using GIMP from the menu:

```none
Menu->Image->Mode->Indexed...
```

A dialog will be presented allowing you choose the number of colours and whether you wish to use dithering etc.

## Naming Conventions ##

Whilst not absolutely required, the workflow will work better if you stick to certain naming conventions
for your image assets.

By default the copper list output of palette data will begin at colour palette index 0
(`COLOR00`/`0xdff180`) and proceed incrementally. This behaviour can be changed by using naming conventions
for the source (`.xcf`) image files:

### Dual Playfields ###

If you are developing a dual-playfield app, it's likely that for images destined for playfield 2 you
will need the palette to start from the 'even bitplanes' palette of `COLOR08`/`0xdff190`
(See the [HRM](https://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node007A.html)
for more details)

This can be achieved by including the text '`pf2`' somewhere in your image source filename.

### Sprites ###

Sprites 0-7 operate in pairs and share a palette of 4 colours. As per the
[HRM](https://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node00B7.html)

```ascii
                 16  Unused   00  |
                 17  Color 1  01  |
                 18  Color 2  10  |-- Sprites 0 and 1
                 19  Color 3  11 _|
                 20  Unused   00  |
                 21  Color 1  01  |
                 22  Color 2  10  |-- Sprites 2 and 3
                 23  Color 3  11 _|
                 24  Unused   00  |
                 25  Color 1  01  |
                 26  Color 2  10  |-- Sprites 4 and 5
                 27  Color 3  11 _|
                 28  Unused   00  |
                 29  Color 1  01  |
                 30  Color 2  10  |-- Sprites 6 and 7
                 31  Color 3  11 _|
```

By including e.g. `spr0` in your filename the copper list palette will be output starting at the appropriate colour index.
Note, that for each sprite pair only one palette file is generated. In the case of multiple source files for the same sprite
pair, the last one to be processed will be used as the source for palette data.

## Makefile ##

The [`Makefile`](./Makefile) is invoked by the command:

```sh
make <TARGET>
```

Where `<TARGET>` is an optional specified component. If `<TARGET>` is not specified it will default to '`all`'
The various useful targets are described in the table below

| Target    | Description |
|-----------|-------------|
| `all`     | Convert assets, build tools, assemble source `.s` files into `.o` object files and link program into `uae/dh0`. |
| `adf`     | Everything in the `all` target PLUS generation of icons and floppy disk image (ADF) file. |
| `assets`  | Only converts image assets (and generates palette include files) |
| `icons`   | Only converts icons |
| `tools`   | Only builds the tools (`vasm` & `vlink`) |

By default the target will not include `linedebug` data and will be stripped of symbols. To preserver these pass `DEBUG=1`:

```sh
make <TARGET> DEBUG=1
```

The Makefile also supports a set of 'clean-up' targets to remove files:

| Target            | Description |
|-------------------|-------------|
| `clean`           | Removes built target program and `.o` object files.|
| `clean_adf`       | Removes the floppy disk image (ADF) file. |
| `clean_assets`    | Removes converted image asset files (and generated palette include files) |
| `clean_icons`     | Removes converted icon files |
| `clean_tools`     | Removes object and executable files for the tools (`vasm` & `vlink`)|
| `clean_all`       | Removes all of the above|

## Image Asset Conversion Script ##

The image asset conversion script (`convert_assets_to_raw.sh`) is located in the [scripts](./scripts/) directory.
It's used by the `Makefile`, but it can also be used standalone to do more selective conversions if required:

Passing `-h` (or `--help`) to the script shows usage information:

```none
$ ./scripts/convert_assets_to_raw.sh -h
usage: convert_assets_to_raw.sh [options] [input file]

Options:
 
 -a,--asset-dir <dir name>
     Use dir <dir name> to find source assets and place output assets.
     Defaults to ./assets 
 -d,--delete-ints
     Delete intermediate files (PNGs & IFFs). 
 -i,--include-dir <dir name>
     Use target dir <dir name> for palette include files. <dir name> MUST exist.
     Defaults to same dir as --asset-dir 
 -n,--dry-run
     Show what would be done only. Do not actually [over]write or delete any output files. 
 -p,--png-iff
     Include generation of IFF files from PNGs. 
 -r,--iff-raw
     Include generation of RAW bitplane data files from IFFs. 
 -s,--inc-pal
     Include generation of palette ASM include code files from IFFs. 
 -x,--xcf-png
     Include generation of PNG files from XCFs. 
```

If no `input_file` is specified, the script will works as a wildcard selecting all applicable files in the specified (or default) 'assets' directory.

## Icon Conversion Script ##

The icon asset conversion script (`amiga-icon-converter.py`) is located in the [scripts](./scripts/) directory.
It's used by the `Makefile`, but it can also be used standalone to do more selective conversions if required:

Passing `-h` (or `--help`) to the script shows usage information:

```none
$ ./scripts/amiga-icon-converter.py -h
usage: amiga-icon-converter.py [-h] [--type {1,2,3,4,5,6,7,8}] [--width WIDTH] [--height HEIGHT] [--output OUTPUT] [--palette {1,2}] input_image

Convert image to Amiga Workbench icon

positional arguments:
  input_image           Path to input image file

options:
  -h, --help            show this help message and exit
  --type {1,2,3,4,5,6,7,8}
                        Icon type (1: Disk, 2: Drawer, 3: Tool, 4: Project, 5: Trashcan, 6: Device, 7: Kickstart ROM, 8: Appicon, default: 3)
  --width WIDTH         Icon width in pixels (default: 48)
  --height HEIGHT       Icon height in pixels (default: 48)
  --output OUTPUT       Optional output path for the .info file
  --palette {1,2}       Palette version (1 for 1.x, 2 for 2.x, default: 2)
```

If no output file is specified with `--output` the output will have the same name and path as the `input_image` but the file extension changed to `.info`

## GitHub Actions Workflow ##

This repository includes a [GitHub Actions](https://docs.github.com/en/actions) (GHA)
[workflow](./.github/workflows/amiga_demo.yml) for automated build and ADF packaging
in the cloud using a GHA hosted
[Ubuntu 24.04 (LTS) runner image](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md).
Successful build artifacts (ADFs) can be downloaded from the
[Actions tab](https://github.com/neildavis/amiga_asmdev_workflow/actions)
