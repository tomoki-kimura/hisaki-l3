function cal_et0_arr, et_arr=et_arr
  net=n_elements(et_arr)
  del_lt=dblarr(net)
  for i=0l, net-1l do begin
    orb_ej=cal_orb(et=et_arr[i], target='JUPITER', observer='EARTH')
    lt_ej=orb_ej.lt
    orb_es=cal_orb(et=et_arr[i], target='SPRINTA', observer='EARTH')
    lt_es=orb_es.lt
    del_lt[i]=lt_ej - lt_es
  endfor
  ii=where(del_lt gt 12.d)
  del_lt[ii]=24.d - del_lt[ii]; <12.
  del_lt_flg=lonarr(net)
  for i=1l, net-1l do begin
    if del_lt[i]-del_lt[i-1l] gt 0.d and $
       del_lt[i]-del_lt[i+1l] ge 0.d then begin
        et0_arr[i:*]=et_arr[i]
    endif 
  endfor
  return, et0_arr
end