/*
C source code driver for IDL CCG_LOESS
routine.  This program calls routines
from
	Private communication with William Cleveland (ptans)

		A Package of C and Fortran Routines for Fitting
 		Local Regression Models
 
 		William S. Cleveland
 		Eric Grosse
 		Ming-Jen Shyu
 		
 		August 20, 1992
 
 	Source downloaded from:
 
 		netlib.att.com

	Compile using make.ccg_loess
*/

#include 	<stdio.h>
#include	<stdlib.h>
/*
#include 	"/home/ccg/ken/idllib/linux/ccglib/src/loess/src/loess.h"
*/
#include 	"/ccg/idl/lib/ccglib/src/loess/src/loess.h"

#define		DEF_LEN		200
#define		MAXSIZE		40000
#define		NO		0
#define		YES		1

int		ifit=NO;

long    	n,p,degree,normalize,iterations;
long		drop_square[8],parametric[8];

double		span,se_fit,cell;
double		x[MAXSIZE],y[MAXSIZE],wt[MAXSIZE];
double		xfit[MAXSIZE],yfit[MAXSIZE];
char		family[DEF_LEN],surface[DEF_LEN];
char		statistics[DEF_LEN],trace_hat[DEF_LEN];
char		tempfile[DEF_LEN],datfile[DEF_LEN],fitfile[DEF_LEN];

struct  	loess_struct    idl_loess;
struct  	pred_struct 	idl_pred;
struct  	ci_struct       idl_ci;

FILE		*fp;

int	main(argc,argv) 
int	argc;
char	**argv;
{
	/*
	Parse the passed arguments
	and execute main program
	body.
	*/	
	extern char	*optarg;
	int		ndat,nfit;
	int		c,i;
	char		temp[DEF_LEN];

	while ((c=getopt(argc,argv,"a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:"))!=EOF) {

		switch (c) {
		case 'a':
			/*
			Get temporary 
			data file name.
			*/
			strcpy(datfile,optarg);
			
			if ((fp=fopen(datfile,"r"))==NULL) {
				fprintf(stdout,"Cannot open: %s\n",datfile);
				exit(-1);
			} else {
				ndat=0;
				while (fscanf(fp,"%lf %lf %lf", 
				&x[ndat],&y[ndat],&wt[ndat])!=EOF) ndat++;
			 	fclose(fp);
			}
			break;
		case 'b':
			/*
			Get number of elements
			in y response array.
			*/
			sscanf(optarg,"%d",&n);
			break;
		case 'c':
			/*
			Get number of predictors
			or independent factors.
			*/
			sscanf(optarg,"%d",&p);
			break;
		case 'd':
			/*
			Get span.
			*/
			sscanf(optarg,"%lf",&span);
			break;
		case 'e':
			/*
			Get local degree of fit.
			*/
			sscanf(optarg,"%d",&degree);
			break;
		case 'f':
			/*
			Get assumed distribution of errors (family).
			*/
			strcpy(family, optarg);
			break;
		case 'g':
			/*
			Should numeric predictors be normalized?
			*/
			sscanf(optarg,"%d",&normalize);
			break;
		case 'h':
			/*
			Compute surface at all points or interpolate?
			*/
			strcpy(surface, optarg);
			break;
		case 'i':
			/*
			Exact or approximate statistics?
			*/
			strcpy(statistics, optarg);
			break;
		case 'j':
			/*
			Which computational method?
			*/
			strcpy(trace_hat, optarg);
			break;
		case 'k':
			/*
			Maximum cell size when surface='approximate'
			*/
			sscanf(optarg,"%lf",&cell);
			break;
		case 'l':
			/*
			Number of iterations.
			*/
			sscanf(optarg,"%d",&iterations);
			break;
		case 'm':
			/*
			Estimates of the standard errors.
			*/
			sscanf(optarg,"%lf",&se_fit);
			break;
		case 'n':
		case 'o':
			/*
			Get drop_term or
			parametric information.
			*/
			strcpy(temp, optarg);
			
			if ((fp=fopen(temp, "r"))==NULL) {
				fprintf(stdout, "Cannot open: %s\n",temp);
				exit(-1);
			} else {
				i=0;
				while (fscanf(fp,"%lf %lf", 
				&drop_square[i],&parametric[i])!=EOF) i++;
				fclose(fp);
			}
			break;
		case 'p':
			/*
			Get x fit data 
			file name.
			*/
			strcpy(fitfile, optarg);
			
			if ((fp=fopen(fitfile, "r"))==NULL) {
				fprintf(stdout, "Cannot open: %s\n",fitfile);
				exit(-1);
			} else {
				nfit=0;
				while (fscanf(fp,"%lf", &xfit[nfit])!=EOF) nfit++;
				fclose(fp);
			}
			ifit=YES;
			break;
		}
	}
	if (ndat!=n) {
		fprintf(stdout, "Number of elements in y array not equal to n\n");
		exit(-1);
	}
        loess_setup(x,y,n,p,&idl_loess);
	idl_loess.model.span=span;
	idl_loess.model.degree=degree;
	idl_loess.model.normalize=normalize;
	idl_loess.model.family=family;

	idl_loess.control.surface=surface;
	idl_loess.control.statistics=statistics;
	idl_loess.control.trace_hat=trace_hat;

	idl_loess.control.cell=cell;
	idl_loess.control.iterations=iterations;

	for (i=0; i<ndat; i++) idl_loess.in.weights[i]=wt[i];
	for (i=0; i<p; i++)
	{
		idl_loess.model.drop_square[i]=drop_square[i];
		idl_loess.model.parametric[i]=parametric[i];
	}
        loess(&idl_loess);
	loess_summary(&idl_loess);
	
	if (ifit) {
		fp=fopen(fitfile,"w");
		predict(xfit, nfit, &idl_loess, &idl_pred, se_fit);
		for(i=0; i<nfit; i++)
		      	fprintf(fp,"%20lf %20lf\n",xfit[i],idl_pred.fit[i]);
		fclose(fp);
	}
	/*
	Write data with fitted
	values and residuals
	to original data input
	file.
	*/
	fp=fopen(datfile,"w");
	for(i=0; i<ndat; i++)
	      	fprintf(fp,"%20lf %20lf %20lf %20lf\n",
		idl_loess.in.x[i],
		idl_loess.in.y[i],
		idl_loess.out.fitted_values[i],
		idl_loess.out.fitted_residuals[i]);
	fclose(fp);

        loess_free_mem(&idl_loess);
	pred_free_mem(&idl_pred);	
	pw_free_mem(&idl_ci);
}
