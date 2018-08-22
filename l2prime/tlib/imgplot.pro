; imgplot
; Plot (draw on windows or output to jpeg file) 2D image data 
; (in) zarr   : 2D array of data
;      xarr   : 1D array of x-axis value
;      yarr   : 1D array of y-axis value
;      xrange : x-axis range to be plotted (if not given, min(xarr) & max(xarr) are selected)
;      yrange : y-axis range to be plotted (if not given, min(yarr) & max(yarr) are selected)
;      zrange : zarr range to be plotted (if not given, min(zarr) & max(zarr) are selected)
;      ncolors: number of color for 2D plot (if not given, ncolors = 64)
;      labels : labels of each axis and graph title
;      jpg    : JPEG file name. It not given, Plot is drawn only on Windows
;      sav    : Cross section data save file name (spc_*: spectrum data, rad_*:radial distribution)
;      xprofile : show cross section of the 2D image in y = xprofile[0] (unit of yarr)
;                 (average between xprofile[0] and xprofile[1])
;      yprofile : show cross section of the 2D image in x = yprofile (unit of xarr)
;                 (average between yprofile[0] and yprofile[1])
;      x_profile : result of x-cross section
;      y_profile : result of y-cross section
;
; Example for HISAKI L2 data
;    IDL> file = dialog_pickfile()
;    IDL> read_exeuvlv02, file,im_trg=im_trg, n_trg=n_trg, im_cal=im_cal, n_cal=n_cal
;    IDL> read_exeuv_cal, xcal, ycal, zcal
;    IDL> imgplot, im_trg, xcal, ycal, xrange=[1300,1100], yrange=[-200.0,200.0], xpro=[100,100], ypro=[1216,1216]

PRO imgplot, zarr, xarr, yarr, xrange=xrange, yrange=yrange, zrange=zrange, ncolors=ncolors, labels=labels, jpg=jpg, sav=sav, $
              xprofile=xprofile, yprofile=yprofile,x_profile=x_profile, y_profile=y_profile, ylog=ylog
 
  ; show axis rage
  ;print, 'Available X-range = ',min(xarr),max(xarr)
  ;print, 'Available Y-range = ',min(yarr),max(yarr)
 
  ; default setting
  m = n_elements(xarr)
  n = n_elements(yarr)
  if ~keyword_set(xrange) then xrange = [xarr[0],xarr[m-1]]
  if ~keyword_set(yrange) then yrange = [yarr[0],yarr[n-1]]
  if ~keyword_set(zrange) then zrange = [min(zarr),max(zarr)]
  if ~keyword_set(ncolors) then ncolors = 255
  if ~keyword_set(labels) then labels = ['X-axis','Y-axis','Z-axis','IMG PLOT']
  
  ; define plot area
  if keyword_set(xprofile) and keyword_set(yprofile) then begin
    px0=0.25 & px1=0.82 & py0=0.30 & py1=0.90 & pxp=0.1 & pyp=0.15 & mar = 0.0
  endif else if keyword_set(xprofile) and ~keyword_set(yprofile) then begin
    px0=0.15 & px1=0.82 & py0=0.30 & py1=0.90 & pxp=0.1 & pyp=0.15 & mar = 0.0
  endif else if ~keyword_set(xprofile) and keyword_set(yprofile) then begin
    px0=0.25 & px1=0.82 & py0=0.15 & py1=0.90 & pxp=0.1 & pyp=0.15 & mar = 0.0
  endif else begin
    px0=0.15 & px1=0.82 & py0=0.15 & py1=0.90 & pxp=0.1 & pyp=0.15 & mar = 0.0
  endelse
  pos_img=[px0,py0,px1,py1]
  pos_xpr=[px0,py0-pyp,px1,py0-mar]
  pos_ypr=[px0-pxp,py0,px0-mar,py1]
  pos_bar=[px1+0.02,py0,px1+0.04,px1+0.08]
     
  ; find plot range
  find_arr_index, ixmin, xrange[0], xarr
  find_arr_index, ixmax, xrange[1], xarr
  find_arr_index, iymin, yrange[0], yarr
  find_arr_index, iymax, yrange[1], yarr
  inc_x = (ixmax-ixmin)/abs(ixmax-ixmin)
  inc_y = (iymax-iymin)/abs(iymax-iymin)
  nx = abs(ixmax-ixmin)+1
  ny = abs(iymax-iymin)+1
  im = fltarr(nx,ny)
 
  ; set cross section data
  x_profile = fltarr(1024)
  y_profile = fltarr(1024)
  if keyword_set(xprofile) then begin
    find_arr_index, iypr0, xprofile[0], yarr
    find_arr_index, iypr1, xprofile[1], yarr
    if (iypr1 ne iypr0) then begin
      inc = (iypr1-iypr0)/abs(iypr1-iypr0)
    endif else begin
      inc=1
    endelse
    for i=iypr0,iypr1,inc do begin
      x_profile = x_profile + zarr[*,i]
    endfor
    x_profile = x_profile/(abs(iypr1-iypr0)+1)
;    range = (max(x_profile)-min(x_profile))*0.1
;    xp_range = [min(x_profile)-range,max(x_profile)+range]
    xp_range = zrange
  endif
  if keyword_set(yprofile) then begin
    find_arr_index, ixpr0, yprofile[0], xarr
    find_arr_index, ixpr1, yprofile[1], xarr
    if (ixpr1 ne ixpr0) then begin
        inc = (ixpr1-ixpr0)/abs(ixpr1-ixpr0)
    endif else begin
      inc=1
    endelse
    for i=ixpr0,ixpr1,inc do begin
      y_profile = y_profile + zarr[i,*]
    endfor
    y_profile = y_profile/(abs(ixpr1-ixpr0)+1)
