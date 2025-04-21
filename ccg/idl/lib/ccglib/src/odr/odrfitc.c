/*
odrfitc.c

Driver to call ODRPACK fortran routines.
to fit an ODR curve to x/y.

*/
#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<sys/stat.h>
#include	<values.h>

#define		MIN_LEN		200
#define		NUM_ARGS	3

extern  void odrfitf_();

int	lines_in_file();

int	main(argc,argv)
int	argc;
char	*argv[];
{
	extern	char	*optarg;
	extern	int	optind;
	int		c,args;
	int		npts,order;

	char		temp[MIN_LEN];
	char		dfile[MIN_LEN],sfile[MIN_LEN];
	/*
	Misc initialization
	*/
	args=0;
	strcpy(dfile,"");
	strcpy(sfile,"");
	/*
	Sort out arguments
	*/
	while((c=getopt(argc,argv,"d:s:o:"))!=EOF) {
	switch (c) {
		case 's':
			/*
			Get source data file.
			*/
			strcpy(sfile,optarg);
			args++;
			break;
		case 'd':
			/*
			Get destination (X/Y prediction) file.
			*/
			strcpy(dfile,optarg);
			args++;
			break;
		case 'o':
			/*
			Get order of fit.
			*/
			strcpy(temp,optarg);
			sscanf(temp,"%d",&order);
			args++;
			break;
		}
	}
	/*
	Check for appropriate number
	of input parameters.
	*/
	if (args!=NUM_ARGS) exit(-1);
	/*
	How many lines in source file?
	*/
	npts=lines_in_file(sfile)-order;
	/* 
	Now call odrfit fortran code that uses ODRPACK library.
	*/
	odrfitf_(sfile,dfile,&npts,&order);
}

int		lines_in_file(f)
char		*f;
{
	/*
	How many lines
	are there in the
	passed file?
	*/
	int		i;
	char		*temp,*tfile;
	struct stat     b, *buf = &b;
	FILE		*fp;
	
	if (stat(f,buf)!=0) return(0);

	temp=(char*)malloc(sizeof(char)*200);
	tfile=(char*)malloc(sizeof(char)*200);

	tmpnam(tfile);
	sprintf(temp,"wc -l %s > %s",f,tfile);
	system(temp);
	fp=fopen(tfile,"r");
	fscanf(fp,"%d",&i);
	fclose(fp);
      	unlink(tfile);
	free(tfile);
	free(temp);
	return(i);
}
