#!/usr/bin/env bash

# Copyright (c) 2024 Neil Davis (https://github.com/neildavis)

# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the
# following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

shopt -s nullglob

# Get absolute path of dir from where script was launched
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# Get script name
script_name="$(basename "$0")"

# Set default input/output dirs
asset_dir=$(realpath "$script_path/../assets")
inc_dir="$asset_dir"

# Function to show usage information and exit
show_usage() {
  echo "usage: ${script_name} [options] [input file]"
  echo -e  "\nOptions:\n" \
            "\n -a,--asset-dir <dir name>\n" \
            "    Use dir <dir name> to find source assets and place output assets.\n" \
            "    Defaults to $asset_dir" \
            "\n -d,--delete-ints\n" \
            "    Delete intermediate files (PNGs & IFFs)." \
            "\n -i,--include-dir <dir name>\n" \
            "    Use target dir <dir name> for palette include files. <dir name> MUST exist.\n" \
            "    Defaults to same dir as --asset-dir" \
            "\n -n,--dry-run\n" \
            "    Show what would be done only. Do not actually [over]write or delete any output files." \
            "\n -p,--png-iff\n" \
            "    Include generation of IFF files from PNGs." \
            "\n -r,--iff-raw\n" \
            "    Include generation of RAW bitplane data files from IFFs." \
            "\n -s,--inc-pal\n" \
            "    Include generation of palette ASM include code files from IFFs." \
            "\n -x,--xcf-png\n" \
            "    Include generation of PNG files from XCFs." \
            "\n"
}

# Function to use GIMP to generate a PNG from a XCF file
# $1 = XCF input filename
# $2 = PNG output filename
gimp_xcf_to_png() {
    gimp_xcf_in_file="$1"
    gimp_png_out_file="$2"
{
cat <<EOF
(define (convert-xcf-to-png filename outfile)
  (let* (
	 (image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
	 (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
	 )
    (file-png-save RUN-NONINTERACTIVE image drawable outfile outfile 0 0 0 0 0 0 0)
    (gimp-image-delete image) ; ... or the memory will explode
    )
  )

(gimp-message-set-handler 1) ; Messages to standard output
EOF

echo "(gimp-message \"$gimp_xcf_in_file\")"
echo "(convert-xcf-to-png \"$gimp_xcf_in_file\" \"$gimp_png_out_file\")"

echo "(gimp-quit 0)"
} | gimp -i -b -
}

show_usage=false
dry_run=false
delete_int_files=false
skip_png=true
skip_iff=true
skip_raw=true
skip_palette=true

while [[ $# > 0 ]]; do
    case ${1} in
        -a | --asset-dir)   asset_dir="$2";         shift;  ;;
        -d | --delete-ints) delete_int_files=true           ;;
        -h | --help)        show_usage=true                 ;;
        -i | --include-dir) inc_dir="$2";           shift;  ;;
        -n | --dry-run)     dry_run=true                    ;;
        -p | --png-iff)     skip_iff=false                  ;;
        -r | --iff-raw)     skip_raw=false                  ;;
        -s | --inc-pal)     skip_palette=false              ;;
        -x | --xcf-png)     skip_png=false                  ;;
        *) input_file="${1}"                                ;;
    esac
    shift
done

if $show_usage; then
  show_usage
  exit 0
fi


if [[ -z "$input_file" ]]; then
    input_file="${asset_dir}/*"
else
    input_file="$(echo ${input_file%.*})"
fi

echo "INPUT FILE(S): ${input_file}"

# Check to make sure we have the tools we need available in $PATH
rgb2iff_cmd="ipng2iff"
ilbm_cmd="ilbmtoppm"
ilbm_pkg="netpbm"

if ! which gimp >/dev/null 2>&1; then
    echo "gimp is not found in your \$PATH"
    echo "Please install GIMP on your system"
    exit 1
fi
if ! which "$rgb2iff_cmd" >/dev/null 2>&1; then
    echo -e "$rgb2iff_cmd is not found in your \$PATH"
    echo "Please build/install $rgb2iff_cmd from https://github.com/m0ppers/ipng2iff"
    exit 1
