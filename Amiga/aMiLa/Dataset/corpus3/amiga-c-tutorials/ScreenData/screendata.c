/* Screen Size */
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase;
struct Screen Screen;

main()
{
	IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
	if( IntuitionBase == NULL ) exit();
  
	if(!GetScreenData(&Screen, sizeof(struct Screen), WBENCHSCREEN, NULL)) 
	{
		printf("Ekran cozunurlulugu alinamiyor\n");
		CloseLibrary( IntuitionBase );
		exit();
	}

	printf("Ekran cozunurlulugu: %d x %d\n",Screen.Width, Screen.Height);
	
	CloseLibrary( IntuitionBase );
}
