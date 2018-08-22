;-------------------------------------------------------------------
PRO l2c_find_roi_area_ypol, xarr, yarr, ypol, mode, roi

  n_roi = n_elements (roi)
    
  for j = 0,n_roi-1 do begin
  
    if (ypol eq 0) and (mode eq 3) then begin    ; North aurora before opposition
      ; X-axis (wavelength) shift

      ret = min(abs(roi[j].wc+roi[j].ws*0.5 - xarr), ind)    & roi[j].m1 = ind
      ret = min(abs(roi[j].wc-roi[j].ws*0.5 - xarr), ind)    & roi[j].m2 = ind
      ; Y-axis reversal
      ret = min(abs(roi[j].s1 - yarr), ind)                  & roi[j].n1 = ind
      ret = min(abs(roi[j].s2 - yarr), ind)                  & roi[j].n2 = ind
    endif else if (ypol eq 0) and (mode eq 4) then begin    ; South aurora before opposition
      ; X-axis (wavelength) shift
      ret = min(abs(roi[j].wc+roi[j].ws*0.5+4.2 - xarr), ind)& roi[j].m1 = ind
      ret = min(abs(roi[j].wc-roi[j].ws*0.5+4.2 - xarr), ind)& roi[j].m2 = ind
      ; Y-axis reversal
      ret = min(abs(roi[j].s2 - yarr), ind)                  & roi[j].n1 = ind
      ret = min(abs(roi[j].s1 - yarr), ind)                  & roi[j].n2 = ind
    endif else if (ypol eq 1) and (mode eq 3) then begin    ; North aurora after opposition
      ; X-axis (wavelength) shift
      ret = min(abs(roi[j].wc+roi[j].ws*0.5+4.2 - xarr), ind)& roi[j].m1 = ind
      ret = min(abs(roi[j].wc-roi[j].ws*0.5+4.2 - xarr), ind)& roi[j].m2 = ind
      ; Y-axis reversal
      ret = min(abs(-roi[j].s2 - yarr), ind)                 & roi[j].n1 = ind
      ret = min(abs(-roi[j].s1 - yarr), ind)                 & roi[j].n2 = ind
    endif else begin                                  ; South aurora after opposition
      ; X-axis (wavelength) shift
      ret = min(abs(roi[j].wc+roi[j].ws*0.5 - xarr), ind)    & roi[j].m1 = ind
      ret = min(abs(roi[j].wc-roi[j].ws*0.5 - xarr), ind)    & roi[j].m2 = ind
      ; Y-axis reversal
      ret = min(abs(-roi[j].s2 - yarr), ind)                 & roi[j].n1 = ind
      ret = min(abs(-roi[j].s1 - yarr), ind)                 & roi[j].n2 = ind
    endelse
    
  endfor

end
;-------------------------------------------------------------------
