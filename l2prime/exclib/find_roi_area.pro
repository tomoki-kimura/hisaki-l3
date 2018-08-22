;-------------------------------------------------------------------
PRO find_roi_area, xarr, yarr, roi

  n_roi = n_elements (roi)
  
  for j = 0,n_roi-1 do begin
    find_arr_index, ind, roi[j].wc+roi[j].ws*0.5, xarr & roi[j].m1 = ind
    find_arr_index, ind, roi[j].wc-roi[j].ws*0.5, xarr & roi[j].m2 = ind
    find_arr_index, ind, roi[j].s1, yarr               & roi[j].n1 = ind
    find_arr_index, ind, roi[j].s2, yarr               & roi[j].n2 = ind
  endfor

end
;-------------------------------------------------------------------
