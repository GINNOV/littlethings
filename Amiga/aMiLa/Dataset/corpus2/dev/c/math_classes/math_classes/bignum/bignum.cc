
#include <iostream.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include "bignum.h"


//***********************************************************
//		Minnesallokering
//-----------------------------------------------------------
//	Denna rutin allokerar minne genom att anropa
// malloc i stdlib.h med den storlek talet skall ha. Om
// malloc returnerar att något gick snett (t.ex minnesbrist)
// så skrivs ett felmeddelande ut och körningen avslutas.
// Går allt som det ska så returneras en pekare till det 
// allokerade minnesområdet.
//***********************************************************

char * Malloc(size_t size)
	{
	char * a;
	if(size == 0) return 0;
	a=(char *)malloc(size);
	if(a==0)
		{
		printf("Out of memory.\n");
		exit(1);
		}
	return a;
	}


//***********************************************************
//		Reallokering av minne
//-----------------------------------------------------------
//	Denna rutin kopierar minnesinnehållet fran en
// tidigare allokerat område till en annat område i minnet.
// Den använder sig av realloc rutinen i stdlib.h, och
// används nar man behöver mer plats utan att forstöra det 
// ursprungliga innehållet.
//***********************************************************

char * Realloc(char *ptr,size_t size)
	{
	char * a;
	a=(char *)realloc((void *)ptr,size);
	if(a==0 && size !=0)
		{
		printf("Out of memory.\n");
		exit(1);
		}
	return a;
	}
	

//***********************************************************
//		Konstruktorer och destruktor
//-----------------------------------------------------------
//	Konstruktorerna fungerar så att, argumentet de
// anropas med styr hur det stora talet konstrueras. Först
// har vi konstruktorn för ett tomt tal det får längden 1 och
// värdet 0. Därefter har vi destruktorn för stora tal som
// anropar "free" i stdlib.h. Sedan är det konstruktorer för
// stora tal som skapas från heltal, andra stora tal (används
// vid kopiering, return och liknande) och stora tal som
// skapas från strängar. Talets egenskaper är en pekare till
// den första siffran i talet, talets längd och talets
// tecken.
//***********************************************************

Bignum::Bignum()
	{
	length=1;
	digits=Malloc(1);
	digits[0]=0;
	negative=false;
	}
	
Bignum::~Bignum()
	{
	free(digits);
	}
	
Bignum::Bignum(int a)
	{
	int i=0;
	if (a<0)
		{
		negative=true;
		a=-a;
		}
	else
		{
		negative = false;
		}
	length=(CHAR_BIT*sizeof(int)+1)/3;
	digits=Malloc(length);
	for(i=length-1;i>=0;i--)
		{
		digits[i]=a%10;
		a/=10;
		}
	
	normalize();
	}
	
Bignum::Bignum(double b)
	{
	double a=b;
	int i=0;
	if (a<0)
		{
		negative=true;
		a=-a;
		}
	else
		{
		negative = false;
		}
	if(a==0)
		{
		length=1;
		digits=Malloc(1);
		digits[0]=0;
		return;
		}
	length=int(log10(a)+1);
	digits=Malloc(length);
	for(i=length-1;i>=0;i--)
		{
		digits[i]=(int)fmod(a,10.0);
		a/=10.0;
		}
	normalize();
	}
	
Bignum::Bignum(const Bignum& b)
	{
	negative=b.negative;
	length=b.length;
	if(length>0)
		{
		digits=Malloc(length);
		memcpy(digits,b.digits,length);
		}
	else
		{
		digits=Malloc(1);
		length=1;
		}
		
	}
	
	
Bignum::Bignum(char *s)
	{
	int i,t,m;
	t=strlen(s);
	if(t==0)
		{
		digits=Malloc(1);
		digits[0]=0;
		return;
		}
	digits=Malloc(t);
	length=t;
	negative=false;
	if(s[0]=='-')
		{
		negative=true;
		m=1;
		digits[0]=0;
		}
	else
		{
		m=0;
		}
	for(i=m;i<t;i++)
		{
		if(s[i]>='0' && s[i]<='9')
			{
			digits[i]=s[i]-'0';
			}
		else
			{
			length=i;
			digits=Realloc(digits,i);
			break;
			}
		}
	normalize();	
	}


