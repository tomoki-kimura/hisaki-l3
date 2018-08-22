;===================================================================
; MAIN ROUTINE  (for Jupiter, slit3, mode3/mode4, north/south aurora)
;===================================================================
PRO exeuv_l2c2roi_jup_r, date, ltr, dl, jpg=jpg

  if not keyword_set(ltr) then ltr = '00-24'
  if not keyword_set(dl) then dl = '030'
  
  ;initialize structure (ROI set)
  roi_ = {s1:0.0, s2:0.0, wc:0.0,ws:0.0, m1:0, m2:0, n1:0, n2:0, lab:''}

  n_roi = 11
  rj1 = 3.0
  rj2 = 8.0
  roi = replicate(roi_,n_roi)
  i=0  & roi[i].s1 =  rj1 & roi[i].s2 =  rj2 & roi[i].wc = 657.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIV657 dawn'
  i=1  & roi[i].s1 =  rj1 & roi[i].s2 =  rj2 & roi[i].wc = 680.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIII680 dawn'
  i=2  & roi[i].s1 =  rj1 & roi[i].s2 =  rj2 & roi[i].wc = 765.0  & roi[i].ws = 20.0  & roi[i].lab = 'SII765 dawn'
  i=3  & roi[i].s1 =  rj1 & roi[i].s2 =  rj2 & roi[i].wc = 705.0  & roi[i].ws = 130.0 & roi[i].lab = 'IPT dawn'
  i=4  & roi[i].s1 =  rj1 & roi[i].s2 =  rj2 & roi[i].wc = 834.0  & roi[i].ws = 20.0  & roi[i].lab = 'OII834 dawn'
  i=5  & roi[i].s1 = -rj2 & roi[i].s2 = -rj1 & roi[i].wc = 657.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIV657 dusk'
  i=6  & roi[i].s1 = -rj2 & roi[i].s2 = -rj1 & roi[i].wc = 680.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIII680 dusk'
  i=7  & roi[i].s1 = -rj2 & roi[i].s2 = -rj1 & roi[i].wc = 765.0  & roi[i].ws = 20.0  & roi[i].lab = 'SII765 dusk'
  i=8  & roi[i].s1 = -rj2 & roi[i].s2 = -rj1 & roi[i].wc = 705.0  & roi[i].ws = 130.0 & roi[i].lab = 'IPT dusk'
  i=9  & roi[i].s1 = -rj2 & roi[i].s2 = -rj1 & roi[i].wc = 834.0  & roi[i].ws = 20.0  & roi[i].lab = 'OII834 dusk'
  i=10 & roi[i].s1 = -1.0 & roi[i].s2 =  1.0 & roi[i].wc = 1410.0 & roi[i].ws = 80.0  & roi[i].lab = 'Aurora Long'

  roi_drk = [70,630,710,960]
  
;  read cal file cal
  read_exeuv_cal, xcal, ycal, zcal, ver=1.1

  syy = strmid(date,0,4)
  infile = '/home/hisaki/data/l2prime/'+syy+'/'+'exeuv.'+date+'_LT'+ltr+'_d'+dl+'.fits'
  if not file_exist(infile) then begin
    print, 'file not found: '+infile
    return
  endif
  
  print, 'reading '+infile
  read_exc_l2c, infile, zarr, acm=acm, cml=cml, pio=pio, apr=apr, ace=ace, et=et, ypol=ypol, dej=dej, mode=mode

  ; open file to save data
  outfile = '/home/hisaki/data/l2prime_out/'+syy+'/'+'exeuv.'+date+'_LT'+ltr+'_d'+dl+'.asc'
  print, 'writing '+outfile
  openw, lun, outfile, /get_lun
  printf, lun, '# UTC ET R & ER('+string(n_roi,format='(i2)')+') SIII PIO INT EXTN APJ'  
  printf, lun, '# List of ROI'
  for i=0,n_roi-1 do begin
    printf, lun, '# ',i+1,roi[i].lab,roi[i].s1,roi[i].s2,roi[i].wc,roi[i].ws, $
                 format = '(a2,1x,i4,1x,a15,4(1x,f6.1))'
  endfor  
  printf, lun, '#'

  ; find total counts in roi area
  n = n_elements(acm)
  print, 'number of image : ',n

  val = fltarr(n_roi*2)   ; val  [2*i] = count rate, val  [2*i+1] = error (counting statics)
  val_r = fltarr(n_roi*2) ; val_r[2*i] = R,          val_r[2*i+1] = error (counting statics)

  for i=0,n-1 do begin

    ; find roi area
    roi_ = roi
    roi_[*].s1 = roi_[*].s1 * apr[i]
    roi_[*].s2 = roi_[*].s2 * apr[i]

    l2c_find_roi_area_ypol, xcal, ycal, ypol[i], mode[i], roi_
    
    if (i eq 0) then begin
      for j=0,n_roi-1 do begin
        print, j+1,roi_[j].lab,roi_[j].s1,roi_[j].s2,roi_[j].wc,roi_[j].ws,roi_[j].m1,roi_[j].m2,roi_[j].n1,roi_[j].n2, $
             format = '(i4,1x,a15,4(1x,f6.1),4(1x,i4))'
      endfor     
      printf, lun, '#',indgen(n_roi)+1, $
           format = '(a1,18x,1x,14x,'+string(n_roi,format='(i2)')+'(i2, 20x),2(1x,5x),1x,3x,1x,4x,1x,8x)'
    endif

    ; integrate count in ROI
    for j=0,n_roi-1 do begin
      val[j*2] = 0.0
      val_r[j*2] = 0.0
      for ii = roi_[j].m1,roi_[j].m2 do begin
        for jj = roi_[j].n1,roi_[j].n2 do begin
          val[j*2] = val[j*2] + zarr[ii,jj,i] / 60.0                  ; count/sec
          val_r[j*2] = val_r[j*2] + zarr[ii,jj,i] * zcal[ii,jj] / (roi_[j].n2 - roi_[j].n1 + 1) ; R
        endfor
      endfor
      val[j*2+1] = sqrt(val[j*2]*acm[i]*60.0)/(acm[i]*60.0)           ; error count/sec
      val_r[j*2+1] = val[j*2+1] * val_r[j*2] / val[j*2]               ; error R
    endfor
    
    ; integrate count in Dark ROI
    val_dark = 0.0
    for ii = roi_drk[0], roi_drk[1] do begin
      for jj = roi_drk[2], roi_drk[3] do begin
        val_dark = val_dark + zarr[ii,jj,i] / 60.0                  ; count/sec
      endfor
    endfor
    val_dark /= ((roi_drk[1]-roi_drk[0])*(roi_drk[3]-roi_drk[2]))   ; count/sec/pixel
    
    if acm[i] gt 0 then begin
      ; save data
       cspice_et2utc, et[i], 'ISOC', 0, utcstr
       printf, lun, utcstr,et[i],val_r,cml[i],pio[i],acm[i],i,apr[i], val_dark, $
                    format = '(a19,1x,e14.7e2,'+string(n_roi*2,format='(i2)')+'(1x,f10.4),2(1x,f5.1),1x,i3,1x,i4,1x,f8.2,1x,e12.3e2)'

      ; plot image
