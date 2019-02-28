;-------------------------------------------------------
; Last modified : 2017-06-13 F. Tsuchiya
;   - add xcal_a [A]
;   - add ycal_a [arcsec]
;   - ycal_j is available if jupiter keyword is not set.
;   - delete xcal [pixel], ycal [pixel], ypol
;
; Call "exc_cal_init" and "init_spice" before calling exc_cal_img
; (in)  jd_in   : julius day  (need to set for Jupiter data)
; (in)  im_ucal : uncal image fltarr(1024,1024)
; (out) im_cal  : calibrated image fltarr(1024,1024)
; (out) xcal_a  : y-axis in arcsec fltarr(1024)
; (out) ycal_a  : y-axis in arcsec fltarr(1024)
; (out) ycal_j  : y-axis in jovian radii fltarr(1024)
; (in)  x_axis  : if set, only x-axis is calibrated
; (in)  y_axis  : if set, only y-axis is calibrated
; (in)  ipt     : if set, IPT position shift is considered (wavelength shift is applyed) & 'jupiter' keyword is set to be 1
; (in)  jupiter : if set, aurora position correction is considered
;-------------------------------------------------------
pro exc_cal_img, jd_in, im_ucal, im_cal, xcal_a, ycal_a, x_axis=x_axis, y_axis=y_axis, $
                  ipt=ipt, ycal_j=ycal_j, jupiter=jupiter

  ;--------------------------------------------
  if not keyword_set(jd_in) then begin
    print, 'Error : jd_in must be input.'
    return
  endif

  ;--------------------------------------------
  npix   = 1024                        ; pixel number
  pscl   = 9.48                        ; exceed plate scale (x-axis) [arcsec/pixel]
  pscl_s = 4.23                        ; exceed plate scale (y-axis) [arcsec/pixel]

  ; X & Y axes [pixel]
  xcal = findgen(npix)
  ycal = findgen(npix)

  ;--------------------------------------------
  ; check EXCEED observation mode (obs_mode and y-axis direction)
  if keyword_set(ipt) then jupiter=1
  exc_cal_obsmode, jd_in, ypol=ypol, mode=mode

  ;--------------------------------------------
  ; get jupiter apparent angular radius
  if keyword_set(ycal_j) then $
  exc_get_io_param, jd=jd_in, ar=ar

  ;--------------------------------------------
  ; Jupiter position determind from aurora data
  ref_corr = 575.0  ; default value
  if keyword_set(jupiter) then begin
    ref_corr = exc_cal_jup(jd_in)
    if ref_corr eq -1 then begin
      print, 'error in exc_cal_img -> exc_cal_jup: invalid jd_in.'
      stop
      return
    endif
  endif
  ycal -= ref_corr
  
  ;--------------------------------------------
  ; Set CAL-table
  if ypol eq 0 then begin
    x_table = !exc_cal_x_table0
  endif else begin
    x_table = !exc_cal_x_table1
  endelse
  y_table = !exc_cal_y_table

  ; Set uniform table
  table0 = findgen(npix)
  x_table0 = fltarr(npix,npix)
  y_table0 = fltarr(npix,npix)
  for i=0,npix-1 do begin
    x_table0[*,i] = table0
    y_table0[i,*] = table0
  endfor  

  ; x table modification (for ipt)
  if keyword_set(ipt) then begin  
    if ( mode eq 3 and ypol eq 0 ) or ( mode eq 4 and ypol eq 1 ) then begin
      offset =  0.4 * (ar[0] * 2.0) / pscl; [pixel]
    endif else begin
      offset = -0.4 * (ar[0] * 2.0) / pscl; [pixel]
    endelse
    
;    print, 'IPT offset =',offset

    ; check position of narrow part of the 140" slit ( width=92 [arcsec] )
    edge = 46.0   ; [arcsec]
    ret = min( abs(ycal*pscl_s + edge), imin1 )
    ret = min( abs(ycal*pscl_s - edge), imin2 )
    for i = 0, imin1 do begin
      x_table[*,i] += offset
    endfor
    for i = imin2, npix-1 do begin
      x_table[*,i] += offset
    endfor
  endif  

  ;--------------------------------------------
  ; apply cal table
  if  keyword_set(x_axis) and ~keyword_set(y_axis) then im_cal = bilinear(im_ucal, x_table,  y_table0)
  if ~keyword_set(x_axis) and  keyword_set(y_axis) then im_cal = bilinear(im_ucal, x_table0, y_table )
  if  keyword_set(x_axis) and  keyword_set(y_axis) then begin
    im_cal = bilinear(im_ucal, x_table,  y_table)
  endif
  if ~keyword_set(x_axis) and ~keyword_set(y_axis) then begin
    im_cal = bilinear(im_ucal, x_table,  y_table)
  endif

  ;--------------------------------------------
  xcal_a = !exc_cal_x_wl         ; [A]
  ycal_a = ycal * pscl_s          ; [arcsec]
  if keyword_set(ycal_j) then ycal_j = ycal * pscl_s / ar[0]  ; [jovian radii]

end