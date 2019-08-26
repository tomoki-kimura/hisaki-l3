
<<<<<<< HEAD
pro cal_caldata_l2prime, incal=incal, outcal=outcal


  caldata=mrdfits(incal,0,phdr)
  xcal   =mrdfits(incal,1,xhdr)
  ycal   =mrdfits(incal,2,yhdr)
  aeffcal=mrdfits(incal,3,aeffhdr)
  nx=n_elements(aeffcal[*,0])
  ny=n_elements(aeffcal[0,*])

  ;tsuchiya calibration
  exc_cal_init
  jd_in = julday(1,1,2014)
  exc_cal_img, jd_in, aeffcal, outdata, outxcal, outycal
  aeffcal=outdata

  iyminout=where(abs(outycal) eq min(abs(outycal)))
  if iyminout[0] ne -1l then iymin=iyminout[0]
  iyminin=where(abs(ycal[0,*]) eq min(abs(ycal[0,*])))
  if iyminin[0] ne -1l then iyminin=iyminin[0]

  for i=0l, ny-1l do begin
    xcal[*,i]=outxcal[*]
    iin=i
    iout=i-iyminin+iyminout
    ;    if iin  gt ny-1l then iin=ny-1l
    ;    if iin  lt 0l    then iin=0l
    if iout gt ny-1l then iout=ny-1l
    if iout lt 0l    then iout=0l
    ycal[*,iin]=outycal[iout]
  endfor

  message, 'Saving '+outcal,/info
  mwrfits, !NULL, outcal, phdr, /create, /silent
  mwrfits, xcal   , outcal, xhdr, /silent
  mwrfits, ycal   , outcal, yhdr, /silent
  mwrfits, aeffcal, outcal, aeffhdr, /silent

  return
end

=======
>>>>>>> f8ce3d9e949aab783bb23e15b85377e8b8001fdb
;===================================================================
;   MAIN ROUTINE
;   Read EXCEED-EUV L2 data for Jupiter
;
;   ex) IDL> read_exc_euv_l2, '20150101', dl=30.0, lt=[20.0, 4.0]
;
;   2016-02-07 F. Tsuchiya
;===================================================================
PRO read_exc_euv_l2, st_date, dl=dl, lt_range=lt_range, status=status, target=target, dt=dt

  status=1

  ;--- Input file
  if not keyword_set(st_date) then begin
    print, 'usage : IDL> read_exc_euv_l2, st_date, dl=dl, lt_range=lt_range, target=target, status=status'
    print, '     (in)    st_date : YYYYMMDD'
    print, '             dl      : S3 longitude range [deg]'
    print, '             lt_range: LT range [hour]'
    print, '             target  : ex) jupiter.mod.03'
    return
  endif
  if not keyword_set(lt_range) then lt_range=[0.0,24.0]
  if not keyword_set(target) then target = 'jupiter.mod.03'

  
  ;--- Define working variables
;  if not keyword_set(dl) then dl=600./(9.925*3600.)*360.; deg
;  if not keyword_set(dt) then dt=53.1d*60.d; sec
  init_variables, fits, extn, blk, const, dl=dl, lt_range=lt_range, dt=dt

  ;--- Init fits file
  fits_arr = replicate(fits,2)
  init_fits, st_date, fits_arr, target=target
  for i=0,n_elements(fits_arr)-1 do begin
    print, 'Input '+fits_arr[i].file
  endfor
  
  ;--- Check headers
  print, '  check pri header'
  chk_fits_pri_hdr, fits_arr, n_ext
  
  if fits_arr[0].n_ext eq -1 then return
  if fits_arr[0].n_ext eq  1 then return
  print, '  number of extention : ',n_ext
  if n_ext eq 0 then begin
    print, 'No output data in ',st_date
    status=2
    return
  endif

;  incal =!l2cal_path +'/calib_'+st_date+'_v1.0.fits'
;  outcal=!l2cal_path2+'/calib_'+st_date+'_v2.0.fits'
;  cal_caldata_l2prime, incal=incal, outcal=outcal

return

  ;--- Read header of each extension
  print, '  check extn header'
  extn_arr = replicate(extn,n_ext)
  chk_fits_ext_hdr, fits_arr, extn_arr

  ;--- Read image of each extension
  print, '  check image'
  chk_fits_ext, const, extn_arr, fits_arr

  ;--- Find planet parameters
  print, '  get jupiter parameter'
  for i=0,n_ext-1 do begin
    get_param_jupiter, extn_arr[i], const
  endfor
  
  if keyword_set(dt) then begin
    ;--- Define data block
    n_blk = long(86400.d/const.dt) + 16 ; (14+2 --- margin,14:number of orbit per day)
    print, '  number of data block derived by dividing with dt: ',n_blk
    blk_arr = replicate(blk,n_blk)
    effexp  = strarr(n_blk,fix(const.dt/60.)+2)
    def_data_blk_sec, blk_arr, extn_arr, st_date, 2, const
  endif else begin
    ;--- Define data block
    n_blk = fix(24.0/const.tj * 360.0/const.dl) + 2 ; (+2 --- margin)
    print, '  number of data block derived by dividing with dl: ',n_blk
    blk_arr = replicate(blk,n_blk)
    effexp  = strarr(n_blk,fix(const.dl/360.*const.tj*60.)+2)
    def_data_blk, blk_arr, extn_arr, st_date, 2, const
  endelse


  nn1=where(blk_arr.ind_end eq fits_arr[0].n_ext-1)
  if nn1 ne -1 then begin
    if blk_arr[nn1].ind_end eq n_elements(extn_arr)-1 then begin
      print,'last extension!'
      !last_extn=1.      
    endif else if extn_arr[blk_arr[nn1].ind_end+1].et - extn_arr[blk_arr[nn1].ind_end].et ge 60. then begin
      print,'last extension!'
      !last_extn=1.      
    endif else !last_extn=0.
  endif else !last_extn=0.

  ;--- Find y-pol change
  check_ypol, blk_arr

  ;--- Composit data
  print, '  composit image'
  im_cmp = fltarr(const.m, const.n, n_blk)
  img_composit, blk_arr, extn_arr, fits_arr, im_cmp, /rej, const=const,effexp=effexp,/no_cal,log=1
  if total(im_cmp) eq 0l then begin
    message, 'Jupiter is outside the slit. No composit date is made',/info
    status=-1
    return
  endif
  
  ;--- Save to fits file
  print, '  save image'
  ;check number of data saved
  n_save = 0
  for i=0,n_blk-1 do begin
    if (blk_arr[i].ena eq 1) and (blk_arr[i].acm ge 1) then begin
      n_save ++
    endif
  endfor
  
  if n_save eq 0 then begin
    status=2
    return    
  endif
  
  save_fits, im_cmp, const, extn_arr, blk_arr, out_file, fits_arr,effexp, dt=dt
  print, 'output file name : ',out_file
  print, '   utc-sta utc-end ena-flag acm-time ypol'
  for i=0,n_elements(blk_arr)-1 do begin
    cspice_et2utc, blk_arr[i].et_sta, 'ISOC', 0, utcstr_sta
    cspice_et2utc, blk_arr[i].et_end, 'ISOC', 0, utcstr_end
    print, '   ',utcstr_sta, ' ', utcstr_end, blk_arr[i].ena, blk_arr[i].acm, blk_arr[i].ypol
  endfor
  
  status = 1

end
