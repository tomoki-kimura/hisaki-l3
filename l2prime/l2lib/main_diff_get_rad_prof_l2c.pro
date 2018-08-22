pro main_diff_get_rad_prof_l2c, set=set, line=line

  if not keyword_set(set) then set=1
  if not keyword_set(line) then line='SII'

  if set eq 1 then  begin
    sta_date = '20141201'  ; DOY=-31 of 2015
    end_date = '20150211'
    ref_doy = -31
    sta_date_ref = '2014122200'
    span_ref     = 42*10 ; hours
  endif else if set eq 2 then begin
    sta_date = '20150213'  ; DOY=44 of 2015
    end_date = '20150510'
    ref_doy = 44
    sta_date_ref = '2015050100'
    span_ref     = 42*10 ; hours
  endif else begin
    print, 'invalid set, ',set
    return
  endelse

  if line eq 'OI' then  begin
    label = 'OI'   & wl = [1311.0,1297.0] & zrange=[2,40]  & zrange2=[10,30] ; OI
  endif else if line eq 'OII' then begin
    label = 'OII'  & wl = [840.0,826.0]   & zrange=[0,320] & zrange2=[95,280] ; OII
  endif else if line eq 'SII' then begin
    label = 'SII'  & wl = [775.0,755.0]   & zrange=[0,240] & zrange2=[50,280] ; SII
  endif else if line eq 'SIII' then begin
    label = 'SIII' & wl = [690.0,670.0]   & zrange=[0,400]  & zrange2=[100,500] ; SIII
  endif else if line eq 'SIV' then begin
    label = 'SIV'  & wl = [667.0,647.0]   & zrange=[0,180]  & zrange2=[30,140] ; SIV
  endif else begin
    print, 'invalid line, ',line
    return
  endelse

  dir_in   = 'D:\EUV_DATA\l2_cmp\'
  dir_out  = 'D:\EUV_DATA\prof\'
;  dir_in   = 'C:\Doc\HISAKI\prof\'
;  dir_out  = 'C:\Doc\HISAKI\prof\'

  ;----------------------
  ; initial setting
  ;----------------------
  if label eq 'OI' or label eq 'OII' then ltr = '20-04' $
  else                                    ltr = '00-24'

  step     = 1                    ; days
  span     = step*42.0/24.0       ; days
  sp       = [-220,220]
  nd       = 105 ; -220 to 220 arcsec

  nd_rj    = 121 ; -9 to 9 RJ, 0.15RJ step
  yarr_rj  = -9.0 + 18.0/(nd_rj-1.0)*findgen(nd_rj)

  file_out = dir_out+'rad\diff_' $
           + sta_date + '-' + end_date + '_LT' $
           + ltr + '_S' + string(step,format='(i2.2)') $
           + '_' + label    ; basename

;  init_spice

  ;----------------------
  ; reference profile
  ;----------------------

  iys_r = strmid(sta_date_ref,0,4)
  ims_r = strmid(sta_date_ref,4,2)
  ids_r = strmid(sta_date_ref,6,2)
  jd_s_ref = julday(ims_r, ids_r, iys_r, 0, 0, 0)
  jd_e_ref = jd_s_ref + span_ref / 24.0
  caldat, jd_s_ref, im1, id1, iy1, ih1
  caldat, jd_e_ref, im2, id2, iy2, ih2
  sd_ref = string(iy1,im1,id1,ih1,format='(i4.4,i2.2,i2.2,i2.2)')
  ed_ref = string(iy2,im2,id2,ih2,format='(i4.4,i2.2,i2.2,i2.2)')

  exc_get_Io_param, jd=(jd_s_ref+jd_e_ref)/2.0, ar = ar_ref
    
  get_rad_prof_l2c, sd_ref, ed_ref, prof=prof0, err_prof=err_prof0, tint=tint, $
                    sp=sp, wl=wl, ltr=ltr, err_flag=err, $
                    xval=yarr, /silent, dir_in=dir_in, dir_out=dir_out
  yarr0_rj = yarr/ar_ref[0]
  prof_rj_ref = interpol(prof0, yarr0_rj, yarr_rj)
  err_prof_rj_ref = interpol(err_prof0, yarr0_rj, yarr_rj)

  ;----------------------
  ; differential profile
  ;----------------------
  
  iys = strmid(sta_date,0,4)
  ims = strmid(sta_date,4,2)
  ids = strmid(sta_date,6,2)
  iye = strmid(end_date,0,4)
  ime = strmid(end_date,4,2)
  ide = strmid(end_date,6,2)
  jd_s = julday(ims, ids, iys, 0, 0, 0)
  jd_e = julday(ime, ide, iye, 0, 0, 0)
  
  md = fix( ( jd_e - jd_s ) / step ) + 1
  xarr     = ref_doy + findgen(md)*step

  prof     = fltarr(md,nd)
  err_prof = fltarr(md,nd)
  ap_rad   = fltarr(md)

  prof_rj     = fltarr(md,nd_rj)
  err_prof_rj = fltarr(md,nd_rj)
  
  jd_set = jd_s
  id = 0
  while ( 1 ) do begin

    caldat, jd_set,      im1, id1, iy1, ih1
    caldat, jd_set+span, im2, id2, iy2, ih2
    sd = string(iy1,im1,id1,ih1,format='(i4.4,i2.2,i2.2,i2.2)')
    ed = string(iy2,im2,id2,ih2,format='(i4.4,i2.2,i2.2,i2.2)')

    exc_get_Io_param, jd=jd_set+span/2.0, ar = ar
    ap_rad[id] = ar
    
    get_rad_prof_l2c, sd, ed, prof=prof0, err_prof=err_prof0, tint=tint, $
                      sp=sp, wl=wl, ltr=ltr, err_flag=err, $
                      xval=yarr, /silent, dir_in=dir_in, dir_out=dir_out
    if (tint gt 200 and err eq 0) then begin
      prof[id,0:nd-1]     = prof0[0:nd-1]
      err_prof[id,0:nd-1] = err_prof0[0:nd-1]
