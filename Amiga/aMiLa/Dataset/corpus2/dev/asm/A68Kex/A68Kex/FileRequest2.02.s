****************************************************************************
*    FileRequest V2.02                     by   Fabrice LIENHARDT          *
*    Written in january 1990                    7, rue de Leicester        *
*                                               67000 STRASBOURG (France)  *
*    (This is Public Domain)                                               *
*    100% assembler - Written with Hisoft's DEVPAC Assembler V2.12         *
****************************************************************************

A68k    set 1        set 1 for A68k else set 0
devpac  set 0        set 1 for devpac else set 0
module  set 1        set 1 for module 0 for program
NULL    EQU 0

        ifne A68k
        include "FileRequest.i"
        endif

        ifne devpac
        opt a+,d+,o+                    :PC Modus, labels, optimise instr.

        incdir  ":include/"             :Load include files
        include exec/exec_lib.i
        include intuition/intuition.i
        include intuition/intuition_lib.i
        include graphics/graphics_lib.i
        include libraries/dos_lib.i
        include libraries/dos.i
        include libraries/filehandler.i
        include libraries/dosextens.i
        endif

        XDEF _Request

_Request
        ifne module
        movem.l d3-d7/a1-a6,-(a7)
        moveq   #0,d5
        suba.l  a5,a5
        movem.l d0-d2/a0,-(a7)
        endif

***************************
*   PATCH

        clr.l   folddiskname

*   END OF PATCH
***************************

        lea     intname,a1
        CALLEXEC OldOpenLibrary         :Open Intuition
        tst.l   d0
        beq     int_error               :quit if error
        move.l  d0,_IntuitionBase

        lea     grafname,a1
        CALLEXEC OldOpenLibrary         :Open Graphics
        tst.l   d0
        beq     gfx_error               :quit if error
        move.l  d0,_GfxBase

        lea.l   dosname,a1
        CALLEXEC OldOpenLibrary         :Open Dos
        tst.l   d0
        beq     dos_error               :quit if error
        move.l  d0,_DOSBase

        move.l #$10000,d1               :clear all reserved memory
        move.l #4832,d0                 :ram with 32*151 characters
        CALLEXEC AllocMem               :allocate memory for buffer (oblig.!)
        tst.l d0
        beq mem_error                   :if error, quit
        move.l d0,filebuffer

****************************************************************************
*-------------------------- CALLING _FileRequest routine -------------------
*
* a0,d0=_FileRequest (Outputhandle, xpos, ypos, windowtitle)
*                          d0        d1    d2        a0
*
        ifne  module
        movem.l (a7)+,d0-d2/a0
        endif
        ifeq  module
        clr.l d0                        :Workbench screen
        move.l #160,d1
        move.l #18,d2
        lea.l a00NewWindowName1,a0
        endif
        bsr _FileRequest                :and call routine FileRequest
*
*
* Result in a0. (a0 is the pointer of drawername/filename)
* Result in d0 too for including this routine in C programms
* Example: (a0)= "DF0:devs/printers/epson"
****************************************************************************

        ifne    module
        move.l  d0,d5
        movea.l a0,a5
        endif

        move.l filebuffer,a1
        move.l #4832,d0
        CALLEXEC FreeMem                :free memory for file buffer
mem_error:
        move.l _DOSBase,a1
        CALLEXEC CloseLibrary           :Close dos library
dos_error:
        move.l  _GfxBase,a1
        CALLEXEC CloseLibrary           :Close gfx library
gfx_error:
        move.l  _IntuitionBase,a1
        CALLEXEC CloseLibrary           :Close int library
int_error:

        ifne   module
        move.l   d5,d0
        movea.l  a5,a0
        movem.l  (a7)+,d3-d7/a1-a6
        endif

        rts

***************************************************************************
* FileRequest -------------------------------------------------------------
***************************************************************************

_FileRequest:
        move.l d0,a00scrp               :move outputhandle in structure
        move.l a0,a00wdnm               :window name
        lea.l a00NewWindowStructure1,a0
        move.w d1,(a0)+                 :x coord to window
        move.w d2,(a0)                  :y coord to window
        sub.l #2,a0
        CALLINT OpenWindow              :and open Window
        move.l d0,filewinhd             :save the handle

        move.l d0,a0
        move.l wd_RPort(a0),fRport      :Determine RastPort
        move.l wd_UserPort(a0),fUport   :Determine UserPort

        lea.l fdevDF0,a0
        add.l #3,a0
        tst.b (a0)                      :test if df0 is present
        bne fnodevicetest               :(if deviceflags are positionned)
        bsr fdevstat                    :if not, test all hardware devices

fnodevicetest:
        lea.l fdevDF0,a5                :Read all device flags
        addq #3,a5
        tst.b (a5)                      :test if DF0 is present
        bne fdf0exists
        lea.l a00Gadget1,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdf0exists:
        addq #4,a5
        tst.b (a5)                      :test if DF1 is present
        bne fdf1exists
        lea.l a00Gadget12,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdf1exists:
        addq #4,a5
        tst.b (a5)                      :test if DF2 is present
        bne fdf2exists
        lea.l a00Gadget13,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdf2exists:
        addq #4,a5
        tst.b (a5)                      :test if DF3 is present
        bne fdf3exists
        lea.l a00Gadget14,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdf3exists:
        addq #4,a5
        tst.b (a5)                      :test if DH0 is present
        bne fdh0exists
        lea.l a00Gadget15,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdh0exists:
        addq #4,a5
        tst.b (a5)                      :test if DH1 is present
        bne fdh1exists
        lea.l a00Gadget16,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fdh1exists:
        addq #4,a5
        tst.b (a5)                      :test if JH0 is present
        bne fjh0exists
        lea.l a00Gadget17,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fjh0exists:
        addq #4,a5
        tst.b (a5)                      :test if VD0 is present
        bne fvd0exists
        lea.l a00Gadget18,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
