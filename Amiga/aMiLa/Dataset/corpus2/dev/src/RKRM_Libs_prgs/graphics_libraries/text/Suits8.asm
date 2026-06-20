* A sparse (but complete) sample font.
*
* 1.  Assemble this file (assumed to have been saved as "suits8.asm"). For example, if you have the
* CAPE 680x0 assembler, and you have assigned "include:" to the directory containing your include
* files, use:
*          CAsm -a "suits8.asm" -o "suits8.o" -i "include:"
*
*     Link "suits8.o".  For example, if you have Lattice, use:
*          BLink from "suits8.o" to "suits8"
*
* 2.  Create the subdirectory "Fonts:suits".  Copy the file "suits8" (created in step 1)
*     to "Fonts:suits/8".
*
* 3.  Create a font contents file for the font.  You can do this by two methods:
*
*   a. Run the program "System/FixFonts" which will create the file "Fonts:suits.font"
*      automatically.
*   b. Use the NewFontContents() call in the diskfont library to create a FontContentsHeader
*      structure, which can be saved in the Fonts: directory as "suits.font".   This is essentially
*      what FixFonts does.
*
* The next word contains the font YSize; in this case, 0x0008.
*
* The next byte contains the font Flags, in this case 0x00.
*
* The last byte contains the font characteristics, in this case 0x60.  This says it is a disk-based
* font (bit 1 set) and the font has been removed (bit 7 set), saying that the font is not currently
* resident.
*
* Summary of suits.font file:
*
* Name: fch_FileID fch_NumEntries fc_FileName     fc_YSize fc_Flags fc_Style
* Size: word       word     MAXFONTPATH bytes word     byte     byte
* Hex:  0f00       0001     73756974732F3800  0008     00       60
* ASCII:            s u i t s / 8 \0
*
* The correct length of a font file may be calculated with this formula:
* length = ((number of font contents entries) * (MAXFONTPATH+4)) + 4. In this case (one entry),
* this becomes (MAXFONTPATH + 8) or 264.
*
* To try out this example font, do the following.  Use the Fonts Preferences editor or a
* program that allows the user to select fonts.  Choose the "suits" font in size 8.
* This example font defines ASCII characters 'a' 'b' 'c' and 'd' only. All other characters
* map to a rectangle, meaning "character unknown".

    INCLUDE  "exec/types.i"
    INCLUDE  "exec/nodes.i"
    INCLUDE  "libraries/diskfont.i"

    MOVEQ     #-1,D0      ; Provide an easy exit in case this file is
    RTS                   ; "Run" instead of merely loaded.

    DC.L      0           ; ln_Succ     * These five entries comprise a Node structure,
    DC.L      0           ; ln_Pred     * used by the system to link disk fonts into a
    DC.B      NT_FONT     ; ln_Type     * list.  See the definition of the "DiskFontHeader"
    DC.B      0           ; ln_Pri      * structure in the "libraries/diskfont.i" include
    DC.L      fontName    ; ln_Name     * file for more information.

    DC.W      DFH_ID      ; FileID
    DC.W      1           ; Revision
    DC.L      0           ; Segment

* The next MAXFONTNAME bytes are a placeholder.  The name of the font contents file (e.g.
* "suits.font") will be copied here after this font descriptor is LoadSeg-ed into memory.  The Name
* field could have been left blank, but inserting the font name and size (or style) allows one to
* tell something about the font by using "Type OPT H" on the file.

fontName:
    DC.B      "suits8"    ; Name

* If your assembler needs an absolute value in place of the "length" variable, simply count the
* number of characters in Name and use that.

length  EQU     *-fontName              ; Assembler calculates Name's length.
        DCB.B   MAXFONTNAME-length,0    ; Padding of null characters.

