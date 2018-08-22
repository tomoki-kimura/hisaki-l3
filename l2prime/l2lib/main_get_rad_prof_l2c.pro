pro main_get_rad_prof_l2c, set=set, line=line, peak_in=peak_in

;  dir = 'C:\Doc\HISAKI\prof\'
  dir = 'D:\EUV_DATA\prof\'

  if not keyword_set(set) then set=1
  if not keyword_set(line) then line='SII'

  if set eq 1 then  begin
    sta_date = '20141201'  ; DOY=-31 of 2015
    end_date = '20150211'
    ref_doy = -31
  endif else if set eq 2 then begin
    sta_date = '20150213'  ; DOY=44 of 2015
    end_date = '20150510'
    ref_doy = 44
  endif else begin
    print, 'invalid set, ',set
    return
  endelse

  if line eq 'OI' then  begin
    label = 'OI'   & wl = [1311.0,1297.0] & zrange=[2,50]  & zrange2=[10,50] ; OI
  endif else if line eq 'OII' then begin
    label = 'OII'  & wl = [840.0,826.0]   & zrange=[0,360] & zrange2=[95,400] ; OII
  endif else if line eq 'SII' then begin
    label = 'SII'  & wl = [775.0,755.0]   & zrange=[0,240] & zrange2=[50,360] ; SII
  endif else if line eq 'SII2' then begin
    label = 'SII-2'  & wl = [1270.0,1250.0]   & zrange=[0,450] & zrange2=[50,700] ; SII
  endif else if line eq 'SIII' then begin
    label = 'SIII' & wl = [690.0,670.0]   & zrange=[0,450]  & zrange2=[100,700] ; SIII
  endif else if line eq 'SIV' then begin
    label = 'SIV'  & wl = [667.0,647.0]   & zrange=[0,180]  & zrange2=[30,200] ; SIV
  endif else if line eq 'HeI' then begin
    label = 'HeI'  & wl = [596.0,576.0]   & zrange=[0,400]  & zrange2=[0,3000] ; HeI
  endif else begin
    print, 'invalid line, ',line
    return
  endelse

  sp       = [-220,220]
  nd       = 105 ; -220 to 220 arcsec
  step     = 1                    ; days
  span     = step*42.0/24.0       ; days

  if label eq 'OI' or label eq 'OII' then ltr = '20-04' $
  else                                    ltr = '00-24'

  file_out = dir + 'rad\rad_' $
           + sta_date + '-' + end_date + '_LT' $
           + ltr + '_S' + string(step,format='(i2.2)') $
           + '_' + label    ; basename
  print, 'output:' + file_out