fi
if ! which "$ilbm_cmd" >/dev/null 2>&1; then
    echo -e "$ilbm_cmd is not found in your \$PATH"
    echo "Please build/install $ilbm_cmd from https://netpbm.sourceforge.net/"
    echo "Alternatively, you may try to install via your package manager, e.g. for Debian:"
    echo "$ sudo apt install $ilbm_pkg"
    exit 1
fi

# Make sure the source dir exists before we do anything. Exit otherwise
if [[ ! -d "$asset_dir" ]]; then
    echo "ERROR: Assets dir '$asset_dir' does not exist."
    exit 1
fi

# Make sure the palette include file target dir exists. Exit otherwise
if [[ ! -d "$inc_dir" ]]; then
    # inc_dir may have been specified as a relative path from cwd
    inc_dir_rel="$(pwd)/$inc_dir"
    if [[ -d "$inc_dir_rel" ]]; then
        inc_dir="$inc_dir_rel"
    else
        echo "ERROR: Cannot find target dir '$inc_dir' for palette include files ."
        exit 1
    fi
fi
inc_dir=$(realpath "$inc_dir")

# Convert *.xcf files in assets/GIMP into PNG files in assets/PNG
if $skip_png; then
    echo "XCF->PNG generation skipped. Specify --xcf-png option to include"
else
    for xcf_file in ${input_file}.xcf; do
        png_file="$(dirname $xcf_file)/$(basename $xcf_file .xcf).png"
        echo -e "\nConverting: XCF --> PNG\n<-- $xcf_file\n--> $png_file"
        if ! $dry_run; then
            # Write PNG file
            gimp_xcf_to_png "$xcf_file" "$png_file"
        fi
    done
fi

# Convert *.png files in assets/PNG into IFF/ILBM *.iff files in assets/IFF
if $skip_iff; then
    echo "PNG->IFF generation skipped. Specify --png-iff option to include"
else
    for png_file in ${input_file}.png; do
        png_res=$(file "$png_file" | grep -oP '([[:digit:]]+[[:blank:]]*x[[:blank:]]*[[:digit:]]+)' | sed 's/ //g')    
        iff_file="$(dirname $png_file)/$(basename $png_file .png).iff"
        echo -e "\nConverting: PNG --> IFF\n<-- $png_file ($png_res)\n--> $iff_file"
        if  ! $dry_run; then
            # Write IFF file
            "$rgb2iff_cmd" "$png_file" "$iff_file"
        fi
    done
fi

get_ilbm_info() {
    ilbm_info=$("$ilbm_cmd" -verbose -ignore BODY -ignore CAMG "$iff_file" 2>&1)
    ilbm_res=$(echo "$ilbm_info" | head -1 | grep -oP '([[:digit:]]+x[[:digit:]]+)')
    ilbm_res_w=$(echo "$ilbm_res" | cut -f1 -d'x')
    ilbm_res_h=$(echo "$ilbm_res" | cut -f2 -d'x')
    ilbm_planes=$(echo "$ilbm_info" | grep -oP '([[:digit:]]+[[:blank:]]*planes)' | cut -f1 -d' ')
    ilbm_cmap=$(echo "$ilbm_info" | grep -oP '([[:digit:]]+[[:blank:]]+[[:digit:]]+[[:blank:]]+[[:digit:]]+[[:space:]]*)')
    # - Calculate offset into iff_file for the bitplanes data in BODY chunk.
    # - Note: this assumes that BODY is the last chunk in the IFF file.
    iff_file_size=$(stat -c '%s' "$iff_file")
    ilbm_body_size=$(echo "$ilbm_res_w * $ilbm_res_h * $ilbm_planes / 8" | bc)
    ilbm_body_offset=$(echo "$iff_file_size - $ilbm_body_size" | bc)
    # generate palette. Recognizes patterns in the IFF filename for setting palette COLORx registers
    color_reg=0
    case "{$iff_file,,}" in
     *pf2* )            color_reg=8     ;; # Playfield 2 palette starts at COLOR08
     *spr0* | *spr1*)   color_reg=16    ;; # Sprites 0 & 1 palette starts at COLOR16
     *spr2* | *spr3*)   color_reg=20    ;; # Sprites 2 & 3 palette starts at COLOR20
     *spr4* | *spr5*)   color_reg=24    ;; # Sprites 4 & 5 palette starts at COLOR24
     *spr6* | *spr7*)   color_reg=28    ;; # Sprites 6 & 7 palette starts at COLOR28
    esac

    palette=()
    while read -r color ; do
        col_r=$(echo "$color" | cut -f1 -d' ')
        col_g=$(echo "$color" | cut -f2 -d' ')
        col_b=$(echo "$color" | cut -f3 -d' ')
        # col_r, col_g, col_b are still in 8-bit color. 
        # We need to convert to 4-bit color for the palette
        # Logical shift right x4 is division by 16
        col_r=$(echo "$col_r / 16" | bc )
        col_g=$(echo "$col_g / 16" | bc)
        col_b=$(echo "$col_b / 16" | bc)
        col_packed=$(echo "$col_r * 256 + $col_g * 16 + $col_b" | bc)
        # Convert to hex and store
        palette+=($(printf "COLOR%02d,$%03x" $color_reg $col_packed))
        color_reg=$(expr $color_reg + 1)
    done <<<$(echo "$ilbm_cmap")
}

