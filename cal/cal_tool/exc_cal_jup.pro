function exc_cal_jup, jd_in

  ; Jupiter position : 'C:\Doc\HISAKI\cal\cal_sp4\jupiter_pos.sav'
  ;        n_range   : number of julius day range
  ;        jd_range  : julius day range                -> !exc_cal_jup_jd
  ;        coef      : 1st-order line fit coeffienet   -> !exc_cal_jup_coef
  
  jd_r = !exc_cal_jup_jd
  coef = !exc_cal_jup_coef
  y_table = !exc_cal_y_table
  
  sz = size(jd_r)
  n_range = sz[2]

  ref_j = -1
  for i=0, n_range-1 do begin
    if jd_in ge jd_r[0,i] and jd_in le jd_r[1,i] then begin
      ref_j = coef[0,i] + coef[1,i] * (jd_in - jd_r[0,i])
    endif
  endfor

  ; out of valid jd range
  if ref_j eq -1 then return, ref_j

  npix = 1024
  table0 = findgen(npix)
  ref_a = 300 ;[pixel]
  x_aur = y_table[ref_a,*]
  ref_j_corr = interpol(table0, x_aur, ref_j)

  caldat, jd_in, mm,dd,yy
;  print, 'input date =', yy,mm,dd
;  print, 'rej_j      =', ref_j
;  print, 'rej_j_corr =', ref_j_corr

  return, ref_j_corr
  
end
