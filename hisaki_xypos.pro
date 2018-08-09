pro hisaki_xypos

  file=file_search('D:\L2\*.fits')
  dir_yc ='D:\L2\yc\'
  dir_xc ='D:\L2\xc\'
  dir_spl='D:\L2\spline\'
  dir_cal='D:\L2\cal\'
  dir_ave='D:\L2\ave\'
  
;  file=file_search('G:\v1\*.fits')
;  dir_yc ='G:\v1\yc\'
;  dir_xc ='G:\v1\xc\'
;  dir_spl='G:\v1\spline\'
;  dir_cal='G:\v1\cal\'
  window,1,xsize=1000,ysize=1000

  for i=0,n_elements(file)-1 do begin
    path_elm=strsplit(file[i],/extract, '\')
    file_elm=strsplit(path_elm[n_elements(path_elm)-1],/extract, '.')
;--------------------------------------------------------
;for L2
;--------------------------------------------------------
;    euvl2_timeintegral, p=file[i], it=90, ip=dir_ave


;    make_peak_list_gauss,  lp=dir_ave+'\intg.'+path_elm[n_elements(path_elm)-1], od=dir_yc,$
;      md='value',cp=dir_cal+'calib_'+file_elm[4]+'_v1.0.fits',xr=[1050,1300],yr=[-200,200]
    make_peak_list_gauss_x,lp=dir_ave+'\intg.'+path_elm[n_elements(path_elm)-1], od=dir_xc,$
      md='value',cp=dir_cal+'calib_'+file_elm[4]+'_v1.0.fits',xr=[670,690],yr=[-200,200]


;--------------------------------------------------------
;for old L2prime
;--------------------------------------------------------
;    file_elm2=strsplit(file_elm[1],/extract, '_')
;;;    make_peak_list_gauss,  lp=file[i], od=dir_yc,$
;;;      md='value',cp=dir_cal+'calib_'+file_elm2[0]+'_v1.0.fits',xr=[1050,1300],yr=[-200,200]
;    make_peak_list_gauss_x,lp=file[i], od=dir_xc,$
;      md='value',cp=dir_cal+'calib_'+file_elm2[0]+'_v1.0.fits',xr=[670,690],yr=[-200,200]
  endfor

;  make_peak_list_spline, yc_d=dir_yc, st='20131218', et='20150514', $
;                           out_p=dir_spl, movmean_p='0'
;  make_peak_list_xy,yc_d='D:\L2\yc\', st='20160101', et='20180101',out_p='D:\L2\spline\', movmean_p='0'
  stop
  stop
end