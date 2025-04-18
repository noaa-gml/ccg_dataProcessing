
/* Put PFP into Sample Plan mode and enter the flight plan information from an input file.
 
Revisions:
	 3 May 2004    Version 3.00,  also uses check_as_id, set_as_date, and set_as_sitecodei

*/
	
#include "as_comm.h"
#include "as_comm_v3.c"
#define MAXLINE 1000
#define in_file  "/home/mike/PFP/PFP/tmp.txt"
#define r_file "/home/mike/PFP/PFP/result.txt"
#include "string.h"
#include "strings.h"


int main(int argc, char *argv[])
{
  
  FILE *inputfile;                        /*This is the file from the calling program*/
  /*FILE *resultfile;*/                       /*This file stores the results back from the PFP*/
  

  const char delimeters[]=" ,\r\n";
  const char scdelimeters[]=",\r\n";
  char *linebuf, *idbuff, *pliststr;
  char line[maxline];
  char liststr[1500];
  char answer[maxline];
  char reply[maxline], sitecode[3];
  static char checkstr[maxline];
 
  int i=0,j=0,n=1,k=1,wrdct=0, a=0, b=0, idint=is_ok;
  int as_eid, check=1,chk2=0, ok=0, err;
  size_t nchars = 0;
 
  char *sum, *altitude, *latitude, *longitude, *datestr, *timestr;
  char *yearstr, *monthstr, *daystr, *hourstr, *minstr;
  char mon[3], min[3];
  char *stoken[100];
  char *sctkn[10];                     /*site code token separator*/
  char *dtkn[100];
  char *ttkn[100];
     
     linebuf=&line[0];
     inputfile = fopen(argv[1], "r");
     /*resultfile = fopen(r_file, "a");*/         /*Output goes to standard out in this version*/
     /*
     Pass serial port device driver
     November 8, 2004 - kam
     */
     strcpy(serialport, argv[2]);

     if (inputfile==NULL)
       {
	 as_exit("as_fplan", "! Couldn't open flight plan input file. \n");
	 return not_ok;
       } 
    
     else
       {
	 /*printf("\n\n"); */
	 as_eid = open_as_comm();
	 /*printf("Checking ID number....\n");*/
	 for (i=0;i<5;i++)
	   {
	     send_as_msg(as_eid,quit_command);    /*send quit command a few times to start off*/
	     get_as_msg(as_eid, reply);
	   }
	 send_as_msg(as_eid,setup_prompt);        /*Send setup command to see if memory is valid*/
	 get_as_msg(as_eid,answer);
	 if(match_as_prompt(answer,"memory invalid\r\nAS> ")==is_ok)
	   fix_memory(as_eid);                    /*fix the memory first if it needs it*/
	 
	 n=getline(&idbuff, &nchars, inputfile);
	 sctkn[0]=strtok(idbuff, delimeters);
	 sctkn[1]=strtok(NULL, delimeters);
	 sitecode[0]=*(sctkn[1]+0);
	 sitecode[1]=*(sctkn[1]+1);
	 sitecode[2]=*(sctkn[1]+2);
	 idint=check_as_id(as_eid, idbuff);
	 if (idint != is_ok)
	    as_exit("as_fplan", "! PFP ID number does not match the ID requested.\n");
	 /*printf("ID number OK.\n");
	   printf("Entering Flight Plan Information...\n\n");*/
	 goto_AS_mode( as_eid ); 
	 
	 err=set_as_date(as_eid);                 /*Set the date and time to UTC*/
	 if(err!=0)
	   as_exit("as_fplan", "! Could not set unit date and time.\n");
	 
	 err=set_as_sitecode(as_eid, sitecode);     /*Set the site code*/
	 if(err!=0)
	   as_exit("as_fplan", "! Error setting site code.");

	 goto_sampleplan_mode( as_eid );
	 delete_samples(as_eid);

	 while(n>=0)                             /*Read each line of the input file, parse it, and send to PFP*/
	   {
	     goto_sampleplan_mode(as_eid); 
	     n = getline(&linebuf, &nchars, inputfile);
	      i=0;
	      j=0;
	      k=1;
	      wrdct=0;
	      
	      if (n>=0)
	      { 
		a=0;
		/* printf("%s\n",linebuf); */
		stoken[a] = strtok(linebuf,delimeters);
		while(stoken[++a]= strtok(NULL,delimeters))
		  ;
		/*printf("sample#%s, altitude=%s, latitude=%s\n",stoken[0], stoken[1], stoken[2]);
		  printf("longitude=%s, time is %s, date is %s\n", stoken[3], stoken[4], stoken[5]);*/
		sum=strcat(stoken[0],"");
		altitude=strcat(stoken[1],"");     /*Create all the parsed strings for data entry*/
		latitude=strcat(stoken[2],"");
		longitude=strcat(stoken[3],"");
		datestr=strcat(stoken[4],"");
		timestr=strcat(stoken[5],"");
		i=0;
		j=0;
		b=0;
		dtkn[b] = strtok(datestr,"-");          /*parse up the date into yyyy, mm, dd*/
		while(dtkn[++b] = strtok(NULL,"-"))
		  ;
		b=0;
		ttkn[b] = strtok(timestr,":");          /*parse up the time into hh, mm*/
		while(ttkn[++b] = strtok(NULL,":"))
		  ;
		yearstr=strcat(dtkn[0],"");
		monthstr=strcat(dtkn[1],"");
		mon[0]=*monthstr;               /*insure that the month is static in memory*/
		mon[1]=*(monthstr+1);
		(int) mon[2]=NULL;
		daystr=strcat(dtkn[2],"");
		hourstr=strcat(ttkn[0],"");
		minstr=strcat(ttkn[1],"");
		min[0]=*minstr;                 /*insure that the minutes are static in memory*/
		min[1]=*(minstr+1);
		(int) min[2]=NULL;
		/*printf("\n---%s,%s,%s,%s---\n",sum,altitude,latitude,longitude);
		printf("---%s,%s,%s---\n",yearstr,mon,daystr);				
		printf("----%s,%s----\n",hourstr, minstr);*/
		send_as_msg(as_eid, add_command);
		get_as_msg( as_eid, reply );
		/*printf("month=%s, minute=%s\n", mon, minstr);*/
		while(reply != sample_prompt && check==1)  /* This loop checks the current prompt and enters the appropriate data*/
		 {
		   check=0; 
		   /*chk2=0;*/
		   memcpy(checkstr, reply, maxline);
		  
		   if (match_data_prompt( add_sample, reply ) == is_ok)
		     {
		       if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		       send_as_data(as_eid, sum);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       check=1;
		       chk2=1;
		     } 
		    if (match_data_prompt( add_altitude, reply ) == is_ok)
		     {
		       if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		       if(altitude=="-99999")
			 altitude="\r\n\0";
		       send_as_data(as_eid, altitude);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       check=1;
		       chk2=1;
		     } 
		    if (match_data_prompt( add_latitude, reply ) == is_ok)
		     {
		       if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		       if(latitude=="-99.999")
			 latitude="\r\n\0";
		       send_as_data(as_eid, latitude);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     } 
		    if (match_data_prompt( add_longitude, reply ) == is_ok)
		     {		      
		       if(longitude=="-999.999")
			 longitude="\r\n\0";
		       send_as_data(as_eid, longitude);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     } 
		    if (chk2==1)
		      memcpy(reply, checkstr, maxline);
		    if (match_data_prompt( add_year, reply ) == is_ok)
		     {
		       if(yearstr=="0000")
			 yearstr="\r\n\0";
		       send_as_data(as_eid, yearstr);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     }
		    if (chk2==1)
		      memcpy(reply, checkstr,maxline);
		    if (match_data_prompt( add_month, reply ) == is_ok)
		     {		      
		       send_as_data(as_eid,mon);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     }
		    if (chk2==1)
		      memcpy(reply, checkstr,maxline);
		    if (match_data_prompt( add_day, reply ) == is_ok)
		     {
		       if(daystr=="00")
			 daystr="\r\n\0";
		       send_as_data(as_eid, daystr);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     } 
		    if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		    if (match_data_prompt( add_hour, reply ) == is_ok)
		     {
		       send_as_data(as_eid, hourstr);
		       get_as_msg( as_eid, reply );
		       /*printf("%s\n",reply);*/
		       memcpy(checkstr, reply, maxline);
		       check=1;
		       chk2=1;
		     } 
		    if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		    if (match_data_prompt( add_minute, reply ) == is_ok)
		     {
		       
		       send_as_data(as_eid, min);
		       get_as_msg( as_eid, reply );
       		       /* printf("%s\n",reply); */
		       memcpy(checkstr, reply, maxline);
		       check=0;
		       chk2=1;
		     } 
		    if (chk2==1)
			 memcpy(reply, checkstr,maxline);
		    if (check==0 || chk2==1)
		      {
			if(match_data_prompt(sample_prompt, reply ) == is_ok)
			  {
			    /*printf("data entered correctly\n");*/
			    check=0;
			  }
			else
			{
			  as_exit("as_fplan","! error in data entry portion of sample plan.\n");
			  check=0;
			}
		      }
		 }
		check=1;   /* Reset Check Value for the next line of the file to be entered*/
	
	  
	      }
	   
	   }
	   	 
       }
     send_as_msg(as_eid, list_command);  /*Send command to retrieve the flight plan*/
     get_as_msg(as_eid, liststr);
     n=strlen(liststr);
     liststr[n]=NULL;
     pliststr=&liststr[0];
     pliststr=pliststr+3;
     printf("\n%s\n", pliststr);         /*Write the controller output to standard out for capture*/
     /*fprintf(resultfile, pliststr);*/  /*Write the controller ouput to a file*/
/*
   add to return to main menu
   to correct checksum errors?
   October 22, 2004 - mph,kam
*/
     goto_AS_mode( as_eid );

     close(as_eid);                      /*Clean up and close all open devices (using exit does this too).*/
     fclose(inputfile);
     /*fclose(resultfile);*/
     exit(ok);
     
}