fvd0exists:
        addq #4,a5
        tst.b (a5)                      :test if RAM is present
        bne framexists
        lea.l a00Gadget22,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget
framexists:
        addq #4,a5
        tst.b (a5)                      :test if RAD is present
        bne fstartprocess
        lea.l a00Gadget23,a0
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT OffGadget               :if not disable the gadget

fstartprocess:
        bsr frefreshdrawer              :refresh the drawer gadget
        bsr freset                      :Unlock/clr filenames&name/init mover
        move.b #0,flaglock              :lock not opened
        move.l #fdrawer,d1              :adress of drawer
        move.l #$fffffffe,d2            :read mode
        CALLDOS Lock                    :Lock
        tst.l d0
        beq flockerr                    :If error print error message
        move.b #1,flaglock              :lock now activated (no error)
        move.l d0,lockhd

        move.l lockhd,d1
        move.l #fileinfo,d2             :buffer = fileinfo
        CALLDOS Examine                 :Examine disk name
        tst.l d0                        :error?
        beq flockerr                    :if yes print error message

        move.b #0,flagdiskremoved       :drawer has changed, no diskremove
        lea.l fileinfo,a0
        addq #8,a0
        lea.l folddiskname,a1
ftestifsamedisk:
        move.b (a0)+,d0                 :test if disk inserted is known
        cmp.b (a1),d0
        bne fnosamedisk                 :compare Oldname = Newname
        tst.b (a1)+
        bne ftestifsamedisk
        tst.b flagreadaborted           :last reading was aborted?
        bne frestartreading             :if yes, restart reading disk
        bra fprintonly                  :if not print filenames without reading

fnosamedisk:
        subq #1,a0
fcopyNewinOldname:
        move.b (a0)+,(a1)               :if not same diskname,copy Newname
        tst.b (a1)+                     :in Oldname (save it)
        bne fcopyNewinOldname
frestartreading:
        move.b #0,flaglect              :reading possible = new disk
        move.b #0,d                     :number of directories = 0
        move.b #0,f                     :number of filenames = 0
        bra fprocess                    :and begin operations

flockerr:
        bsr funlock                     :close lock if possible
        bsr ftestdrawerremoved          :test if disk removed
        bne fnodskindrv                 :if removed print 'No disk...'
        lea.l fileerror3,a0             :else prepare 'Bad drawer'
        bra fbaddrv
fnodskindrv:
        lea.l fileerror1,a0             :prepare 'No disk in drive'
fbaddrv:
        move.b #$ff,flagdiskremoved     :set flag
        lea.l filename,a1
        moveq #4,d0
fcopyerr1:
        move.l (a0)+,(a1)+              :copy message error in filename
        subq #1,d0
        bne fcopyerr1
        bsr frefreshfile                :and print it out on screen
        move.b #1,flaglect              :set flag

fprocess:
        move.l fUport,a0
        CALLEXEC GetMsg                 :read message in MessagePort
        tst.l d0
        beq fnomessage                  :if no message continue
        move.l d0,a1
        move.l im_Class(a1),d4
        move.l im_Code(a1),d5
        move.l im_IAddress(a1),a4       :if message, prepare it
        CALLEXEC ReplyMsg               :and Reply
        bra freadgadget                 :read the message

fnomessage:
        tst.b flaglect                  :reading directory ?
        bne fnoread

        move.l lockhd,d1
        move.l #fileinfo+2,d2
        CALLDOS ExNext                  :if yes continue to read
        tst.l d0
        bne fnofileend                  :if no file more then fileend
fprintonly:
        move.l #0,filename
        bsr frefreshfile                :clear filename (or error msg)
        move.b #0,flagreadaborted       :reading can be aborted
        move.b d,d0
        add.b f,d0
        tst.b d0                        :test if some files are present
        bne fileend                     :ok something is present
        move.b #1,flaglect              :reading is stopped
        bsr funlock                     :Unlock if possible
        bra fprocess                    :and restart the process

fnofileend:
        move.b #$ff,flagreadaborted     :reading must not be aborted
        lea.l fileinfo+8,a0             :Begin to sort filenames
        move.b (a0),d7                  :d7,first letter of the name
        cmp.b #$5b,d7
        bcc fnomajuscule                :test if capital letter
        add.b #$20,d7                   :not case sensitive
fnomajuscule:
        tst.l fileinfo+4
        bpl filedir                     :if + then directory
        lea.l fileinfo+8,a0             :else filename
        lea.l filename,a1
        moveq #15,d0
fcopyname1:
        move.w (a0)+,(a1)+              :copy filename in buffer
        subq #1,d0
        bne fcopyname1
        bsr frefreshfile                :print name
        add.b #1,f                      :number of files +1
        moveq #1,d6                     :prepare color
        moveq #1,d1
        add.b d,d1                      :beginning of filenames = d+1
        move.b f,d2
        add.b d,d2                      :end of filenames = f+d
        bra filesavename                :and compare and stock in memory
filedir:
        lea.l fileinfo+8,a0
        lea.l filename,a1
        move.l #'(Dir',(a1)+            :if dir put first 'dir' in buffer
        move.w #') ',(a1)+
        moveq #6,d0
fcopyname2:
        move.l (a0)+,(a1)+              :now copy dir name
        subq #1,d0
        bne fcopyname2
        bsr frefreshfile
        add.b #1,d                      :number of directories +1
        moveq #3,d6                     :and prepare color
        moveq #1,d1                     :beginning of filenames = 1
        move.b d,d2                     :end of filenames = d
filesavename:
        cmp.b d1,d2                     :last filename?
        beq filemove                    :if yes the move buffer
        move.l d1,d3
        subq #1,d3
        mulu #32,d3                     :offset name (d1) in buffer
        move.l filebuffer,a0
        add.l d3,a0
        move.b (a0),d3                  :d3 = first letter name (d1)
        cmp.b #$5b,d3
        bcc filenomajuscule2            :test if Capital letter for sorting
        add.b #$20,d3                   :not case sensitive
