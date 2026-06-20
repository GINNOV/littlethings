/*
 *	sine.c
 *
 *	Version 2.6 by Steve Sampson, Public Domain, November 1988
 *
 *	This program is used to generate time domain sinewave data
 *	for fft.c.  If you want an opening target - negate the
 *	test frequency.
 */

#include <stdio.h>
#include <alloc.h>
#include <math.h>

#define	SAMPLES	256
#define	TWO_PI	(2.0 * 3.14159265358979324)

double	Sample, Freq, Time, Real[SAMPLES], Imag[SAMPLES];
FILE	*Fp;


main(argc, argv)
int	argc;
char	**argv;
{
	register int	loop;

	if (argc != 2)  {
		fprintf(stderr,"Usage: sine output_file\n");
		exit(1);
	}

	printf("Input The Test Frequency (Hz) ? ");
	scanf("%lf", &Freq);
	printf("Input The Sampling Frequency (Hz) ? ");
	scanf("%lf", &Sample);

	Sample = 1.0 / Sample;
	Time   = 0.0;

	for (loop = 0; loop < SAMPLES; loop++)  {
		Real[loop] =  sin(TWO_PI * Freq * Time);
		Imag[loop] = -cos(TWO_PI * Freq * Time);
		Time += Sample;
	}

	if ((Fp = fopen(*++argv, "wb")) == NULL)  {
		fprintf(stderr,"sine: Unable to create write file\n");
		exit(1);
	}

	fwrite(Real, sizeof(double), SAMPLES, Fp);
	fwrite(Imag, sizeof(double), SAMPLES, Fp);
	fclose(Fp);

	putchar('\n');

	exit(0);
}
