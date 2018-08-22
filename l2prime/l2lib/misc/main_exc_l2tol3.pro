;===================================================================
;   MAIN ROUTINE
;   Read EXCEED-EUV L2 data for Jupiter 
;===================================================================
PRO main_exc_l2tol3, date=date

  ; define working variables
  init_variables, fits, extn, blk, const, dl=10.0
  ; init spice (load kernels)
  init_spice

  ; input file
  if ~keyword_set(date) then begin
    print, 'set date (yyyymmdd)'
    print, 'ex) main_exc_l2tol3, date = 20140101'
    return
  endif
  nd = 2 ; number of fits file (2 days)
  fits_arr = replicate(fits,2)
  init_fits, date, fits_arr
  
  ; check headers
  ;; Check Primary header
  print, 'check pri header'
  chk_fits_pri_hdr, fits_arr, n_ext
  print, 'number of extention : ',n_ext

  ;; Read header of each extension
  print, 'check extn header'
  extn_arr = replicate(extn,n_ext)
  chk_fits_ext_hdr, fits_arr, extn_arr

  ;; Read image of each extension
  print, 'check image data'
  chk_fits_ext, const, extn_arr, fits_arr, s_val, r_val

  ; find planet parameters
  print, 'get jupiter parameter'
  for i=0,n_ext-1 do begin
    get_param_jupiter, extn_arr[i], const
  endfor
  
  ; define data block
  n_blk = fix( 24.0 / const.tj * 360.0 / const.dl) + 2;
  
  print, 'number of data block : ',n_blk
  blk_arr = replicate(blk,n_blk)
  def_data_blk, blk_arr, extn_arr, date, nd, const, /l2tol3

  ; find y-pol
  check_ypol, blk_arr

  ; composit data
  print, 'composit image'
  im_cmp = fltarr(const.m,const.n,n_blk)
  img_composit, blk_arr, extn_arr, fits_arr, im_cmp, /rej
 
  ; save to fits file
  print, 'save image'
  save_l3_fits, im_cmp, const, extn_arr, blk_arr,out_file
  print, 'output file name : ',out_file  
 
  ; plot image
  for i=0,n_blk-1 do begin
    if blk_arr[i].sum eq 0 then continue
    print, i,blk_arr[i].ind_sta,blk_arr[i].ind_end,blk_arr[i].ind_end-blk_arr[i].ind_sta+1, blk_arr[i].ypol
  endfor

end  
