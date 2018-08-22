;----------------------------------------------------------
; Check y-pol Ver.2
; for read_exc_euv_l2.pro
; 2016-06-09 F. Tsuchiya
;----------------------------------------------------------
PRO check_ypol_v2, blk_arr

  ; period of Y-axis south
  ypol_s = [['2014-01-17T00:00:00','2014-01-19T23:59:59'], $ ; mode-3/Y-axis south
            ['2014-01-28T00:00:00','2014-04-30T23:59:59'], $ ; mode-3/Y-axis south
            ['2015-02-13T00:00:00','2015-05-31T23:59:59'], $ ; mode-3/Y-axis south
            ['2016-04-02T00:00:00','2016-09-01T23:59:59']  $ ; mode-3/Y-axis south
           ]

  ; period of mode-4 observations
  mode4 = [['2016-03-05T00:00:00','2016-03-17T23:59:59'] $ ; mode-4 (Y-axis north)
           ]

  sz = size(ypol_s)  & m=sz[1]   & n=sz[2]
  et_s = fltarr(m,n)
  sz_m = size(mode4) & m_m=sz[1] & n_m=sz[2]
  et_m = fltarr(m,n)
  
  for i=0,m-1 do begin
    for j=0,n-1 do begin
      utstr_in = ypol_s[i,j]
      cspice_str2et, utstr_in, et_out
      et_s[i,j] = et_out
    endfor
  endfor

  for i=0,m_m-1 do begin
    for j=0,n_m-1 do begin
      utstr_in = mode4[i,j]
      cspice_str2et, utstr_in, et_out
      et_m[i,j] = et_out
    endfor
  endfor

  nblk = n_elements(blk_arr)
  for i=0,nblk-1 do begin
    for j=0,n-1 do begin

      if (blk_arr[i].et ge et_s[0,j]) and (blk_arr[i].et le et_s[1,j]) then begin
        blk_arr[i].ypol = 1
      endif

      if (blk_arr[i].et ge et_m[0,j]) and (blk_arr[i].et le et_m[1,j]) then begin
        blk_arr[i].mode = 4
      endif else
        blk_arr[i].mode = 3
      endelse

    endfor
  endfor

end
