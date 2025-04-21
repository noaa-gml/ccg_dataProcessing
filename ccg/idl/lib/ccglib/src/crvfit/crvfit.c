/*
crvfit.c

Perform a fit to passed x and y arrays using the curve fitting
techniques developed by the NOAA/CMDL Carbon Cycle Group and
documented in 

	Thoning, K.W., P.P. Tans, and W.D. Komhyr,
	Atmospheric carbon dioxide at Mauna Loa Observatory, 2,
	Analysis of the NOAA/GMCC data, 1974-1985,
	J. Geophys. Res., 94, 8549-8565, 1989.

This program is a 'c' wrapper that calls the Fortran filter
routines developed by Mr. Kirk Thoning of the Carbon Cycle Group.

WARNING:
	Outcome depends on most input keywords.

WRITTEN:	January 1996 - kam
*/
#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<values.h>
#include	<math.h>

#define		DAY		0.002739714
#define 	MAX_PARAMETERS 	50
#define 	MAX_LEN		15000
#define		MED_LEN		2000
#define		MIN_LEN		200
#define		NO		0
#define		YES		1
#define		NUM_ARGS	2
#define		DEFAULT		-999.999

#ifdef FORTRAN_NAMES
#define userfunc        userfunc_
#define fnfilt          fnfilt_
#define spectrum        spectrum_
#define polyv           polyv_
#define spline_f        spline_f_
#define filter_data     filter_data_
#define varnce          varnce_
#define means           means_
#define yearharmonic    yearharmonic_
#endif

char 		*get_sys_date();
float 		pround();
double		rsd_curve();

