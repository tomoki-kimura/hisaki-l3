function cal_et0_arr, et_arr=et_arr
  net=n_elements(et_arr)
  del_lt=dblarr(net)
  et0_arr=dblarr(net)
  for i=0l, net-1l do begin
    cspice_et2utc, et_arr[i], 'ISOC', 0, epoch
    orb_ej=cal_orb(epoch=epoch, intarg='JUPITER', inobs='EARTH', inframe='IAU_EARTH', abcorr='LT+S', ltime=ltime)
    lt_ej=orb_ej.lt_s
    orb_es=cal_orb(epoch=epoch, intarg='SPRINTA', inobs='EARTH', inframe='IAU_EARTH', abcorr='LT+S', ltime=ltime)
    lt_es=orb_es.lt_s
    del_lt[i]=lt_es - lt_ej
  endfor
  ii=where(del_lt gt 12.d)
  jj=where(del_lt lt  0.d)
  del_lt[ii]=24.d - del_lt[ii]; <12.
  del_lt[jj]=del_lt[jj] + 24.d; >0.
  del_lt_flg=lonarr(net)
  for i=1l, net-2l do begin
    if del_lt[i]-del_lt[i-1l] gt 0.d and $
       del_lt[i]-del_lt[i+1l] ge 0.d then begin
        et0_arr[i:*]=et_arr[i]
    endif 
  endfor
  et0_arr[0l]=et0_arr[1l]
  et0_arr[net-1l]=et0_arr[net-2l]
  return, et0_arr
end