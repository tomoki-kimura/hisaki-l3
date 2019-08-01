pro make_cal2_file
  set_env_l3
  
  file_mkdir,!l2cal_path2
  file=file_search(!l2cal_path+'calib_*_v1.0.fits')
  
  for i=0, n_elements(file)-1 do begin
    date=(strsplit(FILE_BASENAME(file[i]),'_',/ext))[1]
    incal =!l2cal_path +'/calib_'+date+'_v1.0.fits'
    outcal=!l2cal_path2+'/calib_'+date+'_v2.0.fits'
    cal_caldata_l2prime, incal=incal, outcal=outcal
  endfor
  
  file=file_search(!l2cal_path+'alpha*.csv')
  for i=0, n_elements(file)-1 do begin FILE_COPY, file[i], !l2cal_path2+FILE_BASENAME(file[i])
  
end 