//***********************************************************
// Operatorer för omvandling av ett Bignum till en int eller double.
// Om Bignum är för stor för att kunna representeras i den givna
// typen skrivs ett felmeddelande ut och programmet avslutas.
//***********************************************************

Bignum::operator int()
	{
	int a;
	int i;
	if ((*this > Bignum(INT_MAX)) || (*this < Bignum(INT_MIN)))
		{
		printf("Overflow\n");
		exit(1);
		}		
	a=0;
	for(i=0;i<length;i++)
		{
		a*=10;
		a=a+digits[i];
		}
	if(negative) a=-a;
	return a;
	}
	
Bignum::operator double()
	{
	double a;
	int i;
	if (abs(*this) > DBL_MAX)
		{
		printf("Overflow\n");
		exit(1);
		}		
	a=0.0;
	for(i=0;i<length;i++)
		{
		a*=10.0;
		a=a+digits[i];
		}
	if(negative) a=-a;
	return a;
	}

//************************************************************
//		Tilldelningsoperatorn
//------------------------------------------------------------
//	Tilldelningsoperatorn tar ett bignum som argument,
// ser till att det allokeras minne för ett nytt tal med samma
// längd som argumentet, att talet får samma tecken och längd
// som argumentet och kopierar sedan argumentets siffror till
// det nya talet. Själva kopieringen sköts med standardfunktionen
// memcpy.
//************************************************************

Bignum& Bignum::operator=(const Bignum& b)
	{
	free(digits);
	negative=b.negative;
	length=b.length;
	if(length>0)
		{
		digits=Malloc(length);
		memcpy(digits,b.digits,length);
		}
	else
		{
		digits=0;
		length=0;
		}
	return *this;
	}


//************************************************************
//		Jämförelseoperatorer (likhet/olikhet)
//------------------------------------------------------------
//	Dessa två operatorer kollar om två tal ar lika/olika.
// Först jämför rutinen talens tecken. Är dessa lika
// fortsätter den att kolla talens längd. Är dessa lika jämfor
// rutinen talen siffra for siffra och hoppar ut så snart 
// olikhet har påträffats.
//************************************************************

int operator==(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative != b2.negative) return 0;
	if(b1.length==b2.length)
		{
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]!=b2.digits[i]) return 0;
			}
		return 1;
		}
	else
		return 0;
	}

int operator!=(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative!=b2.negative) return 1;
	if(b1.length==b2.length)
		{
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]!=b2.digits[i]) return 1;
			}
		return 0;
		}
	else
		return 1;
	}


//************************************************************
//		Jämforelseoperatorer (större än/mindre än)
//------------------------------------------------------------
//	Med hjälp av dessa rutiner kan man kolla om ett tal är
// större än, mindre än ,större än eller lika med eller mindre
// än eller lika med ett annat tal. Rutinerna tar två tal som
// argument och bärjar med att kolla tecken. Därefter jämförs
// (om nödvandigt) talens längder, och är aven dessa lika
// jämfors talen siffra for siffra.
//************************************************************

int operator<(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative == true && b2.negative==false) return 1;
	if(b1.negative == false && b2.negative== true) return 0;
	if(b1.negative == true && b2.negative == true)
		{
		if(b1.length > b2.length) return 1;
		if(b1.length < b2.length) return 0;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]>b2.digits[i]) return 1;
			if(b1.digits[i]<b2.digits[i]) return 0;
			}
		return 0;
		}
	else  // Båda talen > 0
		{
		if(b1.length > b2.length) return 0;
		if(b1.length < b2.length) return 1;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]>b2.digits[i]) return 0;
			if(b1.digits[i]<b2.digits[i]) return 1;
			}
		return 0;
		}
	}

int operator>(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative == true && b2.negative==false) return 0;
	if(b1.negative == false && b2.negative== true) return 1;
	if(b1.negative == true && b2.negative == true)
		{
		if(b1.length > b2.length) return 0;
		if(b1.length < b2.length) return 1;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]>b2.digits[i]) return 0;
			if(b1.digits[i]<b2.digits[i]) return 1;
			}
		return 0;
		}
	else  // Båda talen > 0
		{
		if(b1.length > b2.length) return 1;
		if(b1.length < b2.length) return 0;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]<b2.digits[i]) return 0;
			if(b1.digits[i]>b2.digits[i]) return 1;
			}
		return 0;
		}
	}

