pro test_make_fits_bintable

  if not keyword_set(l2cal_path)  then l2cal_path='/Users/moxon/moxonraid/spa/data/fits/euv/cal/calib_20140101_v1.0.fits'
  if not keyword_set(l2_path)     then l2_path='/Users/moxon/moxonraid/spa/data/fits/euv/l2/exeuv.jupiter.mod.03.20140101.lv.02.vr.00.fits'
  if not keyword_set(tablea_path) then tablea_path='/Users/moxon/moxonraid/spa/data/fits/euv/line/line_list_aurora_v0.dat'
  if not keyword_set(out_path)    then out_path='/Users/moxon/data/geophys/EXCEED/l3/test/'
  intgl2path=out_path+'exeuv.jupiter.mod.03.20140101.lv.02.vr.00.comp.fits'
  intgtime=10
;  euvl2_timeintegral, l2path=l2_path, intgtime=intgtime, intgl2path=intgl2path, intgstime=intgstime, intgetime=intgetime
  make_fits_bintable, l2_p=intgl2path, l2cal_p=l2cal_path, tablea_p=tablea_path, out_p=out_path

end