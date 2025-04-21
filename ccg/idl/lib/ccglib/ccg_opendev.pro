;+
; NAME:
;   CCG_OPENDEV
;
; PURPOSE:
;    Creates a LANDSCAPE or PORTRAIT graphics file according to 
;   the passed user selection.  Procedure accounts 
;   for color capabilities of selected graphics option.
;
;   This procedure loads a default CCG colormap.  Users may
;   pass a file describing an alternative colormap or may
;   overwrite the default colormap following the call to
;   CCG_OPENDEV.  The IDL routine 'CCG_EX_COLOR' provides a 
;   table of colors from the default color map.
;
;   This procedure is intended to be used with CCG_CLOSEDEV.
;
; CATEGORY:
;   Graphics.
;
; CALLING SEQUENCE:
;   CCG_OPENDEV,dev=dev,pen=pen,pcolor=pcolor,win=win,saveas=file
;   CCG_OPENDEV,dev=dev,pen=pen,portrait=1
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
;   backstore:
;      If this keyword is set then backstoring
;      will be maintained by IDL instead of
;      the windowing environment.  This option may
;      be required for some IDL sessions running
;      in an emulated X-window environment.
;
;      As of 2008-03-25 this keyword is set in code.
;      There is evidence that newer Linux operating
;      systems are not managing back store reliably.
;
;      2008-03-25 - kam
;
;   colormap:
;      Set this keyword to specify the name of a text
;      file that defines a colormap.  This file should
;      be constructed with the CCG_RGBSAVE procedure.
;   bw:
;      If set to one (1) then colormap 0 (bw) will be loaded.
;   iconify:
;      This keyword applies to the IDL X-window only.
;      If set then the IDL X-window is opened but
;      set as an icon.
;   landscape:
;      If set to one (1) then graphics device will be
;      set to landscape.  Default.
;   portrait:
;      If set to one (1) then graphics device will be
;      set to portrait.
;   saveas:
;      Save the graphics file in a user-provided file
;      name. saveas must also be passed to CCG_CLOSEDEV.
;   title:   
;      Set this keyword to specify the name of the IDL
;      graphics window.  If not specified, the window
;      is given a label of the form "IDL n" where n is
;      the index number of the window.
;       win:    
;      Set this keyword to specify graphics window. 
;      If set to -1 then the IDL graphics window will
;      NOT be opened.  The default is set to win=0, e.g.,
;      IDL's default window.
;   xpixels:
;      Number of pixels in 'x' direction of IDL
;      X-window display.
;   ypixels:
;      Number of pixels in 'y' direction of IDL
;      X-window display.
;
; OUTPUTS:
;
;   pen:   
;      Array corresponding to the RGB color indices
;      set by the default color map.
;
;   pcolor: 
;      String vector containing a partial list of color names.
;
;      Note:  Users may use this procedure and choose to
;      overwrite the default colormap.  This is accomplished
;      by a first calling CCG_OPENDEV and then overwriting
;      the current colormap with another map.  However, the
;      'pen' vector may yield un-expected results.
;
;      The IDL routine 'CCG_EX_COLOR' provides a table of
;      colors from the default color map.
;
; COMMON BLOCKS:
;   None.
;      
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   None.
;
; PROCEDURE:
;   Example implementation:
;
;      PRO example, dev=dev
;      .
;      .
;      .
;      CCG_OPENDEV,dev=dev,pen=pen,pcolor=pcolor
;      .
;      .
;      PLOT,x,y,PSYM=4,COLOR=pen(5)
;      XYOUTS,xnot,ynot,'test',COLOR=pen(2)
;      .
;      .
;      .
;      CCG_CLOSEDEV,dev=dev
;      END
;
;   From the IDL command line, the
;   procedure can be executed as 
;   follows:
;   
;   IDL>example                   <- sends graphics to X-window
;   IDL>example,dev="phaser850"   <- sends graphics to color PHASER 850
;   IDL>example,dev="png"         <- sends graphics to color png
;
;      
; MODIFICATION HISTORY:
;   Written,  KAM, April 1993.
;   Modified, KAM, November 1995.
;   Modified, KAM, March 1996.
;   Modified, KAM, October 1996.
;   Modified, KAM, September 1997.
;   Modified, KAM, June 1998.
;   Modified, KAM, December 1998.
;   Modified, KAM, March 1999.
;   Modified, KAM, December 2000.
;   Modified, KAM, June 2007.
;-

