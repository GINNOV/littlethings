# This is a demo for the PPCASMPK PowerPC-emulator
# It requires at least Kickstart3.0 and AGA(or gfxboard)
#
#
#NOTE: This demo does not use absolute addressings like "ba".
#      Yet, this would be possible without relocating the code
#      because the emulator simulates the first instruction to
#      reside at address 0. So if you jump to the correct offset,
#      you can use "ba" or address local data without referring to
#      a known "base-address" like is done here.
#
#-----------------------------------------------------------------------------

####BO-field at conditional branches
BO_true   =     12        #if bit=1
BO_false  =     4         #if bit=0
BO_always =     0b10100   #unconditional
####################################

####L-Bit at compare-instructions
L_32bit   =     0
L_64bit   =     1 #(64bit-PPCs only)
#################################

####spr-field at mtspr/mfspr
SPR_XER   =     1
SPR_LR    =     8
SPR_CTR   =     9
############################

crf_lt    =     0
crf_gt    =     1
crf_eq    =     2
crf_so    =     3

####condition-register fields####
CR0       =     0
CR1       =     1
CR2       =     2
CR3       =     3
CR4       =     4
CR5       =     5
CR6       =     6
CR7       =     7
#################################

####register-names(required for GNU only)####
r0        =     0
r1        =     1
r2        =     2
r3        =     3
r4        =     4
r5        =     5
r6        =     6
r7        =     7
r8        =     8
r9        =     9
r10       =     10
r11       =     11
r12       =     12
r13       =     13
r14       =     14
r15       =     15
r16       =     16
r17       =     17
r18       =     18
r19       =     19
r20       =     20
r21       =     21
r22       =     22
r23       =     23
r24       =     24
r25       =     25
r26       =     26
r27       =     27
r28       =     28
r29       =     29
r30       =     30
r31       =     31
#############################################
#-----------------------------------------------------------------------------
        .INCLUDE "intui.lvo"
        .INCLUDE "exec.lvo"
        .INCLUDE "graphics.lvo"
        .INCLUDE "input.lvo"
#-----------------------------------------------------------------------------
MYSCREEN_WIDTH  =     320
MYSCREEN_HEIGHT =     200
MYSCREEN_DEPTH  =     8
MYSCREEN_BARHEIGHT =  11
#-----------------------------------------------------------------------------
#*** (STARTUP:)
#*** stack:            r31        
#*** return address:   LR
#*** execbase(mapped): r0
#***
#*** (INTERNAL:)
#*** base-address:     r15
StartAdr:        

        mfspr r1,SPR_LR         #save LR to r1
        bl BaseAdr              #get the base-adr to LR
