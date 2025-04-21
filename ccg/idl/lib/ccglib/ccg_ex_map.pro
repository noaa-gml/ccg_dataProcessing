;+
PRO 	CCG_EX_MAP,$
	title=title,$
	transparency=transparency,$
	nonames=nonames,$
	dev=dev,$
	nolabid=nolabid,$
	noproid=noproid
;
;-----------------------------------------------procedure description 
;
;Create NOAA/CMDL Cooperative
;Air Sampling Network map.
;
;Data reside in .../data/map.dat
;Data reside in .../data/opc.leg1.dat
;Data reside in .../data/opc.leg2.dat
;Data reside in .../data/scs.dat
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;----------------------------------------------- misc initialization
;
IF KEYWORD_SET(nonames) THEN nonames=1 ELSE nonames=0

IF NOT KEYWORD_SET(title) THEN $
	title='NOAA CMDL Carbon Cycle Group MEASUREMENT PROGRAMS'

IF KEYWORD_SET(transparency) THEN BEGIN
	charsize=2.0
	charthick=6.0
	ycharsize=1.15
	ythick=6.0
	xcharsize=1.1
	xthick=6.0
ENDIF ELSE BEGIN
	charthick=2.0
	charsize=1.5
	ycharsize=1.0
	ythick=2.0
	xcharsize=1.0
	xthick=2.0
ENDELSE
;
;----------------------------------------------- set up plot DEVICE 
;
CCG_OPENDEV,	dev=dev,pen=pen,xpixels=800,ypixels=600
;
;----------------------------------------------- define axes 
;
lat=[	'90!eo!nS','60!eo!nS','30!eo!nS','0!eo!n',$
	'30!eo!nN','60!eo!nN','90!eo!nN']

long=[	'100!eo!nE','140!eo!nE','180!eo!n','140!eo!nW',$
	'100!eo!nW','60!eo!nW','20!eo!nW','20!eo!nE',$
	'60!eo!nE','100!eo!nE']

nolat=MAKE_ARRAY(N_ELEMENTS(lat),/STR,VALUE=' ')
nolong=MAKE_ARRAY(N_ELEMENTS(long),/STR,VALUE=' ')

;
;----------------------------------------------- draw general map 
;
MAP_SET,   	0,-80,$
		/CONT,$
 	 	/CYL,$
		POSITION=[.06,.06,.94,.94],$
	 	MLINETHICK=2.0,$
	 	/NOBORDER,$
		CHARSIZE=charsize,$
	 	CON_COLOR=pen(1)
;
;Put on title
;
XYOUTS,	0.5,0.97,/NORMAL,$
	title,$
	COLOR=pen(1),$
	CHARSIZE=charsize,$
	CHARTHICK=charthick,$
	ALI=0.5

;
;label bottom and left axes
;
AXIS,		YSTYLE = 1, $
		YAXIS = 0, $
		YTHICK=ythick,$
		YCHARSIZE=ycharsize,$
		CHARTHICK=charthick,$
		CHARSIZE=charsize,$
		YMINOR = 3, $
		COLOR=pen(1),$
		YTICKS = 6, $
		YTICKLEN = -0.01, $
		YTICKNAME = lat

AXIS,		XSTYLE = 1, $
		XAXIS = 0, $
		XMINOR = 2, $
		COLOR=pen(1),$
		XTHICK=xthick,$
		XCHARSIZE=xcharsize,$
		CHARSIZE=charsize,$
		CHARTHICK=charthick,$
		XTICKS = 9, $
		XTICKLEN = -0.01, $
		XTICKNAME = long
;
;label right and top axes
;
AXIS,		YSTYLE = 1, $
		YAXIS = 1, $
		YMINOR = 3, $
		YTICKS = 6, $
		YTHICK=ythick,$
		COLOR=pen(1),$
		YCHARSIZE=ycharsize,$
		CHARTHICK=charthick,$
		CHARSIZE=charsize,$
		YTICKLEN = -0.01, $
		YTICKNAME = lat

AXIS,		XSTYLE = 1, $
		XAXIS = 1, $
		XMINOR = 2, $
		XTHICK=xthick,$
		COLOR=pen(1),$
		XCHARSIZE=xcharsize,$
		CHARSIZE=charsize,$
		CHARTHICK=charthick,$
		XTICKS = 9, $
		XTICKLEN = 0.01, $
		XTICKNAME = nolong
;
;----------------------------------------------- read data file
;
file=dir+'data/map.dat'
n=CCG_LIF(file=file)

names=STRARR(n)
pos=FLTARR(2,n)
offset=FLTARR(2,n)
align=FLTARR(n)
i=0 & u=0. & v=0. & w=0. & x=0. & y=0. & z=''

OPENR,unit,file, /GET_LUN
WHILE NOT EOF(unit) DO BEGIN
	READF,unit, x,y,u,v,w,z
	names(i)=z
	pos(0,i)=x
	offset(0,i)=u
	pos(1,i)=y
	offset(1,i)=v
	align(i)=w
	i=i+1
