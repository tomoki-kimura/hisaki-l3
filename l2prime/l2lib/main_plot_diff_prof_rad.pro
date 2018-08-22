pro main_plot_diff_prof_rad, set=set, line=line

  if not keyword_set(set) then set=0
  if not keyword_set(line) then line=0

  dir = 'C:\Doc\HISAKI\data\euv\composit2\output\'

  case line of
  
    0:  begin
          suffix = '.composit2_00.0657.inp'  ; SIV
          yrange1 = [-10,300]
          yrange2 = [-30,30]
          jpg = 'SIV_0657_'+string(set,format='(i1)')
        end
    1:  begin
          suffix = '.composit2_00.0680.inp'  ; SIII
          yrange1 = [-10,1100]
          yrange2 = [-20,200]
          jpg = 'SIII_0680_'+string(set,format='(i1)')
        end
    2:  begin
          suffix = '.composit2_00.0765.inp'  ; SII
          yrange1 = [-10,3000]
          yrange2 = [-40,200]
          jpg = 'SII_0765_'+string(set,format='(i1)')
        end
    3:  begin
          suffix = '.composit2_00.1260.inp'  ; SII
          yrange1 = [-10,1100]
          yrange2 = [-40,200]
          jpg = 'SII_1260_'+string(set,format='(i1)')
        end
    else: begin
          print, 'Invalid line number'
          return
        end
  endcase

  n = 9
  file = strarr(n)
  if set eq 0 then begin
;    file[0] = 'exeuv.jupiter.mod.03.20141231_20150103' + suffix
;    file[1] = 'exeuv.jupiter.mod.03.20150104_20150107' + suffix
    file[0] = 'exeuv.jupiter.mod.03.20150108_20150111' + suffix
    file[1] = 'exeuv.jupiter.mod.03.20150112_20150115' + suffix
    file[2] = 'exeuv.jupiter.mod.03.20150116_20150119' + suffix
    file[3] = 'exeuv.jupiter.mod.03.20150120_20150123' + suffix
    file[4] = 'exeuv.jupiter.mod.03.20150124_20150127' + suffix
    file[5] = 'exeuv.jupiter.mod.03.20150128_20150131' + suffix
    file[6] = 'exeuv.jupiter.mod.03.20150201_20150204' + suffix
    file[7] = 'exeuv.jupiter.mod.03.20150205_20150208' + suffix
    file[8] = 'exeuv.jupiter.mod.03.20150209_20150212' + suffix
  endif else begin
;    file[1] = 'exeuv.jupiter.mod.03.20150213_20150216' + suffix
;    file[1] = 'exeuv.jupiter.mod.03.20150217_20150218' + suffix
;    file[2] = 'exeuv.jupiter.mod.03.20150223_20150226' + suffix
;    file[2] = 'exeuv.jupiter.mod.03.20150227_20150302' + suffix
    file[1] = 'exeuv.jupiter.mod.03.20150303_20150306' + suffix
;    file[4] = 'exeuv.jupiter.mod.03.20150307_20150310' + suffix
    file[2] = 'exeuv.jupiter.mod.03.20150311_20150314' + suffix
;    file[4] = 'exeuv.jupiter.mod.03.20150315_20150318' + suffix
    file[3] = 'exeuv.jupiter.mod.03.20150319_20150322' + suffix
;    file[5] = 'exeuv.jupiter.mod.03.20150323_20150326' + suffix
    file[4] = 'exeuv.jupiter.mod.03.20150327_20150330' + suffix
;    file[6] = 'exeuv.jupiter.mod.03.20150331_20150403' + suffix
    file[5] = 'exeuv.jupiter.mod.03.20150404_20150407' + suffix
;    file[7] = 'exeuv.jupiter.mod.03.20150408_20150411' + suffix
    file[6] = 'exeuv.jupiter.mod.03.20150412_20150415' + suffix
;    file[8] = 'exeuv.jupiter.mod.03.20150416_20150419' + suffix
    file[7] = 'exeuv.jupiter.mod.03.20150420_20150423' + suffix
