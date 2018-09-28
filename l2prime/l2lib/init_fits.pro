;----------------------------------------------------------
; Initialize fits structure
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO init_fits, date, fits_arr, target=target

  if not keyword_set(target) then target = 'jupiter.mod.03'


  n = n_elements(fits_arr)
  yy = fix(strmid(date,0,4))
  mm = fix(strmid(date,4,2))
  dd = fix(strmid(date,6,2))
  
  for i=0,n-1 do begin
    targets=file_search(!FITSDATADIR+'l2/*'+target+string(yy,mm,dd,format='(i4.4,i2.2,i2.2)')+'*.fits')
    fits_arr[i].file =targets[0]

;    fits_arr[i].file = !FITSDATADIR+'l2/exeuv.'+target+'.' $
;                     + string(yy,mm,dd,format='(i4.4,i2.2,i2.2)') + '.lv.02.vr.00.fits'
;    print, i, ' ', fits_arr[i].file
    jd = julday(mm,dd,yy)+1
    caldat, jd, mm,dd,yy
  endfor

end
;----------------------------------------------------------
