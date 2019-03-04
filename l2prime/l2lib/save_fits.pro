;----------------------------------------------------------
; Save L2out fits
; for read_exc_euv_l2.pro
; 2016-06-09 F. Tsuchiya
;----------------------------------------------------------
PRO save_fits, im_cmp, const, extn_arr, blk_arr, file, fits_arr,effexp, dt=dt

  n_ext = n_elements(blk_arr)
  n_ext_w = 0
  for i=0,n_ext-1 do begin
    if (blk_arr[i].ena eq 1) and (blk_arr[i].acm ge 1) then n_ext_w ++
  endfor
  
  ;Output file name
  for i=0,n_ext-1 do begin
    if (blk_arr[i].ena eq 1) and (blk_arr[i].acm ge 1) then begin
      cspice_et2utc, blk_arr[2].et_sta,       'ISOC', 0, utc_sta  ; et_sta
      break
    endif
  endfor
  for i=n_ext-1,0,-1 do begin
    if (blk_arr[i].ena eq 1) and (blk_arr[i].acm ge 1) then begin
      cspice_et2utc, blk_arr[2].et_end,       'ISOC', 0, utc_end  ; et_sta
      break
    endif
  endfor
  
  file_mkdir, !l2_dir+'/' + strmid(utc_sta,0,4) + '/'
  if keyword_set(dt) then begin
    file = !L2_DIR + strmid(utc_sta,0,4) + '/' $
       + 'exeuv.' + strmid(utc_sta,0,4) + strmid(utc_sta,5,2) + strmid(utc_sta,8,2) $
       + '_LT' + string(const.lt_sta,format='(i2.2)') + '-' + string(const.lt_end,format='(i2.2)') $
       + '_dt' + string(round(const.dt/60.),format='(i05)') + '.fits'
  endif else begin
    file = !L2_DIR + strmid(utc_sta,0,4) + '/' $
      + 'exeuv.' + strmid(utc_sta,0,4) + strmid(utc_sta,5,2) + strmid(utc_sta,8,2) $
      + '_LT' + string(const.lt_sta,format='(i2.2)') + '-' + string(const.lt_end,format='(i2.2)') $
      + '_d' + string(const.dl,format='(i3.3)') + '.fits'    
  endelse
  ;Write Primary header  
  phdr = strarr(1)
  sxaddpar, phdr, 'SIMPLE', 'T'
  sxaddpar, phdr, 'BITPIX', 16, 'bits per data value'
  sxaddpar, phdr, 'NAXIS', 0, 'bits per data value'
  sxaddpar, phdr, 'EXTEND', 'T', 'file may contain extensions'
  sxaddpar, phdr, 'EXTNAME', 'Primary', 'name of this HDU'
  sxaddpar, phdr, 'NEXTEND', n_ext_w+1l, 'Number of standard extenstion', format ="i5"
  sxaddpar, phdr, 'DATE_STA', utc_sta
  sxaddpar, phdr, 'DATE_END', utc_end
  sxaddpar, phdr, 'NAXIS_WL', const.m, 'Number of pixel in wavelength axis', format="i5"
  sxaddpar, phdr, 'NAXIS_SP', const.n, 'Number of pixel in spatial axis', format="i5"
  sxaddpar, phdr, 'WL_MIN', const.wmin, 'Minimum wavelength [A]', format="f8.3"
  sxaddpar, phdr, 'WL_MAX', const.wmax, 'Maximum wavelength [A]', format="f8.3"
  sxaddpar, phdr, 'SP_MIN', const.smin, 'Minimum spatial range [arcsec]', format="f10.3"
  sxaddpar, phdr, 'SP_MAX', const.smax, 'Maximum spatial range [arcsrc]', format="f10.3"
  sxaddpar, phdr, 'FOV_CENT', const.fov_cp, 'Pixel number at guide camera center in L2', format="i5"
  sxaddpar, phdr, 'DT_LONG', const.dl, 'SIII longitude range of extention [deg.]', format="f8.3"
  sxaddpar, phdr, 'NP_LONG', const.lon_np, 'North pole SIII longitude [deg.]', format="f8.3"
  sxaddpar, phdr, 'INCL_CE', const.inc_ce, 'Inclinatiion of centrifugal eq. [deg.]', format="f8.3"
  sxaddpar, phdr, 'RADIUS_J', const.rj, 'Jovian Radius [km]', format="f10.3"
  sxaddpar, phdr, 'PERIOD_J', const.tj, 'Jovian rotation period [hour]', format="f8.3"
  sxaddpar, phdr, 'RAD_THL', const.rad_thl, 'Threshold for rad monitor [cnt/min/pix]', format="f8.5"  
  sxaddpar, phdr, 'COMMENT', ''
  sxaddpar, phdr, 'COMMENT', 'Created at ' + SYSTIME()
  sxaddpar, phdr, 'COMMENT', 'Data source : EUV L2'
  sxaddpar, phdr, 'COMMENT', 'PROGRAM     : read_exc_euv_l2.pro'
  sxaddpar, phdr, 'COMMENT', 'AUTHOR      : Tomoki KIMURA'  
  mwrfits, im, file, phdr, /create, /silent

  ;Write Standard extenstion
  im = fltarr(const.m,const.n)
  totexp=0.d
  radmtot=0.d
  radloc=blk_arr[0].radloc
  for i=0l, n_ext-1l do begin
    totexp+=blk_arr[i].acm*60.d; sec
    im[*,*]+=im_cmp[*,*,i]*blk_arr[i].acm; [counts/pixel]
    radmtot+=blk_arr[i].radmon*blk_arr[i].acm; [counts]
  endfor
  cspice_et2utc, blk_arr[0l].et_sta, 'ISOC', 0, utcstr_sta
  cspice_et2utc, blk_arr[-1l].et_end, 'ISOC', 0, utcstr_end
  delta_s = (const.smax-const.smin)/float(const.n)
  delta_w = (const.wmax-const.wmin)/float(const.m)
  hdr = strarr(1)
  dmy = mrdfits(fits_arr[0].file,'Total',hdt,/SILENT)
  hdr=hdt
  sxaddpar, hdr, 'XTENSION', 'IMAGE', 'Type of extension'
  sxaddpar, hdr, 'BITPIX', -32, 'number of bits per data pixel'
  sxaddpar, hdr, 'NAXIS', 2, 'number of data axis'
  sxaddpar, hdr, 'NAXIS1', const.m, 'number of data axis1'
  sxaddpar, hdr, 'NAXIS2', const.n, 'number of data axis2'
  sxaddpar, hdr, 'PCONT', 0, 'number of parameters per group'
  sxaddpar, hdr, 'GCONT', 1, 'number of groups'
  sxaddpar, hdr, 'EXTNAME', 'Total', 'Name of this HDU'
  sxaddpar, hdr, 'EXPOSURE', (totexp), 'Exposure time (sec)', after='NEXTEND'
  sxaddpar, hdr, 'BUNITS', "counts/pixel"
  sxaddpar, hdr, 'CRVAL1', const.wmin, format="f12.6"
  sxaddpar, hdr, 'CRPIX1', 0.0, format="f12.6"
  sxaddpar, hdr, 'CDELT1', delta_w, format="f12.6"
  sxaddpar, hdr, 'CUNIT1', "Angstrom"
  sxaddpar, hdr, 'CRVAL2', 0.0, format="f12.6"
  sxaddpar, hdr, 'CRPIX2', -const.smin/delta_s, format="f12.6"
  sxaddpar, hdr, 'CDELT2', delta_s, format="f12.6"
  sxaddpar, hdr, 'CUNIT2', "arcsec"
  sxaddpar, hdr, 'INT_TIME', (totexp/60.d), 'Intgration time [min]', format ="i5"
  sxaddpar, hdr, 'BLK_STA', utcstr_sta, 'Start Date of this extention'
  sxaddpar, hdr, 'BLK_END', utcstr_end, 'End Date of this extention'
  sxaddpar, hdr, 'RADMON', radmtot, 'Radiation Monitor Value [counts]'
  sxaddpar, hdr, 'RADLOC', strjoin(strcompress(string(radloc))), 'Radiation Monitor location [x0,y0,x1,y1]'
  mwrfits, im, file, hdr, /silent
  
  for i=0,n_ext-1 do begin

    if blk_arr[i].ena eq 0 then continue
    if blk_arr[i].acm le 0 then continue

    im[*,*] = im_cmp[*,*,i]; [counts/pixel/min]
    radmon  = blk_arr[i].radmon; [coounts/min]; radiation monitor
    cspice_et2utc, blk_arr[i].et_sta, 'ISOC', 0, utcstr_sta
    cspice_et2utc, blk_arr[i].et_end, 'ISOC', 0, utcstr_end
    cspice_et2utc, blk_arr[i].et, 'ISOC', 0, utcstr_cen
    delta_s = (const.smax-const.smin)/float(const.n)
    delta_w = (const.wmax-const.wmin)/float(const.m)

    hdr = strarr(1)
    hdr=(*blk_arr[i].hdr)
    sxaddpar, hdr, 'XTENSION', 'IMAGE', 'Type of extension'
    sxaddpar, hdr, 'BITPIX', -32, 'number of bits per data pixel'
    sxaddpar, hdr, 'NAXIS', 2, 'number of data axis'
    sxaddpar, hdr, 'NAXIS1', const.m, 'number of data axis1'
    sxaddpar, hdr, 'NAXIS2', const.n, 'number of data axis2'
    sxaddpar, hdr, 'PCONT', 0, 'number of parameters per group'
    sxaddpar, hdr, 'GCONT', 1, 'number of groups'
    sxaddpar, hdr, 'EXTNAME', utcstr_cen, 'Name of this HDU'
    sxaddpar, hdr, 'BUNITS', "counts/pixel/min"
    sxaddpar, hdr, 'CRVAL1', const.wmin, format="f12.6"
    sxaddpar, hdr, 'CRPIX1', 0.0, format="f12.6"
    sxaddpar, hdr, 'CDELT1', delta_w, format="f12.6"
    sxaddpar, hdr, 'CUNIT1', "Angstrom"
    sxaddpar, hdr, 'CRVAL2', 0.0, format="f12.6"
    sxaddpar, hdr, 'CRPIX2', -const.smin/delta_s, format="f12.6"
    sxaddpar, hdr, 'CDELT2', delta_s, format="f12.6"    
    sxaddpar, hdr, 'CUNIT2', "arcsec"
    sxaddpar, hdr, 'INT_TIME', blk_arr[i].acm, 'Intgration time [min]', format ="i5"
    sxaddpar, hdr, 'BLK_STA', utcstr_sta, 'Start Date of this extention'
    sxaddpar, hdr, 'BLK_END', utcstr_end, 'End Date of this extention'
    sxaddpar, hdr, 'Y_POL', blk_arr[i].ypol, 'Y-axis polarization 0:north/1:south', format="i1"
    sxaddpar, hdr, 'MODE', blk_arr[i].mode, 'Observation mode', format="i1"
    sxaddpar, hdr, 'DIST_EJ', blk_arr[i].rad_j, 'Radial distance from earth to Jupiter [km]', format="f20.2"
    sxaddpar, hdr, 'AP_RAD', blk_arr[i].apr_j, 'Apparrent radius of Jupiter [arcsec]', format="f8.2"
    sxaddpar, hdr, 'CML', blk_arr[i].lon_j, 'System-III longitude [deg]', format="f8.2"
    sxaddpar, hdr, 'ANG_CE', blk_arr[i].inc_ce, 'Inclination of centrifugal equator [deg]', format="f8.2"
    sxaddpar, hdr, 'IO_PHASE', blk_arr[i].ph_io, 'Io phase angle [deg]', format="f8.2"
    sxaddpar, hdr, 'EU_PHASE', blk_arr[i].ph_eu, 'Europa phase angle [deg]', format="f8.2"
    sxaddpar, hdr, 'RADMON', radmon, 'Radiation Monitor Value [counts/min]'
    sxaddpar, hdr, 'RADLOC', strjoin(strcompress(string(radloc))), 'Radiation Monitor location [x0,y0,x1,y1]'
    sxaddpar, hdr, 'JUPLOC', blk_arr[i].ycpxjup, 'Y pixel of Jupiter in original L2 (pixel)', format="f12.6"
    sxaddpar, hdr, 'JPFWHM', blk_arr[i].fwhm, 'FWHM of Jupiter aurora (pixel)', format="f12.6"
    sxaddpar, hdr, 'SLIT1Y', blk_arr[i].slit1, 'Y pixel of btm 140" slit edge', format="f12.6"
    sxaddpar, hdr, 'SLIT2Y', blk_arr[i].slit2, 'Y pixel of btm  20" slit edge', format="f12.6"
    sxaddpar, hdr, 'SLIT3Y', blk_arr[i].slit3, 'Y pixel of top  20" slit edge', format="f12.6"
    sxaddpar, hdr, 'SLIT4Y', blk_arr[i].slit4, 'Y pixel of top 140" slit edge', format="f12.6"
    sxaddpar, hdr, 'JPFLAG', blk_arr[i].juploc, '1:20"slit,2:btw20"&140",3:140"slit,4:140"edge', format="i02"
    et_ave=0
    ave_count=0
    for j=0, (size(effexp))[2]-1 do begin
      if strlen(effexp[i,j]) gt 0l then begin
        sxaddpar, hdr, 'EFFEXP'+string(j+1,format='(i02)'),effexp[i,j],'effective exposure extension'
        cspice_utc2et, effexp[i,j], buff
        et_ave+=+buff
        ave_count+=+1.        
      endif
    endfor
    et_ave=et_ave/ave_count
    cspice_et2utc, et_ave, 'ISOC', 0, utcstr_cen
    sxaddpar, hdr, 'EXTNAME', utcstr_cen, 'Name of this HDU'
    mwrfits, im, file, hdr, /silent

  endfor
    
end
