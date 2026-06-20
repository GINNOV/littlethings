



; FUNCTION:
; process_sample_data
;
; IN:
; A0 = ptr to start of 'FORM' or 'CAT ' block of sample data.
; A1 = ptr to Instrument Entry in Music Data.
; D0 = remaining length of sample file including headers.
;
; OUT:
; sample_status         ; 0 = success, 1 = missing FORM/CAT chunk, 2 = missing 8SVX chunk
; sample_vhdr_ptr       ; address ptr to sample vhdr data
; sample_body_ptr       ; address ptr to raw sample data
;




; ************************************************************************************************************
; ************************************************************************************************************
; ************************************************************************************************************
;       START OF IFF '8SVX' FILE PROCESSING
; ************************************************************************************************************
; ************************************************************************************************************
; ************************************************************************************************************


                ;------------------ process sample data --------------------------
                ; Walks through the IFF 8SVX file format, storing the pointers to
                ; the BODY and VHDL chunks in the variables.
                ;
                ; Also, sets the error/status 'sample_status' - 0 = success
                ;
                ; IN: A0 = ptr to start of 'FORM' or 'CAT ' block of sample data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = remaining length of sample file including headers.
                ;
sample_status                                   ; original address $00048a6a
L00048a6a       dc.w    $0000                   ; error/status flag
                                                ; 1 = missing FORM/CAT chunk
                                                ; 2 = missing 8SVX chunk

process_sample_data                             ; original address $00048a6c
L00048a6c       clr.w   sample_status           ; L00048a6a
                movem.l d0/a0,-(a7)
                bra.w   process_inner_chunk     ; L00048a7a
process_inner_chunk
L00048a7a       tst.l   d0                      ; test remaining sample length     
                beq.b   .exit                   ; L00048a88
                move.l  (a0)+,d1                ; d1.l = iff chunk name
                subq.l  #$04,d0                 ; d0.l = iff remaining chunk length
                bsr.w   process_sample_chunk    ; L00048a8e
                bra.b   process_inner_chunk     ;L00048a7a
.exit
L00048a88       movem.l (a7)+,d0/a0
                rts  



                ;------------------ process sample chunk ------------------
                ; process IFF sample data, top level of file structure.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_sample_chunk                            ; original address $00048a8e
L00048a8e       cmp.l   #'FORM',d1              ; #$464f524d,d1
                beq.w   process_form_chunk      ; L00048aec
                cmp.l   #'CAT ',d1               ; #$43415420,d1
                beq.w   process_cat_chunk       ; L00048aae
                move.w  #$0001,sample_status    ; missing expected FORM/CAT
                clr.l   d0
                rts  



                ;--------------------- process CAT chunk --------------------------
                ; skips header and continues processing any further chunks 
                ; that are nested inside the CAT Chunk, data.
                ;
                ; IN: A0 = ptr to length of chunk data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_cat_chunk                               ; original address $00048aae
L00048aae       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0                ; d0 = CAT chunk length, a0 = start of data
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte            ; L00048abe
.add_pad_byte
                addq.l  #$01,d1                 ; add pad byte
.no_pad_byte
L00048abe       addq.l  #$04,d1                 ; include 'length' field in data length
                add.l   d1,$0004(a7)            ; update data ptr on stack to end of CAT chunk
                sub.l   d1,(a7)                 ; update remaining bytes on stack to end of CAT chunk
                addq.l  #$04,(a0)               ; *** bug?? updating data in CAT chunk?? **
                subq.l  #$04,d0                 ; update remaining length - skip processed length longword
                bra.b   process_inner_chunk     ; process embedded CAT chunks - L00048a7a



                ;------------------- process LIST chunk -----------------
                ; skip the list chunk, and continue processing
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_list_chunk                              ; original address $00048acc
L00048acc       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte            ; L00048adc
.add_pad_byte
                addq.l  #$01,d1
