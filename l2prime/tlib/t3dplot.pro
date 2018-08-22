PRO t3dplot, xarr, yarr, zarr, xrange=xrange, yrange=yrange, zrange=zrange, ncolors=ncolors, $
             pos=pos, xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, title=title, noerase=noerase, $
             pf=pf, ylog=ylog, ct=ct, _extra=extra
  
  ; default setting
  m = n_elements(xarr)
  n = n_elements(yarr)
  if ~keyword_set(xrange)  then xrange  = [xarr[0],xarr[m-1]]
  if ~keyword_set(yrange)  then yrange  = [yarr[0],yarr[n-1]]
  if ~keyword_set(ncolors) then ncolors = 255
  if ~keyword_set(pos)     then pos     = [0.2,0.2,0.8,0.8]
  if ~keyword_set(noerase) then erase
  if ~keyword_set(ylog)    then ylog=0
  if ~keyword_set(ct)      then ct=13

  ; find index range
  ret = min(abs(xarr-xrange[0]),imin)
  ret = min(abs(xarr-xrange[1]),imax)
  ret = min(abs(yarr-yrange[0]),jmin)
  ret = min(abs(yarr-yrange[1]),jmax)
  if ~keyword_set(zrange)  then begin
    zrange  = [min(zarr[imin:imax,jmin:jmax])/2,max(zarr[imin:imax,jmin:jmax])/2]
    if zrange[0] eq zrange[1] then zrange[1] = zrange[0] + 1.0
  endif

  ; create image
  im = (double(zarr)-zrange[0])/(zrange[1]-zrange[0])*ncolors
  for i=0L,m-1L do begin
    for j=0L,n-1L do begin
      if im[i,j] lt 0.0 then im[i,j] = 0.0
      if im[i,j] gt ncolors then im[i,j] = ncolors
    endfor
  endfor
 
  ; plot
  levels = zrange[0] + findgen(ncolors)*(zrange[1]-zrange[0])/ncolors
  xsize = (pos(2) - pos(0)) * !D.X_VSIZE
  ysize = (pos(3) - pos(1)) * !D.Y_VSIZE
  xstart = pos(0) * !D.X_VSIZE
  ystart = pos(1) * !D.Y_VSIZE

  ; load colar code
  loadct, ct, /silent

  contour, zarr[imin:imax,jmin:jmax], xarr[imin:imax], yarr[jmin:jmax], /noerase, /nodata, $
      xtitle=xtitle, xrange=xrange, xsty=1, xgridstyle=0, $
      ytitle=ytitle, yrange=yrange, ysty=1, ygridstyle=0, ylog=ylog, $
      zrange=zrange, $
      title=title, $
      pos=pos, ticklen = -0.02, $
      _extra=extra
  
  if !d.name ne 'PS' then device, decomposed=0
  if not keyword_set(pf) then begin
    tv, congrid(im[imin:imax,jmin:jmax],xsize,ysize), xstart, ystart, xsize=xsize, ysize=ysize
  endif else begin
    for i=imin+1L,imax-1L do begin
      x1 = mean(xarr[i-1:i])
      x2 = mean(xarr[i:i+1])
      for j=jmin+1L,jmax-1L do begin
        y1 = mean(yarr[j-1:j])
        y2 = mean(yarr[j:j+1])
        if (x1 gt xarr[imin] and x2 lt xarr[imax] and x2 gt xarr[imin] and x1 lt xarr[imax] and $
            y1 gt yarr[jmin] and y2 lt yarr[jmax] and y2 gt yarr[jmin] and y1 lt yarr[jmax] ) then begin
          polyfill, [x1,x2,x2,x1], [y1,y1,y2,y2], color=im[i,j]
        endif
      endfor
    endfor
  endelse
  if !d.name ne 'PS' then device, decomposed=1
  
  ; replot frame
  contour, zarr[imin:imax,jmin:jmax], xarr[imin:imax], yarr[jmin:jmax], /noerase, /nodata, $
      xtitle=xtitle, xrange=xrange, xsty=1, xgridstyle=0, $
      ytitle=ytitle, yrange=yrange, ysty=1, ygridstyle=0, ylog=ylog, $
      zrange=zrange, $
      title=title, $
      pos=pos, ticklen = -0.02, $
      _extra=extra

  ; colar bar (from coyote regacy lib)
  pos_bar=[pos[2]+0.02, pos[1], pos[2]+0.04, pos[3]]
  COLORBAR, NCOLORS = ncolors, pos=pos_bar, range=zrange, title=ztitle, /vertical, /right

  ; load colar code
  loadct, 0, /silent

end
