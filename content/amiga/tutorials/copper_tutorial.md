---
title: "The Magic of the Amiga Copper"
layout: "single"
---

<p>Hey Amiga fans! Ever looked at a stunning Amiga demo or game and wondered how they pulled off those amazing color effects? You know the ones – the vibrant, multi-colored skies that seem to defy the Amiga's color limits, or a screen that's split into different color palettes? The secret, my friends, often lies in one of the Amiga's most unique and powerful hardware features: the <strong>Copper</strong>.</p>

<h3>What in the World is a Copper?</h3>
<p>In the heart of the Amiga's custom chipset lies a special co-processor called the Copper. Think of it as a tiny, dedicated graphics programmer that works alongside the main CPU. While the CPU is busy running the game's logic or your Workbench applications, the Copper is tirelessly manipulating the display hardware.</p>
<p>The Copper's job is simple but powerful: it can change the contents of the Amiga's hardware registers at very specific moments in time. This is key. It's all about timing. The Amiga generates its display by drawing the screen line by line, from top to bottom. The Copper can be programmed to "watch" for a specific screen line and, at the precise moment the video beam reaches that line, it can zap a new value into a hardware register.</p>

<h3>The Magic of Copper Lists</h3>
<p>So, how do you tell the Copper what to do? You create a <strong>Copper list</strong>, which is just a simple program for the Copper to follow. This list is a series of instructions that the Copper executes in sync with the screen drawing.</p>
<p>A Copper list is made up of just three basic instructions:</p>
<ul class="list-disc list-inside pl-4">
    <li><strong>WAIT:</strong> This tells the Copper to pause until the video beam reaches a specific horizontal and vertical position on the screen.</li>
    <li><strong>MOVE:</strong> This instruction writes a value to a specified hardware register.</li>
    <li><strong>SKIP:</strong> This tells the Copper to skip the next instruction if the video beam has already passed a certain position.</li>
</ul>
<p>By combining these simple instructions, you can create some truly <a href="copper.html">amazing</a> effects.</p>

<!-- Generated Image Inserted Here -->
<img src="https://storage.googleapis.com/context-images/image_1150499622432924976.png" alt="A photorealistic image of the Amiga's Agnus custom chip, which contains the Copper co-processor, sitting on a circuit board." class="w-full max-w-xl mx-auto my-8 rounded-lg shadow-lg border-2 border-gray-600" />

<h2>Your First Copper List: A Hands-On Tutorial</h2>
<p>Reading about it is one thing, but making it happen is where the real fun is! This tutorial will get our hands dirty with some 68k assembly to talk directly to the hardware.</p>

<h3>The Real Deal: A Two-Color Screen in Assembly</h3>
<p>This assembly program will create a screen that is white on the top half and blue on the bottom half. It's a fundamental technique that demonstrates the core Copper list concept.</p>
<h4>The Tools:</h4>
<p>You'll need an assembler. A great option for cross-compiling from your Mac is <strong>vasm</strong>. You can install it easily using Homebrew (`brew install vasm`).</p>
<h4>The Code (split_screen.asm):</h4>

<div class="code-block-wrapper">
    <button class="copy-code-button"><i class="far fa-copy"></i> Copy</button>
    <pre><code><span class="code-comment">;-----------------------------------------------------</span>
<span class="code-comment">; A simple Copper List example in 68k Assembly</span>
<span class="code-comment">; Splits the screen into two colors.</span>
<span class="code-comment">;-----------------------------------------------------</span>

CHIPMEM         equ     $000000     ; Start of Chip RAM
CUSTOM          equ     $DFF000     ; Base address of custom chips

;--- Custom Chip Registers
INTENA          equ     CUSTOM+$9A
DMACON          equ     CUSTOM+$96
COP1LCH         equ     CUSTOM+$80  ; Copper list pointer (high word)
COP1LCL         equ     CUSTOM+$82  ; Copper list pointer (low word)
COPLOC          equ     CUSTOM+$80  ; For 32-bit access
COLOR00         equ     CUSTOM+$180 ; Background color

;--- Program Start
start:
    ; --- Wait for vertical blank to safely take over ---
.waitvb
    move.l  $4,a6             ; Execbase in a6
    move.w  $DFF006,d0        ; VPOSR
    and.w   #$7F00,d0
    cmp.w   #$2C00,d0         ; Wait until end of display
    bne.s   .waitvb

    ; --- Kill the OS ---
    move.w  #$4000,INTENA(a5)   ; Disable interrupts
    move.w  #$7FFF,DMACON(a5)   ; Disable all DMA

    ; --- Set up our copper list ---
    lea     my_copper_list(pc),a0 ; Get address of our list
    move.l  a0,COPLOC(a5)       ; Point the hardware to our copper list
    move.w  #$8200,DMACON(a5)   ; Enable DMA for Copper only

    ; --- Infinite loop ---
forever:
    bra.s   forever

