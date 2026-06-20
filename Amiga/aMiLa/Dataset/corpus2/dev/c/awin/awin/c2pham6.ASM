; FILE: GG:src/own/awin/c2pham6.ASM          REV: 0 --- rgb565 -> grbb4444 ham6 c2p
; LINK: >LEAVEOBJ>
; History
;  0      Started 18th Dec 1998.
;

; rgb565 -> ham6 grbb4444 [2x1] routine
;
;theory:
;
;     scrpix1       scrpix2
;  [          ]  [          ]
;
;    g      r      b      b
;
;   [ ]    [ ]    [ ]    [ ]
;
; 00gggg 10rrrr 01bbbb 01bbbb
;
; 543210 543210 543210 543210
;
; So we need ham6 screen with double width and downscale chunky width
; with ratio 1:2. Also we fill plane4 with %00110011=$33 and plane5 with
; %01000100=$44. Then set palette (16 colours) to represent 16 green
; shades. During conversion we convert rgb565 to grbb4444 and then
; c2p that to four planes.
;
;implementation:
;
; awin.c/awinitc2pham6
; awin.c/awdoc2pham6