# Convert *.iff files in assets/IFF to raw (interleaved) plane data in RAW
process_ilbm=false
if $skip_raw; then
    echo "IFF->RAW conversion skipped. Specify --iff-raw option to include"
else
    process_ilbm=true
fi
if $skip_palette; then
    echo "IFF->Palette ASM generation skipped. Specify --inc-pal option to include"
else
    process_ilbm=true
fi
if $process_ilbm; then
    for iff_file in ${input_file}.iff; do
        # grab some metadata on the IFF file
        get_ilbm_info
        raw_file="$(dirname $iff_file)/$(basename $iff_file .iff).raw"
        # Only write one palette file for each sprite pair
        case "{$iff_file,,}" in
        *spr0* | *spr1*)   palette_file="$inc_dir/sprites_01_palette.i"     ;; # Sprites 0 & 1 palette file
        *spr2* | *spr3*)   palette_file="$inc_dir/sprites_23_palette.i"     ;; # Sprites 2 & 3 palette file
        *spr4* | *spr5*)   palette_file="$inc_dir/sprites_45_palette.i"     ;; # Sprites 4 & 5 palette file
        *spr6* | *spr7*)   palette_file="$inc_dir/sprites_67_palette.i"     ;; # Sprites 6 & 7 palette file
        *)  palette_file="$inc_dir/$(basename $iff_file .iff)_palette.i"    ;;
        esac
        echo -e "\nProcessing: IFF:\n<-- $iff_file ($ilbm_res, $ilbm_planes bitplanes, file size: $iff_file_size, BODY size: $ilbm_body_size => BODY offset=$ilbm_body_offset)"
        if ! $skip_raw; then
            echo "--> $raw_file"
            if ! $dry_run; then
                # Output 'BODY' chunk of IFF file as RAW bitplane data.
                dd -- if="$iff_file" of="$raw_file" bs="$ilbm_body_offset" skip=1 status=none
                # Verify RAW file size matches ILBM BODY size
                raw_file_size=$(stat -c '%s' "$raw_file")
                if [ "$raw_file_size" == "$ilbm_body_size" ]; then
                    echo "Verify: Success: RAW file size matches ILBM BODY size ($raw_file_size)"
                else
                    echo "Verify: ERROR: RAW file size ($raw_file_size) mismatch with ILBM BODY size ($ilbm_body_size)"
                fi
            fi
        fi
        if ! $skip_palette; then
            echo "--> $palette_file"            
            if ! $dry_run; then
                # Output Palette file as ASM 'Copper list'
                printf "\tdc.w %s\n" "${palette[@]}" > "$palette_file"
            else
                echo "Palette not written due to --dry-run option. Contents follows:"
                printf "dc.w %s\n" "${palette[@]}"
            fi
        fi
    done
fi

# Delete intermediary files if requested:
if $delete_int_files; then
    for png_file in ${input_file}.png; do
        echo "Removing $png_file"
        if ! $dry_run; then
            rm "$png_file"
        fi
    done
    for iff_file in ${input_file}.iff; do
        echo "Removing $iff_file"
        if ! $dry_run; then
            rm "$iff_file"
        fi
    done
fi