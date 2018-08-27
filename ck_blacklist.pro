function ck_blacklist, indate, bpath
  indate_s=time_double(indate)
  
  file_recs = strarr(file_lines(bpath))
  openr, 1, bpath
  readf, 1, file_recs
  close, 1
  
;  time_s =dblarr(n_elements(file_recs))
;  time_e =dblarr(n_elements(file_recs))
  for j = 0, n_elements(file_recs) - 1 do begin
    rec = strsplit(file_recs[j], ',', /EXTRACT)
    time_s = time_double(rec[0])
    time_e = time_double(rec[0])+24l*60*60-1
    if indate_s ge time_s and indate_s le time_e then begin
      print,'blacklist '
      print, indate+rec[1]
      return, -1
    endif 
  endfor
  
  return, 0
end