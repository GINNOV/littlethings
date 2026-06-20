* test assembly of floating point data

 rts                     ;4E75

 dc.p 123.45             ;00020001230000000000
 dc.p 1.2E-13            ;(Devpac no good)
 dc.p 3.14159265358979E0 ;(Devpac no good)
 dc.s 123.45             ;42F6E666
 dc.s 1.2E-13            ;2A071BA5
 dc.s 3.14159265358978E0 ;40490FDB
 dc.d 123.45             ;405EDCCCCCCCCCCD
 dc.d 1.2E-13            ;3D40E374A4F8E0B4
 dc.d 3.14159265358979E0 ;400921FB54442D11
 dc.x 123.45             ;40050000F6E666666666
 dc.x 1.2E-13            ;3FD40000871BA527C705 
 dc.x 3.14159265358978E0 ;40000000C90FDAA22167

 fmove.b #$12,fp0        ;F23C58000012
 fmove.w #$1234,fp0      ;F23C50001234
 fmove.l #$12345678,fp0  ;F23C400012345678
 fmove.p #123.45,fp0     ;F23C4C00000200012300
 fmove.s #123.45,fp0     ;F23C440042F6E666
 fmove.d #123.45,fp0     ;F23C5400405EDCCCCCCC
 fmove.x #123.45,fp0     ;F23C480040050000F6E6
