pro batch_l2prime
  
;  dl=30.
  dl=!NULL
  lt_range=[0.0, 24.0]
  target='jupiter.mod.*'
  
;  sdate='2017-08-08'
;  edate='2017-08-10'
;  cspice_str2et, sdate, set
;  cspice_str2et, edate, eet
;  det=86400.d
;  cet=set
;  while cet lt eet do begin
;    cspice_et2utc, cet, 'ISOC', 0, utc
;    cdate=strsplit(utc,'-T:',/ext)
;    cdate=cdate[0]+cdate[1]+cdate[2]
;    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target
;    cet+=det
;  endwhile
;    pattern='*{140101,161115,170430,170520}*'
;    files=file_search(!FITSDATADIR+'/l2/' + '*'+pattern+'*.fits')
;    foreach fileele, files do begin
;      euvl2_timeintegral, l2path=fileele, intgtime=10, intgl2path=!OUTQLDIR+'../l2prime
;    endforeach
sdatearr=[$
    '20140101',  $
    '20161115', $
    '20170430', $
    '20170520'  $
    ]
  foreach cdate, sdatearr do begin
    if ck_blacklist(cdate) eq -1l then continue
    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target
  endforeach

end