BaseAdr:        #local memory is addressed relative to this address
        mfspr r15,SPR_LR        #r15=base-adr
        stw r1,MainReturnAdr-BaseAdr(r15)       #store the return-adr

        stw r0,ExecBase-BaseAdr(r15)            #store the execbase

        
        #library = OpenLibrary(libName, version)
        #d0                    a1       d0
        #---------------------------------------
        addi r16,r0,0 #r0|0               #d0
        addi r25,r15,IntuitionName-BaseAdr #a1
        addi r0,r0,( 1<<(31-25) )|2       #input-mask: map a1&a6
        addi r1,r0,1<<(31-16)             #output-mask: map d0
        rlwinm r1,r1,0,16,31              #clear the upper halveword
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOOpenLibrary+2(r30)
        sc                                #call it
        cmpi CR0,L_32bit,r16,0
        bc BO_true,crf_eq,ERROR_NoIntuition
        stw r16,IntuitionBase-BaseAdr(r15)

        


        #library = OpenLibrary(libName, version)
        #d0                    a1       d0
        #---------------------------------------
        addi r16,r0,0 #r0 meaning 0       #d0
        addi r25,r15,GraphicsName-BaseAdr #a1
        addi r0,r0,( 1<<(31-25) )|2       #input-mask: map a1&a6
        addi r1,r0,1<<(31-16)             #output-mask: map d0
        rlwinm r1,r1,0,16,31              #clear the upper halveword
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOOpenLibrary+2(r30)
        sc                                #call it
        cmpi CR0,L_32bit,r16,0
        bc BO_true,crf_eq,ERROR_NoGraphics
        stw r16,GraphicsBase-BaseAdr(r15)

        
        

        #error = OpenDevice(devName, unitNumber, iORequest, flags)
        #d0                 a0       d0          a1         d1
        #---------------------------------------------------------
        addi r24,r15,InputName-BaseAdr  #a0
        addi r16,r0,0                   #d0
        addi r25,r15,InputIOReq-BaseAdr #a1
        addi r17,r0,0                   #d1
        addi r0,r0,( 1<<(31-24) )|( 1<<(31-25) )|2 #input-mask: map a0/a1/a6
        addi r1,r0,0                    #no output-mappings
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOOpenDevice+2(r30)
        sc
        cmpi CR0,L_32bit,r16,0  #OpenDevice returns 0 for success
        bc BO_false,crf_eq,ERROR_NoInput

        #get the Input-Base mapped
        lwz r17,InputIOReq-BaseAdr+MN_SIZE(r15)
        addi r0,r0,0
        addi r1,r0,1<<(31-17)   #map from Amiga to PPC-address space
        addi r2,r0,0    #just do the mapping
        sc
        stw r17,InputBase-BaseAdr(r15)


        #map the Title-address
        addi r16,r15,MyScreenTitle-BaseAdr
        addi r2,r0,0    #no call
        addi r0,r0,1<<(31-16) #map r16
        rlwinm r0,r0,0,16,31          #clear the upper halveword        
        addi r1,r0,0    #no address mapping to PPC-address space
        sc

        #setup the NewScreen-structure        
        addi r1,r15,MY_NewScreen-BaseAdr
        addi r0,r0,0
        sth r0,MY_ns_LeftEdge-MY_NewScreen(r1)
        addi r0,r0,0
        sth r0,MY_ns_TopEdge-MY_NewScreen(r1)
        addi r0,r0,MYSCREEN_WIDTH
        sth r0,MY_ns_Width-MY_NewScreen(r1)
        addi r0,r0,MYSCREEN_HEIGHT+MYSCREEN_BARHEIGHT
        sth r0,MY_ns_Height-MY_NewScreen(r1)
        addi r0,r0,MYSCREEN_DEPTH
        sth r0,MY_ns_Depth-MY_NewScreen(r1)
        addi r0,r0,1
        stb r0,MY_ns_DetailPen-MY_NewScreen(r1)
        addi r0,r0,1
        stb r0,MY_ns_BlockPen-MY_NewScreen(r1)
        addi r0,r0,V_SPRITES
        sth r0,MY_ns_ViewModes-MY_NewScreen(r1)
        addi r0,r0,CUSTOMSCREEN
        sth r0,MY_ns_Type-MY_NewScreen(r1)
        addi r0,r0,0
        stw r0,MY_ns_Font-MY_NewScreen(r1)
        addi r0,r0,0
        stw r16,MY_ns_DefaultTitle-MY_NewScreen(r1) #use the mapped adr
        stw r0,MY_ns_Gadgets-MY_NewScreen(r1)
        addi r0,r0,0
        stw r0,MY_ns_CustomBitmap-MY_NewScreen(r1)


        #Screen = OpenScreen( NewScreen )
        #d0                   a0
        #--------------------------------
        addi r24,r15,MY_NewScreen-BaseAdr #a1
        addi r0,r0,( 1<<(31-24) )|2   #input:map a1+a6
        addi r1,r0,1<<(31-16)         #output:map d0
        rlwinm r1,r1,0,16,31          #clear the upper halveword
        lwz r30,IntuitionBase-BaseAdr(r15)
        lwz r2,_LVOOpenScreen+2(r30)
        sc
        cmpi CR0,L_32bit,r16,0
        bc BO_true,crf_eq,ERROR_NoScreen
        stw r16,MyScreen-BaseAdr(r15)   #store our screen


        #** allocates temporary rastport for WritePixelArray8
        #** input:  r17=original Rastport
        #**         r15=Base-Address
        #** return: r16=0 if success/r16=1 if out of ChipMem
        #**         (in BOTH cases call FreePlanes to free allocated chipmem)
        #** altered: r0-r2/r16-r30
        lwz r17,MyScreen-BaseAdr(r15)
        addi r17,r17,sc_RastPort
        bl SetupTempRastport
        cmpi CR0,L_32bit,r16,0
        bc BO_false,crf_eq,ERROR_NoTmpRP
      

        #alloc the chunky buffer

        #memoryblock = AllocMem(byteSize, attributes)
        #d0                     d0        d1
        #--------------------------------------------
        addi r0,r0,2            #input:map a6
        addi r1,r0,1<<(31-16)   #output:map d0
        rlwinm r1,r1,0,16,31    #clear the upper 16 bits
        addi r16,r0,0xffff&(MYSCREEN_WIDTH*(MYSCREEN_HEIGHT+2))
        rlwinm r16,r16,0,16,31  #clear the upper 16 bits
        addis r16,r16,0xffff&((MYSCREEN_WIDTH*(MYSCREEN_HEIGHT+2))>>16)
        stw r16,ChunkyBufSize-BaseAdr(r15)
        addi r17,r0,0           #d1
        addis r17,r17,1 #clear it
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOAllocMem+2(r30)
        sc
        cmpi CR0,L_32bit,r16,0
        bc BO_true,crf_eq,ERROR_NoChunkyBuf
        stw r16,ChunkyBufAdr-BaseAdr(r15)       #store adr of chunky buffer

        ###wait for left mousebutton to be pressed###
