  SECTION FileIOCode,CODE
  XREF    _RequesterBase  ;base variable as opened by the C application

  INCLUDE "FileIO.i"

      XDEF  _SetFileIOHandlers
_SetFileIOHandlers:
      movea.l   4(sp),a0     ;HandlerBlock
      move.l    a2,-(sp)
      lea       StartUpCode,a2
      move.l    (a0)+,(a2)+
      beq.s     n1
      lea       StartHandler,a1
      move.l    a1,-4(a0)
n1    move.l    (a0)+,(a2)+
      beq.s     n2
      lea       DIHandler,a1
      move.l    a1,-4(a0)
n2    move.l    (a0)+,(a2)+
      beq.s     n3
      lea       GadgetHandler,a1
      move.l    a1,-4(a0)
n3    move.l    (a0)+,(a2)+
      beq.s     n4
      lea       KeyHandler,a1
      move.l    a1,-4(a0)
n4    move.l    (a0),(a2)
      beq.s     n5
      lea       MMHandler,a1
      move.l    a1,(a0)
n5    movea.l   (sp)+,a2
      rts

DIHandler:
     movea.l    DICode,a0
     bra.s      handle
MMHandler:
     movea.l    MMCode,a0
     bra.s      handle
GadgetHandler:
     movea.l    GadgetCode,a0
handle:
     movem.l    d0/d2/d5/d6/d7/a2/a3/a4,-(sp)
     jsr        (a0)
     movem.l    (sp)+,d1/d2/d5/d6/d7/a2/a3/a4
     rts
StartHandler:
     movea.l    StartUpCode,a0
     bra.s      handle
KeyHandler:
     movea.l    KeyCode,a0
     bra.s      handle

      XDEF  _SetWaitPointer,__SetWaitPointer
_SetWaitPointer:
  movea.l _RequesterBase,a6
__SetWaitPointer:
  movea.l 4(sp),a0
  jmp     _LVOSetWaitPointer(a6)

      XDEF   _AutoMessage,__AutoMessage
_AutoMessage:
  movea.l _RequesterBase,a6
__AutoMessage:
  move.l  4(sp),d0
  movea.l 8(sp),a0
  jmp     _LVOAutoMessage(a6)

      XDEF   _AutoMessageLen,__AutoMessageLen
_AutoMessageLen:
  movea.l _RequesterBase,a6
__AutoMessageLen:
  move.l  4(sp),d0
  movea.l 8(sp),a0
  move.l  12(sp),d1
  jmp     _LVOAutoMessageLen(a6)

      XDEF _AutoFileMessage,__AutoFileMessage
_AutoFileMessage:
   movea.l _RequesterBase,a6
__AutoFileMessage:
   move.w  6(sp),d1
   movea.l 8(sp),a0
   jmp     _LVOAutoFileMessage(a6)

     XDEF _ResetBuffer,__ResetBuffer
_ResetBuffer:
   movea.l _RequesterBase,a6
__ResetBuffer:
   movea.l 4(sp),a0
   move.b  11(sp),d0
   jmp     _LVOResetBuffer(a6)

     XDEF _GetFileIO,__GetFileIO
_GetFileIO:
      movea.l _RequesterBase,a6
__GetFileIO:
      jmp     _LVOGetFileIO(a6)

   XDEF   _DoFileIO,__DoFileIO
_DoFileIO:
   movea.l _RequesterBase,a6
__DoFileIO:
   movea.l 4(sp),a0
   movea.l 8(sp),a1
   jmp     _LVODoFileIO(a6)

   XDEF   _DoFileIOWindow,__DoFileIOWindow
_DoFileIOWindow:
  movea.l _RequesterBase,a6
__DoFileIOWindow:
  movea.l 4(sp),a0
  movea.l 8(sp),a1
  jmp     _LVODoFileIOWindow(a6)

   XDEF   _GetFullPathname,__GetFullPathname
_GetFullPathname:
       movea.l _RequesterBase,a6
__GetFullPathname:
       movea.l 4(sp),a0
       movea.l 8(sp),a1
       jmp     _LVOGetFullPathname(a6)

     XDEF   _ReleaseFileIO,__ReleaseFileIO
_ReleaseFileIO:
       movea.l _RequesterBase,a6
__ReleaseFileIO:
       movea.l 4(sp),a1
       jmp     _LVOReleaseFileIO(a6)

     XDEF _AutoPrompt3,__AutoPrompt3
_AutoPrompt3:
  movea.l _RequesterBase,a6
__AutoPrompt3:
  movem.l a2/a3,-(sp)
  movea.l 12(sp),a1
  movea.l 16(sp),a2
  movea.l 20(sp),a3
  movea.l 24(sp),a0
  jsr     _LVOAutoPrompt3(a6)
  movem.l (sp)+,a2/a3
  rts

  XDEF _PromptUserEntry,__PromptUserEntry
_PromptUserEntry:
  movea.l  _RequesterBase,a6
__PromptUserEntry:
  move.l   a2,-(sp)
  move.l   a3,-(sp)
  movem.l  12(sp),d0/a0/a1/a2/a3
  jsr      _LVOPromptUserEntry(a6)
  movea.l  (sp)+,a3
  movea.l  (sp)+,a2
  rts

  XDEF _SetTitle,__SetTitle
_SetTitle:
  movea.l  _RequesterBase,a6
__SetTitle:
  move.l   a2,-(sp)
  move.l   a3,-(sp)
  movem.l  12(sp),a0/a1/a2/a3
  jsr      _LVOSetTitle(a6)
  movea.l  (sp)+,a3
  movea.l  (sp)+,a2
  rts

  XDEF _ResetTitle,__ResetTitle
_ResetTitle:
  movea.l  _RequesterBase,a6
__ResetTitle:
  move.l   a2,-(sp)
  move.l   a3,-(sp)
  movem.l  12(sp),a2/a3
  jsr      _LVOResetTitle(a6)
  movea.l  (sp)+,a3
  movea.l  (sp)+,a2
  rts

  XDEF _UserEntry,__UserEntry
_UserEntry:
  movea.l  _RequesterBase,a6
__UserEntry:
  move.l   a2,-(sp)
  move.l   a3,-(sp)
  movem.l  12(sp),d0/a0/a2/a3
  jsr      _LVOUserEntry(a6)
  movea.l  (sp)+,a3
  movea.l  (sp)+,a2
  rts

  XDEF _GetRawkey,__GetRawkey
_GetRawkey:
   movea.l  _RequesterBase,a6
__GetRawkey:
   move.l   a3,-(sp)
   movea.l  4(sp),a3
   jsr      _LVOGetRawkey(a6)
   movea.l  (sp)+,a3
   rts

  XDEF _DecodeRawkey,__DecodeRawkey
_DecodeRawkey:
   movea.l  _RequesterBase,a6
__DecodeRawkey:
   movea.l  4(sp),a1
   move.l   8(sp),d0
   jmp      _LVODecodeRawkey(a6)

  XDEF _TypeFilename,__TypeFilename
_TypeFilename:
   movea.l  _RequesterBase,a6
__TypeFilename:
   movea.l  4(sp),a0
   movea.l  8(sp),a1
   jmp      _LVOTypeFilename(a6)

  XDEF _ParseString,__ParseString
_ParseString:
   movea.l  _RequesterBase,a6
__ParseString:
   movea.l  4(sp),a0
   movea.l  8(sp),a1
   jmp      _LVOParseString(a6)

  SECTION fin,DATA
 
StartUpCode dc.l 0
DICode      dc.l 0
GadgetCode  dc.l 0
KeyCode     dc.l 0
MMCode      dc.l 0

