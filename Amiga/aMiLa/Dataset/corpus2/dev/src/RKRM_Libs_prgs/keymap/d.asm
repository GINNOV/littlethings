*
* Copyright (c) 1992 Commodore-Amiga, Inc.
* 
* This example is provided in electronic form by Commodore-Amiga, Inc. for 
* use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
* published by Addison-Wesley (ISBN 0-201-56775-X).
* 
* The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
* information on the correct usage of the techniques and operating system 
* functions presented in these examples.  The source and executable code 
* of these examples may only be distributed in free electronic form, via 
* bulletin board or as part of a fully non-commercial and freely 
* redistributable diskette.  Both the source and executable code (including 
* comments) must be included, without modification, in any copy.  This 
* example may not be published in printed form or distributed with any
* commercial product.  However, the programming techniques and support
* routines set forth in these examples may be used in the development
* of original executable software products for Commodore Amiga computers.
* 
* All other rights reserved.
* 
* This example is provided "as-is" and is subject to change; no
* warranties are made.  All use is at your own risk. No liability or
* responsibility is assumed.
*
**********************************************************************
*
*   d.asm - d (GERMAN) A2000 key map
*
**********************************************************************


**   Assemble and then link without startup code or linker libs

*------ Included Files -----------------------------------------------
        INCLUDE         "exec/types.i"
        INCLUDE         "devices/keymap.i"
*---------------------------------------------------------------------
        DC.L    0,0             ; ln_Succ, ln_Pred
        DC.B    0,0             ; ln_Type, ln_Pri
        DC.L    KMName          ; ln_Name
        DC.L    KMLowMapType
        DC.L    KMLowMap
        DC.L    KMLCapsable
        DC.L    KMLRepeatable
        DC.L    KMHighMapType
        DC.L    KMHighMap
        DC.L    KMHCapsable
        DC.L    KMHRepeatable