filenomajuscule2:
        cmp.b d7,d3
        bcs filenolower                 :if not lower then continue
        bra filemove                    :else move buffer
filenolower:
        addq #1,d1
        bra filesavename                :next name and loop
filemove:
        moveq #1,d3
        add.b d,d3                      :move all names in buffer
        add.b f,d3
        mulu #32,d3
        move.l filebuffer,a0
        add.l a0,d3
        move.l d3,a3                    :a3 = (f+d+1)*32 ad end transfert
        sub.l #32,d3
        move.l d3,a2                    :a2 = a3-32 adress begin transfert
        moveq #1,d3
        add.b f,d3
        add.b d,d3
        sub.b d1,d3                     :d3 = (f+d+1-d1) nb of transferts
filetransfert:
        moveq #8,d4
filetrans:
        move.l -(a2),-(a3)              :transfert 32 octets
        subq #1,d4
        bne filetrans
        subq #1,d3
        bne filetransfert
        clr.l d3                        :prepare saving name
        move.l d1,d3
        subq #1,d3
        mulu #32,d3
        lea.l fileinfo+8,a0             :adress beginning source
        move.l filebuffer,a1
        add.l d3,a1                     :adress beginning destination
        moveq #15,d4
filecopyname:
        move.w (a0)+,(a1)+              :copy name
        subq #1,d4
        bne filecopyname
        move.b #0,(a1)+                 :move 0 at end of name
        move.b d6,(a1)                  :move color value at end name
        move.b f,d0
        add.b d,d0
        cmp.b #150,d0
        bne fprocess
fileend:
        move.b #1,flaglect
        bsr funlock                     :no more reading
        lea.l a00Gadget11,a0
        move.l filewinhd,a1
        move.l #0,a2
        moveq #5,d0
        moveq #0,d1                     :prepare all parameters for Modifyprop
        moveq #0,d2
        moveq #0,d3
        clr.l d5
        move.b f,d5
        add.b d,d5
        cmp.b #9,d5
        bcs filenogreater               :prepare prop gadget
        move.l #$ffff,d4
        divu d5,d4
        and.l #$0000ffff,d4
        mulu #8,d4                      :mover size = $ffff*8/(f+d)
        bra fileprop
filenogreater:
        move.l #$ffff,d4
fileprop:
        CALLINT ModifyProp              :modify prop gadget
        move.b #1,faffstart             :--print at first name--
        clr.l d2                        :print all file names
        move.b f,d2
        add.b d,d2                      :number of names present
        cmp.b #9,d2
        bcs fminuseight
        moveq #8,d2                     :if > 8 then = 8
fminuseight:
        move.l fRport,a0
        lea.l faffnames,a1              :initialise parameters
        moveq #0,d1
        move.l filebuffer,a3            :print 8 first names
filenamesbcle:
        moveq #25,d0
        lea.l fnames,a2
filecopynames:
        move.b (a3)+,(a2)+              :25 caracters to copy
        subq #1,d0
        bne filecopynames
        move.b #0,(a2)
        addq #6,a3
        move.b (a3)+,faffnames          :place color for dir or file
        movem.l a0-a3/d0-d2,-(sp)       :save parameters
        CALLINT PrintIText              :print file name
        movem.l (sp)+,a0-a3/d0-d2       :load parameters
        add.l #9,d1
        subq #1,d2
        bne filenamesbcle               :print all names
        bra fprocess                    :and restart process

fnoread:
        tst.b flagdiskremoved
        bne fprocess                    :if disk removed loop
        clr.l d0
        move.b f,d0
        add.b d,d0                      :number of files
        cmp.b #9,d0                     :if <8 loop
        bcs fprocess
        sub.b #8,d0                     :search mover position
        mulu fmoverp,d0
        divu #$ffff,d0
        and.l #$0000ffff,d0
        addq #1,d0                      :d0 = first name to print
        move.b faffstart,d1
        cmp.b d1,d0
        beq fprocess                    :if no modif, then loop
        bcc filescrollup                :else scroll up

        sub.b d0,d1                     :or scroll down
        move.l d1,d0
        cmp.b #4,d0                     :if <4 then scroll 1 pixel
        bcc fscrollnot1p
        moveq #9,d6
        moveq #-1,d7
        bra fscroll9p
fscrollnot1p:
        cmp.b #10,d0                    :if <10 then scroll 3 pixels
        bcc fscrollnot3p
        moveq #3,d6
        moveq #-3,d7
        bra fscroll9p
fscrollnot3p:
        moveq #1,d6                     :else if >10 scroll 9 pixels
        moveq #-9,d7
fscroll9p:
        bsr filescroll                  :scroll routine
        sub.b #1,faffstart              :affstart = affstart -1
        move.b faffstart,d0
        subq #1,d0
        move.w #17,faffpos              :print new name up
        bsr fileafterscroll             :and print it
        bra fprocess                    :loop

filescrollup:
        sub.b d1,d0
        cmp.b #4,d0                     :if <4 scroll 1 pixel
        bcc fscrollnot1
        moveq #9,d6
        moveq #1,d7
        bra fscroll9
fscrollnot1:
        cmp.b #10,d0                    :if <10 scroll 3 pixels
        bcc fscrollnot3
        moveq #3,d6
        moveq #3,d7
        bra fscroll9
fscrollnot3:
        moveq #1,d6                     :else scroll 9 pixels
        moveq #9,d7
fscroll9:
        bsr filescroll                  :scroll routine
        add.b #1,faffstart              :faffstart = faffstart +1
        move.b faffstart,d0
        addq #6,d0
        move.w #80,faffpos              :print new name down
        bsr fileafterscroll
        bra fprocess

