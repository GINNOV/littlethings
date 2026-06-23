---
title: "Interactive Sound in Assembly: The Real Deal"
layout: "single"
---

<p>So far, we've made things move on screen. Now, let's make some noise! The Amiga's four 8-bit sound channels, collectively named "Paula," gave it an audio capability that was light-years ahead of its time. In the last tutorial, we used C to work with the OS, but you asked for the real deal: how to do it in pure 68k assembly. Let's dive in.</p>

<h3>The Concept: OS Libraries from Assembly</h3>
<p>This program will run as a proper AmigaDOS process. To do that, we need to talk to the Amiga's libraries. In assembly, this means loading the library into memory to get its "base address," and then calling its functions by jumping to specific negative offsets from that base address. We'll open a window, draw our button, and enter a loop to wait for user input (events). When we detect a mouse click inside our button's area, we'll trigger the sound and provide some visual feedback by changing the button's color.</p>

<img src="https://placehold.co/600x350/9333ea/ddd6fe?text=Amiga+Audio+in+ASM&font=press-start-2p" alt="Illustration of an Amiga playing sound from assembly" class="w-full max-w-lg mx-auto my-8 rounded-lg shadow-lg border-2 border-gray-600" />

<h3>Preparing Your Sound Sample</h3>
<p>For this assembly version, we need a raw sound file. The hardware plays raw, 8-bit signed audio samples. We will embed this data directly into our executable.</p>
<ol class="list-decimal list-inside space-y-2 pl-4">
    <li>Find a short sound effect (`.wav` is a good starting point).</li>
    <li>Use a modern audio editor like <a href="https://www.audacityteam.org/" target="_blank" rel="noopener noreferrer">Audacity</a> to convert it. Open the sound and export it:
        <ul>
            <li>- Set the project rate to something reasonable, like 8363 Hz or 11025 Hz.</li>
            <li>- Go to `File > Export > Export Audio`.</li>
            <li>- Choose "Other uncompressed files" as the format.</li>
            <li>- Under "Header", select "RAW (header-less)".</li>
            <li>- Under "Encoding", select "Signed 8-bit PCM".</li>
        </ul>
    </li>
    <li>Save this new file as `sound.raw`. We will include it directly in our assembly code.</li>
</ol>

<h4>The Code (asm_sound_button.s):</h4>
<div class="code-block-wrapper">
    <button class="copy-code-button"><i class="far fa-copy"></i> Copy</button>
    <pre><code><span class="code-comment">;-----------------------------------------------------</span>
<span class="code-comment">;  Interactive Sound Button in 68k Assembly</span>
<span class="code-comment">;  - Opens an OS-friendly window</span>
<span class="code-comment">;  - Draws a button</span>
<span class="code-comment">;  - Plays an embedded sound on click</span>
<span class="code-comment">;-----------------------------------------------------</span>
    SECTION code,CODE
start:
;--- Open Libraries ---
    move.l  #4,a6
    lea     IntuitionName(pc),a1
    moveq   #37,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,IntuitionBase
    beq.s   .fail

    lea     GfxName(pc),a1
    move.l  #4,a6
    moveq   #37,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,GfxBase
    beq.s   .fail_intuition

;--- Open Window ---
    lea     NewWindow(pc),a0
    move.l  IntuitionBase,a6
    jsr     _LVOOpenWindow(a6)
    move.l  d0,Window
    beq.s   .fail_gfx

    move.l  Window,d0
    move.l  d0,a0
    move.l  116(a0),a1 ; a1 = RastPort
    move.l  a1,RastPort

;--- Draw Button ---
    bsr.s   draw_button_up

;--- Event Loop ---
event_loop:
    move.l  Window,d0
    move.l  108(d0),d0 ; Get signal mask
    move.l  IntuitionBase,a6
    jsr     _LVOWait(a6)

    move.l  Window,a0
    move.l  104(a0),a1 ; UserPort
    move.l  IntuitionBase,a6
    jsr     _LVOGetMsg(a6)
    move.l  d0,Message
    beq.s   event_loop      ; No message? Loop again.

    move.l  Message,a0
    move.w  20(a0),d0      ; Get message Class
    cmp.w   #$202,d0        ; IDCMP_CLOSEWINDOW
    beq.s   .quit

    cmp.w   #$401,d0        ; IDCMP_MOUSEBUTTONS
    bne.s   .reply_msg

    move.l  Message,a0
    move.w  22(a0),d0      ; Get message Code
    cmp.w   #$68,d0         ; SELECTDOWN
    beq.s   .mouse_down
    cmp.w   #$69,d0         ; SELECTUP
    beq.s   .mouse_up

.reply_msg:
    move.l  Message,a1
    move.l  IntuitionBase,a6
    jsr     _LVOReplyMsg(a6)
    bra.s   event_loop

.mouse_down:
    bsr.s   draw_button_down
    bsr.s   play_sound
    bra.s   .reply_msg

.mouse_up:
    bsr.s   draw_button_up
    bra.s   .reply_msg

.quit:
    move.l  Message,a1
    move.l  IntuitionBase,a6
    jsr     _LVOReplyMsg(a6)

