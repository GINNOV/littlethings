#include <math.h>
#include <m68881.h>




static void FFT (float data[], LONG nn, LONG isign);
static void RealFFT (float data[], LONG n, LONG isign);
static void MyFFT (double *real_vet, double *im_vet, long n, int m, int ind, double cf);



/* Disable SAS/C floating point error handling */
void __stdargs _CXFERR(int code)
{
}

#if 0
void Filter (WORD *data, LONG len)
{
	float *fftdata;
	LONG i, nn;


	/* Calculate nearest power of 2 */
	for (i = len-1, nn = 1; i != 0; i >>= 1)
		nn <<= 1;

	if (!(fftdata = AllocVec (sizeof (float) * nn * 2, MEMF_CLEAR)))
		return;

	/* Fill array of complex numbers (imaginary part is always set to 0) */
	for (i = 0; i < len; i++)
		fftdata[i] = (float) data[i];


	/* Obtain frequency spectrum */
	RealFFT (fftdata, nn>>1, 1);

	/* Low-pass Filter */
	for (i = 0; i < nn; i++)
		fftdata[i*2] *= (i/nn) * 4;

	/* Return to time domain */
	RealFFT (fftdata, nn>>1, -1);
	for (i = 0; i < len; i++)
		fftdata[i] /= nn;

	/* Put filtered data */
	for (i = 0; i < len; i++)
		data[i] = (WORD) fftdata[i];

	FreeVec (fftdata);
}
#endif


void Filter (WORD *data, LONG len)
{
	double *fftdata;
	LONG i, nn, mm;


	/* Calculate nearest power of 2 */
	for (i = len-1, nn = 1, mm = 0; i != 0; i >>= 1)
	{
		nn <<= 1;
		mm++;
	}

	if (!(fftdata = AllocVec (sizeof (double) * nn * 2, MEMF_CLEAR)))
		return;

	/* Fill array of complex numbers (imaginary part is always set to 0) */
	for (i = 0; i < len; i++)
		fftdata[i] = (float) data[i];


	/* Obtain frequency spectrum */
	MyFFT (fftdata, fftdata + nn, nn>>1, mm, +1, 1.0/32768.0);

	/* Low-pass Filter */
//	for (i = 0; i < nn; i++)
//		fftdata[i] *= (i/nn) * 4;

	/* Return to time domain */
	MyFFT (fftdata, fftdata + nn, nn>>1, mm, -1, 1.0);

//	for (i = 0; i < len; i++)
//		fftdata[i] /= nn;

	/* Put filtered data */
	for (i = 0; i < len; i++)
		data[i] = (WORD) fftdata[i];

	FreeVec (fftdata);
}


#if 0
#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

static void FFT (float data[], LONG nn, LONG isign)
{
	int n,mmax,m,j,istep,i;
	double wtemp,wr,wpr,wpi,wi,theta;
	float tempr,tempi;

	n=nn << 1;
	j=1;
	for (i=1;i<n;i+=2)
	{
		if (j > i)
		{
			SWAP(data[j],data[i]);
			SWAP(data[j+1],data[i+1]);
		}
		m=n >> 1;
		while (m >= 2 && j > m)
		{
			j -= m;
			m >>= 1;
		}
		j += m;
	}
	mmax = 2;
	while (n > mmax)
	{
		istep=2*mmax;
		theta=6.28318530717959/(isign*mmax);
		wtemp=sin(0.5*theta);
		wpr = -2.0*wtemp*wtemp;
		wpi=sin(theta);
		wr=1.0;
		wi=0.0;
		for (m=1;m<mmax;m+=2)
		{
			for (i=m;i<=n;i+=istep)
			{
				j = i+mmax;
				tempr=wr*data[j]-wi*data[j+1];
				tempi=wr*data[j+1]+wi*data[j];
				data[j]=data[i]-tempr;
				data[j+1]=data[i+1]-tempi;
				data[i] += tempr;
				data[i+1] += tempi;
			}
			wr=(wtemp=wr)*wpr-wi*wpi+wr;
			wi=wi*wpr+wtemp*wpi+wi;
		}
		mmax=istep;
	}
}


