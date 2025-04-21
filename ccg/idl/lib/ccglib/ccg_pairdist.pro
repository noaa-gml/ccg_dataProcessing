;+
; NAME:
;	CCG_PAIRDIST
;
; PURPOSE:
;	Plots a time series and histogram of flask pair differences
;	with statistics.  Retained & rejected pairs are determined
;	based on the (optionally passed) pair difference criterion.
;       Mean, standard deviation, skewness & kurtosis are calculated
;	for all flasks within the (optionally passed) outlier threshold.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_PAIRDIST,	dev=dev, species=species, site=site, file=file, $
;			title=title, $
;			fyear=fyear, lyear=lyear, $
;			method=method, inst=inst, $
;			cond=cond, span=span, res=res, outlier=outlier, $
;			log=log, nolabid=nolabid
;
; INPUTS:
;    species:	CCG species (co2,ch4,co,h2,n2o,sf6,co2c13,co2o18)
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
;    method:	plot pair differences for only one method code
;
;    inst:	plot pair differences only for one instrument code
;
;    cond:	pair rejection criterion
;		defaults are co2: 0.50 ppm
;			     ch4: 4.00 ppb
;			     co:  3.00 ppb
;			     h2:  2.00 ppb
;			     n2o: 3.00 ppb
;			     sf6: 0.50 ppb
;			     co2c13: 0.09 per mil
;			     co2o18: 0.15 per mil
;
;    span:	span of plot (y-axis ranges from -span to span)
;		default is cond * 2
;
;    res:	resolution of histogram bins
;		default is cond / 5
;
;    outlier:	threshold for rejection of outliers from moment calculation
;		default is cond * 2
;
;    log:	specify to capture an output string containing
;		the results of the moment calculation
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
;	Defines internal proocedure 'trim'
;
; RESTRICTIONS:
;	The keyword argument 'species' must be a valid CCG species
;       One of the keywords 'site' or 'file' must be specified
;
; PROCEDURE:
;	Examples:
;		CCG_PAIRDIST, $
;			species='ch4',site='asc', $
;			fyear=1990,lyear=1997, $
;			cond=5,span=15,res=1
;		
;		CCG_PAIRDIST, $
;			species='co2c13',file='/tmp/test.data', $
;			method='D',/nolabid,log=logstring
;		
; MODIFICATION HISTORY:
;	Written, mxt, January 1995
;-

;----------------------------------------------------------------
;--------------------------------------------  ccg_pairdist  ----
;----------------------------------------------------------------

pro ccg_pairdist, dev=dev, species=species, site=site, file=file, title=title, $
                  fyear=fyear, lyear=lyear, $
                  method=method, inst=inst, $
                  cond=cond, span=span, res=res, outlier=outlier, $
                  log=log, nolabid=nolabid, overhead=overhead
 
;-------------------------------------------------  check input parameters

if not keyword_set(species) then begin
  print, "Species must be specified, e.g. species='co2' - exiting ..." &return & endif

case species of
  'co2': begin & if not keyword_set(cond) then cond = 0.50 & dir = 'co2' & units = 'ppm' & end
  'ch4': begin & if not keyword_set(cond) then cond = 4.00 & dir = 'ch4' & units = 'ppb' & end
   'co': begin & if not keyword_set(cond) then cond = 3.00 & dir = 'co'  & units = 'ppb' & end
   'h2': begin & if not keyword_set(cond) then cond = 2.00 & dir = 'h2'  & units = 'ppb' & end
  'n2o': begin & if not keyword_set(cond) then cond = 3.00 & dir = 'n2o' & units = 'ppb' & end
  'sf6': begin & if not keyword_set(cond) then cond = 0.50 & dir = 'sf6' & units = 'ppb' & end
  'co2c13': begin & if not keyword_set(cond) then cond = 0.09 & dir = 'co2c13' & units = 'per mil' & end
  'co2o18': begin & if not keyword_set(cond) then cond = 0.15 & dir = 'co2o18' & units = 'per mil' & end
   else: begin & print, "Unrecognized species - exiting ..." & return & end
