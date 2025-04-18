/*#define DEBUG */

#include <malloc.h>
#include <stdio.h>
#include <math.h>

#include "gc.h"

#define NMAX 10


#define FIT_NONE		-1
#define POWER_CURVE		0
#define POLY_1			1
#define POLY_2			2
#define POLY_3			3
#define POLY_4			4
#define PIECEWISE_LINEAR	5
#define SPLINE			6

static void fit_baseline (float *x, float *y, int n, gcPeaks *p, int fit_type);
static void spline_fit (float *x, float *y, int n, float *a, float *b, float *c, float *d);
static long poly_eval (float x, float *coef, int n);
static long power_eval (float x, float *coef);
static long spline_eval(float *x, int n, float xx, float *a, float *b, float *c, float *d);
static void powerfit (float *x, float *y, int ndata, float *a, int ma);
static void polyfit (float *x, float *y, int ndata, float *a, int ma);
static void matinv(double a[][NMAX],int n,double *b);
static void poly_error(char *error_text);
static int *i_vector(int nl,int nh);
static void free_i_vector(int *v,int nl,int nh);

extern timeFunction TimeFunction[MAX_TIMECODES];
extern int ntf;



/*************************************************************/
/* Subtract a fit to specified points in the data.  If not 
 * data points specified, copy the original data to the
 * Peaks detrend array.
 */
void gc_baselinefit (long *data, int npoints, gcPeaks *p)
{
	int i, fit_type, np = 0;
	float xp[MAX_CURVE_POINTS], yp[MAX_CURVE_POINTS];


/* 
 * Initialize baseline fit values to -1
 * Sections that do not have a baseline fit will remain at this value.
 */

	for (i=0; i<npoints; i++) p->bfit[i] = -1;

/* Fit baseline to each section specified by changing CT */

	fit_type = FIT_NONE;
	np = 0;
	for (i=0; i<ntf; i++) {
		if (TimeFunction[i].type == CT && TimeFunction[i].value != fit_type) {
#ifdef DEBUG
fprintf(stderr, "New CT.\n");
fprintf (stderr, "np = %d, fit_type = %d, CT = %d\n", np, fit_type, TimeFunction[i].type);
#endif

			if (np > 0) {
				fit_baseline (xp, yp, np, p, fit_type);
				np = 0;
			}
			fit_type = TimeFunction[i].value;
		}

		if (TimeFunction[i].type == CB) {
			xp[np] = TimeFunction[i].start;
			yp[np] = data[TimeFunction[i].start];
			np++;
		}
	}
	if (np > 0) {
		fit_baseline (xp, yp, np, p, fit_type);
	}
}

/*******************************************************************/
static void fit_baseline (float *x, float *y, int n, gcPeaks *p, int fit_type)
{
	int i, ncoef = 0, j;
	float v;
	float a[MAX_CURVE_POINTS], b[MAX_CURVE_POINTS];
	float c[MAX_CURVE_POINTS], d[MAX_CURVE_POINTS];
	float coef[50];


/* Store the fit points first */

	j = p->n;
	for (i=0; i<n; i++) {
		p->x[j+i] = x[i];
		p->y[j+i] = y[i];
	}
	p->n += n;

/* Do nothing for CT = -1 */

	if (fit_type == FIT_NONE) return;

#ifdef DEBUG
fprintf (stderr, "Fit type = %d\n", fit_type);
fprintf (stderr, "Fit points = %d\n", n);
for (i=0; i<n; i++) {
fprintf (stderr, "%.1f %.1f\n", x[i], y[i]);
}
#endif

/* Check for valid values.  Must be enough fit points
 * for each fit type 
 */

	switch (fit_type) {
	case PIECEWISE_LINEAR: ncoef = n; break;
	case SPLINE: ncoef = n; break;
	case POWER_CURVE: ncoef = 4; break;
	case POLY_1: ncoef = 2; break;
	case POLY_2: ncoef = 3; break;
	case POLY_3: ncoef = 4; break;
	case POLY_4: ncoef = 5; break;
	default:
		fprintf (stderr, "Unknown baseline curve fit type %d.\n", fit_type);
		return;
	}

	if (n < ncoef) {
		fprintf (stderr, "Not enough points specified for baseline fit type %d.\n", fit_type);
		fit_type = FIT_NONE;
	}

/* Now fit this section of the chromatogram */

	switch (fit_type) {
	case SPLINE:
		spline_fit (x-1, y-1, n, a, b, c, d);
		for (i=(int) x[0]; i<=x[n-1]; i++) {
			p->bfit[i] = spline_eval(x, n, (float) i, a, b, c, d);
		}
		break;
	case PIECEWISE_LINEAR:
		for (i=0; i<n-1; i++) {
			coef[i] = (y[i+1] - y[i]) / (x[i+1] - x[i]);
		}
		ncoef = n-1;

		for (i=x[0]; i<=x[n-1]; i++) {
			for (j=ncoef-1; j>=0; j--) 
				if (i >= x[j]) break;

			if (j<0) j = 0; 
			v = i- x[j];
			v *= coef[j];
			v += y[j];
			p->bfit[i] =  v;
		}
		break;
	case POWER_CURVE:
		powerfit (x, y, n, coef, ncoef);
		for (i=(int) x[0]; i<=x[n-1]; i++) {
			p->bfit[i] = power_eval ((float) i, coef);
		}
		break;
	case POLY_1:
	case POLY_2:
	case POLY_3:
	case POLY_4:
		polyfit (x, y, n, coef, ncoef);
		for (i=(int) x[0]; i<=x[n-1]; i++) {
			p->bfit[i] = poly_eval ((float) i, coef, ncoef);
		}
		break;
	}
}