freadgadget:
        moveq #0,d0
        move.w gg_GadgetID(a4),d0       :d0 = ID from gadget
        cmp.w #0,d0
        beq fstartprocess               :when CR in drawer string
        cmp.w #01,d0
        beq filedf0                     :Reading all gadgets
        cmp.w #02,d0
        beq filedf1
        cmp.w #03,d0
        beq filedf2
        cmp.w #04,d0
        beq filedf3
        cmp.w #05,d0
        beq filedh0
        cmp.w #06,d0
        beq filedh1
        cmp.w #07,d0
        beq filejh0
        cmp.w #08,d0
        beq filevd0
        cmp.w #09,d0
        beq fileram
        cmp.w #10,d0
        beq filerad
        cmp.w #11,d0
        beq fileparent
        cmp.w #12,d0
        beq filecancel
        cmp.w #13,d0
        beq fileok
        cmp.w #15,d0
        beq filetitre
        cmp.w #16,d0
        beq filetitre
        cmp.w #17,d0
        beq filetitre
        cmp.w #18,d0
        beq filetitre
        cmp.w #19,d0
        beq filetitre
        cmp.w #20,d0
        beq filetitre
        cmp.w #21,d0
        beq filetitre
        cmp.w #22,d0
        beq filetitre
        cmp.w #23,d0
        beq fileok
        btst #15,d4
        beq fdiskremoved
        btst #16,d4
        beq fdiskinserted
        bra fprocess

filedf0:
        lea.l fdrawer,a0
        move.l #'DF0:',(a0)+            :put new drawer in buffer (df0:)
        move.b #$00,(a0)
        bra fstartprocess
filedf1:
        lea.l fdrawer,a0
        move.l #'DF1:',(a0)+            :put new drawer in buffer (df1:)
        move.b #$00,(a0)
        bra fstartprocess
filedf2:
        lea.l fdrawer,a0
        move.l #'DF2:',(a0)+            :put new drawer in buffer (df2:)
        move.b #$00,(a0)
        bra fstartprocess
filedf3:
        lea.l fdrawer,a0
        move.l #'DF3:',(a0)+            :put new drawer in buffer (df3:)
        move.b #$00,(a0)
        bra fstartprocess
filedh0:
        lea.l fdrawer,a0
        move.l #'DH0:',(a0)+            :put new drawer in buffer (dh0:)
        move.b #$00,(a0)
        bra fstartprocess
filedh1:
        lea.l fdrawer,a0
        move.l #'DH1:',(a0)+            :put new drawer in buffer (dh1:)
        move.b #$00,(a0)
        bra fstartprocess
filejh0:
        lea.l fdrawer,a0
        move.l #'JH0:',(a0)+            :put new drawer in buffer (jh0:)
        move.b #$00,(a0)
        bra fstartprocess
filevd0:
        lea.l fdrawer,a0
        move.l #'VD0:',(a0)+            :put new drawer in buffer (vd0:)
        move.b #$00,(a0)
        bra fstartprocess
fileram:
        lea.l fdrawer,a0
        move.l #'RAM:',(a0)+            :put new drawer in buffer (ram:)
        move.b #$00,(a0)
        bra fstartprocess
filerad:
        lea.l fdrawer,a0
        move.l #'RAD:',(a0)+            :put new drawer in buffer (rad:)
        move.b #$00,(a0)
        bra fstartprocess

filecancel:
        bsr funlock                     :unlock if possible
        move.l filewinhd,a0
        CALLINT CloseWindow             :Close fileselect Window
        move.l #0,a0
***************************
* PATCH
* return cancel in d0 as well

        moveq  #0,d0

* END OF PATCH
***************************

        rts                             :and quit

fileok:
        bsr funlock                     :unlock if possible
        lea.l filename,a0               :test if filename exists
        tst.b (a0)
        beq filenoload                  :if not print "No file selected"
        cmp.l #'No f',(a0)
        beq filenoload
        cmp.l #'Bad ',(a0)              :test if filename is not an
        beq filenoload                  :error message
        cmp.l #'No d',(a0)
        beq filenoload
        move.l filewinhd,a0
        CALLINT CloseWindow             :Close filerequest Window
        lea.l fdrawer,a0
        lea.l fexitbuffer,a1
fcopyexitbuffer:
        move.b (a0)+,(a1)+              :copy drawer name in exitbuffer
        tst.b (a0)
        bne fcopyexitbuffer
******************************
*    PATCH

        cmpi.b #':',-(a0)
        beq.s  noslash

        move.b #'/',(a1)+               :"/" between drawer and filename

noslash
*
* END OF PATCH
*******************************
        lea.l filename,a0
fcopyexitbuffer2:
        move.b (a0)+,(a1)+              :copy file name in exitbuffer
        tst.b (a0)
        bne fcopyexitbuffer2
        move.b #0,(a1)
        lea.l fexitbuffer,a0            :a0 = pointer to exitbuffer and
        move.l a0,d0                    :given in d0 too for C programms
        rts                             :and quit FileRequest routine

filenoload:
        lea.l fileerror2,a0             :'No file selected'
        lea.l filename,a1
        moveq #4,d0
fcopyerr2:
        move.l (a0)+,(a1)+              :copy error msg in filename
        subq #1,d0
        bne fcopyerr2
        bsr frefreshfile                :and print it
        bra fprocess

fileparent:
        lea.l fdrawer,a0
        moveq #49,d0
fileparentex:
        cmp.b #'/',0(a0,d0)              :search an '/'
        beq fileparentexist
        cmp.b #':',0(a0,d0)              :search an ':'
        beq fileparentexist2
        subq #1,d0                      :if not found continue
        bne fileparentex                :and loop
        bra fprocess                    :if nothing loop to process
fileparentexist:
        move.b #0,0(a0,d0)               :if '/' founded, move 0
        bra fileparexit
fileparentexist2:
        addq #1,d0
        tst.b 0(a0,d0)
        beq fprocess                    :if just dfx: then do nothing
        move.b #0,0(a0,d0)               :do not delete ':'
fileparexit:
        bsr freset                      :Unlock-clr filenames&name-initmover
        bsr frefreshdrawer              :and print new drawer
        bra fstartprocess

