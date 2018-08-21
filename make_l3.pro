pro make_l3
;  set_env
;  l2_path     = 'G:\v2\exeuv.20160815_LT20-04_d030.fits'
;  l2cal_path  = 'G:\v1\cal\calib_20160815_v1.0.fits'
;  tablea_path = 'C:\function\JX-PSPC-464448\etc\FJSVTOOL\tableA.dat'
;  out_path    = 'G:\'
;  make_fits_bintable, l2_p=l2_path, l2cal_p=l2cal_path, tablea_p=tablea_path, out_p=out_path
;
;stop
;stop
;stop  
  
  set_env_l3
;  load_spice
  
  l2_dir      = !l2_dir
  l2cal_path  = !l2cal_path
  tablea_path = !tablea_path
  out_dir     = !out_dir

  pattern='*{140101}*'
;  pattern='*{140101,161115,170430,170520}*'
  ;170520:intermediate
  ;170430:140"
  ;161115:best
  
;  l3= file_search(out_dir + '/*'+pattern+'*.fits')
;  if l3[0] ne '' then file_delete,l3
  
  make_fits_bintable_dir, l2_d=l2_dir, l2cal_p=l2cal_path, tablea_p=tablea_path, out_d=out_dir, pattern=pattern
;  stop
;  stop
;  stop
;  stop
end
;make_fits_bintable, l2_p='C:\Users\hkita\Desktop\exeuv.20160121_LT20-04_d030.fits', l2cal_p='C:\Users\hkita\Desktop\calib_20160101_v1.0.fits', tablea_p='C:\function\JX-PSPC-464448\etc\FJSVTOOL\tableA.dat', out_p='C:\Users\hkita\Desktop\out\'
;
;
;
;
;