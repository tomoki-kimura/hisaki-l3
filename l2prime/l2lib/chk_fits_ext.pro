;----------------------------------------------------------
; Check L2 image
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO chk_fits_ext, const, extn_arr, fits_arr

  n = n_elements(extn_arr)
  
  s_val = fltarr(n)
  r_val = fltarr(n)

;  ; ROI for IPT (x0,y0,x1,y1)
;  roi_ipt = [720,520,850,620]  ; thl = 200/(131*101)
;  ; ROI for Background (radiation) (x0,y0,x1,y1)
;  roi_drk = [70,630,960,710]   ; thl = 300/(891*81)

  ; ROI for IPT (x0,y0,x1,y1)
  roi_ipt = const.iptloc  ; thl = 200/(131*101)
  ; ROI for Background (radiation) (x0,y0,x1,y1)
  roi_drk = const.radloc  ; thl = 300/(449*81)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;disabled byHK 
;  for i=0L,n-1L do begin
;    im = mrdfits(fits_arr[extn_arr[i].fn].file,extn_arr[i].ext,hd,/SILENT)
;    get_roi_cnt, im, roi_ipt, val
;    extn_arr[i].ipt_val = val/(roi_ipt[2]-roi_ipt[0])/(roi_ipt[3]-roi_ipt[1])
;    get_roi_cnt, im, roi_drk, val
;    extn_arr[i].rad_val = val/(roi_drk[2]-roi_drk[0])/(roi_drk[3]-roi_drk[1])
;    if extn_arr[i].rad_val gt const.rad_thl then extn_arr[i].rejflg = 2
;  endfor
  
  ;隣接するL2 imageの時間間隔が90sec以上離れている場合は、そのデータから2枚分のL2は採用しない(HV増加・減少中が含まれるため)
  det1 = extn_arr[1].et   - extn_arr[0].et
  if det1 gt 90.0 then begin
    extn_arr[0].rejflg = 1
    extn_arr[1].rejflg = 1
    extn_arr[2].rejflg = 1
  endif
  det2 = extn_arr[n-1].et   - extn_arr[n-2].et
  if det2 gt 90.0 then begin
    extn_arr[n-1].rejflg = 1
    extn_arr[n-2].rejflg = 1
    extn_arr[n-3].rejflg = 1
  endif
  for i=1L,n-2L do begin
    det1 = abs(extn_arr[i].et   - extn_arr[i-1].et)
    if det1 gt 90.0 then begin
      extn_arr[i-1].rejflg = 1
      extn_arr[i  ].rejflg = 1
      extn_arr[i+1].rejflg = 1
    endif
  endfor

  ; Local time selection
  for i=0L,n-1L do begin
  
    if const.lt_sta gt const.lt_end then begin
      if (extn_arr[i].ltesc ge const.lt_sta) or (extn_arr[i].ltesc le const.lt_end) then begin
        extn_arr[i].lt_ena = 1
      endif else begin
        extn_arr[i].lt_ena = 0
      endelse
    endif else begin
      if (extn_arr[i].ltesc ge const.lt_sta) and (extn_arr[i].ltesc le const.lt_end) then begin
        extn_arr[i].lt_ena = 1
      endif else begin
        extn_arr[i].lt_ena = 0
      endelse
    endelse

  endfor
  
end