;  init_spice

  iys = strmid(sta_date,0,4)
  ims = strmid(sta_date,4,2)
  ids = strmid(sta_date,6,2)
  iye = strmid(end_date,0,4)
  ime = strmid(end_date,4,2)
  ide = strmid(end_date,6,2)
  jd_s = julday(ims, ids, iys, 0, 0, 0)
  jd_e = julday(ime, ide, iye, 0, 0, 0)
  
  md = fix( ( jd_e - jd_s ) / step ) + 1

  prof     = fltarr(md,nd)
  err_prof = fltarr(md,nd)
  ap_rad   = fltarr(md)
  xarr     = ref_doy + findgen(md)*step
  peak_p   = fltarr(md)
  peak_n   = fltarr(md)
  peak     = fltarr(md)

  nd_rj       = 121 ; -9 to 9 RJ, 0.15RJ step
  yarr_rj     = -9.0 + 18.0/(nd_rj-1.0)*findgen(nd_rj)
  prof_rj     = fltarr(md,nd_rj)
  err_prof_rj = fltarr(md,nd_rj)

  dr = [8.0,8.5]
  i_dr = intarr(4)
  dr_v = -dr[1] & ret = min(abs(dr_v-yarr_rj),ind) & i_dr[0] = ind
  dr_v = -dr[0] & ret = min(abs(dr_v-yarr_rj),ind) & i_dr[1] = ind
  dr_v =  dr[0] & ret = min(abs(dr_v-yarr_rj),ind) & i_dr[2] = ind
  dr_v =  dr[1] & ret = min(abs(dr_v-yarr_rj),ind) & i_dr[3] = ind
  didr_p = fltarr(md)
  didr_n = fltarr(md)

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
                      xval=yarr0, /silent
    if (tint gt 100 and err eq 0) then begin
      prof[id,0:nd-1]     = prof0[0:nd-1]
      err_prof[id,0:nd-1] = err_prof0[0:nd-1]

      yarr0_rj = yarr0/ap_rad[id]
      prof0_rj = interpol(prof0, yarr0_rj, yarr_rj)
      err_prof0_rj = interpol(err_prof0, yarr0_rj, yarr_rj)

      prof_rj[id,*]     = prof0_rj
      err_prof_rj[id,*] = err_prof0_rj
            
    endif
    
    jd_set += step
    id ++
    if jd_set gt jd_e then break

  endwhile

  ; PLOT
  window, xsize=600, ysize=800

  ; DI/DR
  didr_n = ( prof_rj[*,i_dr[0]]-prof_rj[*,i_dr[1]] ) / ( yarr_rj[i_dr[0]] - yarr_rj[i_dr[1]] )
  didr_p = -( prof_rj[*,i_dr[2]]-prof_rj[*,i_dr[3]] ) / ( yarr_rj[i_dr[2]] - yarr_rj[i_dr[3]] )
  err_didr_n = sqrt( ( err_prof_rj[*,i_dr[0]] )^2 + ( err_prof_rj[*,i_dr[1]] )^2 ) / ( yarr_rj[i_dr[0]] - yarr_rj[i_dr[1]] )
  err_didr_p = sqrt( ( err_prof_rj[*,i_dr[2]] )^2 + ( err_prof_rj[*,i_dr[3]] )^2 ) / ( yarr_rj[i_dr[2]] - yarr_rj[i_dr[3]] )
  for i=0,md-1 do begin
    if didr_n[i] eq 0 then didr_n[i] = !values.f_nan
    if didr_p[i] eq 0 then didr_p[i] = !values.f_nan
  endfor

  pos = [0.15,0.2,0.8,0.27]
  plot,  xarr, didr_n, pos=pos, xrange=[min(xarr), max(xarr)], /xstyle, $
         yrange=[0.0, 90.0], /ystyle, /nodata, $
         xtitle='Day of year', ytitle='DI/DR'
  if set eq 2 then begin
    oplot, xarr, didr_p ;, color=cgcolor("red")
    errplot, xarr, didr_p-err_didr_p, didr_p+err_didr_p ;, color=cgcolor("red")
  endif else begin
    oplot, xarr, didr_n ;, color=cgcolor("blue")
    errplot, xarr, didr_n-err_didr_n, didr_n+err_didr_n ;, color=cgcolor("blue")
  endelse

  ; (-)
  pos = [0.15,0.36,0.8,0.56]
  yr=[-9.0,-4.0]
  ret = min(abs(yr[0]-yarr_rj),ind1)
  ret = min(abs(yr[1]-yarr_rj),ind2)
  for i=0,md-1 do begin
    ret = max(prof_rj[i,ind1:ind2],ind)
    peak_n[i] = yarr_rj[ind1+ind]
  endfor
  t3dplot, xarr, yarr_rj, prof_rj, pos=pos, $
              ztitle='Brightness [R]', ytitle='Distance[RJ]', $
              zrange = zrange, yrange=yr, /noerase, xtickformat='(a1)'
  oplot, xarr,peak_n,psym=1
  oplot, [min(xarr),max(xarr)],[6,6],color=cgcolor('white'), linestyle=2
  oplot, [min(xarr),max(xarr)],[-6,-6],color=cgcolor('white'), linestyle=2
  peak_n_ave = mean(peak_n)
  print, 'average pos[RJ]=',peak_n_ave

  ; (Aurora)
  pos = [0.15,0.57,0.8,0.69]
  yr=[ -1.7, 1.7]
  ret = min(abs(yr[0]-yarr_rj),ind1)
  ret = min(abs(yr[1]-yarr_rj),ind2)
  for i=0,md-1 do begin
    ret = max(prof_rj[i,ind1:ind2],ind)
    peak[i] = yarr_rj[ind1+ind]
  endfor
  t3dplot, xarr, yarr_rj, prof_rj, pos=pos, $
              zrange = zrange, yrange=yr, /noerase, xtickformat='(a1)'
  oplot, xarr,peak,psym=1
  oplot, [min(xarr),max(xarr)],[0,0],color=cgcolor('white'), linestyle=2
  peak_a = mean(peak)
  print, 'average pos[RJ]=',peak_a

  ; (+)
  pos = [0.15,0.70,0.8,0.90]
  yr=[ 4.0, 9.0]
  ret = min(abs(yr[0]-yarr_rj),ind1)
  ret = min(abs(yr[1]-yarr_rj),ind2)
  for i=0,md-1 do begin
    ret = max(prof_rj[i,ind1:ind2],ind)
    peak_p[i] = yarr_rj[ind1+ind]
  endfor
  t3dplot, xarr, yarr_rj, prof_rj, pos=pos, $
              ztitle='Brightness [R]', ytitle='Distance[RJ]', title='HISAKI/EXCEED '+line, $
              zrange = zrange, yrange=yr, /noerase, xtickformat='(a1)'
  oplot, xarr,peak_p,psym=1
  oplot, [min(xarr),max(xarr)],[6,6],color=cgcolor('white'), linestyle=2
  oplot, [min(xarr),max(xarr)],[-6,-6],color=cgcolor('white'), linestyle=2
  peak_p_ave = mean(peak_p)
  print, 'average pos[RJ]=',peak_p_ave

  ; SUM I
  i_sr = intarr(4)
  if keyword_set(peak_in) then begin
    sr = [peak_in[0]-0.25,peak_in[0]+0.25]
  endif else begin
    sr = [peak_n_ave-0.25,peak_n_ave+0.25]
  endelse
  sr_v = sr[0] & ret = min(abs(sr_v-yarr_rj),ind) & i_sr[0] = ind
  sr_v = sr[1] & ret = min(abs(sr_v-yarr_rj),ind) & i_sr[1] = ind
  if keyword_set(peak_in) then begin
    sr = [peak_in[1]-0.25,peak_in[1]+0.25]
  endif else begin
    sr = [peak_p_ave-0.25,peak_p_ave+0.25]
  endelse
  sr_v =  sr[0] & ret = min(abs(sr_v-yarr_rj),ind) & i_sr[2] = ind
  sr_v =  sr[1] & ret = min(abs(sr_v-yarr_rj),ind) & i_sr[3] = ind
  sr_p = fltarr(md)
  sr_n = fltarr(md)
  err_sr_p = fltarr(md)
  err_sr_n = fltarr(md)
  
  for i=0,md-1 do begin
    sr_n[i] = mean( prof_rj[i,i_sr[0]:i_sr[1]] )
    sr_p[i] = mean( prof_rj[i,i_sr[2]:i_sr[3]] )
    err_sr_n[i] = sqrt( mean( err_prof_rj[i,i_sr[0]:i_sr[1]]^2 ) )
    err_sr_p[i] = sqrt( mean( err_prof_rj[i,i_sr[2]:i_sr[3]]^2 ) )
    if sr_n[i] eq 0 then sr_n[i] = !values.f_nan
    if sr_p[i] eq 0 then sr_p[i] = !values.f_nan
  endfor

  ; (I)
  pos = [0.15,0.28,0.8,0.35]
  plot,  xarr, sr_n, pos=pos, xrange=[min(xarr), max(xarr)], /xstyle, $
         yrange=zrange2, /ystyle, /noerase, xtickformat='(a1)', $
         ytitle='I [R]'
  oplot, xarr, sr_p, color=cgcolor("red")
  errplot, xarr, sr_p-err_sr_p, sr_p+err_sr_p, color=cgcolor("red")
  oplot, xarr, sr_n, color=cgcolor("blue")
  errplot, xarr, sr_n-err_sr_n, sr_n+err_sr_n, color=cgcolor("blue")

  ; SAVE TEXT
  openw, 1, file_out+'.out'
  printf, 1, '# Created by main_get_rad_prof_l2c.pro'
  printf, 1, '# average pos- [RJ] ',peak_n_ave
  printf, 1, '#         pos+ [RJ] ',peak_p_ave
  printf, 1, '#  aurora pos  [RJ] ',peak_a
  printf, 1, '# Day R[arcsec] I[R] ERR_I[R]'
  for i=0,md-1 do begin
    for j=0,nd_rj-1 do begin
      printf, 1, xarr[i], yarr_rj[j], prof_rj[i,j], err_prof_rj[i,j]
    endfor
    printf, 1, ' '
  endfor  
  close, 1

  openw, 1, file_out+'.out2'
  printf, 1, '# Created by main_get_rad_prof_l2c.pro'
  printf, 1, '# average pos- [RJ] ',peak_n_ave
  printf, 1, '#         pos+ [RJ] ',peak_p_ave
  printf, 1, '#  aurora pos  [RJ] ',peak_a
  printf, 1, '# Day I-[R] ERR_I-[R] I+[R] ERR_I+[R] dIdR-[R] ERR_dIdR-[R] dIdR+[R] ERR_dIdR+[R] Peak+[RJ] Peak-[RJ]'
  for i=0,md-1 do begin
    printf, 1, xarr[i], sr_n[i], err_sr_n[i], sr_p[i], err_sr_p[i], $
                didr_n[i], err_didr_n[i], didr_p[i], err_didr_p[i], peak_p[i], peak_n[i], $
                format='(f5.1,10(" ",f7.2))'
  endfor
  close, 1

  ; SAVE JPG
  write_jpeg, file_out+'.jpg', tvrd(/true), /true

end