int operator>=(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative == true && b2.negative==false) return 0;
	if(b1.negative == false && b2.negative== true) return 1;
	if(b1.negative == true && b2.negative == true)
		{
		if(b1.length > b2.length) return 0;
		if(b1.length < b2.length) return 1;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]>b2.digits[i]) return 0;
			if(b1.digits[i]<b2.digits[i]) return 1;
			}
		return 1;
		}
	else  // Båda talen > 0
		{
		if(b1.length > b2.length) return 1;
		if(b1.length < b2.length) return 0;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]<b2.digits[i]) return 0;
			if(b1.digits[i]>b2.digits[i]) return 1;
			}
		return 1;
		}
	}

int operator<=(const Bignum& b1,const Bignum& b2)
	{
	int i;
	if(b1.negative == true && b2.negative==false) return 1;
	if(b1.negative == false && b2.negative== true) return 0;
	if(b1.negative == true && b2.negative == true)
		{
		if(b1.length > b2.length) return 1;
		if(b1.length < b2.length) return 0;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]<b2.digits[i]) return 0;
			if(b1.digits[i]>b2.digits[i]) return 1;
			}
		return 1;
		}
	else  // Båda talen > 0
		{
		if(b1.length > b2.length) return 0;
		if(b1.length < b2.length) return 1;
		for(i=0;i<b1.length;i++)
			{
			if(b1.digits[i]>b2.digits[i]) return 0;
			if(b1.digits[i]<b2.digits[i]) return 1;
			}
		return 1;
		}
	}


//*************************************************************
//		+=, -=, *= och /= operatorerna
//-------------------------------------------------------------
//	Dessa operatorer tar ett bignum som argument, skapar
// ett tal, a, anropar lämplig operator (+, -, * eller /), skriver
// över och returnerar objektet den anropades för.
//*************************************************************

Bignum& Bignum::operator+=(const Bignum& b)
	{
	Bignum a;
	a= *this + b;
	*this = a;
	return *this;
	}
	
Bignum& Bignum::operator-=(const Bignum& b)
	{
	Bignum a;
	a= *this - b;
	*this = a;
	return *this;	
	}

Bignum& Bignum::operator*=(const Bignum& b)
	{
	Bignum a;
	a= *this * b;
	*this = a;
	return *this;
	}
	
Bignum& Bignum::operator/=(const Bignum& b)
	{
	Bignum a;
	a= *this / b;
	*this = a;
	return *this;
	}


//*************************************************************
//		Operatorn plus
//-------------------------------------------------------------
//	Operatorn plus anvands för att addera två stora tal.
// Den anropas med två bignum som argument, och returnerar ett
// bignum som resultat. Först hanterar man argumentens tecken
// eftersom grundalgoritmen bara hanterar positiva tal.
// Därefter jämfors talen för att avgöra vilket som är störst,
// och ett tal av typen bignum med längden (längden av det
// längsta talet + 1) allokeras som resultat. Själva
// additionsalgoritmen går till så att man adderar de stora
// talen siffra för siffra och kollar om det blir någon
// carrysiffra, som skall föras over till nästa position i
// talet. När additionen är klar anropas rutinen normalize för
// att skala av eventuella nollor i början på talet.
//************************************************************

Bignum operator+(const Bignum& b1,const Bignum& b2)
	{
	int i,t;
	int maxl,minl;
	const Bignum *max,*min;
	Bignum a;
	if(b1.negative && b2.negative) return -(-b1 + -b2);
	if(b1.negative && !b2.negative) return b2 - (-b1);
	if(!b1.negative && b2.negative) return b1- (-b2);
	if(b1 > b2)
		{
		max= &b1;
		min= &b2;
		}
	else
		{
		max= &b2;
		min= &b1;
		}
	maxl=max->length;
	minl=min->length;
	a.digits=Malloc(maxl+1);
	for(i=0;i<=maxl;i++) a.digits[i]=0;
	a.length=maxl+1;
	for(i=1;i<=minl;i++)
		{
		t=max->digits[maxl-i]+min->digits[minl-i]+a.digits[maxl+1-i];
		a.digits[maxl+1-i]=t%10;
		a.digits[maxl-i]=t/10;
		}
	for(i=minl+1;i<=maxl;i++)
		{
		t=max->digits[maxl-i]+a.digits[maxl+1-i];
		a.digits[maxl+1-i]=t%10;
		a.digits[maxl-i]=t/10;
		}
	a.normalize();
	return a;		
	}


