pro make_l3
  
;  l2_path     = 'G:\v2\exeuv.20160815_LT20-04_d030.fits'
;  l2cal_path  = 'G:\v1\cal\calib_20160815_v1.0.fits'
;  tablea_path = 'C:\function\JX-PSPC-464448\etc\FJSVTOOL\tableA.dat'
;  out_path    = 'G:\'
;  make_fits_bintable, l2_p=l2_path, l2cal_p=l2cal_path, tablea_p=tablea_path, out_p=out_path
;
;stop
;stop
;stop  
  
  l2_dir      = 'G:\L3\'
  l2cal_path  = 'G:\L3\cal\'
  tablea_path = 'C:\function\JX-PSPC-464448\etc\FJSVTOOL\old_table\line_list_aurora_v1.dat'
  out_dir     = 'G:\L3\L3\'
  
  set_env_l3
  load_spice
  
  l3= file_search(out_dir + '/*.fits')
  if l3[0] ne '' then file_delete,l3
  
  make_fits_bintable_dir, l2_d=l2_dir, l2cal_p=l2cal_path, tablea_p=tablea_path, out_d=out_dir
  stop
  stop
  stop
  stop
end
;make_fits_bintable, l2_p='C:\Users\hkita\Desktop\exeuv.20160121_LT20-04_d030.fits', l2cal_p='C:\Users\hkita\Desktop\calib_20160101_v1.0.fits', tablea_p='C:\function\JX-PSPC-464448\etc\FJSVTOOL\tableA.dat', out_p='C:\Users\hkita\Desktop\out\'
;
;
;
;
;