void FloydSteinbergTexture(UBYTE *oldptr,void *newptr,UWORD large,UWORD high,ULONG oldformat,ULONG newformat)
{

/* This function come from Alain Thellier - Paris - France - 2008 */
/* oldformat=W3D_R8G8B8,W3D_A8R8G8B8,W3D_R8G8B8A8			*/
/* newformat=W3D_A4R4G4B4,W3D_A1R5G5B5,W3D_R5G6B5,W3D_CHUNKY	*/

#define XLOOP(nbre) for(x=0;x<nbre;x++)
#define YLOOP(nbre) for(y=0;y<nbre;y++)
#define   VAR(var) printf(" " #var "=%ld\n",var);
#define SWAP(x,y) {temp=x;x=y;y=temp;}

ULONG x,y,n;
float Rerror,Gerror,Berror,Aerror;			/* the famous error				*/
float Rrounding,Grounding,Brounding,Arounding;	/* Help to choose the nearer value		*/
UWORD Rold,Gold,Bold,Aold;				/* value as 5/6bits or 1bits (alpha)	*/
ULONG Rbits,Gbits,Bbits,Abits;
ULONG Rpos,Gpos,Bpos,Apos;
ULONG Rlostbits,Glostbits,Blostbits,Alostbits;
ULONG Rnew,Gnew,Bnew,Anew;
ULONG newbpp,oldbpp;
ULONG shifting[4];
float *RGBf;		/* Current pixel value including previous errors*/
float *A;		   	/* Neighbors pixels */
float *B;
float *C;
float *D;
float *E;
float Af,Bf,Cf,Df,Ef;	/* Floyd Steinberg coefs to apply to error for each 'neighbors' */
float *ptf;			/* float array to store errors 			*/
UBYTE *oldpixel;		/* Current old 24/32 bits pixel (=in)		*/
UWORD *new16=newptr;	/* Current new 8/16  bits pixel (=out)		*/
UBYTE *new8 =newptr;
UBYTE temp;

/*	Floyd Steinberg algo error diffusion :
 *	+------+------+------+
 *	| E    |curr. | A	   |
 *	| 0/16 |Pixel | 7/16 |
 *	| error|RGBf  | error|
 *	+------+------+------+
 *	| B	 | C	  | D	   |
 *	| 3/16 | 5/16 | 1/16 |
 *	| error| error| error|
 *	+------+------+------+
*/

REM(FloydSteinbergTexture)
REM( set parameters )
	switch (newformat)
	{
	case W3D_A4R4G4B4:
		Abits=4;	Rbits=4;	Gbits=4;	Bbits=4;
		Apos=12;	Rpos=8;	Gpos= 4;	Bpos= 0;
		newbpp=16/8;
		break;
	case W3D_A1R5G5B5:
		Abits=1;	Rbits=5;	Gbits=5;	Bbits=5;
		Apos=15;	Rpos=10;	Gpos= 5;	Bpos= 0;
		newbpp=16/8;
		break;
	case W3D_R5G6B5:
		Abits=0;	Rbits=5;	Gbits=6;	Bbits=5;
		Apos= 0;	Rpos=11;	Gpos= 5;	Bpos= 0;
		newbpp=16/8;
		break;
	case W3D_CHUNKY:
		Abits=0;	Rbits=3;	Gbits=3;	Bbits=2;
		Apos= 0;	Rpos=5;	Gpos= 2;	Bpos= 0;
		newbpp=8/8;
		break;

	default:
		return;
	}

	switch (oldformat)
	{
	case W3D_R8G8B8:
		oldbpp=24/8;break;
	case W3D_A8R8G8B8:
		oldbpp=32/8;break;
	case W3D_R8G8B8A8:
		oldbpp=32/8;break;
	default:
		return;
	}
REM( lostbits is a part that the newformat wont handle )
	Rlostbits=8-Rbits;
	Glostbits=8-Gbits;
	Blostbits=8-Bbits;
	Alostbits=8-Abits;
	Rrounding=(1<<Rlostbits)/2.0;
	Grounding=(1<<Glostbits)/2.0;
	Brounding=(1<<Blostbits)/2.0;
	Arounding=(1<<Alostbits)/2.0;

REM(allocate a float buffer to store 'errors' )
	ptf= (float *)malloc(high*large*3*sizeof(float));
REM( clean it )
	XLOOP(high*large*3)
		ptf[x]=0.0;
/*
REM( display all parameters )
	VAR(oldptr)
	VAR(oldformat)
	VAR(oldbpp)

	VAR(newptr)
	VAR(newformat)
	VAR(newbpp)

	VAR(Abits)
	VAR(Rbits)
	VAR(Gbits)
	VAR(Bbits)
	VAR(Apos)
	VAR(Rpos)
	VAR(Gpos)
	VAR(Bpos)
	VAR(Alostbits)
	VAR(Rlostbits)
	VAR(Glostbits)
	VAR(Blostbits)
	VAR((ULONG)Arounding)
	VAR((ULONG)Rrounding)
	VAR((ULONG)Grounding)
	VAR((ULONG)Brounding)
*/

REM( process all texture )
	YLOOP(high)
	XLOOP(large)
	{
/* printf("XY  %d %d \n",x,y); */
REM( Get current pixel a serpentine way: left to right then right to left)
	if(y&1)
		n=y*large+((large-1)-x);
	else	
		n=y*large+x;

REM( Get current pixel and error )
	oldpixel=&oldptr[n*oldbpp];
	RGBf	=&ptf[n*3];

REM( current color value as integers )
	if(oldformat==W3D_R8G8B8)	{Rold=oldpixel[0]; Gold=oldpixel[1]; Bold=oldpixel[2]; Aold=255;		}
	if(oldformat==W3D_R8G8B8A8)	{Rold=oldpixel[0]; Gold=oldpixel[1]; Bold=oldpixel[2]; Aold=oldpixel[3];}
	if(oldformat==W3D_A8R8G8B8)	{Rold=oldpixel[1]; Gold=oldpixel[2]; Bold=oldpixel[3]; Aold=oldpixel[0];}

REM( add total of previous errors to the current RGB value and round it to the nearer value)
	RGBf[0]=RGBf[0]+Rold+Rrounding;
	RGBf[1]=RGBf[1]+Gold+Grounding; 
	RGBf[2]=RGBf[2]+Bold+Brounding;	

REM( store color in integers and manage overflow)
    	Rold=RGBf[0];
	Gold=RGBf[1];
	Bold=RGBf[2];
	if(RGBf[0]>255.0)	Rold=255;	
	if(RGBf[1]>255.0)	Gold=255;	
	if(RGBf[2]>255.0)	Bold=255;	
	if(RGBf[0]<0.0)	Rold=0;	
	if(RGBf[1]<0.0)	Gold=0;	
	if(RGBf[2]<0.0)	Bold=0;

REM( current 'new' color value )
	Rnew=((Rold&255)>>Rlostbits);
	Gnew=((Gold&255)>>Glostbits);
	Bnew=((Bold&255)>>Blostbits);
	Anew=((Aold&255)>>Alostbits);

REM( store to new pixel )
	if(newbpp==2)
		new16[n]=(Anew<<Apos) + (Rnew<<Rpos) + (Gnew<<Gpos) + (Bnew<<Bpos);
	if(newbpp==1)
		new8[n] =(Anew<<Apos) + (Rnew<<Rpos) + (Gnew<<Gpos) + (Bnew<<Bpos);

REM( error part = what cant be stored in the 'new' pixel)
	Rerror= Rold - (Rnew<<Rlostbits);
	Gerror= Gold - (Gnew<<Glostbits);
	Berror= Bold - (Bnew<<Blostbits);

REM( Rounding is not a real part of the error ==> remove rounding)
	Rerror= Rerror - Rrounding;
	Gerror= Gerror - Grounding;
	Berror= Berror - Brounding;

REM( obtain the five currents 'neighbors'  )
	A=RGBf+3;
	E=RGBf-3;
	B=RGBf+3*large-3;
	C=RGBf+3*large+0;
	D=RGBf+3*large+3;

REM( keep 'neighbors' inside the texture )
	if(x==(large-1))
		{
		A=E;	REM( x=large-1 avoid  to set the 'neighbor' on current pixel RGBf )
		D=C;
		}
	if(x==0)
		{
		E=A;	REM( x=0 avoid  to set the 'neighbor' on current pixel RGBf )
		B=C;
		}
	if(y==(high-1))
		{
		B=E;
		C=A;		REM(y=high-1  avoid  to set the 'neighbor' on current pixel RGBf )
		D=A;
		}

REM( Floyd Steinberg coefs to apply to error for each 'neighbors' )
	if(y&1)		
	{
REM( change coefs for odd/even lines = serpentine method )
	Af=0.0/16.0;
	Bf=1.0/16.0;
	Cf=5.0/16.0;
	Df=3.0/16.0;
	Ef=7.0/16.0;
	}	
	else
	{
	Af=7.0/16.0;
	Bf=3.0/16.0;
	Cf=5.0/16.0;
	Df=1.0/16.0;
	Ef=0.0/16.0;	
	}

REM( add error to 'neighbors'  )

	A[0]=A[0]+Rerror*Af;
	A[1]=A[1]+Gerror*Af;
	A[2]=A[2]+Berror*Af;

	B[0]=B[0]+Rerror*Bf;
	B[1]=B[1]+Gerror*Bf;
	B[2]=B[2]+Berror*Bf;

	C[0]=C[0]+Rerror*Cf;
	C[1]=C[1]+Gerror*Cf;
	C[2]=C[2]+Berror*Cf;

	D[0]=D[0]+Rerror*Df;
	D[1]=D[1]+Gerror*Df;
	D[2]=D[2]+Berror*Df;

	E[0]=E[0]+Rerror*Ef;
	E[1]=E[1]+Gerror*Ef;
	E[2]=E[2]+Berror*Ef;

/*
VAR(ptf)
VAR(RGBf)
VAR(A)
VAR(B)
VAR(C)
VAR(D)
VAR(E)
*/
	}	REM( end of loop )

free(ptf);

#if defined(__AROS__) && (AROS_BIG_ENDIAN == 0)
	if(newbpp==2)
	YLOOP(high)
	XLOOP(large)
	{
	SWAP(new8[0],new8[1]); new8+=2;
	}

#endif

}