PRO DEVICE_X, k

   SET_PLOT, 'X'
   DEVICE, decomposed = 0, cursor_standard = 2

   IF k.win EQ -1 THEN RETURN

   WINDOW, k.win, title = k.title, xsize = k.xpixels, ysize = k.ypixels, retain = k.retain
   ERASE
   WSHOW, iconic = k.iconify

END

PRO DEVICE_PS, k

   e = { BITS:8, LANGUAGE_LEVEL:2 }

   IF k.font NE '' THEN BEGIN
         !P.FONT = 1
         e = CREATE_STRUCT(e, { SET_FONT:k.font, TT_FONT:1 })
   ENDIF

   IF k.xsize NE 0 THEN e = CREATE_STRUCT(e, { XSIZE:k.xsize })
   IF k.ysize NE 0 THEN e = CREATE_STRUCT(e, { YSIZE:k.ysize })
   IF k.xoffset NE 0 THEN e = CREATE_STRUCT(e, { XOFFSET:k.xoffset })
   IF k.yoffset NE 0 THEN e = CREATE_STRUCT(e, { YOFFSET:k.yoffset })

   SET_PLOT, 'PS'

   DEVICE, FILENAME = k.saveas, COLOR = k.color, $
   LANDSCAPE = k.landscape, $
   PORTRAIT = k.portrait, $
   ENCAPSULATED = k.encapsulated, $
   PREVIEW = k.preview, $
   _EXTRA = e

END