;    file[8] = 'exeuv.jupiter.mod.03.20150424_20150427' + suffix
    file[8] = 'exeuv.jupiter.mod.03.20150428_20150501' + suffix
;    file[8] = 'exeuv.jupiter.mod.03.20150502_20150505' + suffix
    file[0] = 'exeuv.jupiter.mod.03.20150506_20150509' + suffix
;    file[0] = 'exeuv.jupiter.mod.03.20150510_20150513' + suffix
  endelse

  nl = 91
  prof_s     = fltarr(n,3,nl)
  prof_diff  = fltarr(n-1,3,nl)
  prof_r     = fltarr(3,nl)

; Read data
  hdr = ''
  for i=0,n-1 do begin
    openr, lun, dir+file[i], /get_lun
    readf, lun, hdr
    readf, lun, prof_r
    prof_s[i,*,*] = prof_r
    close, lun
    free_lun, lun
    ; radial position shift
    if set eq 1 then begin
      prof_s[i,0,*] = prof_s[i,0,*]-0.4
    endif else begin
;      prof_s[i,0,*] = prof_s[i,0,*]-0.4
      prof_s[i,0,*] = -prof_s[i,0,*]+0.3
;      prof_s[i,0,*] = -prof_s[i,0,*]
    endelse
  endfor
    
; Difference
  for i=1,n-1 do begin
    prof_diff[i-1,0,0:nl-1] = prof_s[0,0,*]
    prof_diff[i-1,1,0:nl-1] = prof_s[i,1,*]-prof_s[0,1,*]
    for j=0,nl-1 do begin
      prof_diff[i-1,2,j] = sqrt( prof_s[i,2,j]*prof_s[i,2,j] + prof_s[0,2,j]*prof_s[0,2,j] )
    endfor
  endfor
  
; PLOT data
  window, 0, xsize=600, ysize=600
  erase
  xrange = [-10,10]
  yrange = yrange1
  xpos   = [0.2,0.9]
  for i=0,n-2 do begin

    py1 = 1.0/(n+1)*(i+1)+0.01
    py2 = 1.0/(n+1)*(i+2)
    
    xtickformat='(a1)'
    if i eq 0 then xtickformat = '(f5.1)'
    xtitle = ''
    ytitle = 'Bri.[R]'
    if i eq 0 then xtitle = 'Radial distance [RJ]'

    plot, prof_s[i+1,0,*], prof_s[i+1,1,*], xtickformat=xtickformat, pos=[xpos[0],py1,xpos[1],py2], $
          xrange=xrange, yrange=yrange, /noerase, /xstyle, /ystyle, xtitle=xtitle, ytitle=ytitle, $
          xgridstyle=1, xticklen=1.0, xticks=10, CHARSIZE=0.7 
    errplot, prof_s[i+1,0,*], prof_s[i+1,1,*]-prof_s[i+1,2,*], prof_s[i+1,1,*]+prof_s[i+1,2,*]
    oplot, prof_s[0,0,*], prof_s[0,1,*], color=cgcolor('blue')
    errplot, prof_s[0,0,*], prof_s[0,1,*]-prof_s[0,2,*], prof_s[0,1,*]+prof_s[0,2,*], color=cgcolor('blue')
    
    lab = strmid(file[i+1],21,8)
    xyouts, xrange[0]+(xrange[1]-xrange[0])*0.02,yrange[1]-(yrange[1]-yrange[0])*0.2,lab
    if i eq n-2 then begin
      lab = jpg
      xyouts, xrange[0]+(xrange[1]-xrange[0])*0.02,yrange[1]+(yrange[1]-yrange[0])*0.2,lab
    endif
    
  endfor
  write_jpeg, dir+jpg+'.jpg', tvrd(/true), /true    

