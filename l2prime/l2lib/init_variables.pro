;----------------------------------------------------------
; Define structures
; for read_exc_euv_l2.pro
; 2016-06-09
;----------------------------------------------------------
PRO init_variables, fits, extn, blk, const, dl=dl, lt_range=lt_range, dt=dt

  ; Initialize structure to set constant
  ;; m      : number of wavelength grid
  ;; n      : number of spatial grid
  ;; dl     : system III longitude range for one data block
  ;; inc_ce : inclination of centrifugal equator [degree]
  ;; lon_np : system III lonitude of north pole [degree]
  ;; rj     : jovian radius [km]
  ;; tj     : rotation period of Jupiter [hour]
  ;; smin   : min spatial range [pixel]
  ;; smax   : max spatial range [pixel]
  ;; wmin   : min wavelength range [A]
  ;; wmax   : max wavelength range [A]
  ;; fov_cp : pixel number of EUV at the guide camera center
  ;; lt_sta : HISAKI local time (start)
  ;; lt_end : HISAKI local time (end)
  ;; rad_thl : radiation rejection threshold level (count/min/pixel)
  ;; ipt_thl: IPT detection threshold level (count/min/pixel)
  const = {m:1024,n:1024,dl:10.0,dt:53.1d*60.d, inc_ce:6.8,lon_np:210.0,rj:71492.0,tj:9.925, cal_enadis_period:0.,$
          smin:-2345.2, smax:1853.2, wmin:1529.43, wmax:468.867, fov_cp:575, $
          lt_sta:0.0, lt_end:24.0,rad_thl:0.004,radloc:([512l,630l,960l,710l]), ipt_thl:0.015, iptloc:([720l,520l,850l,620l])}
  if keyword_set(dl) then const.dl = dl
  if keyword_set(dt) then const.dt = dt
  if keyword_set(lt_range) then begin
    const.lt_sta = lt_range[0]
    const.lt_end = lt_range[1]
  endif

  cspice_str2et, '2016-07-05T00:00:00', cet
  const.cal_enadis_period=cet
  
  ; Initialize working structure
  ;; file   : L2 data file name  
  ;; n_ext  : number of extenstion in fits file
  fits = {file:'',n_ext:0L}

  ; Initialize working structure
  ;; fn     : L2 data file number  
  ;; ext    : extenstion number in fits file
  ;; et     : ephemeris seconds past J2000
  ;; lon_j  : System III longitude of Jupiter seen from earth [deg]
  ;; calflg : calibration frag (ena=1, dis=0, unknown=-1)  
  ;; rejflg : data refect flag (reject=1)
  ;; tarra  : target R.A. [deg]
  ;; tardec : target Decl.[deg]
  ;; ltesc  : HISAKI local time [hour]
  ;; gc_uh  : centroid upper h value [pixel]
  ;; gc_uv  : centroid upper v value [pixel]
  ;; gc_lh  : centroid lower h value [pixel]
  ;; gc_lv  : centroid lower v value [pixel]
  ;; lt_ena : data selection ENA(1)/DIS(0) by HISAKI local time
  ;; ipt_val: count rate in IPT ROI ;disabled
  ;; rad_val: count rate in RAD ROI ;cnt/min
  ;; mode   : AOCP mode
  ;; submode: AOCP submode
  extn = {fn:0, ext:0L, et:0.0, lon_j:0.0, calflg:0, rejflg:0, tarra:0.0, tardec:0.0, $
          ltesc:0.0, gc_uh:-1.0, gc_uv:-1.0, gc_lh:-1.0, gc_lv:-1.0, lt_ena:1, $
          ipt_val:0.0, rad_val:0.0, submod:0, submst:0}

  ; Initialize working structure
  ;; ena     : block ENA(1)/DIS(0) flag
  ;; et_sta  : start ET of each data block   
  ;; et_end  : end ET of each data block
  ;; et      : (et_sta + et_end) / 2   
  ;; ind_sta : start index of L2 data for each data block   
  ;; ind_end : end index of L2 data for each data block
  ;; sum     : number of L2 extenstion summed in the data block
  ;; rad_j   : radial distance from earth to Jupiter [km]
  ;; apr_j   : apparrent radious of Jupiter seen from earth [arcsec]
  ;; lon_j   : System III longitude of Jupiter seen from earth [deg]
  ;; inc_ce  : inclination of centrifugal equator seen from earth [deg]
  ;; ph_io   : Io phase angle seen from Earth [deg]
  ;; ph_eu   : Europa phase angle seen from Earth [deg] 
  ;; ypol    : Y-axis polarization 0:north/1:south
  ;; mode    : Observation mode for Jupiter 
  ;; hdr     : fits header at the first extention of the block
  ;; radmon  : radiation monitor value counts/min
  ;; radthr  : threshold of radiation monitor value counts/min
  ;; juploc  : flag of jupiter location 1:slit center, 2:boundary btw 20"-140", 3: bottom 140", 4:outside slit
  ;; ycpxjup : y pixel number of jupiter in original l2 data
  blk = {ena:0,et_sta:0.0,et_end:0.0,et:0.0,ind_sta:0,ind_end:0,acm:0,$
      rad_j:0.0,apr_j:0.0, lon_j:0.0,inc_ce:0.0,ph_io:0.0,ph_eu:0.0,ypol:0,$
      mode:3,hdr:ptr_new(),radmon:0.0,radloc:([512l,630l,960l,710l]),radthr:130.d,$
      juploc:0.d,ycpxjup:0.d,slit1:0.d,slit2:0.d,slit3:0.d,slit4:0.d,fwhm:0.d}
  radloc=blk.radloc
  radthr=blk.radthr
  const.rad_thl=radthr/double((radloc[2]-radloc[0]+1)*(radloc[3]-radloc[1]+1))
  return
end
;----------------------------------------------------------
