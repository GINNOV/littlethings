/*
 *	pulse.c
 *
 *	Version 2.6 by Steve Sampson, Public Domain, November 1988
 *
 *	This program is used to generate time domain pulse data	for fft.c.
 */

#include <stdio.h>
#include <alloc.h>

#define SAMPLES	256

double	Sample, Pw, Time, Real[SAMPLES], Imag[SAMPLES];
FILE	*Fp;


main(argc, argv)
int	argc;
char	**argv;
{
	register int	loop;

	if (argc != 2)  {
		fprintf(stderr,"Usage: pulse output_file\n");
		exit(1);
	}

	printf("Input The Pulse Width (Seconds) ? ");
	scanf("%lf", &Pw);
	printf("Input The Sampling Time (Seconds) ? ");
	scanf("%lf", &Sample);

	Time = 0.0;

	for (loop = 0; loop < SAMPLES; loop++)  {
		if (Time < Pw)
			Real[loop] = 1.0;
		else
			Real[loop] = 0.0;

		Imag[loop] = 0.0;
		Time += Sample;
	}

	if ((Fp = fopen(*++argv, "wb")) == NULL)  {
		fprintf(stderr,"pulse: Unable to create write file\n");
		exit(1);
	}

	fwrite(Real, sizeof(double), SAMPLES, Fp);
	fwrite(Imag, sizeof(double), SAMPLES, Fp);
	fclose(Fp);

	putchar('\n');

	exit(0);
}
