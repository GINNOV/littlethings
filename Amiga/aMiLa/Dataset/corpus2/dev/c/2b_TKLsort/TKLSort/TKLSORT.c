#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//#include <powerup/gcclib/powerup_protos.h>
/*#include <powerup/ppcproto/dos.h>
#include <powerup/ppcproto/exec.h>
*/

const char version[]="$VER: TKLSortDyn 0.4, BLABLA PRODUCT";

char Kolejn[]="blabla.xtk";
unsigned char Znaki[256];
char *Kol=Kolejn;
char *From=NULL;
char *TO=NULL;
unsigned short int Kolumna=0;
struct KaczInd
{  char *ADDR;
	unsigned short int Wlk;
};

typedef struct KaczInd TKSTR;

int Porownaj(unsigned char *s1,unsigned char *s2,unsigned short int max/*,unsigned short int b*/)
{  int war=0;
	int war2;
	int i;
	for(i=Kolumna;(war==0)&&(i<max);i++)
	{  if(Znaki[s1[i]]>Znaki[s2[i]])
			war=1;
		else
		{  if(Znaki[s1[i]]<Znaki[s2[i]])
				war=-1;
		}
	}
	if(war==0)
	{  war=strlen(s1);
		war2=strlen(s2);
		war=war-war2;
	}

	return war;
}

inline unsigned short int Min(unsigned short int a,unsigned short int b)
{  if(a<b)
		return a;
	else
		return b;
}

int ParseArgs(char *a,int kt)
{  int IL=strlen(a),b;
	b=0;
	if(IL>3)
	{ if(strncmp(a,"TO",2)==0)
		{  TO=&a[3];
			b=1;
		}
		else
		{  if(IL>5)
			{  if(strncmp(a,"FROM",4)==0)
				{  b=2;
					From=&a[5];
				}
				else
				{  if(IL>6)
					{  if(strncmp(a,"NRKOL",5)==0)
						{  b=3;
							Kolumna=atoi(&a[6]);
						}
						else
						{  if(strncmp(a,"INDEX",5)==0)
							{  b=4;
								Kol=&a[6];
							}
						}
					}
				}
			}
		}
	}
	if(b==0)
	{  switch(kt)
		{  case 0: b=5;break;
			case 1: From=a;
						b=2;
						break;
			case 2:  TO=a;
						b=1;
						break;
			default: break;
		}
	}
	return b;
}



int main(int argc,char **argv)
{  
	unsigned char *buf;
	unsigned char pomm[256];
	char pkf;
	char pamiec=0;
	unsigned short int mm;
	unsigned long int Licznik,Ile,i,j,wielplik;
	TKSTR *Indexy,bb;
	FILE *plik,*outp;
	char *Bufor1=NULL;
	pamiec=1;
	/*czytanie parametrów
     read parametrs*/
	for(i=0;(i<argc)&&ParseArgs(argv[i],i);i++);
	if(From&&TO)//Podane plik wejôciowy i wyjôciowy
	{  for(i=0;i<256;i++)
			pomm[i]=255;
		plik=fopen(Kol,"r");
		if(plik)                 //kryterium sortowania
		{  fread(pomm,1,256,plik);
			fclose(plik);
			for(i=0;i<256;i++)
				Znaki[pomm[i]]=i;
			plik=fopen(From,"r");
			if(plik)
			{  fseek(plik,0,SEEK_END);
				wielplik=ftell(plik)+1;
				Bufor1=malloc(wielplik);
				if(Bufor1)
				{  fseek(plik,0,0);
					fread(Bufor1,1,wielplik-1,plik);
					fclose(plik);
					Licznik=0;
					for(i=0;i<(wielplik-1);i++)
					{  if(Bufor1[i]=='\n')
						{  Licznik++;
							Bufor1[i]=0;
						}
					}
					if(Bufor1[wielplik-2]!='\n')
					{  Bufor1[wielplik-1]=0;
						Licznik++;
					}
					Ile=Licznik;
					if(Licznik)
					{  Indexy=malloc(sizeof(TKSTR)*Licznik);
							if(Indexy==NULL)
							pamiec=0;
						if(pamiec)
						{  Indexy[0].ADDR=&Bufor1[0];
							j=1;
							for(Licznik=0,i=2;Licznik<Ile;i++)
							{  j++;
								if(Bufor1[i]==0)
								{  Indexy[Licznik].Wlk=j;
									Licznik++;
									Indexy[Licznik].ADDR=&Bufor1[i+1];
									j=0;
								}

							}
							Indexy[Ile-1].Wlk=strlen(Indexy[Ile-1].ADDR);
							/*sortowanie*/
							
							i=Ile/2;
							while(i>0)
							{  
								do
								{  pkf=0;
									for(j=0;j<Ile-i;j++)
									{  
										mm=Min(Indexy[j].Wlk,Indexy[j+i].Wlk);
										if(Porownaj(Indexy[j].ADDR,Indexy[j+i].ADDR,mm>0)
										{  pkf=1;
											bb=Indexy[j+i];                     //zamiana
											Indexy[j+i]=Indexy[j];
											Indexy[j]=bb;
											
										}
									}
									
								}
								while(pkf);
								i=i/2;
							}
							/* Koniec sortowania
                            end sorting*/
							outp=fopen(TO,"w");
							if(outp)         //zapis caîoôci
							{  for(i=0;i<Ile;i++)
								{ 
									fprintf(outp,"%s\n",Indexy[i].ADDR);
								}
								fclose(outp);
							}
							else
								printf("Niestety nie mogë otworzyê pliku do zapisu\a\n");
                                /*Info - unfortunately I can't open file to write*/
							free(Indexy);
						}
					}
				}
				else
				{  pamiec=0;
					fclose(plik);
				}
			}
			else
				printf("Niestety nie mogë otworzyê pliku z danymi do sortowania\a\n");
                /*Info - unfortunately I can't open file to read*/
		}
		else
			printf("Niestety nie mogë otworzyê pliku z kryterium sortowania\a\n");
            /*Info - unfortunately I can't open file with info about how sorting*/
	}
	else
		printf("Niestety zîy format, powinno byê:\n %s FROM=nazwapliku TO=nazwapliku [INDEX=nazwapliku] [NRKOL=nrkolumny]\a\n",argv[0]);
        /*Info - unfortunately user use wrong parametrs*/
	if(pamiec==0)
		printf("Problem z pamiëciâ\a\n");
        /*Info - unfortunately I can some problem with memory*/
	if(Bufor1)
		free(Bufor1);
	return 0;
}