filetitre:
        tst.b flaglect                  :test if reading directory
        beq fprocess                    :if true, ignore selection
        tst.b flagdiskremoved           :same case if disk removed
        bne fprocess
        add.b faffstart,d0              :d0 = position - 16(gadget) -1 (off)
        sub.b #16,d0                    :d0 from 0 to x
        move.b f,d1
        add.b d,d1
        cmp.b d1,d0
        bcc fprocess                    :if field not present then error
        mulu #32,d0
        move.l filebuffer,a0
        add.l d0,a0                     :adress of buffer
        move.b 31(a0),d7
        cmp.b #03,d7                    :d7 = color
        beq fileseldir                  :directory
        lea.l filename,a1               :else filename
        move.l a0,a2
filetittst:
        move.b (a1)+,d5
        cmp.b (a2),d5                   :it is present in filename?
        bne filefirst                   :if not copy it in string filename
        tst.b (a2)+
        bne filetittst
        bra fileok                      :else go to fileok
filefirst:
        moveq #15,d0
        lea.l filename,a1
filecopyfile:
        move.w (a0)+,(a1)+              :copy name in string
        subq #1,d0
        bne filecopyfile
        bsr frefreshfile                :and print name in filename string
        bra fprocess
fileseldir:
        moveq #7,d0                     :it is a directory
        lea.l fdrawer,a1
filetestend:
        tst.b (a1)+                     :search end of drawer
        bne filetestend
        subq #2,a1
        cmp.b #':',(a1)+
        beq filenewdrawer
        move.b #'/',(a1)+               :put slash
filenewdrawer:
        move.b (a0),(a1)+               :copy new drawer
        tst.b (a0)+
        bne filenewdrawer
filenewend:
        bsr freset                      :Unlock-clr titres-no oldname
        bsr frefreshdrawer              :print new drawer
        bra fstartprocess

fdiskremoved:
        tst.b flaglect
        beq fprocess                    :is no disk operation now?
        tst.b flagdiskremoved
        bne fprocess                    :is a disk removed?
        bsr funlock
        bsr ftestdrawerremoved          :Z flag if drawer is present
        beq fprocess
        lea.l fdrawer,a0
        move.b #0,4(a0)                 :cut drawer after :
        move.b #$ff,flagdiskremoved     :set flag
        bsr freset
        bsr frefreshdrawer
        bra fprocess

fdiskinserted:
        tst.b flaglect
        beq fprocess
        tst.b flagdiskremoved
        beq fprocess
        bsr ftestdrawerremoved          :Z flag if drawer is inserted
        bne fprocess
        bra fstartprocess

****************************************************************************
* Sub-Routines -------------------------------------------------------------
****************************************************************************


frefreshdrawer:
        move.w #0,fdrawp                :print starting first character
        move.l #0,a00Gadget2            :Refresh only the string gadget
        lea.l a00Gadget2,a0             :"Drawer"
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT RefreshGadgets          :Refresh it
        lea.l a00Gadget3,a0
        move.l a0,a00Gadget2            :replace the next gadget pointer
        rts

frefreshfile:
        move.w #0,ffilep                :print starting first character
        lea.l a00Gadget25,a0            :Refresh the string gadget Filename
        move.l filewinhd,a1
        move.l #0,a2
        CALLINT RefreshGadgets          :Refresh it
        rts

funlock:
        tst.b flaglock                  :Unlock possible?
        beq fnounlock                   :if not quit this sub-routine
        move.b #0,flaglock              :else clear flag
        move.l lockhd,d1
        CALLDOS UnLock                  :and unlock
fnounlock:
        rts

freset:
        bsr funlock                     :unlock before new drawer
        move.l fRport,a1
        moveq #0,d0
        CALLGRAF SetAPen                :Set color before filling area
        move.l fRport,a1
        moveq #10,d0
        move.l #17,d1
        move.l #208,d2
        move.l #87,d3
        CALLGRAF RectFill               :clear all file names
        bsr frefreshmover               :re init mover
        move.w #1,faffstart
        move.b #$0,filename             :delete old filename
        bsr frefreshfile
        rts

frefreshmover:
        lea.l a00Gadget11,a0
        move.l filewinhd,a1
        move.l #0,a2
        moveq #5,d0
        moveq #0,d1                     :replace all original parameters
        moveq #0,d2
        moveq #0,d3
        move.l #$ffff,d4
        CALLINT ModifyProp              :modify the proportionnal gadget
        rts

filescroll:
        cmpi.b #1,$dff006
        bne filescroll                  :wait sync. before scrolling
        move.l  fRport,a1               :prepare scrollraster
        move.l  #0,d0
        move.l  d7,d1
        move.l  #10,d2
        move.l  #17,d3
        move.l  #208,d4
        move.l  #87,d5
        CALLGRAF ScrollRaster           :scroll text x pixelline(s) down
        move.l d7,d1
        subq #1,d6
        bne filescroll                  :scroll 8 bits down
        move.l filebuffer,a0
        clr.l d0
        rts
fileafterscroll:
        mulu #32,d0
        add.l d0,a0                     :a0 = adress begin of new title
        lea.l fafftext,a1               :copy text for next title
        moveq #25,d0
fcopy:
        move.b (a0)+,(a1)+              :25 characters to copy
        subq #1,d0
        bne fcopy
        move.b #0,(a1)                  :copy the 0
        addq #6,a0
        move.b (a0),faffnewline         :copy the colour
        move.l fRport,a0
        lea.l faffnewline,a1
        moveq #0,d0
        moveq #0,d1
        CALLINT PrintIText              :print file name
        rts

ftestdrawerremoved:
        bsr funlock
        cmp.l #'DF0:',fdrawer
        bne fnodf0rem
        clr.l d0
        bra ftestrem
fnodf0rem:
        cmp.l #'DF1:',fdrawer
        bne fnodf1rem
        moveq #1,d0
        bra ftestrem
fnodf1rem:
        cmp.l #'DF2:',fdrawer
        bne fnodf2rem
        moveq #2,d0
        bra ftestrem