PRO   CCG_OPENDEV, $

      ; input keywords

      dev=dev, $
      saveas=saveas,win=win,$
      colormap=colormap,$
      backstore=backstore,$
      landscape=landscape,$
      portrait=portrait,$
      bw = bw, $
      font=font,$
      title=title,$
      iconify=iconify,$
      yoffset=yoffset,ysize=ysize,$
      xoffset=xoffset,xsize=xsize,$
      xpixels=xpixels,ypixels=ypixels, $

      ; return keywords

      pen = pen, pcolor = pcolor, $
      keys = keys, $

      help = help

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   ;
   ;----------------------------------------------- begin set up plot device 
   ;

   win = KEYWORD_SET(win) ? win : 0
   dev = KEYWORD_SET(dev) ? dev : ""
   idldir = '/ccg/idl/lib/ccglib/'
   colormap = KEYWORD_SET(colormap) ? colormap : idldir + 'data/color_comb1'
   bw = KEYWORD_SET(bw) ? 1 : 0
   portrait = CCG_VDEF(portrait) ? portrait : 0

   ; IDL is the most reliable "manager" of backing store, 
   ; but it is not as efficient a manager as the operating system.
   ;
   ; Historically, I let the operating system manage backing store
   ; for the above reason.  Recently, it seems that the o.s. is not
   ; always managing backing store properly.  Today, I will change
   ; the default status so that retain=2 instead of retain=1.
   ; 2008-03-25 - kam
   ;
   ; backstore = KEYWORD_SET(backstore) ? 1 : 0

   backstore = 1
   retain = backstore EQ 1 ? 2 : 1

   landscape = portrait EQ 1 ? 0 : 1
   iconify = KEYWORD_SET(iconify) ? 1 : 0
   title = KEYWORD_SET(title) ? title : ""
   font = KEYWORD_SET(font) ? font : ""

   sdev = dev EQ 'psc' ? 'ps' : dev
   saveas = KEYWORD_SET(saveas) ? saveas : GETENV("HOME") + '/idl.' + sdev
    
   ;units are cm

   xsize = KEYWORD_SET(xsize) ? xsize : 24.25 * landscape + 18 * portrait
   ysize = KEYWORD_SET(ysize) ? ysize : 17.75 * landscape + 22 * portrait

   xoffset = KEYWORD_SET(xoffset) ? xoffset : 0 * landscape + 2 * portrait
   yoffset = KEYWORD_SET(yoffset) ? yoffset : 0 * landscape + 3 * portrait

   ;units are px

   xpixels = KEYWORD_SET(xpixels) ? xpixels : 640 * landscape + 512 * portrait
   ypixels = KEYWORD_SET(ypixels) ? ypixels : 512 * landscape + 640 * portrait
    
   ; Devices

   ps_bw = ['ps', 'lj5', 'lj5_s', 'canon', 'canon_s', 'culj4000', 'o3lj', 'o3lj_s', $
                'GD405', 'bw1_2d', 'bw1_2d_s', 'bw1_3d', 'bw1_3d_s']

   ps_color = ['psc', 'phaser840', 'phaser840_s', 'phaser850', 'phaser850_s', $
               '2d_color', '3d_color', 'color_2d_2', 'color_2d_2_s', 'color_3d_2', 'color_3d_2_s', $
               'Color2d_grad', 'Color2d_grad_s', 'hp4600', 'eps', 'pdf', 'png', 'png_pdf']

   ; device color capabilities

   color = TOTAL(STRCMP(ps_bw, dev, /FOLD_CASE)) EQ 0 ? 1 : 0
   color = TOTAL(STRCMP(ps_color, dev, /FOLD_CASE)) NE 0 ? 1 : 0
   color = DEV EQ "" ? 1 : color

   ; This overwrites device color capabilities

   color = bw EQ 1 ? 0 : color

   ;EPS specifics

   encapsulated = dev EQ 'eps' ? 1 : 0
   preview = dev EQ 'eps' ? 1 : 0

   !P.MULTI = 0
   !P.FONT = (-1)
   ncolors = 256

   ; Build structure

   keys = CREATE_STRUCT('dev', dev, 'saveas', saveas, $
   'landscape', landscape, 'portrait', portrait, $
   'xsize', xsize, 'ysize', ysize, 'xoffset', xoffset, 'yoffset', yoffset, $
   'xpixels', xpixels, 'ypixels', ypixels, $
   'font', font, 'colormap', colormap, 'backstore', backstore, $
   'iconify', iconify, 'title', title, 'win', win, 'retain', retain, $
   'preview', preview, 'encapsulated', encapsulated, 'color', color)

   ; Color considerations

   IF color EQ 0 THEN BEGIN

      pen = MAKE_ARRAY(ncolors, /INT, VALUE=1)
      pcol = MAKE_ARRAY(ncolors, /STR, VALUE="BLACK")

   ENDIF ELSE BEGIN

      pen = [-1,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
      pcol = ["N/A","BLACK","RED","CYAN","GREEN",$
               "BLUE","MAGENTA","PURPLE 1","GRAY",$
               "LIME","CINNAMON","ORANGE","PURPLE 2",$
               "YELLOW","WHITE"]

      n = N_ELEMENTS(pen)

      pen = [pen, INDGEN(ncolors - n) + n]
      pcol = [pcol, MAKE_ARRAY(ncolors - n, /STR, VALUE="UNDEFINED")]
      
      ; invert black/white when device is X

      IF dev EQ "" THEN BEGIN
         pen[1] = 14 & pen[14] = 1
         pcol[1] = "WHITE" & pcol[14] = "BLACK"
      ENDIF

   ENDELSE

   ; Device-specific Commands

   IF dev EQ "" THEN funct = 'device_x' ELSE funct = 'device_ps'
   CALL_PROCEDURE, funct, keys

   IF bw EQ 0 THEN CCG_RGBLOAD, file = keys.colormap ELSE LOADCT, 0
END
