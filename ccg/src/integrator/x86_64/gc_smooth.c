/*
#define DEBUG
*/
/*
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "gc.h"

static float minarg1,minarg2;
#define FMIN(a,b) (minarg1=(a),minarg2=(b),(minarg1) < (minarg2) ?\
        (minarg1) : (minarg2))



static void SGsmooth(int Width, long *Input, float *Output, int Start, int End, int Npoints, int q, int deriv);
static void savgol(float *c,int np,int nl,int nr,int ld,int m);
static void ludcmp(float **a,int n,int *indx,float *d);
static void lubksb(float **a,int n,int *indx,float *b);
static void nrerror(char *error_text);
static float *vector(long nl,long nh);
static int *ivector(long nl,long nh);
static float **matrix(long nrl,long nrh,long ncl,long nch);
static void free_vector(float *v,long nl,long nh);
static void free_ivector(int *v,long nl,long nh);
static void free_matrix(float **m,long nrl,long nrh,long ncl,long nch);


#define DEFAULT_SMOOTH_FACTOR 	0.1
#define DEFAULT_PW		5

extern timeFunction TimeFunction[MAX_TIMECODES];
extern int ntf;

/*********************************************************************/
/* 
 * Smooth the data (degree = 0) or calculate the slope of the data 
 * (degree = 1)
 */
/*********************************************************************/
void gc_smooth(long *data, int n, float *smooth, gcPeaks *ptr, int degree)
{
	int	start, end, nsmooth;
	int	i;
	float factor, pw;
FILE *fp;
	

	factor = DEFAULT_SMOOTH_FACTOR;
	start = 0;
	pw = DEFAULT_PW;
	for (i = 0; i < ntf; i++) {
		
		if (TimeFunction[i].type == SF) factor = TimeFunction[i].value;
		if (TimeFunction[i].type != PW) continue;

		if (TimeFunction[i].start == 0) {
			pw = TimeFunction[i].value;
			continue;
		}
		end = TimeFunction[i].start - 1;

		if (end >= ptr->npoints) break;

		nsmooth = (int) (factor * pw * ptr->sample_rate + 0.5);
		if (degree > 0) nsmooth *= 2;	/* Heavier smoothing for slope */

#ifdef DEBUG
fprintf (stderr, "factor = %g, pw = %f\n", factor, pw);
fprintf (stderr, "nsmooth = %d, start = %d, end = %d, degree = %d\n", nsmooth, start, end, degree);
#endif

		SGsmooth(nsmooth, data, smooth, start, end, ptr->npoints, 2, degree);

		pw = TimeFunction[i].value;
		start = TimeFunction[i].start;
	}
	end = ptr->npoints - 1;
	nsmooth = (int) (factor * pw * ptr->sample_rate + 0.5);
	if (degree > 0) nsmooth *= 2;	/* Heavier smoothing for slope */

#ifdef DEBUG
fprintf (stderr, "factor = %g, pw = %f\n", factor, pw);
fprintf (stderr, "nsmooth = %d, start = %d, end = %d, degree = %d\n", nsmooth, start, end, degree);
#endif
	SGsmooth(nsmooth, data, smooth, start, end, ptr->npoints, 2, degree);

#ifdef DEBUG
for (i=0; i<100; i++) {
    fprintf(stderr, "%f ", smooth[i]);
}
fprintf(stderr, "\n");

fp = fopen("smooth.txt", "w");
for (i=0; i<ptr->npoints; i++) {
fprintf(fp, "%f\n", smooth[i]);
}
fclose(fp);
#endif

}

/*********************************************************************/
static void SGsmooth(
	int  Width,	/* indicator of number of points to use in smoothing */
	long *Input,	/* Input data array (raw data)*/
	float *Output, 	/* Output data array (smoothed data) */
	int Start,	/* where to start in Input[] */
	int End,	/* where to end in Input[] */
	int Npoints,	/* number of points in Input[] (0..Npoints-1) */
	int q,		/* degree of polynomial to use */
	int deriv	/* order of derivative */
)

