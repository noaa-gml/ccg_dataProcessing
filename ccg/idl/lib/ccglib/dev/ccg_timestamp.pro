;+
; NAME:
;   CCG_TIMESTAMP
;
; PURPOSE:
;    Place CCGG label and system
;   date or passed date in 
;   lower right of plot.
;
;   NOAA/ESRL/GMD Carbon Cycle
;   February 13, 1994
;
; CATEGORY:
;   Graphics.
;
; CALLING SEQUENCE:
;   CCG_TIMESTAMP
;   CCG_TIMESTAMP,   full=1
;   CCG_TIMESTAMP,   date=date,x=0.90,y=0.02
;   CCG_TIMESTAMP,   full=1,orientation=90,alignment=0.5,charsize=1.0
;
; INPUTS:
;   None.
;
; OPTIONAL INPUT PARAMETERS:
;   date:      Date in any string format.
;              ex:    date='January 19, 1999'
;                     date='JAN 1990'
;                     date='12-31-99'
;
;   x: y:      User-supplied coordinates for 
;              placement of lab label.
;              Specify in NORMAL coordinates   
;              i.e., bottom/left of plotting surface -> x=0,y=0 
;              top/right of plotting surface   -> x=1,y=1 
;
;              Default position coordinates
;              x=0.950
;              y=0.030
;
;   full:      If non=zero then full date and time format
;              is used, Mon Sep 19 15:18:02 1994.
;
;   orientation:   The lab identification and date may be
;              rotated by any angle.  See IDL manual
;              for acceptable values.
;
;              Default: orientation=0 
;            
;   alignment: Alignment (justification) of the lab identification 
;              and date may be   specified.  See IDL manual
;              for acceptable values.
;
;              Default: alignment=1
;            
;   charsize:  Character size of the lab identification 
;              and date may be   specified.  See IDL manual
;              for acceptable values.
;
;              Default: charsize=0.75
;            
;   charthick: Character thickness of the lab identification 
;              and date may be   specified.  See IDL manual
;              for acceptable values.
;
;              Default: charsize=0.75
;
;   color:     [0-255]
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
;   None.
;
; PROCEDURE:
;   Example:
;
;      PRO example,labid=labid
;      .
;      .
;      .
;      PLOT,[0,0],[1,1]
;      .
;      .
;      .
;      IF NOT KEYWORD_SET(labid) THEN CCG_TIMESTAMP,date='February 1994'
;               or
;      IF NOT KEYWORD_SET(labid) THEN CCG_TIMESTAMP,full=1
;      
;      note:
;         using the KEYWORD_SET with the variable 'labid'
;         allows the user to omit the label by specifying
;         labid=1 when the example procedure is invoked.
;      .
;      .
;      .
;      END
;      
; MODIFICATION HISTORY:
;   Written, KAM, February 1994.
;   Modified, KAM, June 1996.
;-
;
PRO    CCG_TIMESTAMP, $
   x = x, $
   y = y, $
   full = full, $
   charsize = charsize, $
   charthick = charthick, $
   color = color, $
   data = data, $
   normal = normal, $
   device = device, $
   ori = ori, $
   ali = ali, $
   text = text, $
   help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
 
;return to caller if an error occurs
 
ON_ERROR,2   
 
; Initialize

ali = CCG_VDEF(ali) ? ali : 0.0
ori = CCG_VDEF(ori) ? ori : 90
charsize = KEYWORD_SET(charsize) ? charsize : 0.75
charthick = KEYWORD_SET(charthick) ? charthick : 1.0
color = KEYWORD_SET(color) ? color : !P.COLOR
data = CCG_VDEF(data) ? 1 : 0
normal = CCG_VDEF(normal) ? 1 : 0
device = CCG_VDEF(device) ? 1 : 0

IF NOT CCG_VDEF(x) OR NOT CCG_VDEF(y) THEN BEGIN

   aspect = !D.X_SIZE / FLOAT(!D.Y_SIZE)

   xy = CONVERT_COORD(!X.CRANGE, !Y.CRANGE, /DATA, /TO_DEVICE)

   dx = xy[0, 1] - xy[0, 0]
   dy = xy[1, 1] - xy[1, 0]

   x = xy[0, 1] + 0.03 * dx / aspect
   y = xy[1, 0] + 0.01 * dy / aspect

   xy = CONVERT_COORD(x, y, /DEVICE, /TO_NORMAL)
   x = xy[0] & y = xy[1]

   normal = 1 & data = 0 & device = 0

ENDIF


IF NOT KEYWORD_SET(text) THEN BEGIN
    
   today = CCG_SYSDATE()
    
   text = KEYWORD_SET(full) ? today.s9 : today.s4
   text = 'NOAA/ESRL Carbon Cycle, ' + text + '!3'

ENDIF

XYOUTS, x,y,$
   normal = normal, $
   data = data, $
   device = device, $
   text, $
   ALI=ali,$
   COLOR=color,$
   ORI=ori,$
   CHARTHICK=charthick, $
   CHARSIZE=charsize
END
