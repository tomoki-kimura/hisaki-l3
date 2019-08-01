;----------------------------------------------------------
; Set data block which is defined by the system-III longitude of Jupiter
; Use SPICE
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO def_data_blk_sec, blk_arr, extn_arr, start_date, nd, const

  ; reference frame
  ref  = 'IAU_JUPITER'
  ; light time correction
  corr = 'LT+S'
  ; targets
  trg1 = 'JUPITER'
  trg2 = 'IO'
  trg3 = 'EUROPA'
  ; origin (observer)
  org  = 'EARTH'

  ; size of 1-min step array
;  n = fix(24*60 + const.dl/360.0*const.tj*60)
  n = long(86400l + const.dt*2);*2: margin ;1 sec step???

  ; block size
  n_blk = n_elements(blk_arr)
  n_ext = n_elements(extn_arr)

  ; Start time (UT string and ET)
  yy = fix(strmid(start_date,0,4))
  mm = fix(strmid(start_date,4,2))
  dd = fix(strmid(start_date,6,2))
  ut_str = string(yy,mm,dd,format='(i4.4,"-",i2.2,"-",i2.2,"T00:00:00")')
  cspice_str2et, ut_str, et
  et_arr = et + findgen(n)
  et0_arr=cal_et0_arr(et_arr=et_arr)

  ; calculate temporal difference from anti-target meridional plane (1-sec step)
  deletarr = et_arr-et0_arr

  ; Define start and end ETs of each data block
  iblk = 0L
  for i=1L,n-1L do begin
    del_t1 = deletarr[i-1] mod const.dt
    del_t2 = deletarr[i  ] mod const.dt
    if (del_t2 lt del_t1) then begin
      if iblk ge n_blk-1l then break
      blk_arr[iblk].et_end = et_arr[i]
      iblk ++
      blk_arr[iblk].et_sta = et_arr[i]
    endif
  endfor
  blk_arr[0].et_sta = blk_arr[0].et_end - const.dt
  blk_arr[iblk].et_end = blk_arr[iblk].et_sta + const.dt

  ; search start and end index of extentions in each data block
  t_date = string(yy,mm,dd,format='(i4.4,"-",i2.2,"-",i2.2)')   ; target date
  for i=0L,n_blk-1 do begin

    ; start index of extention for data block "i"
    for j=0L,n_ext-1L do begin
      if (extn_arr[j].et ge blk_arr[i].et_sta) and (extn_arr[j].et lt blk_arr[i].et_end) then begin
        blk_arr[i].ind_sta = j ; record index of the first data
        break
      endif
    endfor

    ; end index of extention for data block "i"
    for j=0L,n_ext-1L do begin
      if (extn_arr[j].et ge blk_arr[i].et_sta) and (extn_arr[j].et lt blk_arr[i].et_end) then begin
        blk_arr[i].ind_end = j ; record index of the last data
      endif
      if extn_arr[j].et ge blk_arr[i].et_end then break
    endfor

    ; check Block ENA/DIS
    cspice_et2utc, blk_arr[i].et_sta, 'ISOC', 0, utcstr
    c_date = strmid(utcstr,0,10)   ; check date
    if t_date ne c_date then begin
      blk_arr[i].ena = 0
    endif else begin
      blk_arr[i].ena = 1
    endelse

  endfor

  ; find Jupiter parameter
  for i=0L,n_blk-1L do begin

    ; Center time of the data block
    blk_arr[i].et = (blk_arr[i].et_sta + blk_arr[i].et_end) * 0.5

    ; Get state vector : Earth to Jupiter
    cspice_spkezr, trg1, blk_arr[i].et, ref, corr, org, state_j , lt_j
    cspice_vpack, state_j[0], state_j[1], state_j[2], vec_j
    ; Get state vector : Earth to Io
    cspice_spkezr, trg2, blk_arr[i].et, ref, corr, org, state_i , lt_i
    cspice_vpack, state_i[0], state_i[1], state_i[2], vec_i
    cspice_vsub, vec_i, vec_j, vec_i
    ; Get state vector : Earth to Europa
    cspice_spkezr, trg3, blk_arr[i].et, ref, corr, org, state_e , lt_e
    cspice_vpack, state_e[0], state_e[1], state_e[2], vec_e
    cspice_vsub, vec_e, vec_j, vec_e

    ; Distance from Earth to Jupiter
    blk_arr[i].rad_j = cspice_vnorm( vec_j )

    ; Angular radius of Jupiter [arcsec]
    blk_arr[i].apr_j = const.rj / blk_arr[i].rad_j * cspice_dpr() * 3600.0

    ; CML
    blk_arr[i].lon_j = -atan(-state_j[1],-state_j[0]) * cspice_dpr();
    if blk_arr[i].lon_j lt 0.0 then blk_arr[i].lon_j = blk_arr[i].lon_j + 360.0

    ; Phase angles of Io and Europa
    ;; matrix which converts reference frame from IAU_JUPITER to a new frame
    ;; where x-axis points jupiter to earth and z-axis is parallel to Jupiter's rotation axis
    cspice_vpack, state_j[0], state_j[1], 0.0, vec_x
    cspice_vpack, 0.0, 0.0, 1.0, vec_z
    cspice_twovec, vec_x, 1, vec_z, 3, mout
    ;; phase angle of Io
    cspice_mxv, mout, vec_i, vec_i
    blk_arr[i].ph_io = atan(vec_i[1],vec_i[0]) * cspice_dpr();
    if blk_arr[i].ph_io lt 0.0 then blk_arr[i].ph_io = blk_arr[i].ph_io + 360.0
    ;; phase angle of Europa
    cspice_mxv, mout, vec_e, vec_e
    blk_arr[i].ph_eu = atan(vec_e[1],vec_e[0]) * cspice_dpr();
    if blk_arr[i].ph_eu lt 0.0 then blk_arr[i].ph_eu = blk_arr[i].ph_eu + 360.0
    ;; Inclination of centrifugal equator relative to rotational equator
    cspice_sphrec, 1.0, const.inc_ce*cspice_rpd(), -const.lon_np*cspice_rpd(), vec_nce
    cspice_mxv, mout, vec_nce, vec_nce
    blk_arr[i].inc_ce = atan(vec_nce[1],vec_nce[2]) * cspice_dpr();

  endfor

end