;--- Cleanup ---
.fail_window:
    move.l  Window,a0
    move.l  IntuitionBase,a6
    jsr     _LVOCloseWindow(a6)
.fail_gfx:
    move.l  GfxBase,a1
    move.l  #4,a6
    jsr     _LVOCloseLibrary(a6)
.fail_intuition:
    move.l  IntuitionBase,a1
    move.l  #4,a6
    jsr     _LVOCloseLibrary(a6)
.fail:
    moveq   #0,d0
    rts

;--- Subroutine to draw button (up state) ---
draw_button_up:
    movem.l d1-d2/a1,-(sp)
    move.l  RastPort,a1
    move.l  GfxBase,a6
    move.w  #1,d0           ; Color 1
    jsr     _LVOSetAPen(a6)
    move.w  #100,d0
    move.w  #40,d1
    move.w  #220,d2
    move.w  #60,d3
    jsr     _LVORectFill(a6)
    move.w  #2,d0           ; Color 2
    jsr     _LVOSetAPen(a6)
    move.w  #140,d0
    move.w  #50,d1
    jsr     _LVOMove(a6)
    lea     button_text(pc),a0
    move.w  #10,d0
    jsr     _LVOText(a6)
    movem.l (sp)+,d1-d2/a1
    rts

;--- Subroutine to draw button (down state) ---
draw_button_down:
    movem.l d1-d2/a1,-(sp)
    move.l  RastPort,a1
    move.l  GfxBase,a6
    move.w  #2,d0           ; Color 2
    jsr     _LVOSetAPen(a6)
    move.w  #100,d0
    move.w  #40,d1
    move.w  #220,d2
    move.w  #60,d3
    jsr     _LVORectFill(a6)
    move.w  #1,d0           ; Color 1
    jsr     _LVOSetAPen(a6)
    move.w  #140,d0
    move.w  #50,d1
    jsr     _LVOMove(a6)
    lea     button_text(pc),a0
    move.w  #10,d0
    jsr     _LVOText(a6)
    movem.l (sp)+,d1-d2/a1
    rts

;--- Subroutine to play sound ---
play_sound:
    lea     $DFF000,a5
    lea     sound_data(pc),a0
    move.l  a0,$DFF0A0    ; AUD0LCH/LCL - Audio channel 0 pointer
    move.w  #sound_len,$DFF0A4 ; AUD0LEN - Length of sample in words
    move.w  #15000/8363,d0  ; Period for 8363Hz playback (adjust for your sample rate)
    move.w  d0,$DFF0A8    ; AUD0PER - Playback period
    move.w  #64,$DFF0A6     ; AUD0VOL - Max volume
    move.w  #%0000000000000001,DMACON(a5) ; Enable audio channel 0 DMA
    rts

;--- Data section ---
    SECTION data,DATA
IntuitionName: dc.b 'intuition.library',0
GfxName:       dc.b 'graphics.library',0
button_text:   dc.b 'Play Sound',0
    even
IntuitionBase: dc.l 0
GfxBase:       dc.l 0
Window:        dc.l 0
RastPort:      dc.l 0
Message:       dc.l 0

NewWindow:
    dc.w 0,0,320,100  ; Left, Top, Width, Height
    dc.w 1,2          ; DetailPen, BlockPen
    dc.l $10001203    ; IDCMP Flags
    dc.l $0007001F    ; Flags (WFLG_DRAGBAR, etc)
    dc.l 0,0          ; FirstGadget, CheckMark
    dc.l .title,.screen,0,0,0 ; Title, Screen, BitMap, Min/Max size
    dc.w 0            ; Type (custom screen)
.title: dc.b 'Sound Player',0
.screen: dc.l 0 ; Use default screen

    even
    SECTION chip,BSS_C ; Sound data must be in Chip RAM
sound_data:
    incbin  "sound.raw" ; Include your raw sound file here
sound_end:
sound_len       equ (sound_end-sound_data)/2 ; Length in words
    even

;--- Library function offsets ---
_LVOOpenLibrary equ -552
_LVOCloseLibrary equ -414
_LVOOpenWindow equ -222
_LVOCloseWindow equ -72
_LVOWait equ -468
_LVOGetMsg equ -372
_LVOReplyMsg equ -378
_LVOSetAPen equ -330
_LVOMove equ -294
_LVOText equ -342
_LVORectFill equ -318
</code></pre>
</div>

<h4>How to Compile and Run</h4>
<ol class="list-decimal list-inside space-y-2 pl-4">
    <li><strong>Save the Code:</strong> Save the assembly code into a file named `asm_sound_button.s`.</li>
    <li><strong>Prepare the Sound:</strong> Convert a sound to `sound.raw` (8-bit signed mono) and place it in the same folder.</li>
    <li><strong>Assemble:</strong> Open your Terminal and run the command: `vasm -Fhunk -o asm_sound_button asm_sound_button.s`</li>
    <li><strong>Run in Emulator:</strong> Mount the folder containing your new executable and `sound.raw`. Boot into Workbench, open the Shell, and run `asm_sound_button`.</li>
    <li><strong>See the Result:</strong> A window will appear with a button. Clicking it will animate the button and play your sound!</li>
</ol>
