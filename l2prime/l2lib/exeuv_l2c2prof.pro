;===================================================================
; MAIN ROUTINE  (for Jupiter, slit3, mode3/mode4, north/south aurora)
;===================================================================
PRO exeuv_l2c2prof, date, ltr=ltr, dl=dl, wl=wl, jpg=jpg

  ;デフォルト値設定
  if not keyword_set(ltr) then ltr = '00-24'
  if not keyword_set(dl) then dl = '010'
  if not keyword_set(wl) then wl = [670,690]

  pscl_s = 4.23    ; EXCEED プレートスケール[arcsec/pixel]  
  wl_c = mean(wl)

  ;出力プロファイルのグリッド設定
  grid        = 0.15   ; [RJ]
  span        = 18.0   ; [RJ]
  nd_rj       = fix((span+grid)/grid+1)
  yarr_rj     = -span*0.5 + span/(nd_rj-1.0)*findgen(nd_rj)
  npix = 1024
  
  ref_year = 2015

  prof0       = fltarr(npix) 
  err_prof0   = fltarr(npix) 
  
;  read cal file cal
  read_exeuv_cal, xcal0, ycal0, zcal0, ver=1.1
  jd_ref = julday(1,1,ref_year,0,0,0)

  infile = 'D:\EUV_DATA\l2_cmp\exeuv.'+date+'_LT'+ltr+'_d'+dl+'.fits'
  if not file_exist(infile) then begin
    print, 'file not found: '+infile
    return
  endif

; read composited L2 data
  print, 'reading '+infile
  read_exc_l2c, infile, zarr, acm=acm, cml=cml, pio=pio, apr=apr, ace=ace, jd=jd, ypol=y_axis_pol, dej=dej, mode=mode

; get radial profile
  nd = n_elements(acm)
    
  prof        = fltarr(nd,nd_rj) 
  err_prof    = fltarr(nd,nd_rj) 

  ; for each composit image
  for i=0, nd-1 do begin

    ; wave length correction
    ypol = 0
    if ((y_axis_pol[i] eq 0) and (mode[i] eq 4)) or ((y_axis_pol[i] eq 1) and (mode[i] eq 3)) then ypol=1
    
    jd_in = jd[i]

    ;cal table translation
    exc_cal_img, jd_in, zcal0, zcal, xcal, ycal, ypol=ypol, /ipt

    ; composit L2 image translation
    im_ucal = zarr[*,*,i]       ; count/pixel/min
    exc_cal_img, jd_in, im_ucal, im, xcal, ycal, ypol=ypol, /ipt

    ; axis corrected
    xcal = !exc_cal_x_wl        ; Angstorm
    ycal *= pscl_s              ; arcsec
    im *= zcal                  ; count/pixel/min > Rayleigh/pixel

    ; spatial axis correction
    if (y_axis_pol[i] eq 1) then begin
      ycal = -ycal
    endif    

    ; get radial profile
    ret = min(abs(wl[0]-xcal),ix2)
    ret = min(abs(wl[1]-xcal),ix1)
    zcal_sp = zcal[ (ix2+ix1)/2, * ] ; cal table (Rayleigh/(count/min) along spatial axis (y-axis)

    for j=0,npix-1 do begin
      prof0[j] = total(im[ix1:ix2,j])
    endfor
    err_prof0 = sqrt( prof0 * acm[i] / zcal_sp ) * zcal_sp / acm[i]

    ; interpolation/re-bin
    yarr0_rj = ycal/apr[i]      ; arcsec -> RJ
    prof_rj1 = interpol(prof0, yarr0_rj, yarr_rj)
    err_prof_rj1 = interpol(err_prof0, yarr0_rj, yarr_rj)

    prof[i,*] = prof_rj1
    err_prof[i,*] = err_prof_rj1

  endfor

  doy = jd-jd_ref

   ; plot image
  if keyword_set(jpg) and nd gt 1 then begin
    title = 'exeuv.prof.'+date+'_w'+string(fix(wl_c),format='(i4.4)')+'_LT'+ltr+'_d'+dl
    xr=[min(doy),max(doy)]
    pos = [0.2,0.2,0.8,0.69]
    t3dplot, doy, yarr_rj, prof, pos=pos, xrange=xr, /xstyle,  $
                xtitle='Day of Year', ytitle='Distance from Jup [RJ]', /pf
    pos = [0.2,0.7,0.8,0.85]
    plot, doy, acm, /noerase, pos=pos, xrange=xr, /xstyle, xtickformat='(a1)', ytitle='Int[min]', title=title, psym=1
    jpg_file = 'D:\EUV_DATA\l2c_out\jpg\exeuv.prof.'+date+'_w'+string(fix(wl_c),format='(i4.4)')+'_LT'+ltr+'_d'+dl+'.jpg'
    write_jpeg, jpg_file, tvrd(/true), /true
  endif
  
; open output data file
  outfile = 'D:\EUV_DATA\l2c_out\exeuv.prof.'+date+'_w'+string(fix(wl_c),format='(i4.4)')+'_LT'+ltr+'_d'+dl+'.asc'
  print, 'writing '+outfile
  openw, lun, outfile, /get_lun
  if not keyword_set(ltr) then ltr = '00-24'
  if not keyword_set(dl) then dl = '010'
  if not keyword_set(wl) then wl = [670,690]
  printf, lun, '# Date, LT range, delta S3, wave length'
  printf, lun, '# '+date+' '+ltr+' '+dl+' '+string(fix(wl_c),format='(i4.4)')
  printf, lun, '# Day of year, distance from Jup[RJ], Intensity[R], Intensity err[R]'
  printf, lun, '#   (distance from Jup[RJ]  -:dawn, +:dusk)'
  for i=0, nd-1 do begin
     printf, lun, '# Int time[min], CML[deg], Io phase[deg], Jup radii[arcsec], y_axis_pol, obs mode'
     printf, lun, '# ',acm[i],cml[i],pio[i],apr[i],y_axis_pol[i],mode[i]
    for j=0, nd_rj-1 do begin
      printf, lun, doy[i], yarr_rj[j], prof[i,j], err_prof[i,j]
    endfor
    printf, lun, ' '
  endfor

  ; close file
  free_lun, lun

end    