.no_pad_byte
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7)
                nop
                movem.l (a7)+,d0/a0
                rts



                ;---------------- process FORM chunk ------------------
                ; Expects to find an '8SVX' inner chunk of data.
                ; If not, then sets error/status flag = $0002
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length field.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_form_chunk                                      ; original address $00048aec
L00048aec       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte                    ; L00048afc
.add_pad_byte
                addq.l  #$01,d1
.no_pad_byte
L00048afc       addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7)
                move.l  (a0)+,d1
                subq.l  #$04,d0
                cmp.l   #'8SVX',d1                      ;  #$38535658,d1
                beq.w   process_8svx_chunk              ; L00048b20 
                move.w  #$0002,sample_status            ; L00048a6a ; 2 = missing 8SVX chunk
                movem.l (a7)+,d0/a0
                rts



                ;------------------ process 8SVX chunk ---------------------
                ; loops through sample data until no bytes remaining.
                ; processes inner chunks of 8SVX chunk, including:-
                ;  - VHDL, BODY, NAME, ANNO
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data.
                ; IN: D1.l = chunk identifier, i.e '8SVX'
                ;
process_8svx_chunk                                      ; original address $00048b20
L00048b20       tst.l   d0
                beq.b   .exit                           ; L00048b2e
                move.l  (a0)+,d1                        ; d1 = inner chunk name
                subq.l  #$04,d0                         ; d1 = updated remaining bytes length
                bsr.w   process_inner_8svx_chunk        ; L00048b34
                bra.b   process_8svx_chunk              ; loop - L00048b20
.exit
                movem.l (a7)+,d0/a0
                rts 



                ;---------------- process inner 8SVX chunk --------------
                ; process data held inside the 8SVX chunk, this is only
                ; concerned with the VHDR and BODY chunks. it skips
                ; other chunks such as the NAME, ANNO meta data chunks.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_inner_8svx_chunk
L00048b34       cmp.l   #'FORM',d1              ; #$464f524d,d1
                beq.b   process_form_chunk      ; L00048aec
                cmp.l   #'LIST',d1              ; #$4c495354,d1
                beq.b   process_list_chunk      ; L00048acc
                cmp.l   #'CAT ',d1              ; #$43415420,d1
                beq.w   process_cat_chunk       ; L00048aae
                cmp.l   #'VHDR',d1              ; #$56484452,d1
                beq.w   process_vhdr_chunk      ; L00048b84
                cmp.l   #'BODY',d1              ; #$424f4459,d1
                beq.w   process_body_chunk      ; L00048bac
.skip_unused_chunks
L00048b62       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte            ;L00048b72
.add_pad_byte
                addq.l  #$01,d1
.no_pad_byte
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7)
                movem.l (a7)+,d0/a0
                rts  



                ;-------------------- process VHDR chunk ----------------------
                ; stores address of VHDR chunk in variable 'sample_vhdr_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_vhdr_ptr                                 ; original address $00048b80
L00048b80       dc.l    $00000000               ; ptr to VHDR data

process_vhdr_chunk
L00048b84       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte            ; L00048b94
.add_pad_byte
                addq.l  #$01,d1
.no_pad_byte
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7) 
                move.l  a0,sample_vhdr_ptr      ; L00048b80 ; store address of VHDL data for instrument processing
                movem.l (a7)+,d0/a0
                rts 



                ;------------------------- process body chunk ------------------------
                ; store address of the raw sample data in variable 'sample_body_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_body_ptr                                 ; original address $00048ba8
L00048ba8       dc.l    $00000000               ; ptr to raw sample data

process_body_chunk                              ; original addresss $00048bac
L00048bac       movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte            ; L00048bbc
.add_pad_byte 
                addq.l  #$01,d1
.no_pad_byte
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7) 
                move.l  a0,sample_body_ptr      ; L00048ba8 ; store address of raw sample data
                movem.l (a7)+,d0/a0
                rts 





; ************************************************************************************************************
; ************************************************************************************************************
; ************************************************************************************************************
;       END OF IFF '8SVX' FILE PROCESSING
; ************************************************************************************************************
; ************************************************************************************************************
; ************************************************************************************************************







