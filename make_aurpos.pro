pro make_aurpos
set_env_l3

;  set_plot,'Z'
  window,1,xsize=1000,ysize=1000
;  DEVICE, SET_RESOLUTION = [1000, 1000]
;  DEVICE, SET_PIXEL_DEPTH = 24
;  DEVICE, DECOMPOSED = 0
  

;  window,1,xsize=1900,ysize=1000
;  make_slitpos, lp=!L2p_DIR, od=!DIR_SLIT
;;  make_slitpos, lp='D:\sky\', od=!DIR_SLITS
;  stop


  file=file_search(!L2pa_DIR,'*2018*.fits')
  
;;xr=[1100,1160]
;;xr=[1070,1385];;before 190422
;;xr=[1070,1480]20190423
  for i=0,n_elements(file)-1 do begin
    file_elm=strsplit(FILE_BASENAME(file[i]),/extract, '[._]')
    l2cal_path2=!l2cal_path2+'/calib_'+stregex(FILE_BASENAME(file[i]),'20[0-9]{6}',/ext)+'_v2.0.fits'    ;--------byhk
    make_peak_list_gauss,  lp=file[i], md='value',cp=l2cal_path2,xr=[1070,1480],yr=[-200,200],ret=ret
    if keyword_set(ret) eq 0 then continue
    ;if ret[0].time_s eq -1 then continue
    if keyword_set(aur_slit) eq 0 then aur_slit=ret else aur_slit=[aur_slit,ret]
    ret=!NULL
  endfor
  
  
  time_s = aur_slit.time_s
  time_m = aur_slit.time_m
  time_e = aur_slit.time_e
  aur_yc   = aur_slit.yc
  aur_fwhm = aur_slit.fwhm
  slit1    = aur_slit.slit1
  slit2    = aur_slit.slit2
  slit3    = aur_slit.slit3
  slit4    = aur_slit.slit4
  flag     = aur_slit.flag
  aur_yc2  = aur_slit.yc2
  aur_yc3  = aur_slit.yc3
  iptpos1  = aur_slit.ipt1
  iptpos2  = aur_slit.ipt2
  print,n_elements(time_s)
  openw, 1, !DIR_SLIT+'\aur_pos_test'+get_local_time('YYYYMMDDThhmmss')+'.csv'
  printf, 1, '#time_s,time_m,time_e,pos,fwhm,slit1,slit2,slit3,slit4,flag,pos2,pos3,ipt1,ipt2'
  for k = 0., n_elements(time_s) - 1 do begin
    rec = time_s[k]+','+time_m[k]+','+time_e[k] $
      + ',' + strcompress(string(aur_yc[k])) $
      + ',' + strcompress(string(aur_fwhm[k])) $
      + ',' + strcompress(string(slit1[k])) $
      + ',' + strcompress(string(slit2[k])) $
      + ',' + strcompress(string(slit3[k])) $
      + ',' + strcompress(string(slit4[k])) $
      + ',' + strcompress(string(flag[k]))  $
      + ',' + strcompress(string(aur_yc2[k]))$
      + ',' + strcompress(string(aur_yc3[k]))$
      + ',' + strcompress(string(iptpos1[k]))$
      + ',' + strcompress(string(iptpos2[k]))
    printf, 1, rec
  endfor
  close, 1

;stop

end