WaitForMouse:
        
        #***work with the chunky-buffer***
        bl DoChunky

        #***display the chunky-buffer***
        
        #count = WritePixelArray8(rp,xstart,ystart,xstop,ystop,array,temprp)
        #d0                       a0 d0     d1     d2    d3    a2    a1
        #-------------------------------------------------------------------
        lwz r24,MyScreen-BaseAdr(r15)
        addi r24,r24,sc_RastPort                #a0
        addi r25,r15,TmpRastport-BaseAdr        #a1
        lwz r26,ChunkyBufAdr-BaseAdr(r15)       #a2
        addi r16,r0,0                           #d0
        addi r17,r0,0+MYSCREEN_BARHEIGHT        #d1
        addi r18,r0,MYSCREEN_WIDTH-1            #d2
        addi r19,r0,MYSCREEN_HEIGHT-1+MYSCREEN_BARHEIGHT   #d3
        addi r0,r0,(1<<(31-24))|(1<<(31-25))|(1<<(31-26))|2  #map a0/a1/a2/a6
        addi r1,r0,0
        lwz r30,GraphicsBase-BaseAdr(r15)
        lwz r2,_LVOWritePixelArray8+2(r30)
        sc


        #qualifier = PeekQualifier()
        #d0
        #---------------------------
        addi r0,r0,2    #map a6
        addi r1,r0,0    #no output-mappings
        lwz r30,InputBase-BaseAdr(r15)
        lwz r2,_LVOPeekQualifier+2(r30)
        sc

        andi. r16,r16,IEQUALIFIER_LEFTBUTTON
        bc BO_true,crf_eq,WaitForMouse
        #############################################




        #FreeMem(memoryBlock, byteSize)
        #        a1           d0
        #------------------------------
        lwz r25,ChunkyBufAdr-BaseAdr(r15)       #a1
        lwz r16,ChunkyBufSize-BaseAdr(r15)      #d0
        addi r0,r0,( 1<<(31-25) )|2             #map a1/a6
        addi r1,r0,0
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOFreeMem+2(r30)
        sc

