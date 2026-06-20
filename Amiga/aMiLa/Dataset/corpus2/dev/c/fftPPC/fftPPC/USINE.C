/*
 *	sine.c
 *
 *	Unix Version 2.4 by Steve Sampson, Public Domain, September 1988
 *
 *	This program is used to generate time domain sinewave data
 *	for fft.c.  If you want an opening target - negate the
 *	test frequency.
 */

/* argument handling and fopen() calls fixed by ARK in 2000 */

#include <stdio.h>
#include <malloc.h>
#include <math.h>

#define	TWO_PI	(2.0 * 3.14159265358979324)
#define Chunk	(Samples * sizeof(double))

static double	Sample, Freq, Time, *Real, *Imag;
static int	Samples;
static void	err_report();
static FILE	*Fp;


main(argc, argv)
int	argc;
char	**argv;
{
	register int	loop;

	if (argc != 3)
		err_report(0);

/*	Samples = abs(atoi(*++argv)); */
	Samples = abs(atoi(argv[1]));

	if ((Real = (double *)malloc(Chunk)) == NULL)
		err_report(1);

	if ((Imag = (double *)malloc(Chunk)) == NULL)
		err_report(2);

	printf("Input The Test Frequency (Hz) ? ");
	scanf("%lf", &Freq);
	printf("Input The Sampling Frequency (Hz) ? ");
	scanf("%lf", &Sample);
	Sample = 1.0 / Sample;

	Time = 0.0;
	for (loop = 0; loop < Samples; loop++)  {
		Real[loop] =  sin(TWO_PI * Freq * Time);
		Imag[loop] = -cos(TWO_PI * Freq * Time);
		Time += Sample;
	}

/*	if ((Fp = fopen(*++argv, "w")) == NULL) */
	if ((Fp = fopen(argv[2], "wb")) == NULL)
		err_report(3);

	fwrite(Real, sizeof(double), Samples, Fp);
	fwrite(Imag, sizeof(double), Samples, Fp);
	fclose(Fp);

	putchar('\n');

	free((char *)Real);
	free((char *)Imag);

	exit(0);
}


static void err_report(n)
int	n;
{
	switch (n)  {
	case 0:
		fprintf(stderr,"Usage: sine samples output_file\n");
		fprintf(stderr,"Where samples is a power of two\n");
		break;
	case 1:
		fprintf(stderr,"sine: Out of memory getting real space\n");
		break;
	case 2:
		fprintf(stderr,"sine: Out of memory getting imag space\n");
		free((char *)Real);
		break;
	case 3:
		fprintf(stderr,"sine: Unable to create write file\n");
	}

	exit(1);
}

/* EOF */
