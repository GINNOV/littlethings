/* Alert message */
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase;
int main()
{
	char message[106];
	BOOL result;
	
	IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
	  
	if( IntuitionBase == NULL )
		exit();

	/*
	Dikkat: message degiskenine deger atarken ilk 3 bayt bosluk
	bu baytlar x ve y posizyonlari icin kayit tutacak
	*/
	strcpy( message, "   Amiga Alert Mesaj Ekranina Hosgeldiniz!");
	/* burada da ilk 5 bayt message icin 42-46 karakterleri */
	strcat( message, "     MLB: Tamam   MRB: Iptal Et");    

	message[0]=0;       /* ilk satirin X pozisyonu */
	message[1]=32;      /* */
	message[2]=16;      /* ilk satirin Y pozisyonu */

	message[42]='\0';   /* ilk satir sonu */
	message[43]=TRUE;   /* yeni satir icin devam */

	message[44]=0;      /* ikinci satir X pozisyonu */
	message[45]=32;     /* */
	message[46]=32;     /* ikinci satir Y pozisyonu */

	message[73]='\0';  /* ikinci satir sonu */
	message[74]=FALSE; /* ikinci satir sonrasi devam etmeyecek */

	/* Alert message ekrani goster */
	/* 48 alert kutusu icin satir yuksekligi*/
	result = DisplayAlert( RECOVERY_ALERT, message, 48 );

	if(result)
	{
		printf("Tamam: Mouse Sol tusuna basildi\n");
	}
	else
	{
		printf("Iptal Et: Mouse Sag tusuna basildi\n");
	}

	CloseLibrary( IntuitionBase );
	return 0;
}