endcase
if not keyword_set(site) and not keyword_set(file) then begin
  print, "Site or file must be specified, e.g. site='brw' - exiting ..." & return & endif

if not keyword_set(site) then site = file
if not keyword_set(title) then title = strupcase(site) + ' (' + species + ')'
if not keyword_set(fyear) then fyear = 0
if not keyword_set(lyear) then lyear = 9999 else lyear = lyear + 1
if not keyword_set(span) then span = 2 * cond
if not keyword_set(res) then res = cond / 5
if not keyword_set(outlier) then outlier = 2 * cond

;-------------------------------------------------  some setup stuff

x = [0.20,0.79,0.94,0.30]
y = [0.15,0.92,0.04]

;-------------------------------------------------  read site file

if not keyword_set(file) then file = '/projects/' + dir + '/flask/site/' + site + '.' + species
temp = 'pairdiff.temp' + '.' + species
ccg_fsread, flask, file=file

reject = strmid(flask.flag,0,1)
ok = where(flask.x ge fyear and flask.x le lyear and reject ne 'N' and reject ne 'A' and reject ne '*',oks)
if (oks eq 0) then begin print, 'No acceptable flasks - exiting' & return & endif
flask = flask(ok)

if keyword_set(method) then begin
  ok = where(flask.meth eq method,oks)
  if (oks eq 0) then begin print, 'No flasks with method ' + method + ' - exiting' & return & endif
  flask = flask(ok)
endif

if keyword_set(inst) then begin
  ok = where(flask.inst eq inst,oks)
  if (oks eq 0) then begin print, 'No flasks with instrument ' + inst + ' - exiting' & return & endif
  flask = flask(ok)
endif

ccg_fswrite, flask, file=temp
ccg_pairdiff, sp=species, import=temp, cond=cond, diff=diff, gp=gp
spawn, 'rm ' + temp
diffs = n_elements(diff(0,*))
bins = findgen(1+2*span/res) * res - span
hist = 1.0 * histogram(diff(1,*), min=-span-res/2, max=span+res/2, binsize=res) / diffs

outhigh = where(diff(1,*) gt outlier, outhighs)
outlow = where(diff(1,*) lt -outlier, outlows)
ok = where(diff(1,*) ge -outlier and diff(1,*) le outlier)
mom = moment(diff(1,ok), sdev=sdev)

log = string(site + '.' + species, format='(a11)') + ' ' + $
      string(diffs,    format='(i5)')   + ' ' + $
      string(cond,     format='(f8.3)') + ' ' + $
      string(gp,       format='(f5.1)') + ' ' + $
      string(outlier,  format='(f8.3)') + ' ' + $
      string(outlows,  format='(i3)')   + ' ' + $
      string(outhighs, format='(i3)')   + ' ' + $
      string(mom(0),   format='(f8.3)') + ' ' + $
      string(sdev,     format='(f8.3)') + ' ' + $
      string(mom(2),   format='(f8.3)') + ' ' + $
      string(mom(3),   format='(f8.3)')

;-------------------------------------------------  prepare x & y axis ranges & labels

if not keyword_set(fyear) then fyear = floor(min(diff(0,*)))
if not keyword_set(lyear) or lyear eq 9999 then lyear = floor(max(diff(0,*))) + 1
nyears = lyear-fyear

yearval = indgen(nyears) + fyear
if (nyears gt 6) then yearval = yearval - 1900
years = strcompress(string(yearval),/remove_all)
if (nyears gt 12) then years(where(yearval mod 2 ne 0)) = ' '
blanks = make_array(nyears+1,/str,value=' ')

;-------------------------------------------------  set up graphics device 

ccg_opendev, dev=dev, pen=pen, /backstore
!p.multi=[0,2,1]

;-------------------------------------------------  plot pair difference time series

