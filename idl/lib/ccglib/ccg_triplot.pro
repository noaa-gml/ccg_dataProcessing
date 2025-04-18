;+
; NAME:
;	CCG_TRIPLOT
;
; PURPOSE:
;	Generates stacked plots of co2 mixing ratio, c13 and o18 for 
;	a CCG site.  By default, retained, non-background and rejected
;	data are plotted, default axis scales are used, and offscale 
;       values are plotted at ymin or ymax.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_TRIPLOT,    dev=dev, site=site, title=title, $
;			fyear=fyear, lyear=lyear, $
;			co2y=co2y, c13y=c13y, o18y=o18y, $
;			noret=noret, nonbg=nonbg, norej=norej, nooff=nooff, $
;			co2fit=co2fit, c13fit=c13fit, o18fit=o18fit, $
;			legendxy=legendxy, nolegend=nolegend, $
;			reclenxy=reclenxy, noreclen=noreclen, $
;			nolabid=nolabid
;
; INPUTS:
;    site: 	CCG site code (e.g. alt)
;
; OPTIONAL INPUT PARAMETERS:
;    dev:     	plotting device (must be recognized by CCG_OPENDEV)
;		
;    title:	plot title
;
;    fyear:	first year (begin plot at January 1 of fyear)
;
;    lyear:	last year (end plot at January 1 of lyear + 1)
;
;    co2y:	[ymin,ymax,yticks,yminor] for co2 plot
;		default is [340,380,2,4]
;
;    c13y:	[ymin,ymax,yticks,yminor] for c13 plot
;		default is [-9.0,-7.0,2,4]
;
;    o18y:	[ymin,ymax,yticks,yminor] for o18 plot
;		default is [-3.0,1.0,2,4]
;
;    noret:	don't plot retained data
;
;    nonbg:	don't plot non-background data
;
;    norej:	don't plot rejected data
;
;    nooff:	don't plot out-of-range values on ymin,ymax
;
;    co2fit:	plot co2 CCGVU smooth curve and trend (see below)
;		default parameters are [3,4,7, 80,667,1980]
;
;    c13fit:	plot c13 CCGVU smooth curve and trend (see below)
;		default parameters are [3,4,7,150,667,1980]
;
;    o18fit:	plot o18 CCGVU smooth curve and trend (see below)
;		default parameters are [3,2,7,150,667,1980]
;
;    legendxy:	location for legend (normal coords) in co2 plot
;		default is [0.24,0.90] ([x,y])
;
;    nolegend:	don't plot a symbol legend 
;
;    reclenxy:	location for record length legend (normal coords)
;		default is [0.70,0.72] ([x,y])
;
;    noreclen:	don't plot a record length legend
;
;    nolabid:	don't plot the CCG laboratory id
;
;	co2fit, c13fit, o18fit may be passed as: 
;	... a scalar (to use default CCGVU fitting parameters) or
;	... [npoly,nharm,interval,cutoff1,cutoff2,tzero]
;
; OUTPUTS: 
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	'site' must be a vaild CCG site with co2, c13 and o18 data
;
; PROCEDURE:
;	Example:
;		CCG_TRIPLOT, $
;			site='asc',fyear=1990,lyear=1997, $
;                       /norej,/nooff, $
;			/co2fit,/c13fit=[3,2,7,150,667,1980]
;		
; MODIFICATION HISTORY:
;	Written, mxt, January 1995
;-

;----------------------------------------------------------------
;--------------------------------  trim out-of range values  ----
;----------------------------------------------------------------

pro trim, arr=arr, min=min, max=max

; arguments: arr ........ array of values
;            min ........ minimum cutoff
;            max ........ maximum cutoff

offscale = where(arr lt min, n)
if (n gt 0) then arr(offscale) = min
offscale = where(arr gt max, n)
if (n gt 0) then arr(offscale) = max

end


;----------------------------------------------------------------
;---------------------------------------------  ccg_triplot  ----
;----------------------------------------------------------------

