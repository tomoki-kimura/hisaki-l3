pro batch_l2prime_aur
  
  set_env_l3
  dt=106.2d*60.d; sec
;  dl=43;30.
  dl=!NULL
  lt_range=[0.0, 24.0]
  target='jupiter.mod.{03,04,20,21,22}*'
  
;  defsysv, '!L2_DIR'        ,'D:\l2prime_aur\'
  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_dummy.csv'
  defsysv, '!aurpos_l2p'     ,1
;  sdate='20161001'
;  edate='20190101'
  
  sdate='20160122'
  edate='20160122'


;;;------------------------------------------------------------------
  defsysv,'!last_extn', 1.
  close, 2
  free_lun, 2
  openw,/append,2,!log_place+'flaglist_'+get_local_time('YYYYMMDDThhmmss')+'.txt'
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
      !last_extn=1.
      continue
    endif
    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target, dt=dt
  endforeach
  close,2
  print,'finished'
end
