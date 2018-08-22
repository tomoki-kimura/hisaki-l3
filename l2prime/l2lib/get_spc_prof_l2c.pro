;-------------------------------------------------------------------------------
; Get spectrum profiles at given spatial range
; このプログラム実行前に、spiceカーネルのロードを行っておくこと
; IDL> init_spice
;-------------------------------------------------------------------------------
; (in)
;  sta_data                  : start date of source data (yyyymmddhh)
;  end_date                  : end date of source data   (yyyymmddhh)
;  dir_in
;  dir_out
;  ltr                       : local time range ('00-24' or '20-04')
;  s3 = [sta_cml, end_cml]   : CML range for data selection [deg]
;  ip = [sta_io, end_io]     : Io phase range for data selection [deg]
;  wl = [sta_wl, end_wl]     : Wavelength range for data selection [A]
;  sp = [sta_sp, end_sp]     : Output spatial range [RJ] (negative value=dawn, positive value=dusk)
; (out)
;  prof                      : spectral profile
;  err_prof                  : error of spectral profile
;-------------------------------------------------------------------------------
pro get_spc_prof_l2c, sta_date, end_date, dir_in=dir_in, dir_out=dir_out, $
                      ltr=ltr, s3=s3, wl=wl, sp=sp, ip=ip, $
                      ow=ow, no_corr=no_corr, $
                      prof=prof, err_prof=err_prof, xval=xw, err=err, $
                      tint=tint

;----------------------------------------------------------
; Default keyword set
;----------------------------------------------------------
  if ~keyword_set(dir_in)   then dir_in   = 'D:\EUV_DATA\l2_cmp\'
  if ~keyword_set(dir_out)  then dir_out  = 'D:\EUV_DATA\prof\'
  if ~keyword_set(sta_date) then sta_date = '2015010100'
  if ~keyword_set(end_date) then end_date = '2015010217'
  if ~keyword_set(ltr)      then ltr      = '00-24'
  if ~keyword_set(s3)       then s3       = [0.0,360.0]
  if ~keyword_set(ip)       then ip       = [0.0,360.0]
  if ~keyword_set(wl)       then wl       = [1450.0,550.0]
  if ~keyword_set(sp)       then sp       = [3.5,7.5]
  err = 0
  tint = 0

;----------------------------------------------------------
; init SPICE
;----------------------------------------------------------
;  init_spice

;----------------------------------------------------------
; Extract date/time info
;----------------------------------------------------------
  iys = strmid(sta_date,0,4)
  ims = strmid(sta_date,4,2)
  ids = strmid(sta_date,6,2)
  ihs = strmid(sta_date,8,2)
  iye = strmid(end_date,0,4)
  ime = strmid(end_date,4,2)
  ide = strmid(end_date,6,2)
  ihe = strmid(end_date,8,2)
  jd_s = julday(ims, ids, iys, ihs, 0, 0)
  jd_e = julday(ime, ide, iye, ihe, 0, 0)
  nd = fix(fix(jd_e+0.5) - fix(jd_s+0.5))+1 ; number of input file

  exc_get_Io_param, jd = (jd_s+jd_e)*0.5, ar = ar
  sp *= ar[0]    ; RJ to arcsec

;----------------------------------------------------------
; Read CAL data
;----------------------------------------------------------
  jd_ver1 = julday(11, 1, 2014, 0, 0, 0)
  if jd_s ge jd_ver1 then ver=1.1 else ver=1.0
  read_exeuv_cal, xcal, ycal, zcal, ver=ver

;----------------------------------------------------------
; Read Composit image file if exist
;----------------------------------------------------------
  ; Composit image file name
  file_img = dir_out + 'img_' + sta_date + '-' + end_date + '_LT' + ltr $
           + string( fix(s3[0]),fix(s3[1]),fix(ip[0]),fix(ip[1]), $
                     format='("_L",i3.3,"-",i3.3,"_I",i3.3,"-",i3.3)') $
           + '.fits'
  ; check file_exist
  if not keyword_set(ow) then begin 
    openr, 1, file_img, ERROR = err
    if err eq 0 then begin
      ; if exist, read the image
      close, 1
      print, 'reading '+file_img
      im = mrdfits(file_img,0,hd)
      sum = fxpar(hd,'TINT')
      naxis1 = fxpar(hd,'NAXIS1')
      crval1 = fxpar(hd,'CRVAL1')
      crpix1 = fxpar(hd,'CRPIX1')
      cdelt1 = fxpar(hd,'CDELT1')
      xarr = crval1 + cdelt1 * ( findgen(naxis1) - crpix1 )
      naxis2 = fxpar(hd,'NAXIS2')
      crval2 = fxpar(hd,'CRVAL2')
      crpix2 = fxpar(hd,'CRPIX2')
      cdelt2 = fxpar(hd,'CDELT2')
      yarr = crval2 + cdelt2 * ( findgen(naxis2) - crpix2 )
      obs_mode = fxpar(hd, 'OBS_MODE')
      y_axis_pol = fxpar(hd,'Y-POL')
      goto, SKIP1
    endif
  endif 