pro ccg_triplot, dev=dev, site=site, title=title, $
                 fyear=fyear, lyear=lyear, $
                 co2y=co2y, c13y=c13y, o18y=o18y, $
                 noret=noret, nonbg=nonbg, norej=norej, nooff=nooff, $
                 co2fit=co2fit, c13fit=c13fit, o18fit=o18fit, $
                 legendxy=legendxy, nolegend=nolegend, $
                 reclenxy=reclenxy, noreclen=noreclen, $
                 nolabid=nolabid
 
;-------------------------------------------------  check input parameters

shown = 3
if keyword_set(noret) then shown = shown - 1
if keyword_set(nonbg) then shown = shown - 1
if keyword_set(norej) then shown = shown - 1
if (shown eq 0) then begin
  ccg_message, "Nothing to plot - exiting ..." & return & endif
if not keyword_set(site) then begin
  ccg_message, "Site must be specified, e.g. site='brw' - exiting ..." & return & endif

if not keyword_set(title) then title = strupcase(site)
if keyword_set(co2fit) and n_elements(co2fit) lt 6 then co2fit = [3,4,7, 80,667,1980]
if keyword_set(c13fit) and n_elements(c13fit) lt 6 then c13fit = [3,4,7,150,667,1980]
if keyword_set(o18fit) and n_elements(o18fit) lt 6 then o18fit = [3,2,7,150,667,1980]

;-------------------------------------------------  some setup stuff

thick=2.0
labelsize=1.2
x = [0.20,0.94]
y = [0.16,0.40,0.42,0.66,0.68,0.92]
if not keyword_set(co2y) then co2y = [340,380,2,4]
if not keyword_set(c13y) then c13y = [-9.0,-7.0,2,4]
if not keyword_set(o18y) then o18y = [-3.0,1.0,2,4]
if not keyword_set(legendxy) then legendxy = [0.24,0.90]
if not keyword_set(reclenxy) then reclenxy = [0.70,0.72]

co2inc = (co2y(1) - co2y(0)) * 0.02
c13inc = (c13y(1) - c13y(0)) * 0.02
o18inc = (o18y(1) - o18y(0)) * 0.02

;-------------------------------------------------  read site files

ccg_flaskave, sp='co2', site=site, xretco2, yretco2, xnbgco2, ynbgco2, xrejco2, yrejco2
ccg_flaskave, sp='co2c13', site=site, xretc13, yretc13, xnbgc13, ynbgc13, xrejc13, yrejc13
ccg_flaskave, sp='co2o18', site=site, xreto18, yreto18, xnbgo18, ynbgo18, xrejo18, yrejo18

if not keyword_set(nooff) then begin
  trim, arr=yretco2, min=co2y(0)+co2inc, max=co2y(1)-co2inc
  trim, arr=yrejco2, min=co2y(0)+co2inc, max=co2y(1)-co2inc
  trim, arr=ynbgco2, min=co2y(0)+co2inc, max=co2y(1)-co2inc
  trim, arr=yretc13, min=c13y(0)+c13inc, max=c13y(1)-c13inc
  trim, arr=yrejc13, min=c13y(0)+c13inc, max=c13y(1)-c13inc
  trim, arr=ynbgc13, min=c13y(0)+c13inc, max=c13y(1)-c13inc
  trim, arr=yreto18, min=o18y(0)+o18inc, max=o18y(1)-o18inc
  trim, arr=yrejo18, min=o18y(0)+o18inc, max=o18y(1)-o18inc
  trim, arr=ynbgo18, min=o18y(0)+o18inc, max=o18y(1)-o18inc
endif

;-------------------------------------------------  set up graphics device 

ccg_opendev, dev=dev, pen=pen, /portrait, /backstore
!p.multi = [0,1,3]

;-------------------------------------------------  prepare x & y axis ranges & labels