static void RealFFT (float data[], LONG n, LONG isign)
{
	int i,i1,i2,i3,i4,n2p3;
	float c1=0.5,c2,h1r,h1i,h2r,h2i;
	double wr,wi,wpr,wpi,wtemp,theta;
	void four1();

	theta=3.141592653589793/(double) n;
	if (isign == 1)
	{
		c2 = -0.5;
		FFT (data,n,1);
	}
	else
	{
		c2=0.5;
		theta = -theta;
	}

	wtemp=sin(0.5*theta);
	wpr = -2.0*wtemp*wtemp;
	wpi=sin(theta);
	wr=1.0+wpr;
	wi=wpi;
	n2p3=2*n+3;
	for (i=2;i<=n/2;i++)
	{
		i4=1+(i3=n2p3-(i2=1+(i1=i+i-1)));
		h1r=c1*(data[i1]+data[i3]);
		h1i=c1*(data[i2]-data[i4]);
		h2r = -c2*(data[i2]+data[i4]);
		h2i=c2*(data[i1]-data[i3]);
		data[i1]=h1r+wr*h2r-wi*h2i;
		data[i2]=h1i+wr*h2i+wi*h2r;
		data[i3]=h1r-wr*h2r+wi*h2i;
		data[i4] = -h1i+wr*h2i+wi*h2r;
		wr=(wtemp=wr)*wpr-wi*wpi+wr;
		wi=wi*wpr+wtemp*wpi+wi;
	}
	if (isign == 1)
	{
		data[1] = (h1r=data[1])+data[2];
		data[2] = h1r-data[2];
	}
	else
	{
		data[1]=c1*((h1r=data[1])+data[2]);
		data[2]=c1*(h1r-data[2]);
		FFT (data,n,-1);
	}
}


#undef SWAP
#endif

static void MyFFT (double *real_vet, double *im_vet, long n, int m, int ind, double cf)
{
	long l, i, j, nbut, ngrup, nc;
	long but, grup;
	long primo, secondo;
	double w_real, w_im;
	double t_real, t_im;
	double arg;

	// Ordinamento binario del vettore
	j = 0;
	nc = n >> 1;
	for (i = 0 ; i< n-1; i++)
	{
		if (i < j)
		{
			t_real = real_vet[j];
			t_im = im_vet[j];
			real_vet[j] = real_vet[i];
			im_vet[j] = im_vet[i];
			real_vet[i] = t_real;
			im_vet[i] = t_im;
		}
		l = nc;
		while(l <= j)
		{
			j -= l;
			l >>= 1;
		}
		j+=l;
	}

	//Calcolo FFT
	for(l=0; l<m; l++)						//Ciclo esterno Log2(N)
	{
		nbut = (1L) << l;
		ngrup = nc / nbut;
		for(but = 0; but < nbut; but++)				//Ciclo medio: numero di farfalle
		{
			arg = PI * but / nbut;			// M_PI e' la costante PI Greco
			w_real = cos(arg);
			w_im = (-1)*ind*sin(arg);
			for(grup = 0; grup < ngrup; grup++)		//Ciclo interno: numero di gruppi
			{
				primo = 2*nbut*grup + but;
				secondo = primo + nbut;
				t_real = w_real * real_vet[secondo] - w_im * im_vet[secondo];
				t_im = w_real * im_vet[secondo] + w_im * real_vet[secondo];
				real_vet[secondo] = real_vet[primo] - t_real;
				im_vet[secondo] = im_vet[primo] - t_im;
				real_vet[primo] += t_real;
				im_vet[primo] += t_im;
			}
		}
	}

	//Normalizzazione
	if (cf != 1.0)				// Modifica di Bernardo
		for(i = 0; i < n; i++)
		{
			real_vet[i] *= cf;
			im_vet[i] *= cf;
		}
}
