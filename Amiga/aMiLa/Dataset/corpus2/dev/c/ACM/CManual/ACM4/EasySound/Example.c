/*   Example.c

     EEEEE  AAA   SSS Y   Y       SSS   OOO  U   U N   N DDD
     E     A   A S     Y Y       S     O   O U   U NN  N D  D
     EEEE  AAAAA  SSS   Y   ===   SSS  O   O U   U N N N D   D
     E     A   A     S  Y            S O   O U   U N  NN D  D
     EEEEE A   A SSSS   Y        SSSS   OOO   UUU  N   N DDD


             EEEEE X   X  AAA  M   M PPPP  L     EEEEE
             E      X X  A   A MM MM P   P L     E
             EEEE    X   AAAAA M M M PPPP  L     EEEE
             E      X X  A   A M   M P     L     E
             EEEEE X   X A   A M   M P     LLLLL EEEEE


   EASY-SOUND    EXAMPLE    V2.00    1990-09-23    ANDERS BJERIN

Now at last you can easily write C programs that plays digitized
sound. You simply use four functions that will take care of all the
work of allocating memory, loading the files, opening the ports and
reserving the sound channels. Despite the simplicity you can still
decide what volume and rate, which channel, and how many times the
sound should be played. The functions contain full error checking,
and will close and return everything that have been taken.

EASY-SOUND was written by Anders Bjerin, and is distributed as
public domain with NO RIGHTS RESERVED. That means that you can do
what ever you want with the program. You may use EASY-SOUND in your
own programs, commercial or not, and do not even need to mention
that you have used it. You may alter the source code to fit your
needs, and you may spread it to anyone.

V2.00: You can now play the same sound in one or more channels at the
same time. Before you could only use one of the four channels for
each sound. Some code improvements have also been done.


I N S T R U C T I O N S

1. There are four functions that you need to use. The first one is called
PrepareSound(), and must be called before you can play the soundeffect.
You simply give it a file name as the only parameter, and it will
allocate space and load the sound file. It will also prepare some other
things that is needed before you may play the sound. If PrepareSound()
has successfully done its task, it will return a normal memory pointer
(CPTR), else it will return NULL which means something went wrong.

Synopsis: pointer = PrepareSound( filename );

pointer:  (CPTR) PrepareSound() will return a normal memory pointer if
          the sound was prepared successfully, else it will return NULL
					which means something went wrong.

filename: (STRPTR) Pointer to a string containing the name of the
          sound file.



2. After you have prepared the sound, you may play it. You do it by calling
the function PlaySound(). If the sound was played successfully, TRUE is
returned, else FALSE is returned which means something went wrong.

Synopsis: ok = PlaySound( pointer, volume, channel, drate, times );

ok:       (BOOL) If the sound was played successfully TRUE is
          returned, else FALSE.

pointer:  (CPTR) The pointer that was returned by PrepareSound().

volume:   (UWORD) Volume, 0 to 64. (MINVOLUME - MAXVOLUME)

channel:  (UBYTE) Which channel should be used. (LEFT0, RIGHT0,
          RIGHT1 or LEFT1)

drate:    (WORD) Delta rate. When the sound is prepared, the record
          rate is automatically stored in the SoundInfo structure,
          so if you do not want to change the rate, write NORMALRATE.
					However, if you want to increase/decrease the speed, you
					simply write the desired delta value.

times:    (UWORD) How many times the sound should be played. If you
          want to play the sound forever, write 0.



3. If you want to stop an audio channel you simply call the function
StopSound(). (It is not dangerous to stop a sound that has already
terminated, or has not started.)

Synopsis: StopSound( channel );

channel:  (UBYTE) Which channel should be stopped. (LEFT0, RIGHT0,
          RIGHT1 or LEFT1)



4. Before your program terminates you must call the function RemoveSound()
which will deallocate all memory that was allocated by the PrepareSound()
function. IMPORTANT! All sound channels that is currentely playing the
sound must have been stopped before this function may be called!

Synopsis: RemoveSound( pointer );

pointer:  (CPTR) The pointer that was returned by PrepareSound().



I hope you will have a lot of use of EASY-SOUND and happy programming,

Anders Bjerin

AMIGA C CLUB (ACC)
Tulevagen 22
181 41  LIDINGO
SWEDEN

*/


/* Include some important header files: */
#include "exec/types.h" /* Declares CPTR, BOOL and STRPTR. */
#include "EasySound.h"  /* Declares LEFT0, LEFT1, RIGHT0, etc. */


/* Pointers to the three sound effects: */
CPTR fire;
CPTR explosion;
CPTR background;


/* Declare the functions in this module: */
void main();
void free_memory();
void pause();


void main()
{
	printf("\nE A S Y - S O U N D\n");
	printf("Amiga C Club (ACC)\nAnders Bjerin\nTulevagen 22\n");
	printf("181 41  LIDINGO\nSWEDEN\n\n");
  printf("1. Prepare the sound Fire.snd\n");
	fire = PrepareSound( "Fire.snd" );
  if( !fire )
	  free_memory( "Could not prepare the sound effect!" );

  printf("   Prepare the sound Explosion.snd\n");
	explosion = PrepareSound( "Explosion.snd" );
  if( !explosion )
	  free_memory( "Could not prepare the sound effect!" );

  printf("   Prepare the sound Background.snd\n");
	background = PrepareSound( "Background.snd" );
  if( !background )
	  free_memory( "Could not prepare the sound effect!" );



  printf("2. Play the sound\n");

  /* Start with some atmospheric background sounds: */
  PlaySound( background, MAXVOLUME/2, LEFT0, NORMALRATE, NONSTOP );
  PlaySound( background, MAXVOLUME/2, RIGHT0, NORMALRATE, NONSTOP );
	pause( 500 );

  PlaySound( fire, MAXVOLUME, LEFT1, NORMALRATE, 2 );
  pause( 400 );

  PlaySound( explosion, MAXVOLUME, RIGHT1, NORMALRATE, 2 );
  pause( 1000 );



  printf("3. Stop the audio channels\n");
  StopSound( LEFT0 );
  StopSound( LEFT1 );
  StopSound( RIGHT0 );
  StopSound( RIGHT1 );


  printf("4. Remove the sound effects\n");
  free_memory( "THE END" );
}


void free_memory( message )
STRPTR message;
{
	printf("%s\n\n", message );

  /* It is not dangerous to try to remove a sound that has not been     */
	/* prepared. We can therefore try to remove all sounds, even if some  */
	/* have not been initialized. (However, all channels that are playing */
	/* the sound must have been stopped before you may remove the sound!  */
  RemoveSound( fire );
  RemoveSound( explosion );
  RemoveSound( background );

  exit();
}


void pause( time )
int time;
{
	int loop;
	for( loop=0; loop < time*100; loop++ )
	  ;
}