//************************************************************
//		Operatorn binärt minus
//------------------------------------------------------------
//	Operatorn minus subtraherar ett stort tal från ett
// annat. Den anropas med två bignum som argument och ger ett
// bignum som resultat. Först hanteras eventuella
// minustecken i argumenten eftersom grundalgoritmen
// bara hanterar positiva tal. Sedan jämfor rutinen de två
// talen för att avgöra vilket av dem som är störst.
// Algoritmen kräver nämligen att resultatet >= 0.
// Algoritmen är den gamla vanliga, man går igenom talen siffra
// för siffra , entalen först sedan tiotalen osv. Om den övre
// siffran minus den undre blir negativt lånar man från närmast
// högre siffra.
//************************************************************

Bignum operator-(const Bignum& b1,const Bignum& b2)
	{
	int i,t,m;
	int maxl,minl;
	const Bignum *max,*min;
	Bignum a;
	if(b1.negative && b2.negative) return -b2 - -b1;
	if(b1.negative && !b2.negative) return -(-b1 +b2);
	if(!b1.negative && b2.negative) return b1 + -b2;
	if(b1 > b2)
		{
		max= &b1;
		min= &b2;
		a.negative=false;
		}
	else
		{
		max= &b2;
		min= &b1;
		a.negative=true;
		}
	
	maxl=max->length;
	minl=min->length;
	a.digits=Malloc(maxl);
	a.length=maxl;
	for(i=0;i<maxl;i++)a.digits[i]=0;
	m=0;
	for(i=1;i<=minl;i++)
		{
		t=max->digits[maxl-i]-min->digits[minl-i]-m;
		if(t < 0)
			{
			t=t+10;
			m=1;	
			}		
		else
			{
			m=0;		
			}
		a.digits[maxl-i]=t;
		}
	for(i=minl+1;i<=maxl;i++)
		{
		t=max->digits[maxl-i]-m;
		if(t < 0)
			{
			t=t+10;
			m=1;	
			}		
		else
			{
			m=0;		
			}
		a.digits[maxl-i]=t;
		}
	a.normalize();
	return a;
	}


//************************************************************
//		Operatorn unärt minus
//------------------------------------------------------------
//	Operatorn unärt minus tar ett bignum som argument och
// byter tecken på det, och returnerar det.
//************************************************************
	
Bignum operator-(const Bignum& b)
	{
	Bignum a(b);
	if(a.negative)	
		a.negative=false;
	else
		a.negative=true;
	
	return a;
	}
		

//***********************************************************
//		Operatorn gånger
//-----------------------------------------------------------
//	Operatorn gånger tar två bignum som argument och ger
// tillbaka ett bignum som resultat. Först hanteras
// eventuella minustecken i argumenten, eftersom
// grundalgoritmen bara hanterar positiva operander. Sedan
// jämför man vilket av talen som är störst och allokerar
// ett tal som har lika många siffror som de två argumenten
// tillsammans (resultatet) och ett tal som har en siffra mer
// än det största talet (temporär variabel).
// Själva multiplikationsalgoritmen går till så att man 
// multiplicerar en siffra i det mindre talet med hela det
// större talet och lagrar resultatet i en temporär vektor
// som förskjuts ett antal steg åt höger lika med antalet siffror
// i det mindre talet som redan är färdigbehandlade och
// adderas  sedan till resultatet. Sedan tar man nästa
// siffra i det minsta talet och multiplicerar med hela det
// största talet o.s.v.
//***********************************************************

