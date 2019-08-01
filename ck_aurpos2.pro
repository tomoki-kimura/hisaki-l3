function ck_aurpos2, indate, bpath
  indate_s=time_double(indate)
  margin=4.
    
  rec=read_csv(bpath)
  time_s=time_double(rec.field1)
  time_e=time_double(rec.field3)

  n1=where(time_double(indate) ge time_s and time_double(indate) le time_e,count)
  if count eq 1 then begin
    time_s =rec.field1[n1]
    time_m =rec.field2[n1]
    time_e =rec.field3[n1]
    yc      =rec.field4[n1]
    fwhm    =rec.field5[n1]
    slit1   =rec.field6[n1]
    slit2   =rec.field7[n1]
    slit3   =rec.field8[n1]
    slit4   =rec.field9[n1]

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
  return, create_struct('flag',-1,'time_s','','time_m','','time_e','',$
    'yc',-1.,'fwhm',-1.,'slit1',-1.,'slit2',-1.,'slit3',-1.,'slit4',-1.)
  

end