#!/usr/contrib/bin/perl

##############################################################################
#                                                                            #
# This script reads a CCGG aircraft summary file and uses the 31-character   #
# key to build a string that contains analysis results for all species. The  #
# script may be called either with no arguments, in which the script will    #
# process all summary files, with one argument, which must be the site code, #
# or with site and year, in which it will process that years' summary files  #
# for that site, or with filename, site, and year, in which it will only     #
# process the file provied.                                                  #
#                                                                            #
# July 19, 1999 - Andrew Burr                                                #
#                                                                            #
##############################################################################
#                                                                            #
#   pfp_merge_db.pl (processes all .sum files)                      #
#    or                                                                      #
#   pfp_merge_db.pl car (processes all car .sum files)              #
#    or                                                                      #
#   pfp_merge_db.pl car 1999 (process all 1999 car .sum files)      #
#    or                                                                      #
#   pfp_merge_db.pl 1999-07-07.1642.sum car 1999 (processes .sum    #
#                                                               file given)  #
#                                                                            #
##############################################################################

##############################################################################
#                            Constant Variables                              #
##############################################################################
 $site_dir="/projects/aircraft";
 $merge_dir="/projects/aircraft";
 @gases=("co2","ch4","co","h2","n2o","sf6","co2c13","co2o18");
 $num_gases="8";                #the number of gases above.
 $default_value="-999.999 *..";
 $format_line="(A3,1X,I4,4(1X,I2),1X,A8,1X,1A,1X,F6.2,1X,F7.2,1X,I6,1X,A2,1X,F5.1,1X,F6.1,1X,F5.1,1X,$num_gases(F8.3,1X,A3))";
##############################################################################
#                                  Main                                      #
##############################################################################
 if(($ARGV[0] eq "") && ($ARGV[1] eq "") && ($ARGV[2] eq "")) {
   &process_all;
   }
 elsif(($ARGV[0] ne "") && ($ARGV[1] eq "") && ($ARGV[2] eq "")) {
   $sitedirs[0]=$ARGV[0];
   &process_site;
   }
 elsif(($ARGV[0] ne "") && ($ARGV[1] ne "") && ($ARGV[2] eq "")) {
   $site=$ARGV[0];
   $yeardirs[0]=$ARGV[1];
   &process_year;
   }
 else {
    if(($ARGV[0] eq "") || ($ARGV[1] eq "") || ($ARGV[2] eq "")) {
      die "Must supply filename, site, and year.";
      }
    else  {
      chop($ARGV[0]); chop($ARGV[0]); chop($ARGV[0]); chop($ARGV[0]);
      open(MERGEFILE,">$merge_dir/$ARGV[1]/history/$ARGV[2]/$ARGV[0].mrg");
       print MERGEFILE "$format_line\n";
       &print_rows("$ARGV[0].sum",$ARGV[1],$ARGV[2]);
      close(MERGEFILE);
      }
 }
##############################################################################
#                                 Subroutines                                #
##############################################################################
 sub process_all
 {
  # Get a list of sites from ASF directory.
  opendir(DIR,"$site_dir") || die "Can't open $site_dir";
    local(@sitedirs)=sort(grep(!/^\.\.?/,readdir(DIR)));
  closedir(DIR);
  &process_site;
 }

 # Loop through each ASF site directory
 sub process_site
 {
  for (@sitedirs)
  {
   opendir(DIR,"$site_dir/$_/history") || die "Can't open $site_dir/$_/history";
   local(@yeardirs)=sort(grep(!/^\.\.?/,readdir(DIR)));
   closedir(DIR);
   $site = $_;
   &process_year;
  }
 }

 sub process_year 
 {
  for (@yeardirs)
   {
    opendir(DIR,"$site_dir/$site/history/$_") || die "Can't open $site_dir";
    local(@filenames)=sort(grep(!/\.sum.bak/, grep( /\.sum/,readdir(DIR))));
    closedir(DIR);
    $year = $_;
    for (@filenames)
    {
     chop; chop; chop; chop;
     $z="$merge_dir/$site/history/$year/$_.mrg";
  #   open(MERGEFILE,">$z");
  #    printf MERGEFILE "$format_line\n";
  #    &print_rows("$_.sum", $site, $year);
  #   close(MERGEFILE);
    }
   }
 }

 sub print_rows
 {
  local($filename, $site, $year)=@_;
  local($where)="$site_dir/$site/history/$year/$filename";
  open(SUMFILE, "grep -i -s '$site' $where | cut -c1-31 |") || die "Can't open $where.";
   while(<SUMFILE>)
   {
    $key = $_;
    chop($key);
    # see if sample is valid
    open(VALID, "grep -s '$key' $where | cut -c58-59 |") || die "Can't open $where.";
     while(<VALID>) { $valid=$_; }
    close(VALID);
    if($valid == 0) { next; }
    local($merge_string)=&append_row($filename,$site,$year,$key);
    $merge_string.=&append_values($key, $site);
    print MERGEFILE "$merge_string\n";
   }
  close(SUMFILE);
 }
 sub append_row
 {
  local($filename, $site, $year, $key)=@_;
  local($where)="$site_dir/$site/history/$year/$filename";
  open(FRONT, "grep -s '$key' $where | cut -c1-56 |") || die "Can't open $where.";
   while(<FRONT>) { $first=$_; chop($first);}
  close(FRONT);
  open(REAR, "grep -s '$key' $where | cut -c60-77 |") || die "Can't open $where.";
   while(<REAR>) {$second=$_; chop($second);}
  close(REAR);
  return "$first $second "; 
 }
 sub append_values
 {
  local($key, $site)=@_;
  $append_string="";
  foreach $gas (@gases)
  {
   local($where)="/projects/$gas/aircraft/site/$site.$gas";
   $gas_string="";
   open(GASFILE, "grep -s '$key' $where | cut -c33-44 |") || die "Can't open $where.";
    while(<GASFILE>)
    {
     $gas_string=$_;
     chop($gas_string);
    }
   close(GASFILE);
   if($gas_string eq "") {$gas_string = $default_value;}
   $append_string.="$gas_string ";
  }
  return $append_string;
 }
