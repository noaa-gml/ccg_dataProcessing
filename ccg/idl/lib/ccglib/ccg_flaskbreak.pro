;+
; NAME:
;	CCG_FLASKBREAK
;
; PURPOSE:
;	Plot a time series of data from a CCG site-format file,
;	with data points distinguished by color according to
;	sample date, analysis date, method or instrument.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_FLASKBREAK,	dev=dev, species=species, site=site, file=file, $
;			title=title, $
;			fyear=fyear, lyear=lyear, yscale=yscale, all=all, $
;			adate=adate, sdate=sdate, method=method, inst=inst, $
;			noret=noret, nonbg=nonbg, norej=norej, nooff=nooff, $
;			nolabid=nolabid
;
; INPUTS:
;    species:	CCG species (co2,ch4,co,h2,n2o,sf6,c13,o18)
;
; OPTIONAL INPUT PARAMETERS:
;    dev:     	plotting device (must be recognized by CCG_OPENDEV)
;		
;    site: 	CCG site code (e.g. alt)
;
;    file: 	filename (if data is not in a CCG site file)
;
;    title:	plot title
;
;    fyear:	first year (begin plot at January 1 of fyear)
;
;    lyear:	last year (end plot at January 1 of lyear + 1)
;
;    yscale:	[ymin,ymax,yticks,yminor] for plot
;		defaults are co2: [ 320, 400,4,2]
;			     ch4: [1200,2000,4,2]
;			     co:  [   0, 200,4,2]
;			     h2:  [   0, 800,4,2]
;			     n2o: [ 280, 360,4,2]
;			     sf6: [   0,  20,4,2]
;			     c13: [-9.0,-7.0,4,2]
;			     o18: [-3.0, 1.0,4,2]
;
;    all:	plot flask pairs without averaging
;		lines are drawn between pair mate values
;
;    adate:	array of decimal dates at which to break the record
;		by analysis date
;
;    sdate:	array of decimal dates at which to break the record
;		by sample date
;
;    method:	array of method codes
;		(if specified as /method, captures all methods)
;
;    inst:	array of instrument codes
;		(if specified as /inst, captures all methods)
;
;    noret:	don't plot retained data
;
;    nonbg:	don't plot non-background data
;
;    norej:	don't plot rejected data
;
;    nooff:	don't plot out-of-range values on ymin,ymax
;
;    nolabid:	don't plot the CCG laboratory id
;
; OUTPUTS: 
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Defines internal procedures 'trim' and 'flaskpairave'
;
; RESTRICTIONS:
;	The keyword argument 'species' must be a valid CCG species
;       One of the keywords 'site' or 'file' must be specified
;       One of the keywords 'adate', 'sdate', 'method' or 'inst' must be specified
;
; PROCEDURE:
;	Examples:
;		CCG_FLASKBREAK,
;			species='co2',site='brw', $
;			fyear=1990,lyear=1997, $
;			/method,/all
;		
;		CCG_FLASKBREAK,
;			species='c13',site='brw', $
;			fyear=1990,lyear=1997, $
;			sdate=[1992.526,1994.123]
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
;-----  average flask pairs (result gets flag of 1st member) ----
;----------------------------------------------------------------

pro flaskpairave, flask=flask
 
;-------------------------------------------------  description

; average flask pairs in a flask structure (no defalut-value handling)
;
; arguments: flask ...... flask structure (overwritten)

;-------------------------------------------------  check input parameters

if not keyword_set(flask) then return

;-------------------------------------------------  average pairs

flasks = n_elements(flask)

ib = 0
for ia = 0,flasks-1 do begin
  flask(ib) = flask(ia)
  if (ia eq flasks-1) then begin
    flask(ib).y = flask(ia).y
  endif else if ((flask(ia).code   eq flask(ia+1).code)   and $
                 (flask(ia).x      eq flask(ia+1).x)      and $
                 (flask(ia).id     ne flask(ia+1).id)     and $
                 (flask(ia).meth   eq flask(ia+1).meth)   and $
                 (flask(ia).source eq flask(ia+1).source) and $
                 (flask(ia).inst   eq flask(ia+1).inst)) then begin
    flask(ib).y = (flask(ia).y + flask(ia+1).y) / 2.0 
    ia = ia + 1
  endif else begin
    flask(ib).y = flask(ia).y
  endelse
  ib = ib + 1
endfor

flask = flask(0:ib-1)

end


;----------------------------------------------------------------
;------------------------------------------  ccg_flaskbreak  ----
;----------------------------------------------------------------