*------ Key Translation Table ----------------------------------------
*  Raw key codes
*
*  45   50  51  52  53  54   55  56  57  58  59
*  00   01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 41  46  5F    5A  5B  5C  5D
*  42    10 11 12 13 14 15 16 17 18 19 1A 1B   44            3D  3E  3F  4A
*  63 62  20 21 22 23 24 25 26 27 28 29 2A 2B        4C      2D  2E  2F  5E
*  60 30   31 32 33 34 35 36 37 38 39 3A     61   4F 4D 4E   1D  1E  1F  43
*     64  66                40             67 65             0F      3C
*
*---------------------------------------------------------------------
*  German (D) mapping
*
*  ESC  F1  F2  F3  F4  F5   F6  F7  F8  F9  F10
*  `~   1! 2" 3S 4$ 5% 6& 7/ 8( 9) 0= B? '` \| BS  DEL HELP  [{  ]}  /   *
*  TAB   qQ wW eE rR tT zZ uU iI oO pP uU +*  RET            7   8   9   -
*  CT CL  aA sS dD fF gG hH jJ kK lL oO aA #^        UC      4   5   6   +
*  SH <>   yY xX cC vV bB nN mM ,; .: -_     SH   LC DC RC   1   2   3   ENT
*     ALT AM              SPACE            AM ALT            0       .
*
*---------------------------------------------------------------------
*   For comparison, here's the USA1 mapping
*
*  ESC  F1  F2  F3  F4  F5   F6  F7  F8  F9  F10
*  `~   1! 2@ 3# 4$ 5% 6^ 7& 8* 9( 0) -_ =+ \| BS  DEL HELP  ((  ))  //  **
*  TAB   qQ wW eE rR tT yY uU iI oO pP [{ ]}  RET            77  88  99  --
*  CT CL  aA sS dD fF gG hH jJ kK lL ;: '" [2B]      UC      44  55  66  ++
*  SH [30] zZ xX cC vV bB nN mM ,< .> /?     SH   LC DC RC   11  22  33 ENT
*     ALT AM              SPACE            AM ALT            00      ..
*
*--------------------------------------------------------------------------
*
*       40      Space
*       41      Backspace
*       42      Tab
*       43      Enter
*       44      Return
*       45      Escape
*       46      Delete
*       4A      Numeric Pad -
*       4C      Cursor Up
*       4D      Cursor Down
*       4E      Cursor Forward
*       4F      Cursor Backward
*
*       50-59   Function keys F1-F10
*       5A      Numeric Pad [{  (A2000)
*       5B      Numeric Pad ]}  (A2000)
*       5C      Numeric Pad /   (A2000)
*       5D      Numeric Pad *   (A2000)
*       5E      Numeric Pad +   (A2000)
*       5F      Help
*
*       60      Left Shift
*       61      Right Shift
*       62      Caps Lock
*       63      Control
*       64      Left Alt
*       65      Right Alt
*       66      Left Amiga
*       67      Right Amiga
*
*       68      Left Mouse Button (not converted)
*       69      Right Mouse Button (not converted)
*       6A      Middle Mouse Button (not converted)
*
*---------------------------------------------------------------------
KMLCapsable: ; NL means NULL (undefined) and RE means RESERVED
        DC.B    %00000000       ; 7\ 6& 5% 4$ 3s 2" 1! []  07 - 00
        DC.B    %00000000       ; 0N NL \| '` B? 0= 9) 8(  0F - 08
        DC.B    %11111111       ; iI uU zZ tT rR eE wW qQ  17 - 10
        DC.B    %00000111       ; 3N 2N 1N NL +* UU pP oO  1F - 18
        DC.B    %11111111       ; kK jJ hH gG fF dD sS aA  27 - 20
        DC.B    %00000111       ; 6N 5N 4N NL #' AA OO lL  2F - 28
        DC.B    %11111110       ; mM nN bB vV cC xX yY <>  37 - 30
        DC.B    %00000000       ; 9N 8N 7N .N NL -_ .: ,;  3F - 38

KMHCapsable:
        DC.B    %00000000       ; 47 - 40
        DC.B    %00000000       ; 4F - 48
        DC.B    %00000000       ; 57 - 50
        DC.B    %00000000       ; 5F - 58
        DC.B    %00000000       ; 67 - 60
        DC.B    %00000000       ; 6F - 68
        DC.B    %00000000       ; 77 - 70
KMLRepeatable:
        DC.B    %11111111       ; 7\ 6& 5% 4$ 3s 2" 1! []  07 - 00
        DC.B    %10111111       ; 0N NL \| '` B? 0= 9) 8(  0F - 08
        DC.B    %11111111       ; iI uU zZ tT rR eE wW qQ  17 - 10
        DC.B    %11101111       ; 3N 2N 1N NL +* UU pP oO  1F - 18
        DC.B    %11111111       ; kK jJ hH gG fF dD sS aA  27 - 20
        DC.B    %11101111       ; 6N 5N 4N NL #' AA OO lL  2F - 28
        DC.B    %11111111       ; mM nN bB vV cC xX yY <>  37 - 30
        DC.B    %11110111       ; 9N 8N 7N .N NL -_ .: ,;  3F - 38
KMHRepeatable:
        DC.B    %01000111       ; 47 - 40
        DC.B    %11110100       ; 4F - 48
        DC.B    %11111111       ; 57 - 50
        DC.B    %01111111       ; 5F - 58
        DC.B    %00000000       ; 67 - 60
        DC.B    %00000000       ; 6F - 68
        DC.B    %00000000       ; 77 - 70
KMLowMapType:
        DC.B    KC_VANILLA              ; []            $00
        DC.B    KCF_SHIFT+KCF_ALT       ; 1!
        DC.B    KCF_SHIFT+KCF_ALT       ; 2"
        DC.B    KCF_SHIFT+KCF_ALT       ; 3s
        DC.B    KCF_SHIFT+KCF_ALT       ; 4$
        DC.B    KCF_SHIFT+KCF_ALT       ; 5%
        DC.B    KC_VANILLA              ; 6&
        DC.B    KCF_SHIFT+KCF_ALT       ; 7/
        DC.B    KCF_SHIFT+KCF_ALT       ; 8(            $08
        DC.B    KCF_SHIFT+KCF_ALT       ; 9)
        DC.B    KCF_SHIFT+KCF_ALT       ; 0=
        DC.B    KC_VANILLA              ; B?
        DC.B    KCF_DEAD+KCF_SHIFT+KCF_ALT ; '`
        DC.B    KC_VANILLA              ; \|
        DC.B    KCF_NOP                 ;NL
        DC.B    KC_NOQUAL               ; 0N
        DC.B    KC_VANILLA              ; qQ            $10
        DC.B    KC_VANILLA              ; wW
        DC.B    KCF_DEAD+KC_VANILLA     ; eE
        DC.B    KC_VANILLA              ; rR
        DC.B    KC_VANILLA              ; tT
        DC.B    KC_VANILLA              ; zZ
        DC.B    KCF_DEAD+KC_VANILLA     ; uU
        DC.B    KCF_DEAD+KC_VANILLA     ; iI
        DC.B    KCF_DEAD+KC_VANILLA     ; oO            $18
        DC.B    KC_VANILLA              ; pP
        DC.B    KC_VANILLA              ; omlatuU
        DC.B    KC_VANILLA              ; +*
        DC.B    KCF_NOP                 ; NL
        DC.B    KC_NOQUAL               ; 1N
        DC.B    KC_NOQUAL               ; 2N
        DC.B    KC_NOQUAL               ; 3N
        DC.B    KCF_DEAD+KC_VANILLA     ; aA            $20
        DC.B    KC_VANILLA              ; sS
        DC.B    KC_VANILLA              ; dD
        DC.B    KCF_DEAD+KC_VANILLA     ; fF
        DC.B    KCF_DEAD+KC_VANILLA     ; gG
        DC.B    KCF_DEAD+KC_VANILLA     ; hH
        DC.B    KCF_DEAD+KC_VANILLA     ; jJ
        DC.B    KCF_DEAD+KC_VANILLA     ; kK
        DC.B    KC_VANILLA              ; lL            $28
        DC.B    KCF_SHIFT+KCF_ALT       ; umlotoO
        DC.B    KCF_SHIFT+KCF_ALT       ; umlotaA
        DC.B    KC_VANILLA              ; #^
        DC.B    KCF_NOP                 ; NL
        DC.B    KC_NOQUAL               ; 4N
        DC.B    KC_NOQUAL               ; 5N
        DC.B    KC_NOQUAL               ; 6N
        DC.B    KCF_SHIFT               ; <>            $30
        DC.B    KCF_DEAD+KC_VANILLA     ; yY
        DC.B    KC_VANILLA              ; xX
        DC.B    KC_VANILLA              ; cC
        DC.B    KC_VANILLA              ; vV
        DC.B    KC_VANILLA              ; bB
        DC.B    KCF_DEAD+KC_VANILLA     ; nN
        DC.B    KC_VANILLA              ; mM
        DC.B    KCF_SHIFT+KCF_ALT       ; ,;            $38
        DC.B    KCF_SHIFT+KCF_ALT       ; .:
        DC.B    KC_VANILLA              ; -_
        DC.B    KCF_NOP                 ; NL
        DC.B    KC_NOQUAL               ; .N
        DC.B    KC_NOQUAL               ; 7N
        DC.B    KC_NOQUAL               ; 8N
        DC.B    KC_NOQUAL               ; 9N
KMHighMapType:
        DC.B    KCF_DEAD+KCF_ALT        ; SPACE         $40
        DC.B    KC_NOQUAL               ; BACKSPACE
        DC.B    KCF_STRING+KCF_SHIFT    ; TAB
        DC.B    KC_NOQUAL               ; ENTER
        DC.B    KCF_CONTROL             ; RETURN
        DC.B    KCF_ALT                 ; ESCAPE
        DC.B    KC_NOQUAL               ; DELETE
        DC.B    KCF_NOP
        DC.B    KCF_NOP                 ;               $48
        DC.B    KCF_NOP
        DC.B    KC_NOQUAL               ; Numeric Pad -
        DC.B    KCF_NOP
        DC.B    KCF_STRING+KCF_SHIFT    ; CURSOR UP
        DC.B    KCF_STRING+KCF_SHIFT    ; CURSOR DOWN
        DC.B    KCF_STRING+KCF_SHIFT    ; CURSOR FORWARD
        DC.B    KCF_STRING+KCF_SHIFT    ; CURSOR BACKWARD
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 1        $50
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 2
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 3
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 4
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 5
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 6
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 7
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 8
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 9        $58
        DC.B    KCF_STRING+KCF_SHIFT    ; FKEY 10
        DC.B    KCF_SHIFT+KCF_CONTROL   ; Numeric Pad [{
        DC.B    KCF_SHIFT+KCF_CONTROL   ; Numeric Pad ]}
        DC.B    KC_NOQUAL               ; Numeric Pad /
        DC.B    KC_NOQUAL               ; Numeric Pad *
        DC.B    KC_NOQUAL               ; Numeric Pad +
        DC.B    KCF_STRING              ; Help
        DC.B    KCF_NOP                 ; Left Shift    $60
        DC.B    KCF_NOP                 ; Right Shift
        DC.B    KCF_NOP                 ; Caps Lock
        DC.B    KCF_NOP                 ; Control
        DC.B    KCF_NOP                 ; Left Alt
        DC.B    KCF_NOP                 ; Right Alt
        DC.B    KCF_NOP                 ; Left Amiga
        DC.B    KCF_NOP                 ; Right Amiga
        DC.B    KCF_NOP                 ; Left Mouse Button $68
        DC.B    KCF_NOP                 ; Right Mouse Button
        DC.B    KCF_NOP                 ; Middle Mouse Button
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP                 ; $70
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
        DC.B    KCF_NOP
KMLowMap:
        DC.B    '~','`','~','`' ; `, ~, `, ~                            $00
        DC.B    '!',$B9,'!','1' ; 1, !, super 1, !
        DC.B    $B2,'@','"','2' ; 2, ", @, super 2
        DC.B    '#',$B3,$A7,'3' ; 3, section, super 3, #
        DC.B    $A2,$B0,'$','4' ; 4, $, degree, cents
        DC.B    '%',$BC,'%','5' ; 5, %, 1/4, %
        DC.B    '^',$BD,'&','6' ; 6, &, 1/2, ^
        DC.B    '&',$BE,'/','7' ; 7, /, 3/4, &
        DC.B    '*',$B7,'(','8' ; 8, (, bullet, *                       $08
        DC.B    '(',$AB,')','9' ; 9, ), <<, (
        DC.B    ')',$BB,'=','0' ; 0, =, >>, )
        DC.B    '_','-','?',$DF ; sharp s, ?, -, _
        DC.L    key0C           ; dead ', dead `, =, +
        DC.B    '|','\','|','\' ; \, |, \, |
        DC.L    0               ; NOP
        DC.B    0,0,0,'0'       ; numeric pad 0 (0N)
        DC.B    $C5,$E5,'Q','q' ; q, Q, dot a, dot A                    $10
        DC.B    $B0,$B0,'W','w' ; w, W, dot, dot
        DC.L    key12   ; e, E, (c), (c)
        DC.B    $AE,$AE,'R','r' ; r, R, (r), (r)
        DC.B    $DE,$FE,'T','t' ; t, T, thorn, THORN
        DC.B    $A5,$A4,'Z','z' ; z, Z, IMS, Yen
        DC.L    key16           ; u, U, micro, micro
        DC.L    key17           ; i, I, inverted !, broken |
        DC.L    key18           ; o, O, slash o, slash O                $18
        DC.B    $B6,$B6,'P','p' ; p, P, paragraph, paragraph
        DC.B    '{','[',$DC,$FC ; umlaut u, umlaut U, [, {
        DC.B    '}',']','*','+' ; +, *, ], }
        DC.L    0               ; NOP
        DC.B    0,0,0,'1'       ; numeric pad 1 (1N)
        DC.B    0,0,0,'2'       ; numeric pad 2 (2N)
        DC.B    0,0,0,'3'       ; numeric pad 3 (3N)
        DC.L    key20           ; a, A, ae, AE                          $20
        DC.B    $A7,$DF,'S','s' ; s, S, sharp s, section
        DC.B    $D0,$F0,'D','d' ; d, D, bar d, bar D
        DC.L    key23           ; f, F, dead '
        DC.L    key24           ; g, G, dead `
        DC.L    key25           ; h, H, dead ^
        DC.L    key26           ; j, J, dead ~
        DC.L    key27           ; k, K, dead "
        DC.B    $A3,$A3,'L','l' ; l, L, pound, pound                    $28
        DC.B    ':',';',$D6,$F6 ; umlaut o, umlaut O, ;, :
        DC.B    '"',$27,$C4,$E4 ; umlaut a, umlaut A, ', "
        DC.B    '^','#','^','#' ; #, ^, #, ^
        DC.L    0               ; NOP
        DC.B    0,0,0,'4'       ; numeric pad 4 (4N)
        DC.B    0,0,0,'5'       ; numeric pad 5 (5N)
        DC.B    0,0,0,'6'       ; numeric pad 6 (6N)
        DC.B    0,0,'>','<'     ; <, >                                  $30
        DC.L    key31           ; y, Y, +/-, not
        DC.B    $F7,$D7,'X','x' ; x, X, times, divide
        DC.B    $C7,$E7,'C','c' ; c, C, c cedilla, C cedilla
        DC.B    $AA,$AA,'V','v' ; v, V, female ordinal
        DC.B    $BA,$BA,'B','b' ; b, B, male ordinal
        DC.L    key36           ; n, N, SHY, overbar
        DC.B    $BF,$B8,'M','m' ; m, M, cedilla, inverted ?
        DC.B    '<',',',';',',' ; ,, ;, ,, <                            $38
        DC.B    '>','.',':','.' ; ., :, ., >
        DC.B    '?','/','_','-' ; -, _, /, ?
        DC.L    0               ; NOP
        DC.B    0,0,0,'.'       ; numeric pad . (.N)
        DC.B    0,0,0,'7'       ; numeric pad 7 (7N)
        DC.B    0,0,0,'8'       ; numeric pad 8 (8N)
        DC.B    0,0,0,'9'       ; numeric pad 9 (9N)
KMHighMap:
        DC.L    key40                                                   $40
        DC.B    0,0,0,$08
        DC.L    key42
        DC.B    0,0,0,$0D
        DC.B    0,0,$0A,$0D
        DC.B    0,0,$9B,$1B
        DC.B    0,0,0,$7F
        DC.L    0
        DC.L    0                                                       $48
        DC.L    0
        DC.B    0,0,0,'-'
        DC.L    0
        DC.L    key4C
        DC.L    key4D
        DC.L    key4E
        DC.L    key4F
        DC.L    key50                                                   $50
        DC.L    key51
        DC.L    key52
        DC.L    key53
        DC.L    key54
        DC.L    key55
        DC.L    key56
        DC.L    key57
        DC.L    key58                                                   $58
        DC.L    key59
        DC.B    $1B,$1B,'{','[' ; numeric pad [, {
        DC.B    $1D,$1D,'}',']' ; numeric pad ], }
        DC.B    0,0,0,'/'       ; numeric pad /
        DC.B    0,0,0,'*'       ; numeric pad *
        DC.B    0,0,0,'+'       ; numeric pad +
        DC.L    key5F
        DC.L    0                                                       $60
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0                                                       $68
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0                                                       $70
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
        DC.L    0
;------ possible dead keys
key0C:
        DC.B    DPF_DEAD,1+(6<<DP_2DFACSHIFT)   ; dead '
        DC.B    DPF_DEAD,2+(6<<DP_2DFACSHIFT)   ; dead `
        DC.B    0,'=',0,'+'                     ; =, +
key23:
        DC.B    0,'f',0,'F'                     ; f, F
        DC.B    DPF_DEAD,1+(6<<DP_2DFACSHIFT)   ; dead '
        DC.B    DPF_DEAD,1+(6<<DP_2DFACSHIFT)   ; dead '
        DC.B    0,$06,0,$06,0,$86,0,$86         ; control translation
key24:
        DC.B    0,'g',0,'G'                     ; g, G
        DC.B    DPF_DEAD,2+(6<<DP_2DFACSHIFT)   ; dead `
        DC.B    DPF_DEAD,2+(6<<DP_2DFACSHIFT)   ; dead `
        DC.B    0,$07,0,$07,0,$87,0,$87         ; control translation
key25:
        DC.B    0,'h',0,'H'                     ; h, H
        DC.B    DPF_DEAD,3,DPF_DEAD,3           ; dead ^, dead ^
        DC.B    0,$08,0,$08,0,$88,0,$88         ; control translation
key26:
        DC.B    0,'j',0,'J'                     ; j, J
        DC.B    DPF_DEAD,4,DPF_DEAD,4           ; dead ~, dead ~
        DC.B    0,$0A,0,$0A,0,$8A,0,$8A         ; control translation
key27:
        DC.B    0,'k',0,'K'                     ; k, K
        DC.B    DPF_DEAD,5,DPF_DEAD,5           ; dead ", dead "
        DC.B    0,$0B,0,$0B,0,$8B,0,$8B         ; control translation
;------ deadable keys (modified by dead keys)
key12:                  ; e, E, (c), (c)
        DC.B    DPF_MOD,key12u-key12,DPF_MOD,key12s-key12
        DC.B    0,$A9,0,$A9
        DC.B    0,$05,0,$05,0,$85,0,$85 ; control translation
key12u:
        DC.B    'e',$E9,$E8,$EA,'e',$EB
        DC.B    $E9,$E9,$EA,$E9,$E9,$E9
        DC.B    $E8,$EA,$E8,$E8,$E8,$E8
key12s:
        DC.B    'E',$C9,$C8,$CA,'E',$CB
        DC.B    $C9,$C9,$CA,$C9,$C9,$C9
        DC.B    $C8,$CA,$C8,$C8,$C8,$C8
key16:                  ; u, U, micro, micro
        DC.B    DPF_MOD,key16u-key16,DPF_MOD,key16s-key16
        DC.B    0,$B5,0,$B5
        DC.B    0,$15,0,$15,0,$95,0,$95 ; control translation
key16u:
        DC.B    'u',$FA,$F9,$FB,'u',$FC
        DC.B    $FA,$FA,$FB,$FA,$FA,$FA
        DC.B    $F9,$FB,$F9,$F9,$F9,$F9
key16s:
        DC.B    'U',$DA,$D9,$DB,'U',$DC
        DC.B    $DA,$DA,$DB,$DA,$DA,$DA
        DC.B    $D9,$DB,$D9,$D9,$D9,$D9
key17:                  ; i, I, inverted !, broken |
        DC.B    DPF_MOD,key17u-key17,DPF_MOD,key17s-key17
        DC.B    0,$A1,0,$A6
        DC.B    0,$09,0,$09,0,$89,0,$89 ; control translation
key17u:
        DC.B    'i',$ED,$EC,$EE,'i',$EF
        DC.B    $ED,$ED,$EE,$ED,$ED,$ED
        DC.B    $EC,$EE,$EC,$EC,$EC,$EC
key17s:
        DC.B    'I',$CD,$CC,$CE,'I',$CF
        DC.B    $CD,$CD,$CE,$CD,$CD,$CD
        DC.B    $CC,$CE,$CC,$CC,$CC,$CC
key18:                  ; o, O, bar o, bar O
        DC.B    DPF_MOD,key18u-key18,DPF_MOD,key18s-key18
        DC.B    0,$F8,0,$D8
        DC.B    0,$0F,0,$0F,0,$8F,0,$8F ; control translation
key18u:
        DC.B    'o',$F3,$F2,$F4,$F5,$F6
        DC.B    $F3,$F3,$F4,$F3,$F3,$F3
        DC.B    $F2,$F4,$F2,$F2,$F2,$F2
key18s:
        DC.B    'O',$D3,$D2,$D4,$D5,$D6
        DC.B    $D3,$D3,$D4,$D3,$D3,$D3
        DC.B    $D2,$D4,$D2,$D2,$D2,$D2
key20:                  ; a, A, ae, AE
        DC.B    DPF_MOD,key20u-key20,DPF_MOD,key20s-key20
        DC.B    0,$E6,0,$C6
        DC.B    0,$01,0,$01,0,$81,0,$81 ; control translation
key20u:
        DC.B    'a',$E1,$E0,$E2,$E3,$E4
        DC.B    $E1,$E1,$E2,$E1,$E1,$E1 ; most recent is '
        DC.B    $E0,$E2,$E0,$E0,$E0,$E0 ; most recent is `
key20s:
        DC.B    'A',$C1,$C0,$C2,$C3,$C4
        DC.B    $C1,$C1,$C2,$C1,$C1,$C1 ; most recent is '
        DC.B    $C0,$C2,$C0,$C0,$C0,$C0 ; most recent is `
key36:                  ; n, N, SHY, overbar
        DC.B    DPF_MOD,key36u-key36,DPF_MOD,key36s-key36
        DC.B    0,$AD,0,$AF
        DC.B    0,$0E,0,$0E,0,$8E,0,$8E ; control translation
key36u:
        DC.B    'n','n','n','n',$F1,'n'
        DC.B    'n','n','n','n','n','n'
        DC.B    'n','n','n','n','n','n'
key36s:
        DC.B    'N','N','N','N',$D1,'N'
        DC.B    'N','N','N','N','N','N'
        DC.B    'N','N','N','N','N','N'
key31:                  ; y, Y, +/-, not
        DC.B    DPF_MOD,key31u-key31,DPF_MOD,key31s-key31
        DC.B    0,$B1,0,$AC
        DC.B    0,$19,0,$19,0,$99,0,$99 ; control translation
key31u:
        DC.B    'y',$FD,'y','y','y',$FF
        DC.B    $FD,$FD,$FD,$FD,$FD,$FD
        DC.B    'y','y','y','y','y','y'
key31s:
        DC.B    'Y',$DD,'Y','Y','Y','Y'
        DC.B    $DD,$DD,$DD,$DD,$DD,$DD
        DC.B    'Y','Y','Y','Y','Y','Y'
key40:                  ; space,,NBSP, and accents
        DC.B    DPF_MOD,key40d-key40,0,$A0
key40d:
        DC.B    ' ',$B4,'`','^','~',$A8
        DC.B    $B4,'^',$B4,$B4,$B4,$B4
        DC.B    '`','`','^','`','`','`'
;------ string keys
key42:
        DC.B    key42ue-key42us,key42us-key42
        DC.B    key42se-key42ss,key42ss-key42
key42us:
        DC.B    $09
key42ue:
key42ss:
        DC.B    $9B,'Z'
key42se:
key4C:
        DC.B    key4Cue-key4Cus,key4Cus-key4C
        DC.B    key4Cse-key4Css,key4Css-key4C
key4Cus:
        DC.B    $9B,'A'
key4Cue:
key4Css:
        DC.B    $9B,'T'
key4Cse:
key4D:
        DC.B    key4Due-key4Dus,key4Dus-key4D
        DC.B    key4Dse-key4Dss,key4Dss-key4D
key4Dus:
        DC.B    $9B,'B'
key4Due:
key4Dss:
        DC.B    $9B,'S'
key4Dse:
key4E:
        DC.B    key4Eue-key4Eus,key4Eus-key4E
        DC.B    key4Ese-key4Ess,key4Ess-key4E
key4Eus:
        DC.B    $9B,'C'
key4Eue:
key4Ess:
        DC.B    $9B,' ','@'
key4Ese:
key4F:
        DC.B    key4Fue-key4Fus,key4Fus-key4F
        DC.B    key4Fse-key4Fss,key4Fss-key4F
key4Fus:
        DC.B    $9B,'D'
key4Fue:
key4Fss:
        DC.B    $9B,' ','A'
key4Fse:
key50:
        DC.B    key50ue-key50us,key50us-key50
        DC.B    key50se-key50ss,key50ss-key50
key50us:
        DC.B    $9B,'0~'
key50ue:
key50ss:
        DC.B    $9B,'10~'
key50se:
key51:
        DC.B    key51ue-key51us,key51us-key51
        DC.B    key51se-key51ss,key51ss-key51
key51us:
        DC.B    $9B,'1~'
key51ue:
key51ss:
        DC.B    $9B,'11~'
key51se:
key52:
        DC.B    key52ue-key52us,key52us-key52
        DC.B    key52se-key52ss,key52ss-key52
key52us:
        DC.B    $9B,'2~'
key52ue:
key52ss:
        DC.B    $9B,'12~'
key52se:
key53:
        DC.B    key53ue-key53us,key53us-key53
        DC.B    key53se-key53ss,key53ss-key53
key53us:
        DC.B    $9B,'3~'
key53ue:
key53ss:
        DC.B    $9B,'13~'
key53se:
key54:
        DC.B    key54ue-key54us,key54us-key54
        DC.B    key54se-key54ss,key54ss-key54
key54us:
        DC.B    $9B,'4~'
key54ue:
key54ss:
        DC.B    $9B,'14~'
key54se:
key55:
        DC.B    key55ue-key55us,key55us-key55
        DC.B    key55se-key55ss,key55ss-key55
key55us:
        DC.B    $9B,'5~'
key55ue:
key55ss:
        DC.B    $9B,'15~'
key55se:
key56:
        DC.B    key56ue-key56us,key56us-key56
        DC.B    key56se-key56ss,key56ss-key56
key56us:
        DC.B    $9B,'6~'
key56ue:
key56ss:
        DC.B    $9B,'16~'
key56se:
key57:
        DC.B    key57ue-key57us,key57us-key57
        DC.B    key57se-key57ss,key57ss-key57
key57us:
        DC.B    $9B,'7~'
key57ue:
key57ss:
        DC.B    $9B,'17~'
key57se:
key58:
        DC.B    key58ue-key58us,key58us-key58
        DC.B    key58se-key58ss,key58ss-key58
key58us:
        DC.B    $9B,'8~'
key58ue:
key58ss:
        DC.B    $9B,'18~'
key58se:
key59:
        DC.B    key59ue-key59us,key59us-key59
        DC.B    key59se-key59ss,key59ss-key59
key59us:
        DC.B    $9B,'9~'
key59ue:
key59ss:
        DC.B    $9B,'19~'
key59se:
key5F:
        DC.B    key5Fe-key5Fs,key5Fs-key5F
key5Fs:
        DC.B    $9B,'?~'
key5Fe:
KMName:
        DC.B    'd',0
kmEnd
        END
