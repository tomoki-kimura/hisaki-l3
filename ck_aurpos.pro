function ck_aurpos, indate, bpath
  indate_s=time_double(indate)
  margin=4.
  
  if indate_s le time_double('2016-01-01') then $
    return, create_struct('flag',1D,'time_s','','time_m','','time_e','',$
      'yc',-1.,'fwhm',-1.,'slit1',-1.,'slit2',-1.,'slit3',-1.,'slit4',-1.)    
  
  file_recs = strarr(file_lines(bpath))
  openr, 1, bpath
  readf, 1, file_recs
  close, 1
  
  for j = 1, n_elements(file_recs) - 1 do begin;j=0=>header
    rec = strsplit(file_recs[j], ',', /EXTRACT)
    time_s =rec[0]
    time_m =rec[1]
    time_e =rec[2]
    yc      =rec[3]
    fwhm    =rec[4]
    slit1   =rec[5]
    slit2   =rec[6]
    slit3   =rec[7]
    slit4   =rec[8]
    arr_time_s = time_double(time_s)
    arr_time_e = time_double(time_e)
    if indate_s ge arr_time_s and indate_s lt arr_time_e then begin
      if yc le slit1 + margin then begin
        flag=4D
      endif else if yc gt slit1+margin and yc lt slit2-margin then begin
        flag=3D
      endif else if yc ge slit2-margin and yc le slit2+margin then begin
        flag=2D
      endif else if yc gt slit2+margin and yc lt slit3-margin then begin
        flag=1D
      endif else if yc ge slit3-margin and yc le slit3+margin then begin
        flag=2D
      endif else if yc gt slit3+margin and yc lt slit4-margin then begin
        flag=3D
      endif else if yc ge slit4-margin then begin
        flag=4D
      endif
      
      return, create_struct('flag',flag,'time_s',time_s,'time_m',time_m,'time_e',time_e,$
        'yc',yc,'fwhm',fwhm,'slit1',slit1,'slit2',slit2,'slit3',slit3,'slit4',slit4)
    endif
  endfor

  return, create_struct('flag',-1,'time_s','','time_m','','time_e','',$
    'yc',-1.,'fwhm',-1.,'slit1',-1.,'slit2',-1.,'slit3',-1.,'slit4',-1.)
end