ENDWHILE
FREE_LUN, unit
;
;----------------------------------------------- define symbol and label map 
;
CCG_SYMBOL,	sym=2,fill=1
o=fltarr(2)
;
FOR i=0,n-1 DO BEGIN
	lon=pos(1,i)
	lat=pos(0,i)
	p=CONVERT_COORD(lon, lat, /DATA, /TO_DEVICE)
	o(0) = offset(0, i) * 5 * !D.Y_CH_SIZE / 4
	o(1) = offset(1, i) * 5 * !D.Y_CH_SIZE / 4

        IF names(i) EQ "  WLEF" OR $
	   names(i) EQ "  WITN" THEN BEGIN
		CCG_SYMBOL,	sym=3,fill=1
		PLOTS, p(0), p(1),/DEVICE,PSYM=8,COLOR=pen(4),SYMSIZE=4.0
	ENDIF
        IF names(i) EQ "  SOUTH POLE" OR $
	   names(i) EQ "  BARROW" OR $
           names(i) EQ "  SAMOA" OR $
	   names(i) EQ "  MAUNA LOA" THEN BEGIN
		CCG_SYMBOL,	sym=1,fill=1
		PLOTS, p(0), p(1),/DEVICE,PSYM=8,COLOR=pen(3),SYMSIZE=3.0
	ENDIF
	IF names(i) EQ "  CARR" OR $
	   names(i) EQ "  MAINE" OR $
	   names(i) EQ "  MOSCOW" THEN BEGIN
		CCG_SYMBOL,	sym=7,fill=1
		PLOTS, p(0), p(1),/DEVICE,PSYM=8,COLOR=pen(5),SYMSIZE=4.5
		IF NOT nonames THEN $
			XYOUTS, p(0) + o(0), p(1) + o(1), /DEVICE, names(i), $
			ALI=align(i),CHARSIZE=0.75, COLOR=pen(5)
	ENDIF ELSE BEGIN
		CCG_SYMBOL,	sym=2,fill=1
		PLOTS, p(0), p(1), /DEVICE, PSYM=8, COLOR=pen(2),SYMSIZE=1.5
		IF NOT nonames THEN $
			XYOUTS, p(0) + o(0), p(1) + o(1), /DEVICE, names(i), $
			ALI=align(i), CHARSIZE=0.75, COLOR=pen(2)
	ENDELSE
ENDFOR
;
;----------------------------------------------- Southland Star leg 1 (PAC) 
;
file=dir+'data/opc.leg1.dat'
CCG_FREAD,file=file,nc=2,data
n=N_ELEMENTS(data[0,*])

CCG_SYMBOL,	sym=2,fill=1
FOR i=0,n-1 DO BEGIN
	p=CONVERT_COORD(data(1,i), data(0,i), lat, /DATA, /TO_DEVICE)
	PLOTS, p(0), p(1), /DEVICE, PSYM=8, COLOR=pen(2),SYMSIZE=0.5;
ENDFOR

OPLOT, data(1,0:n-1), data(0,0:n-1), LINESTYLE=0, COLOR=pen(2)
;
;----------------------------------------------- Southland Star leg 2 (PAC) 
;
file=dir+'data/opc.leg2.dat'
CCG_FREAD,file=file,nc=2,data
n=N_ELEMENTS(data[0,*])

CCG_SYMBOL,	sym=2,fill=1

FOR i=0, n-1 DO BEGIN
	p=CONVERT_COORD(data(1,i), data(0,i), lat, /DATA, /TO_DEVICE)
 	PLOTS, p(0), p(1), /DEVICE, PSYM=8, COLOR=pen(2),SYMSIZE=0.5
ENDFOR

OPLOT, data(1,0:n-1), data(0,0:n-1), LINESTYLE=0, COLOR=pen(2)

p=CONVERT_COORD(-178, -30, /DATA, /TO_DEVICE)
IF NOT nonames THEN $
	XYOUTS, p(0), p(1), /DEVICE, $
	"PACIFIC OCEAN CRUISES",$
	ALI=0.0, SIZE=0.75, COLOR=pen(2)
;
;----------------------------------------------- South China Sea (SCS) 
;
file=dir+'data/scs.dat'
CCG_FREAD,file=file,nc=2,data
n=N_ELEMENTS(data[0,*])

CCG_SYMBOL,	sym=2,fill=1

FOR i=0, n-1 DO BEGIN
	p = CONVERT_COORD(data(1,i), data(0,i), lat, /DATA, /TO_DEVICE)
 	PLOTS, p(0), p(1), /DEVICE, PSYM=8, COLOR=pen(2),SYMSIZE=0.5
ENDFOR
OPLOT, data(1,0:n-1), data(0,0:n-1), LINESTYLE=0, COLOR=pen(2)
;
p=CONVERT_COORD(116, 19.25, /data, /TO_DEVICE)
IF NOT nonames THEN $
	XYOUTS, p(0), p(1),$
		/DEVICE,$
		"SOUTH CHINA SEA",$
		ALI=0.0,$
		SIZE=0.75,$
		COLOR=pen(2)
;
;------------------------------------------------ lab id
;
IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID,x=.93,y=0.09
;
;------------------------------------------------ lab id
;
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID,x=.07,y=0.08
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