fnodf2rem:
        cmp.l #'DF3:',fdrawer
        beq fdf3rem
        sub.l d0,d0                     :Z > Not DFx or Bad drawer
        bra fexitdrawerremoved
fdf3rem:
        moveq #3,d0
ftestrem:
        clr.l d1
        lea.l fdiskio,a1
        lea.l ftrddevice,a0
        CALLEXEC OpenDevice
        lea.l fdiskio,a1
        move #$e,28(a1)
        CALLEXEC DoIO
        lea.l fdiskio,a1
        CALLEXEC CloseDevice
        lea.l fdiskio,a1
        tst.l 32(a1)
fexitdrawerremoved:
        rts

** Sub-routine that open Ram Disk and search all mounted devices **********
* (see also public domain programm: DevStatus in Fish Disk 292)

fdevstat:
        move.l #fdevactram,d1           :Open ram disk
        move.l #$fffffffe,d2            :
        CALLDOS Lock                    :
        move.l d0,d1                    :
        CALLDOS UnLock                  :ram disk is now activated

        move.l _DOSBase,a0              :Search pointer of DeviceNodes------
        move.l dl_Root(a0),a1           :search dl_Root
        move.l rn_Info(a1),d0           :search rn_Info (BPTR)
        asl.l #2,d0                     :(convert BPTR in APTR)
        move.l d0,a0                    :
        move.l di_DevInfo(a0),d0        :search di_DevInfo (BPTR)
        asl.l #2,d0                     :
        move.l d0,a5                    :save pointer of Devicenodes

fdevDLT_DEVICE:
        cmp.l #DLT_DEVICE,dn_Type(a5)   :is it a harware device?
        bne fdevdevcont

        move.l dn_Name(a5),d0
        asl.l #2,d0
        move.l d0,a0
        move.l (a0),d0
        asl.l #8,d0                     :d0 = devicename

        moveq #10,d7                    :prepare to compare with all devices
        lea.l fdevDF0,a1
fdevnextdev:
        move.l (a1),d1
        cmp.l d0,d1                     :compare name with names in table
        beq fdevrecon
        subq #1,d7
        beq fdevdevcont                 :next name if not standard name
        add.l #4,a1
        bra fdevnextdev

fdevrecon:
        add.l #3,a1
        move.b #$ff,(a1)+               :modify flag of name if founded

fdevdevcont:
        move.l dn_Next(a5),d7           :Search the next pointer
        tst.l d7
        beq fdevend                     :if no more, then end of sub-routine
        asl.l #2,d7
        move.l d7,a5
        bra fdevDLT_DEVICE              :else search other devicename

fdevend:
        rts

****************************************************************************
* Declaration of system variables and handles ------------------------------
****************************************************************************

_IntuitionBase  dc.l 0                  :Bases of libraries
_DOSBase        dc.l 0
_GfxBase        dc.l 0

intname         INTNAME                 :Name of libraries
                even
grafname        GRAFNAME
                even
dosname         DOSNAME
                even

ftrddevice      dc.b 'trackdisk.device',0
                even
fdiskio         ds.l 20

fRport          dc.l 0
fUport          dc.l 0
filewinhd       dc.l 0

filebuffer      dc.l 0
fexitbuffer     ds.l 25
folddiskname    ds.w 25

fdevDF0         dc.b 'DF0',0
fdevDF1         dc.b 'DF1',0
fdevDF2         dc.b 'DF2',0
fdevDF3         dc.b 'DF3',0
fdevDH0         dc.b 'DH0',0
fdevDH1         dc.b 'DH1',0
fdevJH0         dc.b 'JH0',0
fdevVD0         dc.b 'VD0',0
fdevRAM         dc.b 'RAM',0
fdevRAD         dc.b 'RAD',0

fdevactram      dc.b 'ram:',0
                even

lockhd          dc.l 0

                cnop 0,4
fileinfo        ds.l 260

f               dc.w 0
d               dc.w 0
faffstart       dc.w 0

flaglect        dc.w 0
flaglock        dc.w 0
flagdiskremoved dc.w 0
flagreadaborted dc.w 0

fileerror1      dc.b 'No disk in drive',0
                even
fileerror2      dc.b 'No file selected',0
                even
fileerror3      dc.b 'Bad drawer      ',0
                even

****************************************************************************
* Declaration of window and gadgets structures -----------------------------
****************************************************************************

a00NewWindowStructure1:
        dc.w    114,27  ;window XY origin relative to TopLeft of screen
        dc.w    420,107 ;window width and height
        dc.b    0,1     ;detail and block pens
        dc.l    GADGETDOWN+GADGETUP+DISKINSERTED+DISKREMOVED    ;IDCMP flags
        dc.l    WINDOWDRAG+ACTIVATE+RMBTRAP     ;other window flags
        dc.l    a00GadgetList1  ;first gadget in gadget list
        dc.l    NULL    ;custom CHECKMARK imagery
a00wdnm dc.l    a00NewWindowName1       ;window title
a00scrp dc.l    NULL    ;custom screen pointer
        dc.l    NULL    ;custom bitmap
        dc.w    5,5     ;minimum width and height
        dc.w    -1,-1   ;maximum width and height
        dc.w    WBENCHSCREEN    ;destination screen type ! Replace it with
                                ;CUSTOMSCREEN when you use your own screen
a00NewWindowName1:
        dc.b    'FileRequest V2.02 by F.Lienhardt',0
        cnop 0,2
a00GadgetList1:
a00Gadget1:
        dc.l    a00Gadget2      ;next gadget
        dc.w    251,49  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border1      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText1       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    01      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border1:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors1       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors1:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText1:
        dc.b    1,2,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText1   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText1:
        dc.b    'DF0',0
        cnop 0,2