;      prof[id,*]     = prof0
;      err_prof[id,*] = err_prof0

      yarr0_rj = yarr/ap_rad[id]
      prof0_rj = interpol(prof0, yarr0_rj, yarr_rj)
      err_prof0_rj = interpol(err_prof0, yarr0_rj, yarr_rj)

      prof_rj[id,*]     = prof0_rj
      err_prof_rj[id,*] = err_prof0_rj

      ; --- plot ---
      plot, yarr_rj, prof0_rj, xrange=[min(yarr_rj),max(yarr_rj)], /xstyle, $
          yrange=[0.0,zrange[1]*2.5], /ystyle, $
          xtitle='Distance from Jupiter [arcsec]', ytitle='Brightness [R]', $
          title = sd+'-'+ed
      errplot, yarr_rj, prof0_rj-err_prof0_rj, prof0_rj+err_prof0_rj
      oplot,   yarr_rj, prof_rj_ref, color=cgcolor('red')
      errplot, yarr_rj, prof_rj_ref-err_prof_rj_ref, prof_rj_ref+err_prof_rj_ref, color=cgcolor('red')

    endif

    jd_set += step
    id ++
    if jd_set gt jd_e then break;

  endwhile
  
  ;----------------------
  ; output result
  ;----------------------
  openw, 1, file_out+'.out'
  printf, 1, '# Created by main_diff_get_rad_prof_l2c.pro'
  printf, 1, '# start date of reference profile : ',sta_date_ref
  printf, 1, '# span of reference profile [hour]: ',span_ref
  printf, 1, '# Day R[arcsec] I[R] ERR_I[R] I_diff[R] ERR_I_diff[R]'
  for i=0,md-1 do begin
    for j=0,nd_rj-1 do begin
      printf, 1, xarr[i], yarr_rj[j], prof_rj[i,j], err_prof_rj[i,j], prof_rj[i,j]-prof_rj_ref[j], err_prof_rj[i,j]*sqrt(2.0)
    endfor
    printf, 1, ' '
  endfor  
  close, 1
  
  prof_rj_diff     = fltarr(md,nd_rj)
  for i=0,md-1 do begin
    prof_rj_diff[i,*] = prof_rj[i,*] - prof_rj_ref
  endfor
  
  pos = [0.15,0.1,0.8,0.49]
  t3dplot, xarr, yarr_rj, prof_rj_diff, $
;              xtitle='Day of Year', ytitle='Distance from Jupiter [RJ]', $
              ztitle='Diff. Brightness [R]', $ ;title=label+' ref:'+sta_date_ref, $
              zrange = zrange, pos=pos, yrange=[-9.0,-4.0]
  pos = [0.15,0.51,0.8,0.9]
  t3dplot, xarr, yarr_rj, prof_rj_diff, $
;              xtitle='Day of Year', ytitle='Distance from Jupiter [RJ]', $
              ztitle='Diff. Brightness [R]', $ ;title=label+' ref:'+sta_date_ref, $
              zrange = zrange, pos=pos, yrange=[4.0,9.0], /noerase, xtickformat='(a1)'
  write_jpeg, file_out+'.jpg', tvrd(/true), /true

end