co2start = floor(xretco2(0))
co2end = floor(xretco2(n_elements(xretco2)-1))

if not keyword_set(fyear) then fyear = co2start
if not keyword_set(lyear) then lyear = co2end + 1 else lyear = lyear + 1
nyears = lyear-fyear

yearval = indgen(nyears) + fyear
if (nyears gt 6) then yearval = yearval - 1900
years = strcompress(string(yearval),/remove_all)
if (nyears gt 12) then years(where(yearval mod 2 ne 0)) = ' '
blanks = make_array(nyears+1,/str,value=' ')

retsymbol=5  & retcolor=3
nbgsymbol=10 & nbgcolor=6
rejsymbol=11 & rejcolor=1

;-------------------------------------------------  plot co2 time series

plot, xretco2, yretco2, /nodata, color=pen(1), charsize=3.0, charthick=thick, $
  position=[x(0),y(4),x(1),y(5)], title=title, $
  xrange=[fyear,lyear], xstyle=1, xticks=nyears, xminor=1, xthick=thick, xtickname=blanks, $
  yrange=co2y(0:1), ystyle=1, yticks=co2y(2), yminor=co2y(3), ythick=thick, ytickformat='(i4)', $
  ycharsize=labelsize, ytitle='CO!i2!n (ppm)'
	
if not keyword_set(noret) then begin
  ccg_symbol, sym=retsymbol
  oplot, xretco2, yretco2, color=pen(retcolor), psym=8, symsize=0.6 
endif
if not keyword_set(nonbg) then begin
  ccg_symbol, sym=nbgsymbol
  oplot, xnbgco2, ynbgco2, color=pen(nbgcolor), psym=8, symsize=0.6 
endif
if not keyword_set(norej) then begin
  ccg_symbol, sym=rejsymbol
  oplot, xrejco2, yrejco2, color=pen(rejcolor), psym=8, symsize=0.6 
endif
if keyword_set(co2fit) then begin
  ccg_ccgvu, x=xretco2, y=yretco2, /even, sc=sc, tr=tr, $
    npoly=co2fit(0), nharm=co2fit(1), interval=co2fit(2), $
    cutoff1=co2fit(3), cutoff2=co2fit(4), tzero=co2fit(5)
  oplot, sc(0,*), sc(1,*), color=pen(7), linestyle=0, thick=thick
  oplot, tr(0,*), tr(1,*), color=pen(1), linestyle=1, thick=thick
endif

if not keyword_set(noreclen) and fyear gt co2start then $
  xyouts, reclenxy(0), reclenxy(1), /normal, $
    'Record begins in ' + string(co2start,format='(i4)'), color=pen(retcolor)
if not keyword_set(noreclen) and lyear-1 lt co2end then $
  xyouts, reclenxy(0), reclenxy(1)-0.02, /normal, $
    'Record ends in ' + string(co2end,format='(i4)'), color=pen(retcolor)

;-------------------------------------------------  plot c13 time series

plot, xretc13, yretc13, /nodata, color=pen(1), charsize=3.0, charthick=thick, $
  position=[x(0),y(2),x(1),y(3)], $
  xrange=[fyear,lyear], xstyle=1, xticks=nyears, xminor=1, xthick=thick, xtickname=blanks, $
  yrange=c13y(0:1), ystyle=1, yticks=c13y(2), yminor=c13y(3), ythick=thick, ytickformat='(f5.1)', $
  ycharsize=labelsize, ytitle='!4d!3!e13!nC (!10(!3)'
	
if not keyword_set(noret) then begin
  ccg_symbol, sym=retsymbol
  oplot, xretc13, yretc13, color=pen(4), psym=8, symsize=0.6 
endif
if not keyword_set(nonbg) then begin
  ccg_symbol, sym=nbgsymbol
  oplot, xnbgc13, ynbgc13, color=pen(nbgcolor), psym=8, symsize=0.6 