; PLOT data (Diff)
  window, 1, xsize=600, ysize=600
  erase
  xrange = [-9,9]
  xrange1 = [-9,-6]
  xrange2 = [6,9]
  yrange = yrange2
  xpos   = [0.2,0.9]
  pxv = fltarr(nl+2)
  pyv = fltarr(nl+2)
  for i=0,n-2 do begin

    py1 = 1.0/(n+1)*(i+1)+0.01
    py2 = 1.0/(n+1)*(i+2)
    
    xtickformat='(a1)'
    if i eq 0 then xtickformat = '(f5.1)'
    xtitle = ''
    ytitle = 'Bri.Diff.[R]'
    if i eq 0 then xtitle = 'Radial distance [RJ]'

    for j=1,nl do begin
      if prof_diff[i,0,j-1] lt xrange1[0] then pxv[j] = xrange1[0] else $
      if prof_diff[i,0,j-1] gt xrange1[1] then pxv[j] = xrange1[1] else $
      pxv[j] = prof_diff[i,0,j-1]
      if prof_diff[i,1,j-1] lt yrange[0] then pyv[j] = yrange[0] else $
      if prof_diff[i,1,j-1] gt yrange[1] then pyv[j] = yrange[1] else $
      pyv[j] = prof_diff[i,1,j-1]
    endfor
    pxv[0] = pxv[1]
    pyv[0] = 0.0
    pxv[nl+1] = pxv[nl]
    pyv[nl+1] = 0.0

    plot, pxv, pyv, xtickformat=xtickformat, pos=[xpos[0],py1,0.54,py2], CHARSIZE=0.7, XTICKINTERVAL=0.5, $
          xrange=xrange1, yrange=yrange, /noerase, /xstyle, /ystyle, xtitle=xtitle, ytitle=ytitle, xgridstyle=1, xticklen=1.0, xticks=10
    POLYFILL, pxv, pyv, COLOR = 175, /NOCLIP
    errplot, prof_diff[i,0,*], prof_diff[i,1,*]-prof_diff[i,2,*], prof_diff[i,1,*]+prof_diff[i,2,*]

    lab = strmid(file[i+1],21,8)
    xyouts, xrange1[0]+(xrange1[1]-xrange1[0])*0.02,yrange[1]-(yrange[1]-yrange[0])*0.2,lab
    if i eq n-2 then begin
      lab = jpg + ' difference from ' + strmid(file[0],21,8)
      xyouts, xrange1[0]+(xrange1[1]-xrange1[0])*0.02,yrange[1]+(yrange[1]-yrange[0])*0.2,lab
    endif

    for j=1,nl do begin
      if prof_diff[i,0,j-1] lt xrange2[0] then pxv[j] = xrange2[0] else $
      if prof_diff[i,0,j-1] gt xrange2[1] then pxv[j] = xrange2[1] else $
      pxv[j] = prof_diff[i,0,j-1]
      if prof_diff[i,1,j-1] lt yrange[0] then pyv[j] = yrange[0] else $
      if prof_diff[i,1,j-1] gt yrange[1] then pyv[j] = yrange[1] else $
      pyv[j] = prof_diff[i,1,j-1]
    endfor
    pxv[0] = pxv[1]
    pyv[0] = 0.0
    pxv[nl+1] = pxv[nl]
    pyv[nl+1] = 0.0

    plot, pxv, pyv, xtickformat=xtickformat, pos=[0.56,py1,xpos[1],py2], CHARSIZE=0.7, XTICKINTERVAL=0.5, ytickformat='(a1)', $
          xrange=xrange2, yrange=yrange, /noerase, /xstyle, /ystyle, xtitle=xtitle, ytitle='', xgridstyle=1, xticklen=1.0, xticks=10
    POLYFILL, pxv, pyv, COLOR = 175, /NOCLIP
    errplot, prof_diff[i,0,*], prof_diff[i,1,*]-prof_diff[i,2,*], prof_diff[i,1,*]+prof_diff[i,2,*]

  endfor
  write_jpeg, dir+jpg+'_diff.jpg', tvrd(/true), /true    
 
 end