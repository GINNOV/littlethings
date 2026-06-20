#include <stdio.h>
#include <exec/types.h>

FILE *dosya;
char c[64];

/* main */
int main()
{	
	// dosya oluştur ve yaz - create a file & write bytes
	dosya=fopen("deneme.txt", "w");
	if (dosya==NULL){
		printf("Dosya acilamadi\n"); // file not opened
		exit(TRUE);
	}
	fputs("veri", dosya);
	fclose(dosya);
	
	// dosyadan oku - read line from file
	dosya=fopen("deneme.txt","r");
	if (dosya==NULL)
	{
		printf("Dosya acılamadı"); // file not opened
		exit(TRUE);
	}
	
	
	fgets(c, 10, dosya);
	printf("deneme.txt adli dosya icine '%s' eklendi\n",c);
	fclose(dosya);
	
	return 0;
}