a00Gadget2:
        dc.l    a00Gadget3      ;next gadget
        dc.w    251,31  ;origin XY of hit box relative to window TopLeft
        dc.w    153,8   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    STRGADGET       ;gadget type flags
        dc.l    a00Border2      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    a00a00Gadget2SInfo      ;SpecialInfo structure
        dc.w    0       ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00a00Gadget2SInfo:
        dc.l    fdrawer ;buffer where text will be edited
        dc.l    NULL    ;optional undo buffer
        dc.w    0       ;character position in buffer
        dc.w    50      ;maximum number of characters to allow
fdrawp  dc.w    0       ;first displayed character buffer position
        dc.w    0,0,0,0,0       ;Intuition initialized and maintained variables
        dc.l    0       ;Rastport of gadget
        dc.l    0       ;initial value for integer gadgets
        dc.l    NULL    ;alternate keymap (fill in if you set the flag)
fdrawer:
        dc.b "DF0:"
        dcb.l 12,0
        cnop 0,2
a00Border2:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors2       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors2:
        dc.w    0,0
        dc.w    154,0
        dc.w    154,9
        dc.w    0,9
        dc.w    0,0
a00Gadget3:
        dc.l    a00Gadget4      ;next gadget
        dc.w    10,16   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border3      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    15      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border3:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    1,2,RP_JAM2     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors3       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors3:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,73
        dc.w    0,73
        dc.w    0,1
a00Gadget4:
        dc.l    a00Gadget5      ;next gadget
        dc.w    10,25   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border4      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    16      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border4:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors4       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors4:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget5:
        dc.l    a00Gadget6      ;next gadget
        dc.w    10,34   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border5      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    17      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border5:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors5       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors5:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget6:
        dc.l    a00Gadget7      ;next gadget
        dc.w    10,43   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border6      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    18      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border6:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors6       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors6:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget7:
        dc.l    a00Gadget8      ;next gadget
        dc.w    10,52   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border7      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    19      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border7:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors7       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors7:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget8:
        dc.l    a00Gadget9      ;next gadget
        dc.w    10,61   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border8      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    20      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border8:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors8       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors8:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget9:
        dc.l    a00Gadget10     ;next gadget
        dc.w    10,70   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border9      ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    21      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border9:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors9       ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors9:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget10:
        dc.l    a00Gadget11     ;next gadget
        dc.w    10,79   ;origin XY of hit box relative to window TopLeft
        dc.w    200,9   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border10     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    22      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border10:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    0,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors10      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors10:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,10
        dc.w    0,10
        dc.w    0,0
a00Gadget11:
        dc.l    a00Gadget12     ;next gadget
        dc.w    218,15  ;origin XY of hit box relative to window TopLeft
        dc.w    20,74   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    NULL    ;activation flags
        dc.w    PROPGADGET      ;gadget type flags
        dc.l    a00Image1       ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    a00a00Gadget11SInfo     ;SpecialInfo structure
        dc.w    14      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00a00Gadget11SInfo:
        dc.w    AUTOKNOB+FREEVERT       ;PropInfo flags
        dc.w    0       ;horizontal and vertical pot values
fmoverp dc.w    0
        dc.w    0       ;horizontal and vertical body values
fmovers dc.w    $ffff
        dc.w    0,0,0,0,0,0     ;Intuition initialized and maintained variables
a00Image1:
        dc.w    0,0     ;XY origin relative to container TopLeft
        dc.w    12,70   ;Image width and height in pixels
        dc.w    0       ;number of bitplanes in Image
        dc.l    NULL    ;pointer to ImageData
        dc.b    $0000,$0000     ;PlanePick and PlaneOnOff
        dc.l    NULL    ;next Image structure
a00Gadget12:
        dc.l    a00Gadget13     ;next gadget
        dc.w    291,49  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border11     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText2       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    02      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border11:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,1,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors11      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors11:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText2:
        dc.b    1,0,RP_JAM2,0   ;front and back text pens, drawmode and fill byte
        dc.w    6,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText2   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText2:
        dc.b    'DF1',0
        cnop 0,2
a00Gadget13:
        dc.l    a00Gadget14     ;next gadget
        dc.w    331,49  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border12     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText3       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    03      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border12:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors12      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors12:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText3:
        dc.b    1,2,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    -3,1    ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText3   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText3:
        dc.b    ' DF2 ',0
        cnop 0,2
a00Gadget14:
        dc.l    a00Gadget15     ;next gadget
        dc.w    371,49  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border13     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText4       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    04      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border13:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors13      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors13:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText4:
        dc.b    1,0,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText4   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText4:
        dc.b    'DF3',0
        cnop 0,2
a00Gadget15:
        dc.l    a00Gadget16     ;next gadget
        dc.w    251,62  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border14     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText5       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    05      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border14:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors14      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors14:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText5:
        dc.b    1,0,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText5   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText5:
        dc.b    'DH0',0
        cnop 0,2
a00Gadget16:
        dc.l    a00Gadget17     ;next gadget
        dc.w    291,62  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border15     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText6       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    06      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border15:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors15      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors15:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText6:
        dc.b    1,0,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    6,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText6   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText6:
        dc.b    'DH1',0
        cnop 0,2
a00Gadget17:
        dc.l    a00Gadget18     ;next gadget
        dc.w    331,62  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border16     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText7       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    07      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border16:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors16      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors16:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText7:
        dc.b    1,0,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText7   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText7:
        dc.b    'JH0',0
        cnop 0,2
a00Gadget18:
        dc.l    a00Gadget19     ;next gadget
        dc.w    371,62  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border17     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText8       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    08      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border17:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors17      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors17:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText8:
        dc.b    1,3,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText8   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText8:
        dc.b    'VD0',0
        cnop 0,2
a00Gadget19:
        dc.l    a00Gadget20     ;next gadget
        dc.w    262,94  ;origin XY of hit box relative to window TopLeft
        dc.w    48,8    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border18     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText9       ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    12      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border18:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors18      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors18:
        dc.w    0,0
        dc.w    49,0
        dc.w    49,9
        dc.w    0,9
        dc.w    0,0