endif
if not keyword_set(norej) then begin
  ccg_symbol, sym=rejsymbol
  oplot, xrejc13, yrejc13, color=pen(rejcolor), psym=8, symsize=0.6 
endif
if keyword_set(c13fit) then begin
  ccg_ccgvu, x=xretc13, y=yretc13, /even, sc=sc, tr=tr, $
    npoly=c13fit(0), nharm=c13fit(1), interval=c13fit(2), $
    cutoff1=c13fit(3), cutoff2=c13fit(4), tzero=c13fit(5)
  oplot, sc(0,*), sc(1,*), color=pen(7), linestyle=0, thick=thick
  oplot, tr(0,*), tr(1,*), color=pen(1), linestyle=1, thick=thick
endif

;-------------------------------------------------  plot o18 time series

plot, xreto18, yreto18, /nodata, color=pen(1), charsize=3.0, charthick=thick, $
  position=[x(0),y(0),x(1),y(1)], $
  xrange=[fyear,lyear], xstyle=1, xticks=nyears, xminor=1, xthick=thick, xtickname=blanks, $
  xcharsize=labelsize, xtitle='Year', $
  yrange=o18y(0:1), ystyle=1, yticks=o18y(2), yminor=o18y(3), ythick=thick, ytickformat='(f5.1)', $
  ycharsize=labelsize, ytitle='!4d!3!e18!nO (!10(!3)'
	
if not keyword_set(noret) then begin
  ccg_symbol, sym=retsymbol
  oplot, xreto18, yreto18, color=pen(5), psym=8, symsize=0.6 
endif
if not keyword_set(nonbg) then begin
  ccg_symbol, sym=nbgsymbol
  oplot, xnbgo18, ynbgo18, color=pen(nbgcolor), psym=8, symsize=0.6 
endif
if not keyword_set(norej) then begin
  ccg_symbol, sym=rejsymbol
  oplot, xrejo18, yrejo18, color=pen(rejcolor), psym=8, symsize=0.6 
endif
if keyword_set(o18fit) then begin
  ccg_ccgvu, x=xreto18, y=yreto18, /even, sc=sc, tr=tr, $
    npoly=o18fit(0), nharm=o18fit(1), interval=o18fit(2), $
    cutoff1=o18fit(3), cutoff2=o18fit(4), tzero=o18fit(5)
  oplot, sc(0,*), sc(1,*), color=pen(7), linestyle=0, thick=thick
  oplot, tr(0,*), tr(1,*), color=pen(1), linestyle=1, thick=thick
endif
if o18y(0) lt 0 and o18y(1) gt 0 then begin
  oplot, [fyear,lyear], [0,0], color=pen(8), linestyle=1, thick=thick
endif

;-------------------------------------------------  label x-axis

ccg_xlabel, x1=fyear, x2=lyear, y1=o18y(0), y2=o18y(1), xthick=thick, $
  tarr=years, charsize=1.2*labelsize, charthick=thick

;-------------------------------------------------  legend

if not keyword_set(nolegend) then begin
  legendsymbol = [retsymbol,nbgsymbol,rejsymbol]
  legendfill = [0,0,0]
  legendcolor = [pen(retcolor),pen(nbgcolor),pen(rejcolor)]
  legendtext = ['Retained','Non-background','Rejected']
  if keyword_set(noret) then legendtext(0)=''
  if keyword_set(nonbg) then legendtext(1)=''
  if keyword_set(norej) then legendtext(2)=''
  shown = where(legendtext ne '')
  ccg_slegend, x=legendxy(0), y=legendxy(1), $
    sarr=legendsymbol(shown), $
    farr=legendfill(shown), $
    carr=legendcolor(shown), $
    tarr=legendtext(shown), $
    frame=0
endif

;-------------------------------------------------  CCG lab id

if not keyword_set(nolabid) then ccg_labid

;-----------------------------------------------  close up shop 

ccg_closedev, dev=dev
end

;-----------------------------------------------  all done
