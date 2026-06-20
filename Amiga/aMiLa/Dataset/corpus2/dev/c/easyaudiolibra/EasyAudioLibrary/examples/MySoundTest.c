/* Include some important header files: */
#include <exec/types.h> /* Declares CPTR, BOOL and STRPTR. */
#include <easyaudio/easyaudio.h>  /* Declares LEFT0, LEFT1, RIGHT0, etc. */
/* Sound channels: */
#define LEFT0         0
#define RIGHT0        1
#define RIGHT1        2
#define LEFT1         3

#define NONSTOP       0 /* Play the sound over and over... */
#define ONCE          1 /* Play the sound once. */ 
#define MAXVOLUME    64 /* Maximum volume. */
#define MINVOLUME     0 /* Minimum volume. */
#define NORMALRATE    0 /* Normal rate. */
#define DO_NOT_WAIT   0 /* Do not wait for the sound to be completed. */ 
#define WAIT          1 /* Wait for the sound to be completed. */

/* Sound priorities: */
#define SOUND_PRI_UNSTOPPABLE  (BYTE)127
#define SOUND_PRI_EMERGENCIES  (BYTE)95
#define SOUND_PRI_ATTENTION    (BYTE)85
#define SOUND_PRI_SPEECH       (BYTE)75
#define SOUND_PRI_INFORMATION  (BYTE)60
#define SOUND_PRI_MUSIC        (BYTE)0
#define SOUND_PRI_EFFECT       (BYTE)-35
#define SOUND_PRI_BACKGROUND   (BYTE)-90
#define SOUND_PRI_SILENCE      (BYTE)-128


/* Pointer to the sound effect */
struct SoundInfo *fire;
/*struct SoundInfo *explosion;
struct SoundInfo *background;
*/
/* Declare the functions in this module: */
void main();
void free_memory( STRPTR message );


void main(void)
{
  EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
    printf("\nEasyaudio.library opening failed\n");
    exit(20);
   }

  printf("Library opening WORKED\n");

  printf("1. Prepare the sound Fire.snd\n");
  fire = EA_PrepareSound("flash:Fire.snd");
  if( !fire )
    free_memory( "Could not prepare the sound effect!" );

  /*
  printf("   Prepare the sound Explosion.snd\n");
  explosion = EA_PrepareSound( "Explosion.snd" );
  if( !explosion )
    free_memory( "Could not prepare the sound effect!" );


  printf("   Prepare the sound Background.snd\n");
  background = EA_PrepareSound( "Background.snd" );
  if( !background )
    free_memory( "Could not prepare the sound effect!" );
  */


  printf("2. Play the sound\n");

  /*
  EA_PlaySound( background, MAXVOLUME/2, LEFT0, SOUND_PRI_EFFECT,
               NORMALRATE, NONSTOP, 0, 0, DO_NOT_WAIT );

  EA_PlaySound( background, MAXVOLUME/2, RIGHT0, SOUND_PRI_EFFECT,
               NORMALRATE, NONSTOP, 0, 0, DO_NOT_WAIT  );


  Delay( 4 * 50 );
  */

  EA_PlaySound( fire, MAXVOLUME, LEFT1, SOUND_PRI_EFFECT,
               NORMALRATE, 2, 0, 0, DO_NOT_WAIT  );


  /*Delay( 3 * 50 );

  EA_PlaySound( explosion, MAXVOLUME, RIGHT1,SOUND_PRI_EFFECT,
               NORMALRATE, 2, 0, 0, DO_NOT_WAIT  );


  Delay( 4 * 50 );
  */


  printf("3. Stop the audio channels\n");
  EA_StopSound( LEFT0 );
  EA_StopSound( LEFT1 );
  EA_StopSound( RIGHT0 );
  EA_StopSound( RIGHT1 );


  printf("4. Remove the sound effects\n");
  free_memory( "THE END" );

  CloseLibrary((APTR) EasyaudioBase);
  exit(20);
}


void free_memory( STRPTR message )
{
  printf("%s\n\n", message );

  /* It is not dangerous to try to remove a sound that has not been    */
  /* prepared. We can therefore try to remove all sounds, even if some */
  /* have not been initialized. However, all channels that are playing */
  /* the sound must have been stopped before you may remove the sound! */
  EA_RemoveSound( fire );
  //EA_RemoveSound( explosion );
  //EA_RemoveSound( background );
}

