;-------------------------------------------------------------------
PRO find_roi_area_ypol, xarr, yarr, ypol, et, roi

  n_roi = n_elements (roi)
  
  ; period of slit_shift
  s_shift = {ds:'2014-03-03T00:00:00',de:'2014-03-03T23:59:59',et_s:0.0,et_e:0.0,hs:11.0,vs:0.0}
  dstr = s_shift.ds & cspice_str2et, dstr, et0 & s_shift.et_s = et0
  dstr = s_shift.de & cspice_str2et, dstr, et0 & s_shift.et_e = et0
  
  hs = 0.0
  vs = 0.0
  if ((et gt s_shift.et_s) and (et lt s_shift.et_e)) then begin
     hs = s_shift.hs
     vs = s_shift.vs
  endif
  
  for j = 0,n_roi-1 do begin
  
    if ypol eq 0 then begin
      find_arr_index, ind, roi[j].wc+roi[j].ws*0.5-2.1+vs, xarr & roi[j].m1 = ind
      find_arr_index, ind, roi[j].wc-roi[j].ws*0.5-2.1+vs, xarr & roi[j].m2 = ind
      find_arr_index, ind, roi[j].s1+hs, yarr                   & roi[j].n1 = ind
      find_arr_index, ind, roi[j].s2+hs, yarr                   & roi[j].n2 = ind
    endif else begin
      find_arr_index, ind, roi[j].wc+roi[j].ws*0.5+2.1+vs, xarr & roi[j].m1 = ind
      find_arr_index, ind, roi[j].wc-roi[j].ws*0.5+2.1+vs, xarr & roi[j].m2 = ind
      find_arr_index, ind, -roi[j].s2-hs, yarr                  & roi[j].n1 = ind
      find_arr_index, ind, -roi[j].s1-hs, yarr                  & roi[j].n2 = ind    
    endelse

; since 2015-04-19
;    if ypol eq 0 then begin
;      find_arr_index, ind, roi[j].wc+roi[j].ws*0.5+vs, xarr & roi[j].m1 = ind
;      find_arr_index, ind, roi[j].wc-roi[j].ws*0.5+vs, xarr & roi[j].m2 = ind
;      find_arr_index, ind, roi[j].s1+hs, yarr               & roi[j].n1 = ind
;      find_arr_index, ind, roi[j].s2+hs, yarr               & roi[j].n2 = ind
;    endif else begin
;      find_arr_index, ind, roi[j].wc+roi[j].ws*0.5+4.2+vs, xarr & roi[j].m1 = ind
;      find_arr_index, ind, roi[j].wc-roi[j].ws*0.5+4.2+vs, xarr & roi[j].m2 = ind
;      find_arr_index, ind, -roi[j].s2-hs, yarr               & roi[j].n1 = ind
;      find_arr_index, ind, -roi[j].s1-hs, yarr               & roi[j].n2 = ind    
;    endelse   
 
  endfor

end
;-------------------------------------------------------------------