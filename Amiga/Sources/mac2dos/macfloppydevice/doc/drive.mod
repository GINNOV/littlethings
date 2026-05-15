
	CCS Mac drive modifications

		June 18, 1988


Theory of Operation

The overall idea is to be able to control the motor lead without
actually deselecting the drive.  Normally, the motor can only be
changed by first deselecting the drive, setting the desired motor
state, then reselecting the drive.  Drive selection logic inside the
drive prevents data transfer while the drive is deselected. 
Therefore, attempts at motor speed control using this technique
resulted in "holes" being chopped out of the data stream.

The modification makes it possible to control the motor state
without deselecting the drive, allowing motor speed control during
data transfer.  The idea is to define a "Macintosh" mode, which
allows the drive motor to follow changes in the motor lead without
deselecting the drive.  This permits motor speed control during data
transfer with no lost data.  The standard floppy device driver has
no knowledge of Macintosh mode, so the drive responds normally to
the standard drive commands.

Given the few signals available to control the drive, and the use of
these signals, the only viable choice for indicating Macintosh mode
is the STEP_ signal.  Amiga interface specifications define that
this signal should be pulsed to step the heads.  The documentation
further states that this signal should not be set to 0 when the
drive is initially selected.  Therefore, the standard driver always
sets this lead to 1 (logic 0) before selecting the drive.  This lead
is later pulsed (0-1) to step the heads, but its normal condition is
1.  This makes it possible to use this lead to control Macintosh
mode.  Tests show that the drive seems to ignore the condition of
the step lead when selected.  In any case, the Mac mode program can
verify the track and step to the proper track if necessary.

The idea is to latch the state of the STEP_ lead when the motor is
turned on.  When FF1 (the motor latch) turns on at the beginning of
a disk operation, FF2 latches the state of the STEP_ lead.  Note
that there is no direct method to clear this mode, but that is okay.
The motor is still enabled by the motor latch, and can be turned OFF
while it is in Macintosh mode.  But leaving the Mac mode FF latched
on while the drive is inactive is not a problem, since the motor
latch is not enabled during this time anyway, and the motor is off. 
When the drive is selected again and the motor is turned on, the Mac
mode FF will latch Mac mode at that time.

The available interface chips have one "spare" NAND gate and one
"spare" D flipflop.  The D flop is used to latch "Macintosh" mode. 
The spare gate then gates the motor signal depending on the state of
the flop.