;      if keyword_set(jpg) then begin
;;        exc_3dplot, findgen(1024), findgen(1024), zarr[*,*,i], xrange=[150.0,300.0], yrange=[510.0,630.0], zrange=[0.0,1.0], $
;        exc_3dplot, findgen(1024), findgen(1024), zarr[*,*,i], xrange=[720.0,850.0], yrange=[510.0,630.0], zrange=[0.0,1.0], $
;                    xtitle='pixel [wavelength]', ytitle='pixel [spatial]', title=utcstr
;        for j=0,n_roi-1 do begin
;          oplot, [roi_[j].m1,roi_[j].m2,roi_[j].m2,roi_[j].m1,roi_[j].m1],[roi_[j].n1,roi_[j].n1,roi_[j].n2,roi_[j].n2,roi_[j].n1], color=cgcolor('red')
;        endfor
;        jpg_file = 'D:\EUV_DATA\l2c_out\jpg\exeuv.'+date+'_LT'+ltr+'_d'+dl+'_'+string(i,format='(i3.3)')+'.jpg'
;        write_jpeg, jpg_file, tvrd(/true), /true
;      endif
    endif
    
  endfor

  ; close file
  free_lun, lun

end



;  n_roi = 18
;  rj1_1 = -7.5
;  rj2_1 = -3.5
;  rj1_2 = 3.5
;  rj2_2 = 7.5
;  roi = replicate(roi_,n_roi)
;  i=0  & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 657.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIV657 dawn'
;  i=1  & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 657.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIV657 dusk'
;  i=2  & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 680.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIII680 dawn'
;  i=3  & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 680.0  & roi[i].ws = 20.0  & roi[i].lab = 'SIII680 dusk'
;  i=4  & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 765.0  & roi[i].ws = 20.0  & roi[i].lab = 'SII765 dawn'
;  i=5  & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 765.0  & roi[i].ws = 20.0  & roi[i].lab = 'SII765 dusk'
;  i=6  & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 1191.0 & roi[i].ws = 20.0  & roi[i].lab = 'SII1190 dawn'
;  i=7  & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 1191.0 & roi[i].ws = 20.0  & roi[i].lab = 'SII1190 dusk'
;  i=8  & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 1260.0 & roi[i].ws = 30.0  & roi[i].lab = 'SII1260 dawn'
;  i=9  & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 1260.0 & roi[i].ws = 30.0  & roi[i].lab = 'SII1260 dusk'
;  i=10 & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 1405.0 & roi[i].ws = 40.0  & roi[i].lab = 'SIV1405 dawn'
;  i=11 & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 1405.0 & roi[i].ws = 40.0  & roi[i].lab = 'SIV1405 dusk'
;  i=12 & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 834.0  & roi[i].ws = 20.0  & roi[i].lab = 'OII834 dawn'
;  i=13 & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 834.0  & roi[i].ws = 20.0  & roi[i].lab = 'OII834 dusk'
;  i=14 & roi[i].s1 = rj1_1 & roi[i].s2 = rj2_1 & roi[i].wc = 1301.0 & roi[i].ws = 20.0  & roi[i].lab = 'OI1304 dawn'
;  i=15 & roi[i].s1 = rj1_2 & roi[i].s2 = rj2_2 & roi[i].wc = 1301.0 & roi[i].ws = 20.0  & roi[i].lab = 'OI1304 dusk'
;  i=16 & roi[i].s1 =  -1.0 & roi[i].s2 =   1.0 & roi[i].wc = 1410.0 & roi[i].ws =  80.0 & roi[i].lab = 'Aurora Long'
;  i=17 & roi[i].s1 =  -1.0 & roi[i].s2 =   1.0 & roi[i].wc = 1270.0 & roi[i].ws =  60.0 & roi[i].lab = 'Aurora Short'
