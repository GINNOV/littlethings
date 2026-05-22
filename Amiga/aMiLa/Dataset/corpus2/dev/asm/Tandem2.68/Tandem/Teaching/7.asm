* 7.asm    Signed and unsigned arithmetic    version 0.00    1.9.97

 move.b #$7F,d0 ;signed:   127+2=-127  -> invalid, so VS
 add.b #2,d0    ;unsigned: 127+2=129   ->   valid, so CC

 move.b #$81,d0 ;signed:  -127-2=+127  -> invalid, so VS
 sub.b #2,d0    ;unsigned  129-2=127   ->   valid, so CC

 move.b #1,d0   ;signed:     1-2=-1    ->   valid, so VC
 sub.b #2,d0    ;unsigned:   1-2=255   -> invalid, so CS

 move.b #$FF,d0 ;signed:    -1+2=+1    ->   valid, so VC
 add.b #2,d0    ;unsigned:   1-2=255   -> invalid, so CS

 rts