/***********************************************************************/
/* Evaluate the polynomial with n coeffieints */
static long poly_eval (float x, float *coef, int n)
{
	int j;
	float p;

	p = coef[n-1];
	for (j=n-2; j>=0; j--) p = p*x + coef[j];
	return ((long) p);
}

/***********************************************************************/
/* Evaluate the power function with n coeffieints */
static long power_eval (float x, float *coef)
{
	long p;

        p = (long) ( coef[0] + coef[1]/x + coef[2]/(x*x) + coef[3]/(x*x*x) );
	return (p);

}

/***********************************************************************/
static long spline_eval(float *x, int n, float xx, float *a, float *b, float *c, float *d)
{
	int i;
	float h, v;


	for (i=n-2; i>=0; i--) 
		if (xx > x[i]) break;

	if (i < 0) i=0;

	h = xx - x[i];
	v = (d[i+1]*h*h + c[i+1]*h + b[i+1])*h + a[i+1]; 

	return ((long) v);
}
	
/***********************************************************************/
/* Given the data points x[0..ndata-1] and y[0.. ndata-1] fit a polynomial
 * curve with ma coefficients (ma = 2 -> linear, ma=3 -> quadratic etc.).
 * Return the coefficients in the array a[0..ma-1].
 */

static void polyfit (float *x, float *y, int ndata, float *a, int ma)
{
	double wt;
	double beta[NMAX], covar[NMAX][NMAX], afunc[NMAX];
	int i, j, k;

	for (j=1; j<=ma; j++) {
		for (k=1; k<=ma; k++) covar[j][k] = 0.0;
		beta[j] = 0.0;
	}

	for (i=0; i<ndata; i++) {
		for (j=1; j<= ma; j++) {
			afunc[j] = (j==1) ? 1.0 : afunc[j-1] * (double) x[i];
			wt = afunc[j];
			for (k=1; k<=j; k++) covar[j][k] += wt*afunc[k];
			beta[j] += wt * (double) y[i];
		}
	}


	if (ma > 1) {
		for (j=2; j<= ma; j++) 
			for (k=1; k<j; k++) covar[k][j] = covar[j][k];
	}

	matinv(covar, ma, beta);
	for (j=0; j<ma; j++) a[j] = beta[j+1];
}


/***********************************************************************/
/* Given the data points x[0..ndata-1] and y[0.. ndata-1],
 *
 * fit equation y = a + b/x + c/(x*x) + d/(x*x*x) ...
 *
 * with ma coefficients.
 * Return the coefficients in the array a[0..ma-1].
 */

