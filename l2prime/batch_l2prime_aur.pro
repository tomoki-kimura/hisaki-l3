pro batch_l2prime_aur  
  set_env_l3
<<<<<<< HEAD
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
  
  sdate='20160101'
  edate='20190101'
=======

;  sdate='20160101'; 134
;  edate='20160631';
  sdate='20160701'; 128
  edate='20161231';
;  sdate='20170101'; 131
;  edate='20170525';
;  sdate='20170526'; 128
;  edate='20180103';
;  sdate='20180104'; 147
;  edate='20180619';
;  sdate='20180620'; 148
;  edate='20181231';
>>>>>>> f8ce3d9e949aab783bb23e15b85377e8b8001fdb


;;;------------------------------------------------------------------
;;;------------------------------------------------------------------
  defsysv, '!L2p_DIR'       ,!L2pa_dir ;output dir
  defsysv, '!SLIT_POS'      ,!dir_slit+'/aur_pos_dummy.csv'
  defsysv, '!aurpos_l2p'    ,1 ;1:for making aur pos file (l2prime_aur), 0:for making l2prime
  
  dt=10*60.; integration time 10*60 [sec];  dt=106.2d*60.d; sec
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

;C:\function\JX-PSPC-464448\etc\FJSVTOOL\blacklist_aur.csv'
;;  
;defsysv, '!L2_DIR'    , 'D:\'
;defsysv, '!aurpos_l2p', 0 ;ypol ena
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_dummy.csv' ; for aur pos detection
;;  defsysv, '!aurpos_l2p', 1;0 ;ypol dis ; for aur pos detection
;
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2016.csv'
;;  sdate='20160326';'20160101';_ 134
;;  edate='20160631';_
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2016.csv'
;;  sdate='20161107';'20160701';b 128
;;  edate='20161231';b
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2017.csv'
;;  sdate='20170221';'20170101';c 131
;;  edate='20170525';c
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2017.csv'
;;  sdate='20170812';'20170526';d 128
;;  edate='20180103';d
;;  defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2018.csv'
;;  sdate='20180304';'20180104';e 147
;;  edate='20180619';e
;defsysv, '!SLIT_POS'  , !dir_slit+'/aur_pos_2018.csv'
;sdate='20180815';'20180620';f 148
;edate='20181231';f
