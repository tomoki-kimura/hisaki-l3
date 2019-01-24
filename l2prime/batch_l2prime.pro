pro batch_l2prime
  
  set_env
;  dl=30.
;  dl=!NULL
  dl=600./(9.925*3600.)*360.
;  dl=3000./(9.925*3600.)*360.
  lt_range=[0.0, 24.0]
;  target='jupiter.mod.{03,20,21,22}*'
  target='*ux_ari*'
  
;sdatearr=[$
;;    '20140101',  $
;;    '20161115', $
;;    '20170430', $
;;    '20170520'  $
;    '20180808',  $
;    '20180824'   $
;    ]

  sdate='20190110'
  edate='20190122'
;  sdate='20181115'
;  edate='20181116'
;  sdate='20181208'
;  edate='20181209'
  tds=time_double(sdate)
  tde=time_double(edate)
  tdc=tds
  sdatearr=sdate
  while tdc lt tde do begin
    tdc+=86400.d
    cdate=time_string(tdc)
    cdate=strjoin((strsplit(cdate,'-/:',/ext))[0:2])
    sdatearr=[sdatearr,cdate]
  endwhile
  foreach cdate, sdatearr do begin
    if ck_blacklist(cdate,!BLACK_LIST) eq -1l then begin
      message, 'input date is in the blacklist. Skipped.', /info
      continue
    endif
    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target
  endforeach

end