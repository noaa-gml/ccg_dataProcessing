#!/usr/bin/perl

use Getopt::Long;

#
# This program is a general PostScript conversion program. It can convert
#    a PostScript file to a PNG and PDF. 
# 
# Note: It seems to have problems with CorelDraw PostScripts.
#
# This script can handle 6 process paths
#
# 1. single page ps -> single page pdf
# 2. multiple page ps -> multiple page pdf
# 3. single page ps -> single page png
#
# 4. single page ps -> single page png -> rotate png
#
# 5. multiple page ps -> separate each page -> single page png -> rotate png -> next page
#
# Modified: 2014-12-22 dyc
#
# Modified: 2016-01-06 kwt to add -trimmargin option, which will leave a 20 pixel margin
# around the image whem trimming.

if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "depth=i", "infile|f=s", "help|h", "height=i", "optimization=s", "outfile|o=s", "png", "pdf", "rotate=s", "trim", "trimmargin", "width=i" );

if ( $noerror != 1 ) { exit; }

if ( $Options{help} ) { &showargs(); }
if ( ! $Options{infile} ) { &showargs(); }
$infile = $Options{infile};

%imgoptions_aarr = ();

if ( $Options{height} ) { $imgoptions_aarr{"height"} = $Options{height}; } 
if ( $Options{width} ) { $imgoptions_aarr{"width"} = $Options{width}; } 
if ( $Options{depth} ) { $imgoptions_aarr{"depth"} = $Options{depth}; } 
if ( $Options{trim} ) { $imgoptions_aarr{"trim"} = 1; } 
if ( $Options{trimmargin} ) { $imgoptions_aarr{"trimmargin"} = 1; } 
if ( $Options{optimization} )
{
   if ( $Options{optimization} eq 'quality' ||
        $Options{optimization} eq 'speed' )
   { $imgoptions_aarr{"optimization"} = $Options{optimization}; }
   else
   { die("Exiting... (Invalid value for optimization option)."); }
}
else
{
   $imgoptions_aarr{"optimization"} = "quality";
}
if ( $Options{rotate} )
{
   if ( $Options{rotate} eq 'U' ||
        $Options{rotate} eq 'R' ||
        $Options{rotate} eq 'L' )
   {
      $imgoptions_aarr{"rotate"} = $Options{rotate};
   }
   else
   { die("Exiting... (Invalid value for rotate option)."); }
}