ERROR_NoChunkyBuf:

ERROR_NoTmpRP:
        #** frees the (partially) allocated bitplanes for the temporary rastport
        #** input: r15=base-address
        #** altered: r0-r2/r16-r30
        bl FreePlanes


        #CloseScreen( Screen )
        #             a0
        #---------------------
        lwz r24,MyScreen-BaseAdr(r15)
        addi r0,r0,(1<<(31-24))|2       #map a0&a6
        addi r1,r0,0                    #output:map nothing
        lwz r30,IntuitionBase-BaseAdr(r15)   #execbase in a6
        lwz r2,_LVOCloseScreen+2(r30)   #the address to jump to
        sc
 
ERROR_NoScreen:



        #CloseDevice(iORequest)
        #            a1
        #----------------------
        addi r25,r15,InputIOReq-BaseAdr #a1
        addi r0,r0,( 1<<(31-25) )|2     #map a1&a6
        addi r1,r0,0                    #no output-mappings
        lwz r30,ExecBase-BaseAdr(r15)
        lwz r2,_LVOCloseDevice+2(r30)
        sc


ERROR_NoInput:
        
        #CloseLibrary(library)
        #             a1
        #---------------------
        lwz r25,GraphicsBase-BaseAdr(r15)
        addi r0,r0,(1<<(31-25))|2    #map a1&a6
        addi r1,r0,0    #no output-mappings
        lwz r30,ExecBase-BaseAdr(r15)   #execbase in A6
        lwz r2,_LVOCloseLibrary+2(r30)
        sc


ERROR_NoGraphics:

        #CloseLibrary(library)
        #             a1
        #---------------------
        lwz r25,IntuitionBase-BaseAdr(r15)
        addi r0,r0,(1<<(31-25))|2    #map a1&a6
        addi r1,r0,0    #no output-mappings
        lwz r30,ExecBase-BaseAdr(r15)   #execbase in A6
        lwz r2,_LVOCloseLibrary+2(r30)
        sc

ERROR_NoIntuition:

        lwz r0,MainReturnAdr-BaseAdr(r15)       #restore the return-adr
        mtspr SPR_LR,r0
        bclr BO_always,0        #RETURN 
# # # # # # # # # # # # # # # # # # # # # # #
#####Routines######

#** r16....target
#** r17....source
#** r18....size
#**altered: r16,r17,r18,r19
ByteCopy:
        addi r16,r16,-1
        addi r17,r17,-1

        ByteCopy_loop:
        cmpi CR0,L_32bit,r18,0  #copied all bytes?
        bclr BO_true,crf_eq     #then return

        addi r18,r18,-1

        lbzu r19,1(r17)
        stbu r19,1(r16)

        b ByteCopy_loop

# ; ; ; ; ; ; ; ; ;

