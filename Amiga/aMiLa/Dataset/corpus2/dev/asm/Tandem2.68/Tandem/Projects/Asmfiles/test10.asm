* .L relative addresses (step thru to check)

* set prefs  rel .L  *not*  -> .W

 bra.s xeb
xebb:
 bra.w zak
zakb:
 bra.l yob
yobb:
 bsr.b ferd
 bsr.w ferd
 bsr.l ferd
 rts        ;program ends here!
ferd:
 rts
xeb:
 bra xebb
zak:
 bra zakb
yob:
 bra yobb