{
	int i, j, k, nl, nr, np, ld, m;
	float *c;
	double s;


/*
   Call the Savitzky-Golay routine for calculating the coefficients
   c is the coefficient array,
   np is number of points in c (1..np)  np = nl+nr+1
   nl is number of points to left to use,
   nr is number of points to right to use,
   ld is order of the derivative desired (ld =0 -> smoothing)
   m is order of smoothing polynomial.
*/


	nl = Width;
	nr = Width;
	np = nl + nr + 1;
	ld = deriv;
	m = q;

	c = (float *) calloc ((size_t) np+1, sizeof(float));

	savgol (c, np, nl, nr, ld, m);

/*
 * now that we have the coefficients, compute the smoothed value 
 * for each raw data point
 * Take into account the goofy way the coefficients are stored in
 * the array.
 *
 * Avoid array overflows by using the data point at t = 0 if
 * we need data that is < 0, and the same at the other end.
 */
 

	for (i=Start; i<= End; i++) {
		s = c[1] * Input[i];
		for (j=1; j<=nl; j++) {
			k = i-j;
			if (k<0) k = 0;
			s+= Input[k] * c[j+1];
		}
		for (j=1; j<=nr; j++) {
			k = i+j;
			if (k > Npoints-1) k = Npoints-1;
			s+= Input[k] * c[np-j+1];
		}
		Output[i] = (float) (s);
	}

}

/***************************************************************/
static void savgol(float *c,int np,int nl,int nr,int ld,int m)
{
        int imj,ipj,j,k,kk,mm,*indx;
        float d,fac,sum,**a,*b;

        if (np < nl+nr+1 || nl < 0 || nr < 0 || ld > m || nl+nr < m)
        nrerror("bad args in savgol");
        indx=ivector(1,m+1);
        a=matrix(1,m+1,1,m+1);
        b=vector(1,m+1);
        for (ipj=0;ipj<=(m << 1);ipj++) {
                sum=(ipj ? 0.0 : 1.0);
                for (k=1;k<=nr;k++) sum += pow((double)k,(double)ipj);
                for (k=1;k<=nl;k++) sum += pow((double)-k,(double)ipj);
                mm=FMIN(ipj,2*m-ipj);
                for (imj = -mm;imj<=mm;imj+=2) a[1+(ipj+imj)/2][1+(ipj-imj)/2]=sum;
        }
        ludcmp(a,m+1,indx,&d);
        for (j=1;j<=m+1;j++) b[j]=0.0;
        b[ld+1]=1.0;
        lubksb(a,m+1,indx,b);
        for (kk=1;kk<=np;kk++) c[kk]=0.0;
        for (k = -nl;k<=nr;k++) {
                sum=b[1];
                fac=1.0;
                for (mm=1;mm<=m;mm++) sum += b[mm+1]*(fac *= k);
                kk=((np-k) % np)+1;
                c[kk]=sum;
        }
        free_vector(b,1,m+1);
        free_matrix(a,1,m+1,1,m+1);
        free_ivector(indx,1,m+1);
}
/* (C) Copr. 1986-92 Numerical Recipes Software ##'. */


#define TINY 1.0e-20;

/***************************************************************/
static void ludcmp(float **a,int n,int *indx,float *d)
{
        int i,imax=0,j,k;
        float big,dum,sum,temp;
        float *vv;

        vv=vector(1,n);
        *d=1.0;
        for (i=1;i<=n;i++) {
                big=0.0;
                for (j=1;j<=n;j++)
                        if ((temp=fabs(a[i][j])) > big) big=temp;
                if (big == 0.0) nrerror("Singular matrix in routine ludcmp");
                vv[i]=1.0/big;
        }
        for (j=1;j<=n;j++) {
                for (i=1;i<j;i++) {
                        sum=a[i][j];
                        for (k=1;k<i;k++) sum -= a[i][k]*a[k][j];
                        a[i][j]=sum;
                }
                big=0.0;
                for (i=j;i<=n;i++) {
                        sum=a[i][j];
                        for (k=1;k<j;k++)
                                sum -= a[i][k]*a[k][j];
                        a[i][j]=sum;
                        if ( (dum=vv[i]*fabs(sum)) >= big) {
                                big=dum;
                                imax=i;
                        }
                }
                if (j != imax) {
                        for (k=1;k<=n;k++) {
                                dum=a[imax][k];
                                a[imax][k]=a[j][k];
                                a[j][k]=dum;
                        }
                        *d = -(*d);
                        vv[imax]=vv[j];
                }
                indx[j]=imax;
                if (a[j][j] == 0.0) a[j][j]=TINY;
                if (j != n) {
                        dum=1.0/(a[j][j]);
                        for (i=j+1;i<=n;i++) a[i][j] *= dum;
                }
        }
        free_vector(vv,1,n);
}
#undef TINY
/* (C) Copr. 1986-92 Numerical Recipes Software ##'. */