#** allocates temporary rastport for WritePixelArray8
#** input:  r17=original Rastport
#**         r15=Base-Address
#** return: r16=0 if success/r16=1 if out of ChipMem
#**         (in BOTH cases call FreePlanes to free allocated chipmem)
#** altered: r0-r2/r16-r30
SetupTempRastport:
        mfspr r16,SPR_LR
        stwu r16,-4(r31)        #save LR onto the stack

     #1.copy the rastport structure
        #** r16....target
        #** r17....source
        #** r18....size
        #**altered: r16,r17,r18,r19
        addi r16,r15,TmpRastport-BaseAdr
        addi r18,r18,rp_SIZEOF
        bl ByteCopy
     
     #2.set Layer=NULL
        addi r16,r15,TmpRastport-BaseAdr        #r16=new rastport
        addi r17,r0,0
        stw r17,rp_Layer(r16)

     #3.setup a new Bitmap
        addi r17,r15,TmpBitmap-BaseAdr
        addi r0,r0,1<<(31-17)   #map it first
        addi r1,r0,0
        addi r2,r0,0    #no call
        sc
        stw r17,rp_BitMap(r16)

        #InitBitMap( bm, depth, width, height )
        #            a0  d0     d1     d2
        #--------------------------------------
        addi r24,r15,TmpBitmap-BaseAdr  #a0
        addi r16,r0,MYSCREEN_DEPTH      #d0
        addi r17,r0,MYSCREEN_WIDTH      #d1
        addi r18,r0,MYSCREEN_HEIGHT+MYSCREEN_BARHEIGHT     #d2
        addi r0,r0,( 1<<(31-24) )|2     #map a0&a6
        addi r1,r0,0
        lwz r30,GraphicsBase-BaseAdr(r15)
        lwz r2,_LVOInitBitMap+2(r30)
        sc

        addi r16,r15,TmpBitmap-BaseAdr #r16=new bitmap
        #__set rows=1
        addi r17,r0,1
        sth r17,bm_Rows(r16)
        #__set BytesPerRow
        addi r17,r0,(MYSCREEN_WIDTH>>3)
        sth r17,bm_BytesPerRow(r16)

     #4.allocate the bitplanes
        addi r16,r15,TmpBitmap-BaseAdr+bm_Planes-4 #point to planes-4
        addi r17,r0,MYSCREEN_DEPTH

        SetupTempRastport_allocplanes:
        cmpi CR0,L_32bit,r17,0  #all planes done?
        bc BO_true,crf_eq,SetupTempRastport_success
        addi r17,r17,-1

        stwu r16,-4(r31)        #save r16 to the stack
        stwu r17,-4(r31)        #save r17 to the stack

        #planeptr = AllocRaster( width, height )
        #d0                      d0     d1
        #---------------------------------------
        addi r16,r0,MYSCREEN_WIDTH        #d0
        addi r17,r0,MYSCREEN_HEIGHT+MYSCREEN_BARHEIGHT+2     #d1
        addi r0,r0,2    #map a6
        addi r1,r0,0    #no output-adrs
        lwz r30,GraphicsBase-BaseAdr(r15)
        lwz r2,_LVOAllocRaster+2(r30)
        sc
        ori r18,r16,0           #move the adr to r18

        lwz r17,0(r31)           #restore r17 from the stack
        lwzu r16,4(r31)         #restore r16 from the stack
        addi r31,r31,4

        stwu r18,4(r16)
        cmpi CR0,L_32bit,r18,0  #out of ChipMem?
        bc BO_false,crf_eq,SetupTempRastport_allocplanes

        ##failed! caller should free allocated planes with FreePlanes
        addi r16,r0,1           #indicate failure
        b SetupTempRastport_quit
        
        SetupTempRastport_success:
        addi r16,r0,0           #indicate success
        SetupTempRastport_quit:
        lwz r17,0(r31)   #restore LR from the stack
        addi r31,r31,4
        mtspr SPR_LR,r17
        bclr BO_always,0        #return
# ; ; ; ; ; ; ; ; ;
#** frees the (partially) allocated bitplanes for the temporary rastport
#** input: r15=base-address
#** altered: r0-r2/r16-r30
FreePlanes:

        addi r16,r15,TmpBitmap-BaseAdr+bm_Planes-4      #point to planes-4
        addi r17,r0,MYSCREEN_DEPTH

        FreePlanes_loop:
        cmpi CR0,L_32bit,r17,0  #freed all?
        bc BO_true,crf_eq,FreePlanes_done
        addi r17,r17,-1

        lwzu r24,4(r16)
        cmpi CR0,L_32bit,r24,0  #no more allocated planes?
        bc BO_true,crf_eq,FreePlanes_done

        stwu r16,-4(r31) #push to stack
        stwu r17,-4(r31) #push to stack

        #FreeRaster( p, width, height )
        #           a0  d0     d1
        addi r16,r0,MYSCREEN_WIDTH        #d0
        addi r17,r0,MYSCREEN_HEIGHT+MYSCREEN_BARHEIGHT+2     #d1
        addi r0,r0,2   #map a6 #no mapping of a0 needed
        addi r1,r0,0
        lwz r30,GraphicsBase-BaseAdr(r15)
        lwz r2,_LVOFreeRaster+2(r30)
        sc

        lwz r17,0(r31)   #pop from stack
        lwzu r16,4(r31)  #pop from stack
        addi r31,r31,4

        b FreePlanes_loop

        FreePlanes_done:
        bclr BO_always,0        #return