pro ccg_flaskbreak, dev=dev, species=species, site=site, file=file, title=title, $
                    fyear=fyear, lyear=lyear, yscale=yscale, all=all, $
                    adate=adate, sdate=sdate, method=method, inst=inst, $
                    noret=noret, nonbg=nonbg, norej=norej, nooff=nooff, nolabid=nolabid
 
;-------------------------------------------------  description

; plot a time series broken up by color by analysis date, sample date, method or instrument
;
; arguments: dev ........ plotting device
;            species .... ccg species (co2,ch4,co,h2,n2o,sf6,c13,o18)
;            site ....... site for flaskbreak analysis
;            file ....... file for flaskbreak analysis (not a CCG site file)
;            title ...... plot title
;            fyear ...... first year (begin plot at January 1 of fyear)
;            lyear ...... last year (end plot at January 1 of lyear + 1)
;            yscale ..... yscale for plot
;            all ........ plot all measurements (pairs connected by vertical lines)
;            nooff ...... don't plot out-of-range values on ymin,ymax
;            adate ...... break at adate distinction(s)
;            sdate ...... break at sdate distinction(s)
;            method ..... break by method
;            inst ....... break by instrument
;            noret ...... don't plot retained data
;            nonbg ...... don't plot non-background data
;            norej ...... don't plot rejected data
;            nooff ...... don't plot out-of-range values on ymin,ymax
;            nolabid .... don't plot the CCG laboratory id

;-------------------------------------------------  stuff for species

sp = ['co2','ch4','co','h2','n2o','sf6','c13','o18']
ddef = ['co2','ch4','co','h2','n2o','sf6','silco2','silco2']
ydef = [ [ 320, 400,4,2], [1200,2000,4,2], [   0, 200,4,2],  [   0, 800,4,2], $
         [ 280, 360,4,2], [   0,  20,4,2], [-9.0,-7.0,4,2],  [-3.0, 1.0,4,2] ]
tdef = ['CO!i2!n (ppm)', 'CH!i4!n (ppb)', 'CO (ppb)', $
        'H!i2!n (ppb)',  'N!i2!nO (ppb)', 'SF!i6!n (ppt)', $
        '!4d!3!e13!nC (per mil)', '!4d!3!e18!nO (per mil)']

;-------------------------------------------------  check input parameters

if not keyword_set(species) then begin
  print, "Species must be specified, e.g. species='c13' - exiting ..." & return & endif

if not keyword_set(site) and not keyword_set(file) then begin
  print, "Site or file must be specified, e.g. site='brw' - exiting ..." & return & endif

if not keyword_set(adate) and not keyword_set(sdate) and $
   not keyword_set(method) and not keyword_set(inst) then begin
  print, "Breaks must be specified by adate, sdate, method or instrument - exiting ..." & return & endif

ok = where(sp eq species,oks)
if (oks ne 1) then begin
  print, 'Unrecognized species (' + species + ') - exiting ...' & return & endif

dir = ddef(ok(0))
if not keyword_set(yscale) then yscale = ydef(*,ok(0))
ytitle = tdef(ok(0))

;-------------------------------------------------  read site file & maybe average pairs

if not keyword_set(site) then site = file
if not keyword_set(file) then file = '/projects/' + dir + '/flask/site/' + site + '.' + species
ccg_fsread, file=file, flask
if not keyword_set(all) then flaskpairave, flask=flask
flasks = n_elements(flask)

;-------------------------------------------------  default breakout by method or instrument

if keyword_set(method) then $
  if (n_elements(method) eq 1) then method = flask(uniq(flask.meth,sort(flask.meth))).meth 

if keyword_set(inst) then $
  if (n_elements(inst) eq 1) then inst = flask(uniq(flask.inst,sort(flask.inst))).inst

;-------------------------------------------------  set up time scale

if not keyword_set(fyear) then fyear = floor(min(flask.x))
if not keyword_set(lyear) then lyear = floor(max(flask.x)) + 1 else lyear = lyear + 1
nyears = lyear-fyear

yearval = indgen(nyears) + fyear
if (nyears gt 6) then yearval = yearval - 1900
years = strcompress(string(yearval),/remove_all)
if (nyears gt 12) then years(where(yearval mod 2 ne 0)) = ' '
blanks = make_array(nyears+1,/str,value=' ')

;-------------------------------------------------  trim offscale values

span = yscale(1)-yscale(0) & inc = 0.02 * span

if not keyword_set(nooff) then trim, arr=flask.y, min=yscale(0)+inc, max=yscale(1)-inc

;-------------------------------------------------  set up graphics device 

ccg_opendev, dev=dev, pen=pen, /backstore

;-------------------------------------------------  decide how to break things up

color = intarr(flasks) & color(*) = 0

if keyword_set(adate) then begin
  break = adate(sort(adate)) & by = flask.adate & breakbydate = 1