static void powerfit (float *x, float *y, int ndata, float *a, int ma)
{
	double wt;
	double beta[NMAX], covar[NMAX][NMAX], afunc[NMAX];
	int i, j, k;

	for (j=1; j<=ma; j++) {
		for (k=1; k<=ma; k++) covar[j][k] = 0.0;
		beta[j] = 0.0;
	}

	for (i=0; i<ndata; i++) {
		for (j=1; j<= ma; j++) {
			afunc[j] = (j==1) ? 1.0 : afunc[j-1] / x[i];
			wt = afunc[j];
			for (k=1; k<=j; k++) covar[j][k] += wt*afunc[k];
			beta[j] += wt * y[i];
		}
	}


	if (ma > 1) {
		for (j=2; j<= ma; j++) 
			for (k=1; k<j; k++) covar[k][j] = covar[j][k];
	}

	matinv(covar, ma, beta);
	for (j=0; j<ma; j++) a[j] = beta[j+1];
}

/***********************************************************************/
#define SWAP(a,b) {double temp=(a);(a)=(b);(b)=temp;}

static void matinv(double a[][NMAX],int n,double *b)
{
	int *indxc,*indxr,*ipiv;
	int i,icol=0,irow=0,j,k,l,ll;
	double big,dum,pivinv;

	indxc=i_vector(1,n);
	indxr=i_vector(1,n);
	ipiv=i_vector(1,n);
	for (j=1;j<=n;j++) ipiv[j]=0;
	for (i=1;i<=n;i++) {
		big=0.0;
		for (j=1;j<=n;j++)
			if (ipiv[j] != 1)
				for (k=1;k<=n;k++) {
					if (ipiv[k] == 0) {
						if (fabs(a[j][k]) >= big) {
							big=fabs(a[j][k]);
							irow=j;
							icol=k;
						}
					} else if (ipiv[k] > 1) poly_error("Matinv: Singular Matrix-1");
				}
		++(ipiv[icol]);
		if (irow != icol) {
			for (l=1;l<=n;l++) SWAP(a[irow][l],a[icol][l])
			SWAP(b[irow],b[icol])
		}
		indxr[i]=irow;
		indxc[i]=icol;
		if (a[icol][icol] == 0.0) poly_error("Matinv: Singular Matrix-2");
		pivinv=1.0/a[icol][icol];
		a[icol][icol]=1.0;
		for (l=1;l<=n;l++) a[icol][l] *= pivinv;
		b[icol] *= pivinv;
		for (ll=1;ll<=n;ll++)
			if (ll != icol) {
				dum=a[ll][icol];
				a[ll][icol]=0.0;
				for (l=1;l<=n;l++) a[ll][l] -= a[icol][l]*dum;
				b[ll] -= b[icol]*dum;
			}
	}
	for (l=n;l>=1;l--) {
		if (indxr[l] != indxc[l])
			for (k=1;k<=n;k++)
				SWAP(a[k][indxr[l]],a[k][indxc[l]]);
	}
	free_i_vector(ipiv,1,n);
	free_i_vector(indxr,1,n);
	free_i_vector(indxc,1,n);
}

#undef SWAP


/**********************************************************/
static void poly_error(char *error_text)
{
	void exit();

	fprintf(stderr,"Polynomial fit run-time error...\n");
	fprintf(stderr,"%s\n",error_text);
	fprintf(stderr,"...now exiting to system...\n");
	exit(1);
}


/* allocate an integer array */

/**********************************************************/
static int *i_vector(int nl,int nh)
{
	int *v;

	v=(int *)malloc((unsigned) (nh-nl+1)*sizeof(int));
	if (!v) poly_error("allocation failure in i_vector()");
	return v-nl;
}

/**********************************************************/
static void free_i_vector(int *v,int nl,int nh)
{
	free((char*) (v+nl));
}