Bignum operator*(const Bignum& b1,const Bignum& b2)
	{
	int i,j,t,m,mult;
	int maxl,minl;
	const Bignum *max,*min;
	Bignum a;
	char *tmp;
	if(b1.negative && b2.negative) return -b1 * -b2;
	if(b1.negative && !b2.negative) return -b1 * b2;
	if(!b1.negative && b2.negative) return b1 * -b2;
	
	if(b1 > b2)
		{
		max = &b1;
		min = &b2;
		}
	else
		{
		max = &b2;
		min = &b1;
		}
	maxl = max->length;
	minl = min->length;
	
	a.digits=Malloc(maxl+minl);
	for(i=0;i<maxl+minl;i++) a.digits[i]=0;
	a.length=maxl+minl;
	tmp=Malloc(maxl+1);
	
	for(i=1;i<=minl;i++)
		{
		mult=min->digits[minl-i];
		t=0;m=0;
		for(j=1;j<=maxl;j++)
			{
			t=mult*max->digits[maxl-j]+m;
			m=t/10;
			tmp[maxl+1-j]=t%10;
			tmp[maxl-j]=m;
			}
		t=0;m=0;
		for(j=0;j<=maxl;j++)
			{
			t=tmp[maxl-j]+a.digits[maxl+minl-i-j]+m;
			m=t/10;
			a.digits[maxl+minl-i-j]=t%10;
			}
		}	
	a.normalize();
	free(tmp);
	return a;
	}


Bignum operator/(const Bignum& b1,const Bignum& b2)
	{
	Bignum a,b,c;
	int i,t;
	if(b1.negative && b2.negative) return -b1 / -b2;
	if(b1.negative && !b2.negative) return -b1 / b2;
	if(!b1.negative && b2.negative) return b1 / -b2;
	if(b1 < b2) return 0;
	if(b1==b2) return 1;
	if(b2==1) return b1;
	a.digits=Malloc(b1.length);
	a.length=b1.length;
	b=0;
	for(i=0;i<b1.length;i++)
		{	
		b*=10;
		b=b+b1.digits[i];
		if(b>=b2)
			{
			c=b2;
			t=0;
			while(c<=b)
				{
				c+=b2;
				t++;
				}
			a.digits[i]=t;
			b=b-t*b2;
			}
		else
			{
			a.digits[i]=0;
			}
		}
	a.normalize();
	return a;
	}
	
	
	
	
	
	


//***********************************************************
//		Normaliseringsrutinen
//-----------------------------------------------------------
//	Normaliserings rutinen skalar bort alla nollor i
// början på talet. Först kollar man om talet är längre an
// en siffra. (Är talet noll skall nollan finnas kvar.)
// Sedan kör vi igenom talet tills vi hittar ett nollskillt
// element. Därefter kopierar rutinen de kvarvarande
// elementen till en vektor av rätt storlek.
//***********************************************************

void Bignum::normalize()
	{
	int i,j;
	for(i=0;i<length-1;i++)
		{
		if(digits[i]!=0)
			{
			break;
			}
		}
	if(i==length-1)
		{
		if(digits[length-1]==0)
			{
			digits=Realloc(digits,1);
			digits[0]=0;
			negative=false; // Inga negativa nollor, tack.
			length=1;
			return;
			}
		}
	if(i==0) return;
	for(j=i;j<length;j++)
		{
		digits[j-i]=digits[j];
		}
	digits=Realloc(digits,length-i);
	length=length-i;
	}
	

//***********************************************************
//		Utskriftsrutinen
//-----------------------------------------------------------
//	Utskriftsrutinen tar ett stort tal som argument och
// skriver ut det. Det kollar om det skall skrivas ut ett 
// minustecken, och sedan skriver rutinen ut siffrorna som
// ASCII-tecken, d.v.s. den lägger till ASCII-koden för '0'
// till siffran.
//***********************************************************
	
void print(const Bignum& a)
	{
	int i;
	if(a.negative) putchar('-');
	for(i=0;i<a.length;i++)
		putchar(a.digits[i]+'0');
	}


//***********************************************************
// abs() returnerar absolutbeloppet av sitt argument	
//***********************************************************
Bignum abs(Bignum a)
	{
	if(a < 0)
		return -a;
	else
		return a;
	}
	
	
	
	
	
	