endif else if keyword_set(sdate) then begin
  break = sdate(sort(sdate)) & by = flask.x & breakbydate = 1
endif else if keyword_set(method) then begin
  break = method & by = flask.meth & breakbydate = 0
endif else if keyword_set(inst) then begin
  break = inst & by = flask.inst & breakbydate = 0
endif

breaks = n_elements(break)
colors = pen(indgen(breaks) mod 12 + 2)

if (breakbydate) then begin
  ok = where(by lt break(0),oks)
  if (oks gt 0) then color(ok) = pen(1)
endif
for ia = 0,breaks-1 do begin
  if (breakbydate) $
    then ok = where(by ge break(ia),oks) $
    else ok = where(by eq break(ia),oks)
  if (oks gt 0) then color(ok) = colors(ia)
endfor

;-------------------------------------------------  plot time series

if not keyword_set(title) then begin
  title = site + ' (' + species + ') by '
  if keyword_set(adate) then title = title + 'analysis date'
  if keyword_set(sdate) then title = title + 'sample date'
  if keyword_set(method) then title = title + 'method'
  if keyword_set(inst) then title = title + 'instrument'
endif

plot, flask.x, flask.y, /nodata, color=pen(1), charsize=1.5, charthick=2, title=title, $
  xrange=[fyear,lyear], xstyle=1, xticks=nyears, xminor=6, xthick=2, xtickname=blanks, $
  yrange=yscale(0:1), ystyle=1, yticks=yscale(2), yminor=yscale(3), ythick=2, ytitle=ytitle
	
for ia = 0,flasks-1 do begin
  if (color(ia) gt 0 and flask(ia).x ge fyear and flask(ia).x le lyear) then begin
    rej = strmid(flask(ia).flag,0,1) ne '.'
    nbg = strmid(flask(ia).flag,1,1) ne '.'
    ret = strmid(flask(ia).flag,0,1) eq '.' and strmid(flask(ia).flag,1,1) eq '.'
    if (rej and not keyword_set(norej)) then begin 
      sym=11 & fill=0 
    endif else if (nbg and not keyword_set(nonbg)) then begin 
      sym=10 & fill=0
    endif else if (ret and not keyword_set(noret)) then begin
      sym=5 & fill=1
    endif else begin
      sym=0 & fill=0
    endelse
    if (sym gt 0) then begin
      ccg_symbol, sym=sym, fill=fill
      oplot, [flask(ia).x], [flask(ia).y], color=color(ia), psym=8, symsize=1.0
      if (keyword_set(all) and ia lt flasks-1) then $
        if (flask(ia).x eq flask(ia+1).x and $
            flask(ia).meth eq flask(ia+1).meth and $
            flask(ia).source eq flask(ia+1).source and $
            flask(ia).inst eq flask(ia+1).inst) then $
          oplot, [flask(ia:ia+1).x], [flask(ia:ia+1).y], color=color(ia), linestyle=0
    endif
  endif
endfor

;-------------------------------------------------  label x-axis

ccg_xlabel, x1=fyear, x2=lyear, y1=yscale(0), y2=yscale(1), xthick=2, $
  tarr=years, charsize=1.5, charthick=2

;-------------------------------------------------  legends

if (breakbydate) then begin
  tarr = ['first',string(break,format='(f10.5)')] 
  sarr = make_array(breaks+1,/int,val=5)
  farr = make_array(breaks+1,/int,val=1)
  carr = [pen(1),colors]
endif else begin
  if keyword_set(method) then tarr = 'Method ' + break
  if keyword_set(inst) then tarr = 'Instrument ' + break
  sarr = make_array(breaks,/int,val=5)
  farr = make_array(breaks,/int,val=1)
  carr = colors
endelse
ccg_slegend, x=0.20, y=0.90, charsize=1.2, tarr=tarr, sarr=sarr, farr=farr, carr=carr, frame=0

tarr = ['Retained','Non-background','Rejected']
sarr = [5,10,11]
farr = [1,0,0]
carr = pen([1,1,1])
if keyword_set(noret) then tarr(0)=''
if keyword_set(nonbg) then tarr(1)=''
if keyword_set(norej) then tarr(2)=''
ok = where(tarr ne '')
ccg_slegend, x=0.75, y=0.90, charsize=1.2, $
  tarr=tarr(ok), sarr=sarr(ok), farr=farr(ok), carr=carr(ok), frame=0

;-------------------------------------------------  CCG lab id

if not keyword_set(nolabid) then ccg_labid

;-----------------------------------------------  close up shop 

ccg_closedev, dev=dev
end

;-------------------------------------------------  all done


