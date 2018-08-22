pro filt_var, xarr=xarr, yarr=yarr, outarr=outarr, window=window, ave=ave, max=max
  aveflg=0l
  if keyword_set(max) then aveflg=2l
  if keyword_set(ave) then aveflg=1l
  if aveflg eq 1l then message, '>>> running average is performed instead of running median', /info
  
  nx=n_elements(xarr)
  ny=n_elements(yarr)
  if nx ne ny then begin
    message, '>>> invalid input array. Quit.',/info
    return
  endif
  
  outbuf=dblarr(nx)
  for i=0l, nx-1l do begin
    ii=where(xarr ge xarr[i]-window/2.d and xarr lt xarr[i]+window/2.d)
    if ii[0] ne -1l and n_elements(ii) ge 1l then begin
      if aveflg eq 2l then outbuf[i]=max(yarr[ii])
      if aveflg eq 1l then outbuf[i]=mean(yarr[ii])
      if aveflg eq 0l then outbuf[i]=median(yarr[ii])
    endif else begin
      outbuf[i]=!values.d_nan
    endelse
  endfor
  outarr=outbuf
  return
end