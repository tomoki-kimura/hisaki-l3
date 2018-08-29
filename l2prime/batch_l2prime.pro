pro batch_l2prime
  
  set_env
;  dl=30.
  dl=!NULL
  lt_range=[0.0, 24.0]
  target='jupiter.mod.*'
  
sdatearr=[$
;    '20140101',  $
;    '20161115', $
;    '20170430', $
;    '20170520'  $
    '20180808',  $
    '20180824'   $
    ]
  foreach cdate, sdatearr do begin
    if ck_blacklist(cdate,!BLACK_LIST) eq -1l then continue
    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target
  endforeach

end