/***************************************************************/
static void lubksb(float **a,int n,int *indx,float *b)
{
        int i,ii=0,ip,j;
        float sum;

        for (i=1;i<=n;i++) {
                ip=indx[i];
                sum=b[ip];
                b[ip]=b[i];
                if (ii)
                        for (j=ii;j<=i-1;j++) sum -= a[i][j]*b[j];
                else if (sum) ii=i;
                b[i]=sum;
        }
        for (i=n;i>=1;i--) {
                sum=b[i];
                for (j=i+1;j<=n;j++) sum -= a[i][j]*b[j];
                b[i]=sum/a[i][i];
        }
}
/* (C) Copr. 1986-92 Numerical Recipes Software ##'. */



#define NR_END 1
#define FREE_ARG char*

/***************************************************************/
static void nrerror(char *error_text)
/* Numerical Recipes standard error handler */
{
        void exit();

        fprintf(stderr,"Numerical Recipes run-time error...\n");
        fprintf(stderr,"%s\n",error_text);
        fprintf(stderr,"...now exiting to system...\n");
        exit(1);
}

/***************************************************************/
static float *vector(long nl,long nh)
/* allocate a float vector with subscript range v[nl..nh] */
{
        float *v;

        v=(float *)malloc((unsigned int) ((nh-nl+1+NR_END)*sizeof(float)));
        if (!v) nrerror("allocation failure in vector()");
        return v-nl+NR_END;
}

/***************************************************************/
static int *ivector(long nl,long nh)
/* allocate an int vector with subscript range v[nl..nh] */
{
        int *v;

        v=(int *)malloc((unsigned int) ((nh-nl+1+NR_END)*sizeof(int)));
        if (!v) nrerror("allocation failure in ivector()");
        return v-nl+NR_END;
}


/***************************************************************/
/* allocate a float matrix with subscript range m[nrl..nrh][ncl..nch] */
static float **matrix(long nrl,long nrh,long ncl,long nch)
{
        long i, nrow=nrh-nrl+1,ncol=nch-ncl+1;
        float **m;

        /* allocate pointers to rows */
        m=(float **) malloc((unsigned int)((nrow+NR_END)*sizeof(float*)));
        if (!m) nrerror("allocation failure 1 in matrix()");
        m += NR_END;
        m -= nrl;

        /* allocate rows and set pointers to them */
        m[nrl]=(float *) malloc((unsigned int)((nrow*ncol+NR_END)*sizeof(float)));
        if (!m[nrl]) nrerror("allocation failure 2 in matrix()");
        m[nrl] += NR_END;
        m[nrl] -= ncl;

        for(i=nrl+1;i<=nrh;i++) m[i]=m[i-1]+ncol;

        /* return pointer to array of pointers to rows */
        return m;
}


/***************************************************************/
static void free_vector(float *v,long nl,long nh)
/* free a float vector allocated with vector() */
{
        free((FREE_ARG) (v+nl-NR_END));
}

/***************************************************************/
static void free_ivector(int *v,long nl,long nh)
/* free an int vector allocated with ivector() */
{
        free((FREE_ARG) (v+nl-NR_END));
}


/***************************************************************/
static void free_matrix(float **m,long nrl,long nrh,long ncl,long nch)
/* free a float matrix allocated by matrix() */
{
        free((FREE_ARG) (m[nrl]+ncl-NR_END));
        free((FREE_ARG) (m+nrl-NR_END));
}

