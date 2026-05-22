# Level 1 - Axis Chemical - Music & SFX

This project contains the disassembled code for the Music & SFX player for the Level 1 - Axis Chemicals level.

I have added a test program that will initialise and play the level music/sfx from VSCode.
  - use the left mouse button to cycle through the music/sfx.
  
To run the test of the Music and SFX then uncomment the following lines in chem.s and build and execute this file.
;TEST_MUSIC_BUILD SET 1                 ; run a test build and cycle through music and SFX using left mouse button
;TEST_BUILD_LEVEL SET 1                 ; if enabling TEST_MUSIC_BUILD then also enable this

Just load the project into VSCode and build and run the project to hear the Level 1 music.

Future development will include more reverse engineering of the music/sfx data format and also a better test program to select the tunes/sfx from a menu.

                ; set song number below 'SOUND_TO_PLAY' for different songs/sfx
                ;   #$01 = Level 1 Music
                ;   #$02 = Level 1 Completed
                ;   #$03 = Player Live Lost
                ;   #$04 = Unknown/Unused Music
                ;   #$05 = Drip SFX
                ;   #$06 = Gas Leak
                ;   #$07 = Batarang
                ;   #$08 = Batrope
                ;   #$09 = Grenade
                ;   #$0a = Bad Guy Hit
                ;   #$0b = Splash (jack in the vat)
                ;   #$0c = Ricochet
                ;   #$0d = Explosion (grenade)

## Functions

 - Init_Player - $47fe4 or $48000
 - Stop_Playing - $48004
 - Init_SFX_1 - $48008
 - Init_SFX_2 - $4800c - Same as Init_SFX_1
 - Init_Song - $48010 - D0.l = sound number range 1 to 13
 - Init_SFX - $48014 - D0.l = sound number range 5 to 13 (used by game to play sfx with music)
 - Play_Sounds - $48018 - Called regular intervals to continue playing music/sfx (i.e. 25 frames per second in game)

