;----------------------------------------------------------
; Save L2out fits
; for main_exc_l2tol3.pro
;----------------------------------------------------------
PRO save_l3_fits, im_cmp, const, extn_arr, blk_arr, file

  ; check number of extension saved
  n_blk = n_elements(blk_arr)
  n_ext = 0
  for i=0,n_blk-1 do begin
    if blk_arr[i].sum > 0 then n_ext ++
  endfor
  
  ;Output file name
  cspice_et2utc, blk_arr[2].et_sta,       'ISOC', 0, utc_sta  ; et_sta  
  file = 'G:\EUV_DATA\l3\' $
       + 'exeuv.l3.' + strmid(utc_sta,0,4) + strmid(utc_sta,5,2) + strmid(utc_sta,8,2) $
       + '-d' + string(const.dl,format='(i3.3)') + '.fits'
  
  ;Wite Primary header  
  s_zero = const.smin + float(const.fov_cp)*(const.smax-const.smin)/float(const.n)
  smin = const.smin - s_zero
  smax = const.smax - s_zero
  phdr = strarr(1)
  sxaddpar, phdr, 'SIMPLE', 'T'
  sxaddpar, phdr, 'BITPIX', 16, 'bits per data value'
  sxaddpar, phdr, 'NAXIS', 0, 'bits per data value'
  sxaddpar, phdr, 'EXTEND', 'T', 'file may contain extensions'
  sxaddpar, phdr, 'EXTNAME', 'Primary', 'name of this HDU'
  sxaddpar, phdr, 'NEXTEND', n_ext, 'Number of standard extenstion', format ="i5"
  sxaddpar, phdr, 'DATE_STA', utc_sta
  sxaddpar, phdr, 'NAXIS_WL', const.m, 'Number of pixel in wavelength axis', format="i5"
  sxaddpar, phdr, 'NAXIS_SP', const.n, 'Number of pixel in spatial axis', format="i5"
  sxaddpar, phdr, 'WL_MIN', const.wmin, 'Minimum wavelength [A]', format="f8.3"
  sxaddpar, phdr, 'WL_MAX', const.wmax, 'Maximum wavelength [A]', format="f8.3"
  sxaddpar, phdr, 'SP_MIN', smin, 'Minimum spatial range [arcsec]', format="f10.3"
  sxaddpar, phdr, 'SP_MAX', smax, 'Maximum spatial range [arcsrc]', format="f10.3"
  sxaddpar, phdr, 'FOV_CENT', const.fov_cp, 'Pixel number at guide camera center in L2', format="i5"
  sxaddpar, phdr, 'DT_LONG', const.dl, 'SIII longitude range of extention [deg.]', format="f8.3"
  sxaddpar, phdr, 'NP_LONG', const.lon_np, 'North pole SIII longitude [deg.]', format="f8.3"
  sxaddpar, phdr, 'INCL_CE', const.inc_ce, 'Inclinatiion of centrifugal eq. [deg.]', format="f8.3"
  sxaddpar, phdr, 'RADIUS_J', const.rj, 'Jovian Radius [km]', format="f10.3"
  sxaddpar, phdr, 'PERIOD_J', const.tj, 'Jovian rotation period [hour]', format="f8.3"
  sxaddpar, phdr, 'COMMENT', ''
  sxaddpar, phdr, 'COMMENT', 'Created at ' + SYSTIME()
  sxaddpar, phdr, 'COMMENT', 'Data source : EUV L2'
  sxaddpar, phdr, 'COMMENT', 'PROGRAM     : main_exc_l2tol3.pro'
  sxaddpar, phdr, 'COMMENT', 'AUTHOR      : Fuminori Tsuchiya'  
  mwrfits, im, file, phdr, /create, /silent

  ;Write Standard extenstion
  im = fltarr(const.m,const.n)
  for i=0,n_blk-1 do begin

    ; skip empty image
    if blk_arr[i].sum eq 0 then continue

    im[*,*] = im_cmp[*,*,i]
    cspice_et2utc, blk_arr[i].et_sta, 'ISOC', 0, utcstr_sta
    cspice_et2utc, blk_arr[i].et_end, 'ISOC', 0, utcstr_end
    cspice_et2utc, blk_arr[i].et, 'ISOC', 0, utcstr_cen
    delta_s = (smax-smin)/float(const.n)
    delta_w = (const.wmax-const.wmin)/float(const.m)

    hdr = strarr(1)
    sxaddpar, hdr, 'XTENSION', 'IMAGE', 'Type of extension'
    sxaddpar, hdr, 'BITPIX', -32, 'number of bits per data pixel'
    sxaddpar, hdr, 'NAXIS', 2, 'number of data axis'
    sxaddpar, hdr, 'NAXIS1', const.m, 'number of data axis1'
    sxaddpar, hdr, 'NAXIS2', const.n, 'number of data axis2'
    sxaddpar, hdr, 'PCONT', 0, 'number of parameters per group'
    sxaddpar, hdr, 'GCONT', 1, 'number of groups'
    sxaddpar, hdr, 'EXTNAME', utcstr_cen, 'Name of this HDU'
    sxaddpar, hdr, 'CRVAL1', const.wmin, format="f12.6"
    sxaddpar, hdr, 'CRPIX1', 0.0, format="f12.6"
    sxaddpar, hdr, 'CDELT1', delta_w, format="f12.6"
    sxaddpar, hdr, 'CUNIT1', "Angstrom"    
    sxaddpar, hdr, 'CRVAL2', 0.0, format="f12.6"
    sxaddpar, hdr, 'CRPIX2', -smin/delta_s, format="f12.6"
    sxaddpar, hdr, 'CDELT2', delta_s, format="f12.6"    
    sxaddpar, hdr, 'CUNIT2', "arcsec"
    sxaddpar, hdr, 'INT_TIME', blk_arr[i].sum, 'Intgration time [min]', format ="i5"
    sxaddpar, hdr, 'BLK_STA', utcstr_sta, 'Start Date of this extention'
    sxaddpar, hdr, 'BLK_END', utcstr_end, 'End Date of this extention'
    sxaddpar, hdr, 'Y_POL', blk_arr[i].ypol, 'Y-axis polarization 0:north/1:south', format="i1"
    sxaddpar, hdr, 'DIST_EJ', blk_arr[i].rad_j, 'Radial distance from earth to Jupiter [km]', format="f20.2"
    sxaddpar, hdr, 'AP_RAD', blk_arr[i].apr_j, 'Apparrent radius of Jupiter [arcsec]', format="f8.2"
    sxaddpar, hdr, 'CML', blk_arr[i].lon_j, 'System-III longitude [deg]', format="f8.2"
    sxaddpar, hdr, 'ANG_CE', blk_arr[i].inc_ce, 'Inclination of centrifugal equator [deg]', format="f8.2"
    sxaddpar, hdr, 'IO_PHASE', blk_arr[i].ph_io, 'Io phase angle [deg]', format="f8.2"
    sxaddpar, hdr, 'EU_PHASE', blk_arr[i].ph_eu, 'Europa phase angle [deg]', format="f8.2"
    mwrfits, im, file, hdr, /silent

  endfor
    
end
