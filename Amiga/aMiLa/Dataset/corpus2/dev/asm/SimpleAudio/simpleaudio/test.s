; test

   opt   c+,d+

   include  simpleaudio.i


   ALLOCAUDIO  #LEFT1!RIGHT1,#MUSIC

   tst.l d0
   bne.w exit_quick

   PLAY  #FireBird,#FireLen,#10814,#64,#WAIT!LEFT1,#1
   PLAY  #FireBird,#FireLen,#10814,#64,#WAIT!RIGHT1,#1
   PLAY  #FireBird,#FireLen,#12814,#64,#WAIT!LEFT1,#1

   DEALLOCAUDIO

exit_quick: rts


   section  sounds,data_c

FireBird:   incbin   "work:audio/samples/effects/firebird.raw"
FireLen: equ   *-FireBird