TmpBitmap:.zero bm_SIZEOF  #bitplanes here remain in Amiga-address space
        .align 4
TmpRastport:.zero rp_SIZEOF
        .align 4
# ; ; ; ; ; ; ; ; ;
#** does the chunky graphic
DoChunky:
        mfspr r0,SPR_LR
        stwu r0,-4(r31)         #save the return-address onto the stack
        
        ##clear the buffer        
#WritePixelArray8 clears the buffer itself
#        lwz r1,ChunkyBufSize-BaseAdr(r15)
#        addi r2,r0,0
#        lwz r3,ChunkyBufAdr-BaseAdr(r15)
#        addi r3,r3,-4
#        DoChunky_clear:
#        stwu r2,4(r3)
#        addi r1,r1,-4
#        cmpi CR0,L_32bit,r1,0
#        bc BO_false,crf_eq,DoChunky_clear


        ##do some moving graphics
        
        lwz r1,DoChunky_counter-BaseAdr(r15)
        addi r1,r1,2
        lwz r2,DoChunky_xy-BaseAdr(r15)
        cmpi CR0,L_32bit,r2,0
        bc BO_true,crf_eq,DoChunky_xmode
        
        addi r17,r0,0                   #x1        
        subfic r18,r1,MYSCREEN_HEIGHT-1 #y1
        addi r19,r0,MYSCREEN_WIDTH-1    #x2
        or r20,r1,r1                    #y2

        cmpi CR0,L_32bit,r1,MYSCREEN_HEIGHT-1
        bc BO_true,crf_lt,DoChunky_ymode_notyet
        xori r2,r2,1
        stw r2,DoChunky_xy-BaseAdr(r15)
        addi r1,r0,0    #counter to zero
        DoChunky_ymode_notyet:

        b DoChunky_set

        DoChunky_xmode:
        or r17,r1,r1                    #x1
        addi r18,r0,0                   #y1
        subfic r19,r1,MYSCREEN_WIDTH-1  #x2
        addi r20,r0,MYSCREEN_HEIGHT-1   #y2
        
        cmpi CR0,L_32bit,r1,MYSCREEN_WIDTH-1
        bc BO_true,crf_lt,DoChunky_xmode_notyet
        xori r2,r2,1
        stw r2,DoChunky_xy-BaseAdr(r15)
        addi r1,r0,0    #counter to zero
        DoChunky_xmode_notyet:
        
        DoChunky_set:
        stw r1,DoChunky_counter-BaseAdr(r15)

        lwz r16,ChunkyBufAdr-BaseAdr(r15)       #buffer
        addi r21,r0,10                          #color
        addi r22,r0,MYSCREEN_WIDTH              #buffer width
        bl DrawChunkyLine

        lwz r0,0(r31)   #restore LR from the stack
        addi r31,r31,4
        mtspr SPR_LR,r0
        bclr BO_always,0        #return
DoChunky_xy:.zero 4  #0/1
DoChunky_counter:.zero 4

