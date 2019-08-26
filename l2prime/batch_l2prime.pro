pro batch_l2prime
  set_env_l3
  
;  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2016.csv'
;  sdate='20160101'; 134
;  edate='20160631';
;  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2016.csv'
;  sdate='20160701'; 128
;  edate='20161231';
;  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2017.csv'
;  sdate='20170101'; 131
;  edate='20170525';
;  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2017.csv'
;  sdate='20170526'; 128
;  edate='20180103';
;  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2018.csv'
;  sdate='20180104'; 147
;  edate='20180619';
  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_2018.csv'
  sdate='20180620'; 148
  edate='20181231';

;-------------
; Aurora L2p
;-------------
  dt=10*60.      ;integration time 10*60 [sec]
;-------------
; Torus L2p
;-------------
;  dt=106.2d*60.d ;integration time 106*60 [sec]



;;;------------------------------------------------------------------
;;;------------------------------------------------------------------
;;;------------------------------------------------------------------
  defsysv, '!aurpos_l2p'    ,0 ;1:for making aur pos file (l2prime_aur), 0:for making l2prime
  
  dl=!NULL
  lt_range=[0.0, 24.0]
  target='jupiter.mod.{03,04,20,21,22}*'
  defsysv,'!last_extn', 1.
  close, 2
  free_lun, 2
  openw, /append,2,!log_place+'flaglist_'+get_local_time('YYYYMMDDThhmmss')+'.txt'
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
    read_exc_euv_l2, cdate, dl=dl, lt_range=lt_range, target=target, dt=dt
  endforeach
  close,2
  print,'finished'
  
end