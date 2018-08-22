; ex) IDL> file = 'G:\hisaki\euv\l2\exeuv.star.mod.01.20151230.lv.02.vr.00.fits'
;     IDL> exc_GD71, file
;     IDL> exc_GD71, file, save_dir = 'C:\HISAKI\temp\GD71\', wl_raneg=[1050.0, 1150.0]
pro exc_GD71, file, save_dir=save_dir, wl_range=wl_range

  if not keyword_set(file) then begin
    print, 'Usage : exc_GD71, file, save_dir = save_dir, wl_raneg=wl_range'
    return
  endif

  if not keyword_set(wl_range) then begin
     wl_range = [1050.0, 1150.0]
  endif

  if not keyword_set(save_dir) then begin
    save_dir = 'C:\HISAKI\temp\GD71\jpg\'
  endif

  !P.CHARSIZE = 1.5
   
  ;target RADEC (GD71)
  ra_trg = (05.0 + 52.0/60.0 + 27.614/3600.0)/24.0*360.0 ; degree 
  dc_trg =  15.0 + 53.0/60.0 +  13.75/3600.0             ; degree

  if keyword_set(save_dir) then begin
    openw, lun, save_dir + file_basename(file) + '.txt', /get_lun
    printf, lun, '# SLCRA SLCDEC TRG_RA TRG_DEC LT PIX_MAX Y_MAX[asec] MAX_VAL[R/A]'
  endif
  
  print, file
  print, save_dir
  
  ; get number of L2 image
  fits_read, file, data, header, exten_no=0
  n_ext = fxpar(header,'NEXTEND')

  ; get CAL data
  read_exeuv_cal, cal_x, cal_y, cal_z 
  cal_x = reverse(cal_x)
  cal_z = reverse(cal_z,  1)

  ; integration range (wavelength)
  find_arr_index, i1, wl_range[0], cal_x
  find_arr_index, i2, wl_range[1], cal_x
  prof_y = fltarr(1024)

  for i=1,n_ext-1 do begin

    ; read L2 image
    fits_read,file,data,header,exten_no=i+1

    ; read haeder contents
    tarra = fxpar(header,'TARRA')
    tardc = fxpar(header,'TARDEC')
    ltesc = fxpar(header,'LTESC')
    
    if tarra eq 0.0 and tardc eq 0.0 then begin
      tarra = ra_trg
      tardc = dc_trg
    endif
    slcra = fxpar(header,'SLCRA')
    slcdc = fxpar(header,'SLCDEC')
    date_obs = fxpar(header,'DATE-OBS')

    ; apply cal to image
    data  = reverse(data, 1)
    im = float(data)*cal_z

    ; wavelength integration
    for j=0, 1023 do begin
      prof_y[j] = mean(im[i1:i2,j])
    endfor
    
    ; peak detection of source position
    iprof = sort(prof_y)

    x = findgen(21) - 10 + iprof[1023]
    if iprof[1023]-10 lt 0 then continue
    if iprof[1023]+10 gt 1023 then continue    
    y = prof_y[iprof[1023]-10:iprof[1023]+10]
    yfit = GAUSSFIT(x, y, coeff, NTERMS=4)
    y_pix = coeff[1] 
    y_val = coeff[0]

    exc_3dplot, cal_x, cal_y, im, xr=[500,1450], yr=[-250,250], zr=[0.0,500.0], $
            xtitle='Wavelength[A]', ytitle='[arcsec]', ztitle='[R/pixel]', $
            title=date_obs+" "+string(i), pos = [0.2,0.2,0.8,0.5]
    plot, x,y,/psym, xtitle='y-pixel', ytitle='Intensity [R/A]',title=date_obs+" "+string(i), $
            /noerase, pos = [0.2,0.6,0.8,0.9]
    oplot, x,yfit,color=cgcolor('red')
    oplot, [y_pix, y_pix], [min(prof_y),max(prof_y)], color=cgcolor('red')

    ;----------------------------
    ; jpeg fileへの出力
    ;----------------------------
    if keyword_set(save_dir) then begin
      write_jpeg, save_dir + file_basename(file) + '.' + string(i,format='(i3.3)')+'.jpg', tvrd(/true), /true
      printf, lun, i+1, slcra, slcdc, tarra, tardc, ltesc, y_pix, y_val, $
              format='(i3, f10.5, f10.5, f10.5, f10.5, f6.2, f7.2, f8.1)'
    endif
    
  endfor
  
  free_lun, lun
  
end