;    range = (max(y_profile)-min(y_profile))*0.1
;    yp_range = [min(y_profile)-range,max(y_profile)+range]
    yp_range = zrange
  endif
      
  ; input data to image array
  ii = 0
  for i=ixmin,ixmax,inc_x do begin
    jj = 0
    for j=iymin,iymax,inc_y do begin
      im[ii,jj] = (zarr[i,j]-zrange[0])/(zrange[1]-zrange[0])*ncolors
      if im[ii,jj] lt 0.0 then im[ii,jj] = 0.0
      if im[ii,jj] gt ncolors then im[ii,jj] = ncolors
      jj = jj + 1
    endfor
    ii = ii + 1
  endfor
 
  ; load colar code
  LOADCT, 13, ncolors=ncolors, /silent
 
  ; spectra plot  
  ERASE  
  ;; 2D PLOT
  pos=pos_img
  levels = zrange[0] + findgen(ncolors)*(zrange[1]-zrange[0])/ncolors
  xsize = (pos(2) - pos(0)) * !D.X_VSIZE
  ysize = (pos(3) - pos(1)) * !D.Y_VSIZE
  xstart = pos(0) * !D.X_VSIZE
  ystart = pos(1) * !D.Y_VSIZE
  device, decomposed=0
  tv, congrid(im,xsize,ysize), xstart, ystart, xsize=xsize, ysize=ysize

  device, decomposed=1
  
  if keyword_set(xprofile) and keyword_set(yprofile) then begin
    contour, zarr, xarr, yarr, /noerase, /nodata, $
      xrange=xrange, xsty=1, xtickformat='(a1)', $
      yrange=yrange, ysty=1, ytickformat='(a1)', ylog=ylog, $
      zrange=zrange, $
      title=labels[3], pos=pos_img
    oplot, xrange, [xprofile[0],xprofile[0]]
    oplot, xrange, [xprofile[1],xprofile[1]]
    oplot, [yprofile[0],yprofile[0]],yrange
    oplot, [yprofile[1],yprofile[1]],yrange
    ;; X-Z PLOT
    plot, xarr, x_profile, xrange=xrange, yrange=xp_range, xtitle=labels[0], $
      xsty=1, ysty=1, pos=pos_xpr, /noerase
    ;; Z-Y PLOT
    plot, y_profile, yarr, xrange=yp_range, yrange=yrange, ytitle=labels[1], ylog=ylog, $
      xsty=1, ysty=1, pos=pos_ypr, xtickformat='(a1)', /noerase
  endif else if keyword_set(xprofile) and ~keyword_set(yprofile) then begin
    contour, zarr, xarr, yarr, /noerase, /nodata, $
      xrange=xrange, xsty=1, xtickformat='(a1)', $
      ytitle=labels[1], yrange=yrange, ysty=1, $
      zrange=zrange, $
      title=labels[3], charsize=1., pos=pos_img
    oplot, xrange, [xprofile[0],xprofile[0]]
    oplot, xrange, [xprofile[1],xprofile[1]]
    ;; X-Z PLOT
    plot, xarr, x_profile, xrange=xrange, xtitle=labels[0], $
      xsty=1, ysty=1, pos=pos_xpr, /noerase
  endif else if ~keyword_set(xprofile) and keyword_set(yprofile) then begin
    contour, zarr, xarr, yarr, /noerase, /nodata, $
      xtitle=labels[0], xrange=xrange, xsty=1, $
      yrange=yrange, ysty=1, ytickformat='(a1)', ylog=ylog, $
      zrange=zrange, $
      title=labels[3], charsize=1., pos=pos_img
    oplot, [yprofile[0],yprofile[0]],yrange
    oplot, [yprofile[1],yprofile[1]],yrange
    ;; Z-Y PLOT
    plot, y_profile, yarr, yrange=yrange, ytitle=labels[1], $
      xsty=1, ysty=1, pos=pos_ypr, xtickformat='(a1)', /noerase
  endif else begin
    contour, zarr, xarr, yarr, /noerase, /nodata, $
      xtitle=labels[0], xrange=xrange, xsty=1, $ ; xgridstyle=0, $
      ytitle=labels[1], yrange=yrange, ysty=1, ylog=ylog, $ ; ygridstyle=0, $
      zrange=zrange, $
      title=labels[3], charsize=1., pos=pos_img ;, ticklen = -0.02
  endelse

  ; colar bar
  pow = alog10(max(abs(zrange)))
  if pow le 0.0 then begin
    frc = 2-fix(pow)
    fmt = '(f'+string(frc+3,format='(i1)')+'.'+string(frc,format='(i1)')+')'
  endif else begin
    fmt = '(i5)'
  endelse
  COLORBAR, NCOLORS = ncolors, format = fmt, $
  pos=pos_bar, range=zrange, title=labels[2], /vertical, /right

  ; output jpeg file
  if keyword_set(jpg) then write_jpeg, jpg, tvrd(/true), /true

  ; output to ascii data file 
  if keyword_set(sav) then begin

    openw, 1, sav+'.spc'
    for i=0,1023 do begin
      printf, 1, xarr[i], x_profile[i]
    endfor
    close, 1

    openw, 1, sav+'.rad'
    for i=0,1023 do begin
      printf, 1, yarr[i], y_profile[i]
    endfor
    close, 1

  endif

end