;----------------------------------------------------------
; Read data & Composit
;----------------------------------------------------------
  jd_sel = jd_s
  im = fltarr(1024,1024)
  sum = 0
  for i=0,nd-1 do begin
      
    ; reading data
    caldat, jd_sel, im_sel, id_sel, iy_sel
    file_in = dir_in + 'exeuv.' $
            + string(iy_sel,im_sel,id_sel,format='(i4.4,i2.2,i2.2)') $
            + '_LT' + ltr + '_d010.fits'
    if strlen(file_search(file_in)) eq 0 then goto, skip_read
    print, 'reading '+file_in
    read_exc_l2c, file_in, zarr, acm=acm, cml=cml, pio=pio, apr=apr, ace=ace, jd=jd, utcstr=utcstr, $
                  ypol=ypol, dej=dej, mode=mode, xarr=xarr, yarr=yarr

    ; Composit
    md = n_elements(acm)
    for j=1,md-1 do begin
       if mode[j-1] ne mode[j] then begin
          err = 2
          print, 'Mixed different obs mode'
          return
       endif
       if ypol[j-1] ne ypol[j] then begin
          err = 3
          print, 'Mixed different y-pol'
          return
       endif
    endfor
    
    for j=0,md-1 do begin
      if (jd[j] lt jd_s) or (jd[j] gt jd_e) then continue
      if s3[0] gt s3[1] then begin
        if (cml[j] ge s3[0]) and (cml[j] le s3[1]) then continue
      endif else begin
        if  (cml[j] lt s3[0]) or (cml[j] gt s3[1]) then continue    
      endelse 
      if ip[0] gt ip[1] then begin
        if (pio[j] ge ip[0]) and (pio[j] le ip[1]) then continue
      endif else begin
        if (pio[j] lt ip[0]) or (pio[j] gt ip[1]) then continue    
      endelse
;      print, utcstr[j]
      im += zarr[*,*,j] * acm[j]    ; count/pixel/min -> total count/pixel
      sum += acm[j]                 ; minutes    
    endfor

skip_read:
    jd_sel += 1.0  ; next day
   
  endfor

  if sum eq 0 then begin
    err = 1
    print, 'no data'   
    return
  endif

;----------------------------------------------------------
; Save composit image
;----------------------------------------------------------
  print, 'writing '+file_img    

  im = ( im / sum ) * zcal; count/pixel -> count/min/pixel -> R/pixel

  ; Save composit image
  wmax = min(xarr) & wmin = max(xarr) ; inverse increment for x-axis
  smax = max(yarr) & smin = min(yarr)
  delta_s = (smax-smin)/1024.0
  delta_w = (wmax-wmin)/1024.0
  obs_mode = mode[0]
  y_axis_pol = ypol[0]

  hdr = strarr(1)
  sxaddpar, hdr, 'SIMPLE', 'T'
  sxaddpar, hdr, 'BITPIX', 16, 'bits per data value'
  sxaddpar, hdr, 'NAXIS', 0, 'bits per data value'
  sxaddpar, hdr, 'EXTEND', 'T', 'file may contain extensions'
  sxaddpar, hdr, 'TINT', sum, 'integration time [min]', format ="i5"
  sxaddpar, hdr, 'EXTNAME', 'IMAGE'
  sxaddpar, hdr, 'BUNITS', "R/pixel"
  sxaddpar, hdr, 'CRVAL1', wmin, format="f12.6"
  sxaddpar, hdr, 'CRPIX1', 0.0, format="f12.6"
  sxaddpar, hdr, 'CDELT1', delta_w, format="f12.6"
  sxaddpar, hdr, 'CUNIT1', "Angstrom"    
  sxaddpar, hdr, 'CRVAL2', 0.0, format="f12.6"
  sxaddpar, hdr, 'CRPIX2', -smin/delta_s, format="f12.6"
  sxaddpar, hdr, 'CDELT2', delta_s, format="f12.6"    
  sxaddpar, hdr, 'CUNIT2', "arcsec"
  sxaddpar, hdr, 'STA-TIME', sta_date, 'start date (YYYYMMDDHH)'
  sxaddpar, hdr, 'END-TIME', end_date, 'end date (YYYYMMDDHH)'
  sxaddpar, hdr, 'LT_RANGE', ltr, 'HISAKI localtime range'
  sxaddpar, hdr, 'SLON1', s3[0], 'system-III longitude range1'
  sxaddpar, hdr, 'SLON2', s3[1], 'system-III longitude range2'
  sxaddpar, hdr, 'IOPH1', ip[0], 'io phase angle range1'
  sxaddpar, hdr, 'IOPH2', ip[1], 'io phase angle range2'
  sxaddpar, hdr, 'OBS_MODE', obs_mode, 'Observation mode'
  sxaddpar, hdr, 'Y-POL', y_axis_pol, 'S/C Y-axis polarity (0:N, 1:S)'
      
  mwrfits, im, file_img, hdr, /create

