pro main_rad_prof

;  ltr = '20-04' & wl = [840.0,826.0]   & rad_corr = 25.0 & zrange=[0,150] ; OII
;  ltr = '00-24' & wl = [775.0,755.0]   & rad_corr = 15.0 & zrange=[0,200] ; SII
  ltr = '00-24' & wl = [690.0,670.0]   & rad_corr = [7.0, -3.0] & zrange=[0,360] ; SIII
;  ltr = '00-24' & wl = [1325.0,1270.0] & rad_corr = 15.0 & zrange=[0,30]  ; OI/Geo-corona

  n = 2
  sta_date_ref = ['2014122200', '2015050100']  
  span_ref     = 42*10 ; hours
  sp       = [-221.4,221.4]
  nd       = 109 ; -221.4 to 221.4 arcsec
  nd_rj    = 121 ; -9 to 9 RJ, 0.15RJ step
  yarr_rj  = -9.0 + 18.0/(nd_rj-1.0)*findgen(nd_rj)

  init_spice

  for i=0,n-1 do begin
    iys_r = strmid(sta_date_ref[i],0,4)
    ims_r = strmid(sta_date_ref[i],4,2)
    ids_r = strmid(sta_date_ref[i],6,2)
    jd_s_ref = julday(ims_r, ids_r, iys_r, 0, 0, 0)
    jd_e_ref = jd_s_ref + span_ref / 24.0
    caldat, jd_s_ref, im1, id1, iy1, ih1
    caldat, jd_e_ref, im2, id2, iy2, ih2
    sd_ref = string(iy1,im1,id1,ih1,format='(i4.4,i2.2,i2.2,i2.2)')
    ed_ref = string(iy2,im2,id2,ih2,format='(i4.4,i2.2,i2.2,i2.2)')

    exc_get_Io_param, jd=(jd_s_ref+jd_e_ref)/2.0, ar = ar_ref
    
    get_rad_prof_l2c, sd_ref, ed_ref, prof=prof0, err_prof=err_prof0, tint=tint, $
                    sp=sp, wl=wl, ltr=ltr, rad_corr=rad_corr, err_flag=err, $
                    xval=yarr, /silent
    yarr0_rj = yarr/ar_ref[0]
    prof_rj_ref = interpol(prof0, yarr0_rj, yarr_rj)
    err_prof_rj_ref = interpol(err_prof0, yarr0_rj, yarr_rj)

    if i eq 0 then begin

      plot, yarr_rj, prof_rj_ref, xrange=[min(yarr_rj),max(yarr_rj)], /xstyle, $
            xtitle='Distance from Jupiter [arcsec]', ytitle='Brightness [R]', yrange=zrange, $
            xgridstyle=1,xticklen=1
      errplot, yarr_rj, prof_rj_ref-err_prof_rj_ref, prof_rj_ref+err_prof_rj_ref 

    endif else begin

      oplot, yarr_rj, prof_rj_ref, color=cgcolor('red')
      errplot, yarr_rj, prof_rj_ref-err_prof_rj_ref, prof_rj_ref+err_prof_rj_ref, color=cgcolor('red')

    endelse

   ret_n = max(prof_rj_ref[0:nd_rj/2-1],imax_n)
   ret_p = max(prof_rj_ref[nd_rj/2:nd_rj-1],imax_p)
   ret_c = max(prof_rj_ref[nd_rj*3/8:nd_rj*5/8],imax_c)
   print, i, ' max:',ret_n, yarr_rj(imax_n),ret_c, yarr_rj(imax_c+nd_rj*3/8),ret_p, yarr_rj(imax_p+nd_rj/2)

  endfor

end

;  wl       = [1305.0,1290.0] ; OI
;  wl       = [840.0,826.0] ; OII
;  wl       = [775.0,755.0] ; SII
;  wl       = [690.0,670.0] ; SIII
;  wl       = [667.0,647.0] ; SIV

;  ltr='20-04'
;  ltr='00-24'

;get_rad_prof_l2c, '2015021100', '2015021217', xval=x1, prof=prof1, wl=wl, ltr=ltr
;get_rad_prof_l2c, '2015021400', '2015021517', xval=x2, prof=prof2, wl=wl, ltr=ltr

;plot, x2, prof2, /xgridstyle
;oplot, x1, prof1, color=cgcolor('red')
