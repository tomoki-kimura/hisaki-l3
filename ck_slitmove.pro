function ck_slitmove, indate, inlist
  indate_s=time_double(indate)
  inlist_s=time_double(inlist)
    
  buff=inlist_s-indate_s
  m1=where(buff eq 0, count)
  if count eq 1 then begin
    return, m1
  endif else begin
    buff = buff < 0
    nn=where(buff eq 0, count)
    if count ne 0 then begin
      buff[where(buff eq 0)]=-1E10      
    endif
    sub_time=max(buff, n1)
    return, n1  
  endelse
    
end