;----------------------------------------------------------
SKIP1: print, 'integrtion time [min] : ',sum
tint = sum
;----------------------------------------------------------

;----------------------------------------------------------
; Get Profile
;----------------------------------------------------------

; S/C attitude correction
  if not keyword_set(no_corr) then begin
    ; wave length correction
    if ((y_axis_pol eq 0) and (obs_mode eq 4)) or ((y_axis_pol eq 1) and (obs_mode eq 3)) then begin
      print, 'wave length correction has been done.'
      xcal -= 4.5
    endif
    ; spatial axis correction
    if (y_axis_pol eq 1) then begin
      sp = -sp
      print, 'spatial axis correction has been done.'
    endif
  endif

  val = max(wl) & find_arr_index, ix1, val, xcal ; long wavelength is first
  val = min(wl) & find_arr_index, ix2, val, xcal
  val = min(sp) & find_arr_index, iy1, val, ycal
  val = max(sp) & find_arr_index, iy2, val, ycal

  zcal_wl = zcal[ *, (iy2+iy1)/2 ]

  nx = ix2-ix1+1
  ny = iy2-iy1+1
  xw = fltarr(nx)
  ys = fltarr(ny)
  prof = fltarr(nx)
  err_prof = fltarr(nx)

  for i=0,nx-1 do begin
    xw[i] = xcal[ix1+i]
    for j=0,ny-1 do begin
      prof[i] += im[ix1+i,iy1+j]
    endfor
    err_prof[i] = sqrt( prof[i] * sum / zcal_wl[ix1+i] ) * zcal_wl[ix1+i] / sum
  endfor

;----------------------------------------------------------
; plot data
;----------------------------------------------------------
  plot, xw, prof, xrange=wl, /xstyle, yrange=[0.0,1000.0], /ystyle, $
        xtitle='Wavelength [A]', ytitle='Brightness [R]'
  errplot, xw, prof-err_prof, prof+err_prof
  
;----------------------------------------------------------
; save data
;----------------------------------------------------------
  file_prof = dir_out + 'rad\profw_R_' + sta_date + '-' + end_date + '_LT' + ltr $
            + string(fix(s3[0]),fix(s3[1]),fix(ip[0]),fix(ip[1]),fix(wl[0]),fix(wl[1]), $
                     format='("_L",i3.3,"-",i3.3,"_I",i3.3,"-",i3.3,"_W",i4.4,"-",i4.4)')+'.txt'
  print, 'output '+file_prof
  openw, 1, file_prof
  printf, 1, '# start date:',sta_date
  printf, 1, '# end date  :',end_date
  printf, 1, '# integrtion time [min] : ',sum
  printf, 1, '# CML range (for data selection):',s3
  printf, 1, '# Io_phase range (for data selection):',ip
  printf, 1, '# wavelength range  [A]:',wl
  printf, 1, '# spatial range [pixel]:',sp
  printf, 1, '# HISAKI LT range[hour]:',ltr  
  printf, 1, '# Created by get_rad_prof_l2c.pro'
  printf, 1, '# N WL[A] I[R] ERR_I[R]'
  for i=0,nx-1 do begin
    printf, 1, i, xw[i], prof[i], err_prof[i]
  endfor  
  close, 1

end