;--- Our Copper List ---
; It MUST be in Chip RAM, but since our whole program is tiny
; and loaded into Chip RAM, we are fine.
my_copper_list:
    ; Top half of the screen
    dc.w    COLOR00, $FFF       ; MOVE white into background color register

    ; Wait until scanline 100 ($64)
    dc.w    $6401, $FFFE        ; WAIT for vertical position 100

    ; Bottom half of the screen
    dc.w    COLOR00, $00F       ; MOVE blue into background color register

    ; End of list
    dc.w    $FFFF, $FFFE        ; Wait for an impossible position to end
</code></pre>
</div>

<h4>How to Assemble and Test It on Your Mac:</h4>
<ol class="list-decimal list-inside space-y-2 pl-4">
    <li><strong>Assemble:</strong> Open Terminal, navigate to where you saved the `.asm` file, and run the vasm command: `vasmm68k_mot -Fhunk -o split_screen split_screen.asm`</li>
    <li><strong>Set up Emulator:</strong> We'll use FS-UAE. Create a folder on your Mac (e.g., `~/Amiga/Work`). In the FS-UAE settings, go to the "Hard Drives" tab and add this folder as a hard drive. Give it a device name like `DH0` and a volume label like `Work`.</li>
    <li><strong>Run in Emulator:</strong>
        <ul class="list-disc list-inside ml-6 mt-2">
            <li>Start FS-UAE with a basic Amiga 500 config and your `Work` folder mounted. You'll likely need a Workbench disk in `DF0:` to boot from.</li>
            <li>Once Workbench loads, you'll see your `Work` drive on the desktop. Open it, and you should see your `split_screen` executable.</li>
            <li>Open the Shell or CLI from the System drawer on your Workbench disk.</li>
            <li>Type `Work:split_screen` and press Enter.</li>
        </ul>
    </li>
    <li><strong>See the result:</strong> Your emulator screen should now show the top half white and the bottom half blue! To exit, you'll need to reset the emulator (using the menu in FS-UAE or vAmiga).</li>
</ol>

<h3>AMOS to the Rescue</h3>
<p>If diving into 68k assembly seems a bit daunting, don't worry! The legendary AMOS Professional made playing with the Copper incredibly accessible. You can create a classic rainbow effect with just a few lines of code.</p>
<h4>The Code:</h4>

<div class="code-block-wrapper">
    <button class="copy-code-button"><i class="far fa-copy"></i> Copy</button>
    <pre><code>' -- Our First AMOS Copper Rainbow --

' Hide the mouse pointer and set up a screen
Curs Off
Screen Open 0, 320, 200, 16, Lowres
Palette 0, 0, 0, 0 ' Make sure background is black

' Loop through the screen lines
For Y = 0 To 199
    ' Wait for the beam to get to the start of line Y
    Cop Wait 0, Y
    
    ' Create a colour value based on the line number
    R = (Y And 15)
    G = ((Y/16) And 15)
    B = ((Y/32) And 15)
    Colour = (R * $111) + (G * $11) + B
    
    ' Move the new colour into the background colour register ($DFF180)
    Cop Move $180, Colour
Next Y

' An empty loop to keep our program running
Do
Loop
</code></pre>
</div>

<h4>How to Test It:</h4>
<ol class="list-decimal list-inside space-y-2 pl-4">
    <li><strong>Get AMOS:</strong> You can find AMOS Professional ADF (floppy disk image) files online.</li>
    <li><strong>Use an Emulator:</strong> The easiest way to run this is with a Mac-based Amiga emulator like FS-UAE or vAmiga. Set up a basic Amiga 500 configuration with at least 1MB of Chip RAM.</li>
    <li><strong>Load and Run:</strong> Insert the AMOS disk ADF into the virtual floppy drive (DF0:). Boot the emulator. Once you're in the AMOS editor, type in the code above and press F10 (or your Mac's equivalent) or click "Run" from the menu. You should see a beautiful, flowing rainbow of colours filling the screen!</li>
</ol>

<h3>Where to See the Copper in Action</h3>
<p>To truly appreciate the power of the Copper, you need to see it in action. Fire up your emulator and check out some of these classics:</p>
<ul class="list-disc list-inside space-y-2 pl-4">
    <li><strong>Shadow of the Beast:</strong> The quintessential example of Copper rainbows.</li>
    <li><strong>Turrican II:</strong> Features vast, colorful levels with smooth scrolling, all orchestrated by the Copper.</li>
    <li><strong>Agony:</strong> The stunning, ethereal backgrounds are a masterclass in Copper programming.</li>
    <li><strong>Demos from the demoscene:</strong> Groups like Phenomena, Sanity, and Spaceballs pushed the Copper to its absolute limits, creating visual effects that still impress today.</li>
</ul>
<p class="mt-4">The Copper is a testament to the forward-thinking design of the Amiga. It's a feature that gave developers a huge amount of creative freedom and is a big reason why Amiga graphics have such a unique and timeless appeal. So next time you see a beautiful gradient sky or a clever screen effect on your Amiga, you'll know that the little co-processor that could, the Copper, is hard at work.</p>
