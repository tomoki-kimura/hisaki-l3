pro hisaki_xypos
set_env_l3


  set_plot,'Z'
;  window,1,xsize=1000,ysize=1000
  DEVICE, SET_RESOLUTION = [1000, 1000]
  DEVICE, SET_PIXEL_DEPTH = 24
  DEVICE, DECOMPOSED = 0
  pattern='*20181{115,116,208,209}*d030.fits'
  file=file_search(!L2_DIR,pattern)
  dir_cal=!l2cal_path

  
  make_slitpos, lp=!L2_DIR, od=!DIR_SLIT,pattern=pattern
;  stop



  for i=0,n_elements(file)-1 do begin
    file_elm=strsplit(FILE_BASENAME(file[i]),/extract, '[._]')
    ii=where(stregex(file_elm[*],'[0-9]{8}') ge 0l)
    l2cal_path2=!l2cal_path+'calib_'+file_elm[ii]+'_v1.0.fits'
    make_peak_list_gauss,  lp=file[i], od=!DIR_SLIT,$
      md='value',cp=l2cal_path2,xr=[1050,1190],yr=[-200,200],ret=ret
 ;   md='value',cp=l2cal_path2,xr=[1100,1160],yr=[-200,200],ret=ret
    if ret.time_s eq -1 then continue
    if keyword_set(aur_slit) eq 0 then aur_slit=ret else aur_slit=[aur_slit,ret]
  endfor
;  stop
  
  time_s = aur_slit.time_s
  time_m = aur_slit.time_m
  time_e = aur_slit.time_e
  aur_yc   = aur_slit.yc
  aur_fwhm = aur_slit.fwhm
  slit1    = aur_slit.slit1
  slit2    = aur_slit.slit2
  slit3    = aur_slit.slit3
  slit4    = aur_slit.slit4
  
  openw, 1, !SLIT_POS
  printf, 1, '#time_s,time_m,time_e,pos,fwhm,slit1,slit2,slit3,slit4'
  for k = 0, n_elements(time_s) - 1 do begin
    rec = time_s[k]+','+time_m[k]+','+time_e[k] $
      + ',' + strcompress(string(aur_yc[k])) $
      + ',' + strcompress(string(aur_fwhm[k])) $
      + ',' + strcompress(string(slit1[k])) $
      + ',' + strcompress(string(slit2[k])) $
      + ',' + strcompress(string(slit3[k])) $
      + ',' + strcompress(string(slit4[k]))
    printf, 1, rec
  endfor
  close, 1

;stop

end