# ; ; ; ; ; ; ; ;
#** r16....Chunky-Buffer
#** r17....x-start
#** r18....y-start
#** r19....x-stop
#** r20....y-stop
#** r21....color(in lower 8 bits)
#** r22....buffer width
#** altered: r16-r30
DrawChunkyLine:

        mullw r30,r18,r22      #y-offset
        add r30,r30,r17         #x-offset
        add r16,r30,r16         #r16:address of start-pixel

        addi r25,r0,1           #r25:y-stepping
        addi r26,r0,1           #r26:x-stepping

        subf. r30,r17,r19                               #x2-x1
        or r28,r30,r30                                  #r28:dx
        bc BO_false,crf_lt,DrawChunkyLine_dxpositive
        neg r30,r30
        neg r26,r26
        DrawChunkyLine_dxpositive:

        subf. r29,r18,r20                               #y2-y1
        or r27,r29,r29                                  #r27:dy
        bc BO_true,crf_gt,DrawChunkyLine_dypositive
        bc BO_false,crf_eq,DrawChunkyLine_dynegative
        cmpi CR0,L_32bit,r30,0                          #startpixel=endpixel?
        bc BO_true,crf_eq,DrawChunkyLine_onepixel
        DrawChunkyLine_dynegative:
        neg r29,r29
        neg r25,r25
        DrawChunkyLine_dypositive:

        
        cmp CR0,L_32bit,r29,r30         #abs(dy) > abs(dx) ?
        bc BO_true,crf_gt,DrawChunkyLine_ymode

        rlwinm r27,r27,8,0,31-8 #r27:dy*256
        divw r27,r27,r30        #r27:(dy*256)/abs(dx)
        addi r25,r0,0           #r25:y-offset

        add r28,r26,r28         #abs(r28):number of pixels
        DrawChunkyLine_xloop:

        srawi r29,r25,8
        addze r29,r29           #/256
        mullw r29,r29,r22       #*bufferwidth
        stbx r21,r29,r16        #set one pixel

        add r25,r25,r27         #add to y-offset

        add r16,r16,r26         #step in x-direction
        subf. r28,r26,r28       #count the pixels
        bc BO_false,crf_eq,DrawChunkyLine_xloop

        bclr BO_always,0        #return

DrawChunkyLine_onepixel:

        stb r21,0(r16)
        bclr BO_always,0        #return

DrawChunkyLine_ymode:

        rlwinm r28,r28,8,0,31-8 #r28:dx*256
        divw r28,r28,r29        #r28:(dx*256)/abs(dy)
        addi r26,r0,0           #r26:x-offset

        mullw r29,r25,r22       #r29:y-stepping*bufferwidth
        add r27,r25,r27         #abs(r27):number of pixels
        DrawChunkyLine_yloop:

        srawi r30,r26,8
        addze r30,r30           #/256
        stbx r21,r30,r16

        add r26,r28,r26         #add to x-offset

        add r16,r16,r29         #step in y-direction
        subf. r27,r25,r27
        bc BO_false,crf_eq,DrawChunkyLine_yloop

        bclr BO_always,0        #return

# # # # # # # # # # # # # # # # # # # # # # #
MainReturnAdr:.zero 4
ExecBase:.zero 4
IntuitionBase:.zero 4
GraphicsBase:.zero 4
InputBase:.zero 4
MyScreen:.zero 4

ChunkyBufAdr:.zero 4
ChunkyBufSize:.zero 4
        .align 4
                
MY_NewScreen:        
MY_ns_LeftEdge: .zero 2
MY_ns_TopEdge:  .zero 2
MY_ns_Width:    .zero 2
MY_ns_Height:   .zero 2
MY_ns_Depth:    .zero 2
MY_ns_DetailPen:.zero 1
MY_ns_BlockPen: .zero 1
MY_ns_ViewModes:.zero 2
MY_ns_Type:     .zero 2
MY_ns_Font:     .zero 4
MY_ns_DefaultTitle:.zero 4
MY_ns_Gadgets:  .zero 4
MY_ns_CustomBitmap:.zero 4
        .align 4


InputIOReq:.zero 400
        .align 4







IntuitionName:.string "intuition.library"
GraphicsName:.string "graphics.library"
InputName:.string "input.device"

MyScreenTitle:.string "PPC-Emulator Demo(LMB to quit)"
        .align 4

#-----------------------------------------------------------------------------