plot, diff(0,*), diff(1,*), /nodata, color=pen(1), charsize=1.8, charthick=2, $
  position=[x(0),y(0),x(1),y(1)], title=title, $
  xrange=[fyear,lyear], xstyle=1, xticks=nyears, xminor=1, $
  xtickname=blanks, xtitle='Years', xthick=2, $
  yrange=[-span,span], ystyle=1, ythick=2, $
  ycharsize=1.2, ytitle='Pair Difference ('+units+')'
	
retain = where(abs(diff(1,*)) le cond,oks)
ccg_symbol, sym=5, fill=1
if (oks gt 0) then oplot, diff(0,retain), diff(1,retain), color=pen(3), psym=8, symsize=1.0

reject = where(abs(diff(1,*)) gt cond,oks)
ccg_symbol, sym=11
if (oks gt 0) then oplot, diff(0,reject), diff(1,reject), color=pen(2), psym=8, symsize=0.6 

offscale = where(diff(1,*) gt span,oks)
if (oks gt 0) then $
  oplot, diff(0,offscale), replicate(span,oks), color=pen(2), psym=8, symsize=0.6, /noclip

offscale = where(diff(1,*) lt -span,oks)
if (oks gt 0) then $
  oplot, diff(0,offscale), replicate(-span,oks), color=pen(2), psym=8, symsize=0.6, /noclip

oplot, [fyear,lyear], [outlier,outlier], color=pen(13), linestyle=1, thick=4
oplot, [fyear,lyear], [cond,cond], color=pen(1), linestyle=1, thick=4
oplot, [fyear,lyear], [0,0], color=pen(1), linestyle=0, thick=4
oplot, [fyear,lyear], [-cond,-cond], color=pen(1), linestyle=1, thick=2
oplot, [fyear,lyear], [-outlier,-outlier], color=pen(13), linestyle=1, thick=4

xs = fyear + (lyear-fyear)*0.05
ys = 0.05 * span
pm = string('b1'xb)

xyouts, xs, span-2*ys, strtrim(string(diffs, format='(i4, " pairs")'),2)
xyouts, xs, span-3*ys, string(cond, gp, format='("bad pair condition = ",f6.3,"; ",f4.1,"% good")')
xyouts, xs, span-4*ys, string(outlier, format='("outlier threshold = ",f6.3, "; ",$)') + $
                       string(outlows, outhighs, format='(i3," low, ",i3," high")')
xyouts, xs, span-5*ys, string(mom(0), pm, sdev, format='("mean = ",f6.3,x,a1,x, f6.3)')
xyouts, xs, span-6*ys, string(mom(2), format='("skewness = ",f5.1)')
xyouts, xs, span-7*ys, string(mom(3), format='("kurtosis = ",f5.1)')

;-------------------------------------------------  label x-axis

ccg_xlabel, x1=fyear, x2=lyear, y1=-span, y2=span, xthick=2, $
  tarr=years, charsize=1.8, charthick=2

;-------------------------------------------------  plot pair difference histogram

histmax = max(hist)
if histmax ge 0.8 then histmax = 1.0 else $
if histmax ge 0.6 then histmax = 0.8 else $
if histmax ge 0.4 then histmax = 0.5 else $
if histmax ge 0.2 then histmax = 0.4 else histmax = 0.2

plot, hist, bins, /nodata, color=pen(1), charsize=1.8, charthick=2, $
  position=[x(1),y(0),x(2),y(1)], $
  xrange=[0.0,histmax], xstyle=1, xticks=2, xminor=2, xtitle='Fraction', xthick=2, $
  yrange=[-span,span], ystyle=1, yticks=4, yminor=1, ytickname=[' ',' ',' ',' ',' '], ythick=2

ccg_symbol, sym=2, fill=1
oplot, hist, bins, color=pen(6), psym=8, symsize=1.2, /noclip
oplot, hist, bins, color=pen(6), linestyle=1, thick=4

;-------------------------------------------------  CCG lab id

if not keyword_set(nolabid) then ccg_labid, x=x(3), y=y(2)

;----------------------------------------------- close up shop 

ccg_closedev, dev=dev
end

;----------------------------------------------- all done