font:
    DC.L    0               ; ln_Succ       * The rest of the information is a TextFont
    DC.L    0               ; ln_Pred       * structure.  See the "graphics/text.i" include
    DC.B    NT_FONT         ; ln_Type       * file for more information.
    DC.B    0               ; ln_Pri
    DC.L    fontName        ; ln_Name
    DC.L    0               ; mn_ReplyPort
    DC.W    0               ; (Reserved for 1.4 system use.)
    DC.W    8               ; tf_YSize
    DC.B    0               ; tf_Style
    DC.B    FPF_DESIGNED!FPF_PROPORTIONAL!FPF_DISKFONT ; tf_Flags
    DC.W    14              ; tf_XSize
    DC.W    6               ; tf_Baseline  <----* tf_Baseline must be no greater than
    DC.W    1               ; tf_BoldSmear      * tf_YSize-1, otherwise algorithmically-
    DC.W    0               ; tf_Accessors      * generated styles (italic in particular)
    DC.B    97              ; tf_LoChar         * can corrupt system memory.
    DC.B    100             ; tf_HiChar
    DC.L    fontData        ; tf_CharData
    DC.W    8               ; tf_Modulo  <- * add this to the data pointer to go from from
                            ;               * one row of a character to the next row of it.
    DC.L    fontLoc         ; tf_CharLoc <---------------- * bit position in the font data
    DC.L    fontSpace       ; tf_CharSpace                 * at which the character begins.
    DC.L    fontKern        ; tf_CharKern

* The four characters of this font define the four playing-card suit symbols.  The heart, club,
* diamond, and spade map to the lower-case ASCII characters 'a', 'b', 'c', and 'd' respectively The
* fifth entry in the table is the character to be output when there is no entry defined in the
* character set for the requested ASCII value.  Font data is bit-packed edge to edge to save space.

fontData:                             ;   97 (a)       98 (b)       99 (c)   100 (d)      255
    DC.W  $071C0,$08040,$070FF,$0F000 ; <        X        X    X        X        >
    DC.W  $0FBE3,$0E0E0,$0F8C0,$03000 ;  .@@@...@@@.  .....@.....  ...@...  ....@@@....  @@@@@@@@@@@@
    DC.W  $07FCF,$0F9F3,$026C0,$03000 ;  @@@@@.@@@@@  ...@@@@@...  ..@@@..  ...@@@@@...  @@........@@
    DC.W  $03F9F,$0FFFF,$0FFC0,$03000 ;  .@@@@@@@@@.  .@@@@@@@@@.  .@@@@@.  .@@..@..@@.  @@........@@
    DC.W  $01F0E,$0B9F3,$026C0,$03000 ;  ..@@@@@@@..  @@@@@@@@@@@  @@@@@@@  @@@@@@@@@@@  @@........@@
    DC.W  $00E00,$080E0,$020C0,$03000 ;  ...@@@@@...  .@@@.@.@@@.  .@@@@@.  .@@..@..@@.  @@........@@
    DC.W  $00403,$0E040,$0F8FF,$0F000 ;  ....@@@....  .....@.....  ..@@@..  .....@.....  @@........@@
    DC.W  $00000,$00000,$00000,$00000 ;  .....@.....  ...@@@@@...  ...@...  ...@@@@@...  @@@@@@@@@@@@
    DC.W  $00000,$00000,$00000,$00000 ;  ...........  ...........  .......  ...........  ............

fontLoc:                 ; The fontLoc information is used to "unpack" the fontData. Each
    DC.L    $00000000B   ; pair of words specifies how the characters are bit-packed.  For
    DC.L    $0000B000B   ; example, the first character starts at bit position 0x0000, and
    DC.L    $000160007   ; is 0x000B (11) bits wide.  The second character starts at bit
    DC.L    $0001D000B   ; position 0x000B and is 0x000B bits wide, and so on.  This tells
    DC.L    $00028000C   ; the font handler how to unpack the bits from the array.

fontSpace:                        ; fontSpace array:  Use a space this wide to contain this
    DC.W    000012,000012         ; character when it is printed.  For reverse-path fonts
    DC.W    000008,000012,000013  ;  these values would be small or negative.

fontKern:                         ; fontKern array:  Place a space this wide after the
    DC.W    000001,000001         ; corresponding character to separate it from the following
    DC.W    000001,000001,000001  ; character.  For reverse-path fonts these values would be large
                                  ; negative numbers, approximately the width of the characters.
fontEnd:
    END