/**********************************************************/
static void spline_fit (float *x, float *y, int n, float *a, float *b, float *c, float *d)
{

/****** Spline data smoothing routine
 *
 *  Algorithm by C.H. Reinsch Numerische Mathematik 10, 177-183 (1967)
 *
 * INPUT:
 *    x[], y[]   - Arrays containing abscissa and ordiante values of
 *                 data to be fitted.
 *    n          - Number of points in arrays x and y.
 *    s          - Smoothing parameter.  Recommended values are in the 
 *                 range n-sqrt(2*n) <= s <= n+sqr(2*n).
 *                 s is often set = n.
 * OUTPUT:
 *    a[], b[],
 *    c[], d[]   - Arrays containing the coefficients of the spline
 *                 curve where f(xx) = ((d[i]*h*h+c[i]*h+b[i])*h+a[i]
 *                 where h=xx-x[i] and x[i] <= xx < x[i+1]., i=1,n
 *                 and f(x[n])=a[n].  These arrays should be dimensioned
 *                 to hold n points.
 *
 * Converted to c, Nov 1990, kwt.
 * NOTE: arrays x[] and y[] must have data starting at subscript 1,
 *       not 0 as is usual with c arrays.
 */

   int i, n1, n2, m1, m2;
   float h, f, e, g=0.0, f2, p=0.0;
   float *r, *r1, *r2, *t, *t1, *u, *v;
   double sqrt();
   float s;

   s = (float) n;

   r=  (float *)calloc(n+2, sizeof(float));
   r1= (float *)calloc(n+2, sizeof(float));
   r2= (float *)calloc(n+2, sizeof(float));
   t=  (float *)calloc(n+2, sizeof(float));
   t1= (float *)calloc(n+2, sizeof(float));
   u=  (float *)calloc(n+2, sizeof(float));
   v=  (float *)calloc(n+1, sizeof(float));

   n1=1;
   n2=n;
   m1=n1+1;
   m2=n2-1;
   h=x[m1]-x[n1];
   f=(y[m1]-y[n1])/h;

   for (i=m1; i<=m2; i++) {
      g=h;
      h=x[i+1]-x[i];
      e=f;
      f=(y[i+1]-y[i])/h;
      a[i]=f-e;
      t[i]=2*(g+h)/3;
      t1[i]=h/3;
      r2[i]=1/g;
      r[i]=1/h;
      r1[i]= -1/g-1/h;
   }
   for (i=m1; i<=m2; i++) {
      b[i]=r[i]*r[i]+r1[i]*r1[i]+r2[i]*r2[i];
      c[i]=r[i]*r1[i+1]+r1[i]*r2[i+1];
      d[i]=r[i]*r2[i+2];
   }
   f2= -s;
   for (;;) {
      for (i=m1; i<=m2; i++) {
         r1[i-1]=f*r[i-1];
         r2[i-2]=g*r[i-2];
         r[i]=1/(p*b[i]+t[i]-f*r1[i-1]-g*r2[i-2]);
         u[i]=a[i]-r1[i-1]*u[i-1]-r2[i-2]*u[i-2];
         f=p*c[i]+t1[i]-h*r1[i-1];
         g=h;
         h=d[i]*p;
      }
      for (i=m2; i>=m1; i--) {
         u[i]=r[i]*u[i]-r1[i]*u[i+1]-r2[i]*u[i+2];
      }

      e=0;
      h=0;
      for (i=n1; i<=m2; i++) {
         g=h;
         h=(u[i+1]-u[i])/(x[i+1]-x[i]);
         v[i]=(h-g);
         e=e+v[i]*(h-g);
      }
      g= -h;
      v[n2]=g;
      e=e-g*h;
      g=f2;
      f2=e*p*p;


      if (f2>=s || f2<=g) break;

      f=0;
      h=(v[m1]-v[n1])/(x[m1]-x[n1]);
      for (i=m1; i<=m2; i++) {
         g=h;
         h=(v[i+1]-v[i])/(x[i+1]-x[i]);
         g=h-g-r1[i-1]*r[i-1]-r2[i-2]*r[i-2];
         f=f+g*r[i]*g;
         r[i]=g;
      }
      h=e-p*f;

      if (h <= 0) break;

      p=p+(s-f2)/(( sqrt((double) s/e)+p)*h);
   }

   for (i=n1; i<=n2; i++) {
      a[i]=y[i]-p*v[i];
      c[i]=u[i];
   }
   for (i=n1; i<=m2; i++ ) {
      h=x[i+1]-x[i];
      d[i]=(c[i+1]-c[i])/(3*h);
      b[i]=(a[i+1]-a[i])/h - (h*d[i]+c[i])*h;
   }
   free(r);
   free(r1);
   free(r2);
   free(t);
   free(t1);
   free(u);
   free(v);
}

