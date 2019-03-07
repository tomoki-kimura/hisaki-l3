;----------------------------------------------------------
; Check y-pol
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO check_ypol, blk_arr

  ; period of Y-axis south/mode-3 or north/mode-4
  defsysv, '!aurpos_l2p', exists = ret
  if ret eq 1 then begin
    print, 'aurora pos l2p'
    ypol_n = [['2011-01-17T00:00:00','2011-01-19T23:59:59'],$
              ['2013-01-17T00:00:00','2013-01-19T23:59:59']]
  endif else begin
    ypol_n = [['2014-01-17T00:00:00','2014-01-19T23:59:59'], $ ; mode-3/Y-axis south
              ['2014-01-28T00:00:00','2014-04-24T23:59:59'], $ ; mode-3/Y-axis south
              ['2015-02-13T00:00:00','2015-05-17T23:59:59'], $ ; mode-3/Y-axis south
              ['2016-03-18T00:00:00','2016-03-31T23:59:59'], $ ; mode-3/Y-axis south
              ['2016-04-13T00:00:00','2016-08-30T23:59:59'], $ ; mode-3/Y-axis south
              ['2017-04-14T00:00:00','2017-09-25T23:59:59'], $ ; mode-3/Y-axis south
              ['2018-05-10T00:00:00','2019-05-10T23:59:59']  $ ; mode-20/Y-axis south
             ]
  endelse
  sz = size(ypol_n) & m=sz[1] & n=sz[2]
  et_n = fltarr(m,n)
  
  for i=0,m-1 do begin
    for j=0,n-1 do begin
      utstr_in = ypol_n[i,j]
      cspice_str2et, utstr_in, et_out
      et_n[i,j] = et_out
    endfor
  endfor
  
  nblk = n_elements(blk_arr)
  for i=0,nblk-1 do begin
    for j=0,n-1 do begin
      if (blk_arr[i].et ge et_n[0,j]) and (blk_arr[i].et le et_n[1,j]) then begin
        blk_arr[i].ypol = 1
      endif
    endfor
  endfor

end
