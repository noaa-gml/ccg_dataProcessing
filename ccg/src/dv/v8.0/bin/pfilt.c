/* Program for printing out values of the filter 
 * response for the standard ccgvu filtering
 * algorithm
 */

#include <stdio.h>
#include <math.h>

void get_filter_response (int);
float fnfilt (float, float, int );

/***************************************************************************/
main (argc, argv)
int argc;
char **argv;
{
	int cutoff;

	sscanf (argv[1], "%d", &cutoff);
	get_filter_response (cutoff);

	exit (0);
}

/***************************************************************************/
void get_filter_response(cutoff)
int cutoff;
{
	int k, power;
	float f, r, fstep, fmax, sigma;

	fmax = (365.0/(float) cutoff) * 2;	/* estimate of when response ~ 0 */
	fstep = fmax/1000;
	sigma = 1.0 / ((float) cutoff/365.0);
	power = 6;
	k = 0;
	for (f = 0; f< fmax; f += fstep) {
		r = fnfilt (f, sigma, power);
		printf ("%f %f\n", f, r);
		k++;
		if (k == 1000) break;
	}
}

/**********************************************************************/
float fnfilt (float freq, float sigma, int power)
{
	float z, f;

/* Watch out for underflow */

	z = pow ((double) freq/sigma, (double) power);
	if (z > 20.0) {
		f = 1e-10;
	} else {
		f = 1.0/(pow (2.0, (double) z));
	}
	return (f);
}
