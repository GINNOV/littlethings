                incdir      AsI:

DPRINTF         SET         1

                IFD         DPRINTF
                  include   "DPrintf.i"
                ENDC
Start:
                lea         Test(pc),a0
                moveq       #10,d0
                lea         TestWerte(pc),a1
                movea.l     #15,a6
                moveq       #-1,d1


                IFD         DPRINTF
                  DPF       <Test %u %d %% %d %x\\ %s \n%08lx\n\n   %d\n%d\n>,d1,#111,#2,(a1),a0,a6,d0,2(a1)
                ENDC

;                moveq       #-1,d0
;.lll:
;                DPF .
;                dbra        d0,.lll

;                DPF.L       <\d\s>
;                DPF.L       <\d\s>
;                DPF.L       <\d\s>
;                DPF.L       <\d\s>
;                DPF.L       <\d\s>


;                DPF.L       <\b\s>


                moveq       #0,d0
                rts
TestWerte:
                dc.w        $A55A
                dc.w        999

Test:           dc.b        'Dies ist ein Test',0

                END
