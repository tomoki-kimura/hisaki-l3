pro hisaki_xpos_l3
  set_env_l3
    ;defsysv, '!L2p_DIR'      ,'D:\l2prime_90\'

  
  
  file=file_search(!L2p_DIR,'*.fits')
  window,1,xsize=1000,ysize=1000
  for i=0,n_elements(file)-1 do begin
    ret=!NULL
    file_elm=strsplit(FILE_BASENAME(file[i]),/extract, '[._]')
    l2cal_path2=!l2cal_path2+'/calib_'+stregex(FILE_BASENAME(file[i]),'20[0-9]{6}',/ext)+'_v2.0.fits'
    if ck_blacklist(stregex(FILE_BASENAME(file[i]),'20[0-9]{6}',/ext),!BLACK_LIST) eq -1 then continue
    make_peak_list_gauss_x_l3,lp=file[i], $
      md='value',cp=l2cal_path2,xr=[755,775],yr=[-200,200], ret=ret
    if keyword_set(ret) eq 0 then continue
    if keyword_set(aur_slit) eq 0 then aur_slit=ret else aur_slit=[aur_slit,ret]
  endfor

  stop  
  time_s   = aur_slit.time_s
  time_m   = aur_slit.time_m
  time_e   = aur_slit.time_e
  arr_xc   = aur_slit.xc
  arr_sig  = aur_slit.sig
  arr_xc1  = aur_slit.xc1
  arr_xc2  = aur_slit.xc2
  arr_peak1= aur_slit.peak1
  arr_peak2= aur_slit.peak2
  arr_err1 = aur_slit.err1
  arr_err2 = aur_slit.err2
  int_time  = aur_slit.int
  
  cspice_str2et, '2016-01-01T00:00:00', et_0
  cspice_et2utc, et_0,'J',10,buff
  refjd=strmid(buff,3)  ;refjd=ymd2jd(2016,1,1)
  dn=dblarr(n_elements(time_m))
  for i=0, n_elements(time_m)-1 do begin
    cspice_str2et, time_m[i], et
    cspice_et2utc, et,'J',10,buff
    dn[i]=double(strmid(buff,3))-refjd+1    
  endfor
  
  xcdata2 =create_struct($
    'time_s',time_s,$
    'time_m',time_m,$
    'time_e',time_e,$
    'doy'   ,dn,$
    'xc'    ,arr_xc,$
    'sig'   ,arr_sig,$
    'xc1'   ,arr_xc1,$
    'xc2'   ,arr_xc2,$
    'peak1' ,arr_peak1,$
    'peak2' ,arr_peak2,$
    'err1'  ,arr_err1,$
    'err2'  ,arr_err2,$
    'int'   ,int_time)

  stop
  save,xcdata2,filename='xc.sav'
end
