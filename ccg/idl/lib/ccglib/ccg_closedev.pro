;+
; NAME:
;   CCG_CLOSEDEV
;
; PURPOSE:
;    Closes a graphics file type specified by 
;   the passed user selection.  Procedure accounts 
;   for color capabilities of selected graphics option.
;   This procedure is intended to be used with CCG_OPENDEV.
;
;   See CCG_OPENDEV for details.
;
; CATEGORY:
;   Graphics.
;
; CALLING SEQUENCE:
;   CCG_CLOSEDEV,dev=dev
;
; INPUTS:
;   dev:           Specifies the requested graphics option.
;                  Current options are:
;   
;      *** SAVED AS GRAPHICS FILES ***
;
;   ps:            b/w POSTSCRIPT file
;   psc:           color POSTSCRIPT DEVICE file
;   eps:           ENCAPSULATED POSTSCRIPT file
;   png:           PNG (Portable Network Graphics) file (color unless bw=1)
;   pdf:           PDF (Portable Document Format) file (color unless bw=1)
;   png_pdf:       PNG, PSC and PDF (color unless bw=1)
;
;   NOTE:   When a device from the above list is 
;           selected, the file is saved as 'idl.[dev]' 
;           in the   users HOME directory unless an alternate
;           destination has been specified using the
;           'saveas' keyword.
;
;      *** SENT TO SPECIFIC GRAPHICS DEVICES ***
;
;   lj5:           b/w POSTSCRIPT file sent to HP LJ5 (2D701)
;   lj5_s:         b/w POSTSCRIPT file sent to HP LJ5 (2D701, simplex)
;   canon:         b/w POSTSCRIPT file sent to CI550 (3D409)
;   canon_s:       b/w POSTSCRIPT file sent to CI550 (3D409, simplex)
;   culj4000:      b/w POSTSCRIPT file sent to HP4000 (CU/INSTAAR)
;   o3lj:          b/w POSTSCRIPT file sent to HP8000 (3D503)
;   o3lj_s:        b/w POSTSCRIPT file sent to HP8000 (3D503, simplex)
;   lj8000_1:      b/w POSTSCRIPT file sent to HP8000 (3D409)
;   lj8000_2:      b/w POSTSCRIPT file sent to HP8000 (3D409)
;   lj8000_3d:     b/w POSTSCRIPT file sent to either HP8000 (3D409)
;   lj8000_3d_s:   b/w POSTSCRIPT file sent to either HP8000 (3D409, simplex)
;   lj8000_3:      b/w POSTSCRIPT file sent to HP8000 (2D701)
;   lj8000_2d:     b/w POSTSCRIPT file sent to HP8000 (2D701)
;   lj8000_2d_s:   b/w POSTSCRIPT file sent to HP8000 (2D701, simplex)
;   bw1_2d:        b/w POSTSCRIPT file sent to CANON C2030 (2D701)
;   bw1_2d_s:      b/w POSTSCRIPT file sent to CANON C2030 (2D701, simplex)
;   bw1_3d:        b/w POSTSCRIPT file sent to SHARP (3D409)
;   bw1_3d_s:      b/w POSTSCRIPT file sent to SHARP (3D409, simplex)
;   GD405:         b/w POSTSCRIPT file sent to HP8000 (GC405)
;
;   phaser840:     color POSTSCRIPT file sent to TK PHASER 840 (3D409)
;   phaser840_s:   color POSTSCRIPT file sent to TK PHASER 840 (3D409, simplex)
;   phaser840t:    color POSTSCRIPT file sent to TK PHASER 840 (3D409, transparency)
;   phaser850:     color POSTSCRIPT file sent to TK PHASER 850 (2D701)
;   phaser850_s:   color POSTSCRIPT file sent to TK PHASER 850 (2D701, simplex)
;   phaser850t:    color POSTSCRIPT file sent to TK PHASER 850 (2D701,transparency)
;   2d_color:    color POSTSCRIPT file sent to Xerox WorkCentre EC7856 (2D701)
;   3d_color:    color POSTSCRIPT file sent to Xerox WorkCentre EC7856 (3D409)
;   color_2d_2:    color POSTSCRIPT file sent to CANON C2030 (2D701)
;   color_2d_2_s:  color POSTSCRIPT file sent to CANON C2030 (2D701, simplex)
;   Color2d_grad:  color POSTSCRIPT file sent to TK PHASER 6360 (2D403)
;   Color2d_grad_s:color POSTSCRIPT file sent to TK PHASER 6360 (2D403, simplex)
;   hp4600:        color POSTSCRIPT file sent to HP4600 (CU/INSTAAR)
;
; OPTIONAL INPUT PARAMETERS:
;   saveas:   Destination graphics file.  If not specified
;             then the default idl.[dev] file is placed in 
;             the user's home directory.
;
;   depth:    Specify the bit depth of colors. Applies only to PNG device. 
;
;   height:   Specify the height, in pixels, of the output image. 
;             Applies only to PNG device. 
;
;   optimization:  Optimize output image for speed or quality (default).
;             (ex) optimization='speed' or optimization='quality'
;
;   width:    Specify the width, in pixels, of the output image. 
;             Applies only to PNG device. 
;
;   /TRIM:    Trim the image to remove excess white space, leaving a 20 pixel margin 
;             around image.  Applies only to PNG device.
;
; OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   Must be used with CCG_OPENDEV
;
; PROCEDURE:
;   Example implementation:
;
;      PRO example, dev=dev
;      .
;      .
;      .
;      CCG_OPENDEV,dev=dev,pen=pen,saveas='graphicsfile'
;      .
;      .
;      PLOT,x,y,PSYM=4,COLOR=pen(5)
;      XYOUTS,xnot,ynot,'test',COLOR=pen(2)
;      .
;      .
;      .
;      CCG_CLOSEDEV,dev=dev,saveas='graphicsfile'
;      END
;
;   From the IDL command line, the
;   example procedure can be executed
;   as follows:
;   
;   IDL>example                   <- sends graphics to X-window
;   IDL>example,dev="phaser850"   <- sends graphics to phaser 850
;   IDL>example,dev="psc"         <- sends graphics to color postscript file
;
;      
; MODIFICATION HISTORY:
;   Written,  KAM, April 1993.
;   Modified, KAM, November 1995.
;   Modified, KAM, October 1996.
;   Modified, KAM, June 1998.
;   Modified, KAM, March 1999.
;   Modified, KAM, December 2000.
;   Modified, KAM, June 2007.
;   Modified, KWT, Jan 2016.
;-
PRO CCG_CLOSEDEV, $
    dev = dev, $
    saveas = saveas, $
    xpixels = xpixels, $
    ypixels = ypixels, $
    width = width, $
    height = height, $
    depth = depth, $
    keys = keys, $
    optimization=optimization, $
    trim = trim, $
    help = help
   ;
   ;------------------------------------------------ begin close plot device 
   ;
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC

   IF NOT KEYWORD_SET(dev) THEN RETURN

   remove = 1
   
   sdev = dev EQ 'psc' ? 'ps' : dev
   saveas = KEYWORD_SET(saveas) ? saveas : GETENV("HOME") + '/idl.' + sdev
   idldir = '/ccg/idl/lib/ccglib/'
   perl = idldir + 'src/perl/convert_ps.pl'

   ;units are px

   landscape = !D.x_size / !D.y_size GE 1 ? 1 : 0
   portrait = landscape EQ 0 ? 1 : 0

   xpixels = KEYWORD_SET(xpixels) ? xpixels : 640 * landscape + 512 * portrait
   ypixels = KEYWORD_SET(ypixels) ? xpixels : 512 * landscape + 640 * portrait

   DEVICE, /CLOSE

   nb=' -o job-sheets=none '
   dp=' -o sides=two-sided-long-edge '
   sp=' -o sides=one-sided '
   tr=' -o media=Letter,Transparency '
   rot = (landscape EQ 1) ? "-rotate=L" : ""

   soptimization = KEYWORD_SET(optimization) ? STRCOMPRESS('-optimization='+optimization,/RE) : '';

   CASE dev OF
   'ps':      BEGIN
         CCG_MESSAGE, 'File stored as ' + saveas + ' (b&w)'
         remove = 0
         END
   'psc':      BEGIN
         CCG_MESSAGE, 'File stored as ' + saveas + ' (color)'
         remove = 0
         END
   'eps':      BEGIN
         CCG_MESSAGE, 'File stored as '  +saveas
         remove = 0
         END
   'png':      BEGIN
         z = CCG_TMPNAM()
         SPAWN, 'mv -f ' + saveas + ' ' + z

         width = KEYWORD_SET(width) ? ' -width=' + STRCOMPRESS(STRING(width),/RE) : ''
         height = KEYWORD_SET(height) ? ' -height=' + STRCOMPRESS(STRING(height),/RE) : ''
         depth = KEYWORD_SET(depth) ? ' -depth=' + STRCOMPRESS(STRING(depth),/RE) : ''
         trim = KEYWORD_SET(trim) ? ' -trimmargin' : ''
         
         SPAWN, perl + ' -infile=' + z + width + height + depth + ' -outfile=' + saveas + ' ' + rot + ' ' + soptimization + trim
         SPAWN, 'rm -f ' + z

         CCG_MESSAGE, 'File stored as ' + saveas
         remove = 0
         END
   'pdf':      BEGIN
         z = CCG_TMPNAM()
         SPAWN, 'mv -f ' + saveas + ' ' + z
         SPAWN, perl + ' -infile=' + z + ' -outfile=' + saveas + ' ' + rot
         SPAWN, 'rm -f ' + z

         CCG_MESSAGE, 'File stored as ' + saveas
         remove = 0
         END
   'png_pdf':  BEGIN
         tmp = STRSPLIT(saveas, dev, /EXTRACT, /REGEX)
         z = tmp[0] + 'ps'
         SPAWN, 'mv -f ' + saveas + ' ' + z

         ; Prepare png

         tmp = STRSPLIT(saveas, dev, /EXTRACT, /REGEX)
         saveas = tmp[0] + 'png'

         width = KEYWORD_SET(width) ? ' -width=' + STRCOMPRESS(STRING(width),/RE) : ''
         height = KEYWORD_SET(height) ? ' -height=' + STRCOMPRESS(STRING(height),/RE) : ''
         depth = KEYWORD_SET(depth) ? ' -depth=' + STRCOMPRESS(STRING(depth),/RE) : ''
         trim = KEYWORD_SET(trim) ? ' -trimmargin' : ''
         
         SPAWN, perl + ' -infile=' + z + width + height + depth + ' -outfile=' + saveas + ' ' + rot + ' ' + soptimization + trim
         CCG_MESSAGE, 'File stored as ' + saveas

         ; Prepare pdf

         tmp = STRSPLIT(saveas, 'png', /EXTRACT, /REGEX)
         saveas = tmp[0] + 'pdf'

         SPAWN, perl + ' -infile=' + z + ' -outfile=' + saveas + ' ' + rot

         CCG_MESSAGE, 'File stored as ' + saveas
         remove = 0
         END
   'lj5':            SPAWN, 'lp -dlj5' + nb + dp + saveas
   'lj5_s':          SPAWN, 'lp -dlj5' + nb + sp + saveas
   'lj5':            SPAWN, 'lp -dlj5' + nb + dp + saveas
   'lj5_s':          SPAWN, 'lp -dlj5' + nb + sp + saveas
   'canon':          SPAWN, 'lp -dcanon' + nb + dp + saveas
   'canon_s':        SPAWN, 'lp -dcanon' + nb + sp + saveas
   'culj4000':       SPAWN, 'lp -dculj4000' + nb + sp + saveas
   'o3lj':           SPAWN, 'lp -do3lj' + nb + dp + saveas
   'o3lj_s':         SPAWN, 'lp -do3lj' + nb + sp + saveas
   'GD405':          SPAWN, 'lp -dGD405' +  nb + sp + saveas
   'phaser840':      SPAWN, 'lp -dphaser840' + nb + dp + saveas
   'phaser840_s':    SPAWN, 'lp -dphaser840' + nb + sp + saveas
   'color_3d_2':      SPAWN, 'lp -dcolor_3d_2' + nb + dp + saveas
   'color_3d_2_s':    SPAWN, 'lp -dcolor_3d_2' + nb + sp + saveas

   ; Recent problem developed for Tom Conway.  When he specifies
   ; dev='phaser850', the printer receives a segmentation fault and
   ; reboots.  This does not happen when color_2d is used, which,
   ; in theory, is an alias for phaser850.  To fix this problem,
   ; I replace the printer specified in the SPAWN command.  James
   ; Salzman does not understand the cause of this problem, which
   ; developed about a month ago.  2011-09-09 (kam)
   ;'phaser850':      SPAWN, 'lp -dphaser850' + nb + dp + saveas

   'phaser850':      SPAWN, 'lp -dcolor_2d' + nb + dp + saveas
   'phaser850_s':    SPAWN, 'lp -dcolor_2d' + nb + sp + saveas
   'color_2d_2':      SPAWN, 'lp -dcolor_2d_2' + nb + dp + saveas
   'color_2d_2_s':    SPAWN, 'lp -dcolor_2d_2' + nb + sp + saveas
   '2d_color':    SPAWN, 'lp -d2d_color' + nb + sp + saveas
   '3d_color':    SPAWN, 'lp -d3d_color' + nb + sp + saveas
   'Color2d_grad':   SPAWN, 'lp -dColor2d_grad' + nb + dp + saveas
   'Color2d_grad_s': SPAWN, 'lp -dColor2d_grad' + nb + sp + saveas
   'hp4600':         SPAWN, 'lp -dHP4600' + nb + saveas
   'bw1_2d':         SPAWN, 'lp -dbw1_2d' + nb + dp + saveas
   'bw1_2d_s':       SPAWN, 'lp -dbw1_2d' + nb + sp + saveas
   'bw1_3d':         SPAWN, 'lp -dbw1_3d' + nb + dp + saveas
   'bw1_3d_s':       SPAWN, 'lp -dbw1_3d' + nb + sp + saveas
   ELSE:             CCG_FATALERR, dev + ' device not recognized.'
   ENDCASE
    
   ;Remove file?
    
   IF remove THEN SPAWN, '/bin/rm -f ' + saveas
    
   ;Set graphics to 'X'
    
   SET_PLOT, 'X'
END