@infile_arr = split(/\//, $Options{infile});
$infile_name = pop(@infile_arr);
$infile_dir = join('/', @infile_arr);
@infile_name_arr = split(/\./, $infile_name);
$infile_name_extension = pop(@infile_name_arr);
$infile_name_prefix = join('.', @infile_name_arr);

if ( $Options{outfile} )
{
   @outfile_arr = split(/\//, $Options{outfile});
   $outfile_name = pop(@outfile_arr);
   $outfile_dir = join('/', @outfile_arr);
   @outfile_name_arr = split(/\./, $outfile_name);
   $outfile_name_extension = pop(@outfile_name_arr);
   $outfile_name_prefix = join('.', @outfile_name_arr);
}
else
{
   $outfile_dir = '';
   $outfile_name_prefix = $infile_name_prefix;
   if ( $Options{png} && !$Options{pdf} ) { $outfile_name_extension = 'png'; }
   elsif ( !$Options{png} && $Options{pdf} ) { $outfile_name_extension = 'pdf'; }
   else { $outfile_name_extension = ''; }
}

%outfile_aarr = ();
if ( $outfile_dir eq '' ) { $outfile_aarr{"dir"} = '.'; }
else { $outfile_aarr{"dir"} = $outfile_dir; }
$outfile_aarr{"name"} = ();
$outfile_aarr{"name"}{"prefix"} = $outfile_name_prefix;
$outfile_aarr{"name"}{"extension"} = $outfile_name_extension;

if ( $outfile_aarr{"name"}{"extension"} eq "pdf" )
{
   #
   ###############
   # PS TO PDF
   ###############
   #

   $output_pdffile = $outfile_aarr{"dir"}.'/'.$outfile_aarr{"name"}{"prefix"}.'.'.$outfile_aarr{"name"}{"extension"};
   &PS2PDF($infile,$output_pdffile,$imgoptions_aarr{"rotate"});
}
elsif ( $outfile_aarr{"name"}{"extension"} eq "png" )
{
   #
   ###############
   # PS TO PNG
   ###############
   #

   @identify_arr = &ImgIdentify($infile);

   if ( $#identify_arr == 0 )
   {
      # Single page postscript
      $output_pngfile = $outfile_aarr{"dir"}.'/'.$outfile_aarr{"name"}{"prefix"}.'.'.$outfile_aarr{"name"}{"extension"};
      &PS2PNG($infile,$output_pngfile,\%imgoptions_aarr);
   }
   elsif ( $#identify_arr > 0 )
   {
      # Multipage postscript

      # Separate multipage postscript into many single page postscripts
      @separate_psfiles = &PSSeparate($infile);

      # Convert the single page postscripts to the png
      $i = 0;
      foreach $separate_psfile ( @separate_psfiles )
      {
         $output_pngfile = $outfile_aarr{"dir"}.'/'.$outfile_aarr{"name"}{"prefix"}.'-'.$i.'.'.$outfile_aarr{"name"}{"extension"};
         &PS2PNG($separate_psfile,$output_pngfile,\%imgoptions_aarr);
         $i++;
         unlink($separate_psfile);
      }
   }
   else
   {
      #ERROR identify has zero return lines
      die("Exiting... (identify command returned no lines).");
   }
}
else
{
   #ERROR on outfile extension
   die("Exiting... (Invalid output file type specified).");
}

exit;

sub ImgIdentify()
{
   my($imgfile) = @_;

   my @res_arr = ();
   my @identify_arr = `/usr/bin/identify $imgfile`;
   #print($imgfile);
   foreach $identify_line ( @identify_arr )
   {
      chomp($identify_line);
      push(@res_arr, $identify_line);
   }

   if ( $#res_arr < 0 )
   { die("Exiting... (ImgIdentify() could not analyze the image"); }

   return @res_arr;
}

sub ImgWH()
{
   my($imgfile) = @_;

   my @identify_arr = &ImgIdentify($imgfile);
   my $identify_line;
   my @identify_fields = ();

   if ( $#identify_arr > 0 ) { print STDERR "Error... (ImgStats can only handle one page image files).\n"; return -1; }

   $identify_line = pop(@identify_arr);
   @identify_fields = split(/\s+/, $identify_line);
   ($width,$height) = split("x", $identify_fields[2]);

   return($width,$height);
}

sub PS2PDF()
{
   my($psfile,$pdffile,$rotate) = @_;
   my $tmp = '';

   if ( $rotate eq 'R' )
   { $orientation = 3; }
   elsif ( $rotate eq 'L' )
   { $orientation = 1; }
   elsif ( $rotate eq 'U' )
   { $orientation = 2; }
   else
   { $orientation = 0; }

   $tmp = "/usr/bin/gs";
   $tmp = $tmp.' -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=pdfwrite';
   $tmp = $tmp.' -sOutputFile='.$pdffile.' -dAutoRotatePages=/None';
   $tmp = $tmp.' -c "<</Orientation '.$orientation.'>> setpagedevice"';
   $tmp = $tmp.' -f '.$psfile;
   #print "$tmp\n";
   system($tmp); 
}

sub PS2PNG()
{
   my $psfile = $_[0];
   my $pngfile = $_[1];
   my %options = %{$_[2]};
   my $owidth, $twidth;
   my $oheight, $theight;

   my($pswidth, $psheight) = &ImgWH($psfile);
   if ( $pswidth == -1 ) { die "Exiting..."; }

   if ( $pswidth >= $psheight )
   {
      # Landscape
      $owidth = 792;
      $oheight = 612;
   }
   else
   {
      # Portrait
      $owidth = 612;
      $oheight = 792;
   }

   if ( exists $options{"height"} && exists $options{"width"} ) 
   {
      $owidth = $options{"width"};
      $oheight = $options{"height"};
   }

   $outtmp_pnmfile = "/tmp/outtmp_".int(10**8*rand()).".pnm";
   $tmp = '/usr/bin/pstopnm';
   $tmp = $tmp." -dpi 300 -stdout -portrait $psfile > $outtmp_pnmfile";
   #print "$tmp\n";
   system($tmp);

   $tmp = "/usr/bin/convert";
   $tmp = $tmp." -resize ".$owidth."x".$oheight;

   if ( $options{"rotate"} )
   {
     if ( $options{"rotate"} eq 'U' )
     { $rotatedegrees = '180'; }
     elsif ( $options{"rotate"} eq 'R' )
     { $rotatedegrees = '90'; }
     elsif ( $options{"rotate"} eq 'L' )
     { $rotatedegrees = '-90'; }

     $tmp = $tmp." -rotate $rotatedegrees";
   }

   if ( $options{"depth"} )
   { $tmp = "${tmp} -depth ".$options{"depth"}; }
   if ( $options{"trim"} )
   { $tmp = "${tmp} -trim"; }
   if ( $options{"trimmargin"} )
   { $tmp = "${tmp} -trim -bordercolor White -border 20x20 +repage"; }
   $tmp = "${tmp} $outtmp_pnmfile $pngfile";

   #print "$tmp\n";
   system($tmp);

   unlink($outtmp_pnmfile);
}

sub PSSeparate()
{
   my($infile) = @_;

   my @identify_arr = &ImgIdentify($infile);
   my $outfile;
   my @outfiles;
   my $tmp;

   for ( $i=0; $i<=$#identify_arr; $i++ )
   {
      $outfile = "/tmp/tmp_".int(10**8*rand()).".ps";
      $tmp = "/usr/bin/psselect";
      $tmp = $tmp." -p".($i+1)." $infile $outfile";
      $tmp = $tmp." >& /dev/null";
      #print "$tmp\n";
      system($tmp);
      push(@outfiles, $outfile);
   }

   return(@outfiles);

}

sub round {
    my($number) = shift; 
    return int($number + .5);
}

sub showargs()
{
   print "\n#########################\n";
   print "convert_ps\n";
   print "#########################\n\n";
   print "Convert ps to png or pdf. The program will create the output file\n";
   print "specified. If no output file is specified, the program will create\n";
   print "a png or pdf file depending on the option specified.\n";
   print "If no output option is specified, this menu is displayed.\n\n";
   print "Options:\n\n";
   print "-depth=[depth number]\n";
   print "     Specify the bit depth of colors. This keyword\n";
   print "     only applies to PNG files.\n\n";
   print "-f, -infile=[ps file]\n";
   print "     Postscript file to convert.\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-height=[height]\n";
   print "     Specify the height, in pixels, of the output file.\n";
   print "     This keyword only applies to PNG files.\n\n";
   print "-o, -outfile=[output file]\n";
   print "     Specify the output file. If this keyword is specified,\n";
   print "     it obtains the file extension of the output file. This\n";
   print "     keyword overrides the -png and -pdf options.\n\n";
   print "-png\n";
   print "     If this keyword is specified and -outfile and -pdf options\n";
   print "     not specified, then a png file will be created in the same\n";
   print "     directory as the input file. The output file will have the\n";
   print "     same name as the input file but with a .png extension.\n";
   print "     Note: The -outfile overrides this option.\n\n";
   print "-pdf\n";
   print "     If this keyword is specified and -outfile and -png options\n";
   print "     not specified, then a pdf file will be created in the same\n";
   print "     directory as the input file. The output file will have the\n";
   print "     same name as the input file but with a .pdf extension.\n";
   print "     Note: The -outfile overrides this option.\n\n";
   print "-optimization=[optimization]\n";
   print "     This keyword is depreciated and no longer has an effect.\n";
   print "     Specify the optimization for the output image. The options are\n";
   print "     'quality' (default) and 'speed'. This arugemnt only affects\n";
   print "     PNG output.\n\n";
   print "-rotate=[rotation]\n";
   print "     Rotate the image. The options are 'L' (counter clockwise by\n";
   print "     90 degrees ), 'R' ( clockwise by 90 degrees ), and\n";
   print "     'U' ( rotate by 180 degrees ).\n";
   print "     NOTE: This parameter only applies to PNG output.\n\n";
   print "-trim\n";
   print "     If this keyword is specified then remove any edges that are\n";
   print "     exactly the same color as the corner pixels\n";
   print "     Note: This only works with png output. Also, this argument\n";
   print "     takes precedence over height and width arguments.\n\n";
   print "-trimmargin\n";
   print "     Similar to -trim, except leave a 20 pixel white margin\n";
   print "     around the image.  That is, it doesn't trim\n";
   print "     as severely as -trim does, leaving some blank space around\n";
   print "     the image.\n\n";
   print "-width=[width]\n";
   print "     Specify the width, in pixels, of the output file.\n";
   print "     This keyword only applies to PNG files.\n";
   exit;
}
