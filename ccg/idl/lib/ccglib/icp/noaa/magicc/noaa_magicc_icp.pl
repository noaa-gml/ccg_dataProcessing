#!/usr/bin/perl
#
# noaa_magicc_icp
#
# This script ...
#
# (1) is executed at NOAA/GMD
#
# (2) invokes MAGICC ICP software using IDL in batch mode.
#
# June 2007 - kam
#
$srcdir = "/ccg/idl/lib/ccglib/icp/noaa/magicc/";
$log = "${srcdir}noaa_magicc_icp.log";

$subject = "Subject: MAGICC Comparison Experiment: Web Update";
$text = "Results are available at https://omi.cmdl.noaa.gov/icp/magicc/.";

@notify = ( 'ed.dlugokencky@noaa.gov',
            'Gabrielle.Petron@noaa.gov', 'andrew.crotwell@noaa.gov',
            'patricia.m.lang@noaa.gov', 'Sylvia.Englund@Colorado.EDU', 'john.mund@noaa.gov' );

#notify = ( 'john.mund@noaa.gov' );

# Run Flask ICP software [IDL in batch mode]
 
$tmp = "/ccg/idl/scripts/idl ${srcdir}noaa_magicc_icp.bat";
@stdout = `$tmp`;
 
# Notify appropriate CCGG members.
 
foreach $i ( @notify )
{
   $to  = "To: ${i}";
   $cc  = "";
   $bcc  = "bcc: john.mund\@noaa.gov";
   $reply_to = "Reply-to: john.mund\@noaa.gov";

   SendEmail($to, $cc, $bcc, $reply_to, $subject, $text);
}

sub SendEmail()
{
   #
   # Send an e-mail
   #
   local($to,$cc,$bcc,$reply_to,$subject,$content) = @_;

   $sendmail = "/usr/sbin/sendmail -t";
   open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
   print SENDMAIL $to,"\n";
   if ( $cc ne "" ) { print SENDMAIL $cc,"\n"; }
   if ( $bcc ne "" ) { print SENDMAIL $bcc,"\n"; }
   print SENDMAIL $reply_to,"\n";
   print SENDMAIL $subject,"\n";
   print SENDMAIL $content,"\n";
   close(SENDMAIL);
}