int	main(argc,argv)
int	argc;
char	*argv[];
{
	extern	char	*optarg;
	extern	int	optind;
	int		i,c,args;
	int		cutoff1,cutoff2,npoly,nharm,
			numpm,maxpar,nfilt,np;
	int		nxnot,npred;
	int		fcurve,smcurve,trcurve,grcurve,even;
	int		res_func,res_curve;
	int		smooth_sc,harm_func;
	int		coef;

	double		ftemp;
	double		xpred[MAX_LEN];
	double		yftn[MAX_LEN],ysc[MAX_LEN];
	double		ytr[MAX_LEN],ygr[MAX_LEN];
	double		yresfunc[MAX_LEN],yressc[MAX_LEN];
	double		curve[MAX_LEN],work[MAX_LEN],smooth2[MAX_LEN];
	double		ysmooth_sc[MAX_LEN],yharm_func[MAX_LEN];
	double		xp[MAX_LEN],yp[MAX_LEN],xfilt[MAX_LEN],smooth[MAX_LEN],
			trend[MAX_LEN],deriv[MAX_LEN],sig[MAX_LEN];

	float		pm[MAX_PARAMETERS],sampleinterval,varf1,varf2,chisq,rsd1; 

	double		tzero;
	double		xnot[MAX_LEN];

	double		*r1,*r2,*r3,*r4,*r5,*r6;

	double 		covar[MAX_PARAMETERS][MAX_PARAMETERS];
	char		suffix[MIN_LEN],prefix[MIN_LEN];
	char		ddir[MIN_LEN],datfile[MIN_LEN];
	char		predfile[MIN_LEN],temp[MIN_LEN];
	
	FILE		*fp;

	double		polyv();
	double		userfunc();
	double		yearharmonic();
	/*
	Misc initialization
	*/
	strcpy(ddir,"");
	strcpy(predfile,"");
	strcpy(prefix,"zzz");
	strcpy(suffix,"zzz");
	maxpar=MAX_PARAMETERS;
	fcurve=NO;
	smcurve=NO;
	trcurve=NO;
	grcurve=NO;
	smooth_sc=NO;
	coef=NO;
	harm_func=NO;
	res_func=NO;
	res_curve=NO;
	even=NO;
	tzero=0;
	args=0;
	cutoff1=80;
	cutoff2=667;
	npoly=3;
	nharm=4;
	sampleinterval=7;

	/*
	Sort out arguments
	*/
	while((c=getopt(argc,argv,"ad:ef:g:p:s:z:y:w:x:v:u:123456789"))!=EOF) {
	switch (c) {
		case 'f':
			/*
			Get source data file.
			*/
			strcpy(datfile,optarg);
			args++;
			break;
		case 'd':
			/*
			Get destination directory.
			*/
			strcpy(ddir,optarg);
			if (ddir[strlen(ddir)-1]!='/') strcat(ddir,"/\0");
			args++;
			break;
		case 'p':
			/*
			Get prefix.
			*/
			strcpy(prefix,optarg);
			break;
		case 's':
			/*
			Get suffix. 
			*/
			strcpy(suffix,optarg);
			break;
		case 'e':	
			/*
			Use even time steps
			beginning at first sample
			date.
			*/
			even=YES;
			break;
		case 'g':
			/*
			User supplies a file containing 
			time vector for predicted values 
			from smooth curve.
			*/
			strcpy(predfile,optarg);
			break;
		case 'z':
			/*
			Get number of polynomial terms
			*/
			sscanf(optarg,"%d",&npoly);
			break;
		case 'y':
			/*
			Get number of harmonic terms
			*/
			sscanf(optarg,"%d",&nharm);
			break;
		case 'x':
			/*
			Get interval in days
			*/
			sscanf(optarg,"%f",&sampleinterval);
			break;
		case 'w':
			/*
			Get short term filter cutoff
			*/
			sscanf(optarg,"%d",&cutoff1);
			break;
		case 'v':
			/*
			Get long term filter cutoff
			*/
			sscanf(optarg,"%d",&cutoff2);
			break;
		case 'u':
			/*
			Get date at t=0.
			*/
			sscanf(optarg,"%lf",&tzero);
			break;
		case 'a':
			/*
			If specified, save ALL results
			*/
			fcurve=YES;
			smcurve=YES;
			trcurve=YES;
			grcurve=YES;
			harm_func=YES;
			smooth_sc=YES;
			res_func=YES;
			res_curve=YES;
			coef=YES;
			break;
		case '1':	
			/*
			Save function, f(t).
			*/
			fcurve=YES;
		case '2':	
			/*
			Save smooth curve results.
			*/
			smcurve=YES;
			break;
		case '3':	
			/*
			Save smooth trend results.
			*/
			trcurve=YES;
			break;
		case '4':	
			/*
			Save growth rate results.
			*/
			grcurve=YES;
			break;
		case '5':	
			/*
			Save harmonic component of function.
			*/
			harm_func=YES;
			break;
		case '6':	
			/*
			Save smoothed seasonal cycle.
			*/
			smooth_sc=YES;
			break;
		case '7':	
			/*
			Save function residuals.
			*/
			res_func=YES;
			break;
		case '8':	
			/*
			Save smooth curve residuals.
			*/
			res_curve=YES;
		case '9':	
			/*
			Save coefficients and uncertainties.
			*/
			coef=YES;
			break;
		}
	}
	/*
	Check for appropriate number
	of input parameters.
	*/
	if (args!=NUM_ARGS) {
		system("more crvfit.args");
		exit(-1);
	}
	/*
	Get data from 
	input file.
	*/
	np=0;
	if ((fp=fopen(datfile,"r"))==NULL) exit(-1);
	while (fscanf(fp,"%lf %lf",&xp[np],&yp[np])!=EOF) np++;
	fclose(fp);
	/*
	Check to see if there
	is more than 2 years of
	data.
	*/
	if (xp[np-1]-xp[0]<2.0 && npoly>2) npoly=2;
	/*
	What should date be at t=0?
	*/
	if (tzero==0) tzero=xp[0];
	/*
	(1)	Zero xp array by
		subtracting tzero.
	(2) 	Initialize sigma.  
		Probably not necessary.
	*/
	for (i=0; i<np; i++) {
		xp[i]-=tzero;
		sig[i]=1.0;
	}
	/* 
	filter data for the entire record.
	*/
	filter_data(xp,yp,sig,&np,&cutoff1,&cutoff2,&sampleinterval, 
		    &npoly,&nharm,pm,covar,&numpm,&maxpar, 
		    xfilt,smooth,trend,deriv,&nfilt,&varf1,
		    &varf2,&chisq,&rsd1);
	/* 
	Using the filter_data
	results, determine

	(0)	function f(t)
	(1)	smooth curve S(t)
	(2)	smooth long-term trend T(t)
	(3)	Growth rate curve dT/dt
	(4)	Harmonic component of f(t)
	(5)	Smoothed seasonal cycle S(t)-T(t)
	*/
	for (i=0; i<nfilt; i++) {
		ftemp=xfilt[i];
		/*
		(0)	function f(t)
		*/
		yftn[i]=userfunc(pm,&ftemp,&nharm,&npoly);
		/*
		(1)	smooth curve S(t)
		*/
		ysc[i]=userfunc(pm,&ftemp,&nharm,&npoly)+smooth[i];
		/*
		(2)	smooth long-term trend T(t)
		*/
		ytr[i]=polyv(pm,&ftemp,&npoly);
		ytr[i]+=trend[i];
		/*
		(3)	Growth rate curve dT/dt
		*/
		ygr[i]=deriv[i];
		/*
		(4)	Harmonic component of f(t)
		*/
		yharm_func[i]=yearharmonic(pm,&ftemp,&npoly,&nharm);
		/*
		(5)	Smoothed seasonal cycle S(t)-T(t)
		*/
		ysmooth_sc[i]=yharm_func[i]+smooth[i]-trend[i];
	}
	/*
	Determine function residuals 
	and smooth curve residuals
	*/
	for (i=0; i<np; i++) xp[i]+=tzero;
	for (i=0; i<nfilt; i++) xfilt[i]+=tzero;
        spline_f(xfilt,smooth,&nfilt,xp,smooth2,work,&np);

	for (i=0; i<np; i++) {
		ftemp=xp[i]-tzero;
		yresfunc[i]=yp[i]-userfunc(pm,&ftemp,&nharm,&npoly);
		yressc[i]=yp[i]-(userfunc(pm,&ftemp,&nharm,&npoly)+smooth2[i]);
	}
	for (i=0; i<np; i++) xp[i]-=tzero;

	for (i=0,nxnot=np; i<np; i++) xnot[i]=xp[i]+tzero;
	
	if (even) {
		/*
		For all data sets
		start time series at
		beginning of each record
		and take evenly spaced steps
		based on the passed sample 
		interval.
		*/
		xnot[0]=xfilt[0];
		nxnot=0;
		do {
			xnot[nxnot]=sampleinterval*DAY*nxnot+xnot[0];
		} while (xnot[nxnot++]<xfilt[nfilt-1]);
		nxnot--;
	}
	/*
	Save function f(t)?
	*/
	if (fcurve) {
		/*
		Get a value from
		function, f(t), at 
		weekly intervals.
		*/
		spline_f(xfilt,yftn,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write function results to ftn file.
		*/
		sprintf(temp,"%s%s_ftn.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");

		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save smooth curve?
	*/
	if (smcurve) {
		/*
		Get a value from
		smooth curve at 
		weekly intervals.
		*/
		spline_f(xfilt,ysc,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write smooth curve
		results to sc file.
		*/
		sprintf(temp,"%s%s_sc.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Flask smooth curve data.
		*/
		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save trend?
	*/
	if (trcurve) {
		/*
		Get a value from
		trend at weekly 
		intervals.
		*/
		spline_f(xfilt,ytr,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write smoothed trend 
		results to tr file.
		*/
		sprintf(temp,"%s%s_tr.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Flask smoothed trend data.
		*/
		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save growth rate?
	*/
	if (grcurve) {
		/*
		Get a value from
		growth rate at weekly 
		intervals.
		*/
		spline_f(xfilt,ygr,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write growth rate 
		results to gr file.
		*/
		sprintf(temp,"%s%s_gr.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Flask smooth curve data.
		*/
		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save smoothed seasonal cycle?
	*/
	if (smooth_sc) {
		/*
		Get a value from
		smoothed seasonal cycle at weekly 
		intervals.
		*/
		spline_f(xfilt,ysmooth_sc,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write results to ssc file.
		*/
		sprintf(temp,"%s%s_ssc.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Flask smooth seasonal cycle data.
		*/
		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save harmonic component of function?
	*/
	if (harm_func) {
		/*
		Get a value from
		harmonic component of function
		at weekly intervals.
		*/
		spline_f(xfilt,yharm_func,&nfilt,xnot,curve,work,&nxnot);
		/*
		Write results to harm file.
		*/
		sprintf(temp,"%s%s_fsc.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Flask smooth seasonal cycle data.
		*/
		for (i=0; i<nxnot; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xnot[i], pround(curve[i],-4));
		fclose(fp);
	}
	/*
	Save function residuals?
	*/
	if (res_func) {
		/*
		Save residuals about the
		function to file.
		*/
		sprintf(temp,"%s%s_residf.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Residuals about function.
		*/
		for (i=0; i<np; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xp[i]+tzero, pround(yresfunc[i],-4));
		fclose(fp);
	}
	/*
	Save smooth curve residuals?
	*/
	if (res_curve) {
		/*
		Save smooth curve residuals
		to file.
		*/
		sprintf(temp,"%s%s_residsc.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		/*
		Smooth curve residuals.
		*/
		for (i=0; i<np; i++)
			fprintf(fp,"%16.8f %16.8f\n",
			xp[i]+tzero, pround(yressc[i],-4));
		fclose(fp);
	}
	/*
	Save coefficients and uncertainties?
	*/
	if (coef) {
		/*
		Save coefficients to file.
		*/
		sprintf(temp,"%s%s_coef.%s",ddir,prefix,suffix);
		fp=fopen(temp,"w");
		for (i=0; i<numpm; i++)
			fprintf(fp,"%12.6f%12.6f\n",pm[i],sqrt(covar[i][i]));
		fclose(fp);
	}
	/*
	Determine curve fit values using predict file?
	*/
	if (strcmp(predfile,"")) {

		/*
		Get a value from
		several types of fitted curves
		time steps designated
		in predict file.
		*/
		if ((fp=fopen(predfile,"r"))==NULL) exit(-1);
		while (fscanf(fp,"%lf",&xpred[npred])!=EOF) npred++;
		fclose(fp);

		r1=(double*)malloc(sizeof(double)*npred);
		r2=(double*)malloc(sizeof(double)*npred);
		r3=(double*)malloc(sizeof(double)*npred);
		r4=(double*)malloc(sizeof(double)*npred);
		r5=(double*)malloc(sizeof(double)*npred);
		r6=(double*)malloc(sizeof(double)*npred);

		spline_f(xfilt,ysc,&nfilt,xpred,r1,work,&npred);
		spline_f(xfilt,yftn,&nfilt,xpred,r2,work,&npred);
		spline_f(xfilt,ytr,&nfilt,xpred,r3,work,&npred);
		spline_f(xfilt,ygr,&nfilt,xpred,r4,work,&npred);
		spline_f(xfilt,yharm_func,&nfilt,xpred,r5,work,&npred);
		spline_f(xfilt,ysmooth_sc,&nfilt,xpred,r6,work,&npred);
		/*
		Write values to predict file.
		*/
		fp=fopen(predfile,"w");

		for (i=0; i<npred; i++)
			fprintf(fp,"%16.8f %16.8f %16.8f %16.8f %16.8f %16.8f %16.8f\n",
			xpred[i], pround(r1[i],-4),pround(r2[i],-4),pround(r3[i],-4),
			pround(r4[i],-4),pround(r5[i],-4),pround(r6[i],-4));
		fclose(fp);

		free(r6); free(r5); free(r4); free(r3); free(r2); free(r1);
	}
	/*
	Write filter parameters
	to filter summary file.
	*/
	sprintf(temp,"%s%s_sum.%s",ddir,prefix,suffix);
	fp=fopen(temp,"w");
	fprintf(fp,"%20s\n","SMOOTH CURVE RESULTS");
	fprintf(fp,"%20s:  %s\n","Source File",datfile);
	fprintf(fp,"%20s:  %s\n","Prefix",prefix);
	fprintf(fp,"%20s:  %s\n","Suffix",suffix);
	fprintf(fp,"%20s:  %s\n","Creation date",get_sys_date());
	fprintf(fp,"%20s:  %f\n","t=0 years",tzero);
	fprintf(fp,"%20s:  %d\n","Cutoff 1",cutoff1);
	fprintf(fp,"%20s:  %d\n","Cutoff 2",cutoff2);
	fprintf(fp,"%20s:  %f\n","Sample interval",sampleinterval);
	fprintf(fp,"%20s:  %d\n","Polynomial terms",npoly);
	fprintf(fp,"%20s:  %d\n","Harmonic terms",nharm);
	fprintf(fp,"%20s:  %f\n","Start date",xfilt[0]);
	fprintf(fp,"%20s:  %f\n","Stop date",xfilt[nfilt-1]);
	fprintf(fp,"%20s:  %d\n\n","# of Points",np);
	fprintf(fp,"%20s:  \n","Coefficients");
	for (i=0; i<numpm; i++)
		fprintf(fp,"%20d:  %12.6f%12.6f\n",i,pm[i],sqrt(covar[i][i]));
	/*
	determine res. std. dev.
	about smooth curve for
	entire record.
	*/
	fprintf(fp,"\n%20s:  %10.6f\n","RSD of fit",rsd1);
	fprintf(fp,"%20s:  %10.6lf\n\n","RSD of curve",
	rsd_curve(xp,yp,tzero,np,smooth,xfilt,nfilt,nharm,npoly,pm));
	fclose(fp);
}

double	rsd_curve(xp,yp,tz,np,smooth,xfilt,nfilt,nharm,npoly,pm)
double	xp[],yp[],tz;
int	np;
double	smooth[],xfilt[];
int	nfilt,nharm,npoly;
float	pm[];
{
	/*
	Get a value from
	smooth curve at 
	intervals corresponding
	to original data.
	*/
	int	i;
	float	ave,rsd;
	double	twk[MAX_LEN],tsmooth[MAX_LEN];
	double	tx[MAX_LEN];

	for (i=0; i<np; i++) tx[i]=xp[i]+tz;

	spline_f(xfilt,smooth,&nfilt,tx,tsmooth,twk,&np);

	for (i=0; i<np; i++)
		twk[i]=yp[i]-(userfunc(pm,&xp[i],&nharm,&npoly)+tsmooth[i]);

	means(twk,&ave,&rsd,&np);
	if (np==1) rsd=DEFAULT;
	return((double)rsd);
}