a00IText9:
        dc.b    2,1,RP_JAM2,0   ;front and back text pens, drawmode and fill byte
        dc.w    0,0     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText9   ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText9:
        dc.b    'Cancel',0
        cnop 0,2
a00Gadget20:
        dc.l    a00Gadget21     ;next gadget
        dc.w    346,94  ;origin XY of hit box relative to window TopLeft
        dc.w    48,8    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border19     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText10      ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    13      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border19:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors19      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors19:
        dc.w    0,0
        dc.w    49,0
        dc.w    49,9
        dc.w    0,9
        dc.w    0,0
a00IText10:
        dc.b    2,1,RP_JAM2,0   ;front and back text pens, drawmode and fill byte
        dc.w    0,0     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText10  ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText10:
        dc.b    '  Ok  ',0
        cnop 0,2
a00Gadget21:
        dc.l    a00Gadget22     ;next gadget
        dc.w    291,75  ;origin XY of hit box relative to window TopLeft
        dc.w    74,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border20     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText11      ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    11      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border20:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors20      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors20:
        dc.w    0,0
        dc.w    75,0
        dc.w    75,10
        dc.w    0,10
        dc.w    0,0
a00IText11:
        dc.b    1,0,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    13,1    ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText11  ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText11:
        dc.b    'Parent',0
        cnop 0,2
a00Gadget22:
        dc.l    a00Gadget23     ;next gadget
        dc.w    251,75  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border21     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText12      ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    09      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border21:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors21      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors21:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText12:
        dc.b    1,2,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    5,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText12  ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText12:
        dc.b    'RAM',0
        cnop 0,2
a00Gadget23:
        dc.l    a00Gadget24     ;next gadget
        dc.w    371,75  ;origin XY of hit box relative to window TopLeft
        dc.w    34,9    ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border22     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText13      ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    10      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border22:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors22      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors22:
        dc.w    0,0
        dc.w    35,0
        dc.w    35,10
        dc.w    0,10
        dc.w    0,0
a00IText13:
        dc.b    1,2,RP_JAM1,0   ;front and back text pens, drawmode and fill byte
        dc.w    6,1     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText13  ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText13:
        dc.b    'RAD',0
        cnop 0,2
a00Gadget24:
        dc.l    a00Gadget25     ;next gadget
        dc.w    283,14  ;origin XY of hit box relative to window TopLeft
        dc.w    85,8    ;hit box width and height
        dc.w    GADGHBOX+GADGHIMAGE     ;gadget flags
        dc.w    NULL    ;activation flags
        dc.w    BOOLGADGET      ;gadget type flags
        dc.l    a00Border23     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    a00IText14      ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    NULL    ;SpecialInfo structure
        dc.w    99      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00Border23:
        dc.w    -38,1   ;XY origin relative to container TopLeft
        dc.b    1,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors23      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors23:
        dc.w    0,0
        dc.w    165,0
        dc.w    165,73
        dc.w    0,73
        dc.w    0,1
a00IText14:
        dc.b    2,1,RP_JAM2,0   ;front and back text pens, drawmode and fill byte
        dc.w    6,2     ;XY origin relative to container TopLeft
        dc.l    NULL    ;font pointer or NULL for default
        dc.l    a00ITextText14  ;pointer to text
        dc.l    NULL    ;next IntuiText structure
a00ITextText14:
        dc.b    '  Drawer  ',0
        cnop 0,2
a00Gadget25:
        dc.l    NULL    ;next gadget
        dc.w    10,94   ;origin XY of hit box relative to window TopLeft
        dc.w    200,8   ;hit box width and height
        dc.w    NULL    ;gadget flags
        dc.w    RELVERIFY       ;activation flags
        dc.w    STRGADGET       ;gadget type flags
        dc.l    a00Border24     ;gadget border or image to be rendered
        dc.l    NULL    ;alternate imagery for selection
        dc.l    NULL    ;first IntuiText structure
        dc.l    NULL    ;gadget mutual-exclude long word
        dc.l    a00a00Gadget25SInfo     ;SpecialInfo structure
        dc.w    23      ;user-definable data
        dc.l    NULL    ;pointer to user-definable data
a00a00Gadget25SInfo:
        dc.l    filename
        dc.l    NULL    ;optional undo buffer
        dc.w    0       ;character position in buffer
        dc.w    30      ;maximum number of characters to allow
ffilep  dc.w    0       ;first displayed character buffer position
        dc.w    0,0,0,0,0       ;Intuition initialized and maintained variables
        dc.l    0       ;Rastport of gadget
        dc.l    0       ;initial value for integer gadgets
        dc.l    NULL    ;alternate keymap (fill in if you set the flag)
filename:
        dcb.b 32,0
        cnop 0,2
a00Border24:
        dc.w    -1,-1   ;XY origin relative to container TopLeft
        dc.b    3,0,RP_JAM1     ;front pen, back pen and drawmode
        dc.b    5       ;number of XY vectors
        dc.l    a00BorderVectors24      ;pointer to XY vectors
        dc.l    NULL    ;next border in list
a00BorderVectors24:
        dc.w    0,0
        dc.w    201,0
        dc.w    201,9
        dc.w    0,9
        dc.w    0,0

* Structure to print filenames ---------------------------------------------

faffnames       dc.b 1,1        :Colors
                dc.b 0          :Modus JAM1
                even            :parity
                dc.w 10         :pos X
                dc.w 17         :pos Y
                dc.l 0          :font
                dc.l fnames     :text
                dc.l 0          :next text
fnames          ds.l 13

* Structure to print new filename after scrolling up or down ---------------

faffnewline     dc.b 1,1        :Colors
                dc.b 0          :Modus JAM1
                even            :parity
                dc.w 10         :pos X
faffpos         dc.w 80         :pos Y
                dc.l 0          :font
                dc.l fafftext   :text
                dc.l 0          :next text
fafftext        ds.l 13
                end

