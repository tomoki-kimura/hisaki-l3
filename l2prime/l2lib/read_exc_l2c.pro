; read EXCEED-EUV L2 composit data (which is created by read_exc_euv_l2.pro)
; in : file
; out: zarr, acm, cml, pio, apr, ace, et, utcstr, ypol 
; 2016-06-09 F. Tsuchiya
;
PRO read_exc_l2c, file, zarr, acm = acm, cml = cml, pio = pio, apr = apr, ace = ace, $
                  et = et, jd = jd, utcstr = utcstr, ypol = ypol, dej = dej, mode=mode, $
                  xarr=xarr, yarr=yarr

  hd = headfits(file,exten=0,/SILENT)
  wl_min = fxpar(hd,'WL_MIN')
  wl_max = fxpar(hd,'WL_MAX')
  sp_min = fxpar(hd,'SP_MIN')
  sp_max = fxpar(hd,'SP_MAX')
  m = fxpar(hd,'NAXIS_WL')
  n = fxpar(hd,'NAXIS_SP')
  xarr = wl_min + (wl_max-wl_min)/float(m-1)*findgen(m)
  yarr = sp_min + (sp_max-sp_min)/float(n-1)*findgen(n)

  n_blk = fxpar(hd,'NEXTEND')
  
  ; read all image
  zarr = fltarr(m,n,n_blk)
  acm = intarr(n_blk)
  cml = fltarr(n_blk)
  pio = fltarr(n_blk)
  apr = fltarr(n_blk)
  ace = fltarr(n_blk)
  ypol = intarr(n_blk)
  mode = intarr(n_blk)
  dej = intarr(n_blk)
  et = dblarr(n_blk)
  utcstr = strarr(n_blk)
  for i=0,n_blk-1 do begin
    zarr[*,*,i] = mrdfits(file,i+1,hd,/SILENT)
    acm[i] = fxpar(hd,'INT_TIME')
    cml[i] = fxpar(hd,'CML')
    pio[i] = fxpar(hd,'IO_PHASE')
    apr[i] = fxpar(hd,'AP_RAD')
    ace[i] = fxpar(hd,'ANG_CE')
    ypol[i] = fxpar(hd,'Y_POL')      
    mode[i] = fxpar(hd,'MODE')      
    dej[i] = fxpar(hd,'DIST_EJ')
    ext_name = fxpar(hd,'EXTNAME')
    cspice_str2et, ext_name, et_out
    utcstr[i] = ext_name
    et[i] = et_out
  endfor
  jd = cspice_j2000() + et/cspice_spd()
      
end