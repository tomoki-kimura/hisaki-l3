;----------------------------------------------------------
; Check y-pol
; for read_exc_euv_l2.pro
;----------------------------------------------------------
function check_ypol2, blk_arr
;ypol=0 ==> north
;ypol=1 ==> south
  ypol_n = [['2014-01-17T00:00:00','2014-01-19T23:59:59'], $ ; mode-3/Y-axis south
            ['2014-01-28T00:00:00','2014-04-24T23:59:59'], $ ; mode-3/Y-axis south
            ['2015-02-13T00:00:00','2015-05-17T23:59:59'], $ ; mode-3/Y-axis south
            ['2016-03-18T00:00:00','2016-03-31T23:59:59'], $ ; mode-3/Y-axis south
            ['2016-04-13T00:00:00','2016-08-30T23:59:59'], $ ; mode-3/Y-axis south
            ['2017-04-14T00:00:00','2017-09-25T23:59:59'], $ ; mode-3/Y-axis south
            ['2018-05-10T00:00:00','2019-05-10T23:59:59']  $ ; mode-20/Y-axis south
           ]
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
  ypol = intarr(nblk)
  for i=0,nblk-1 do begin
    for j=0,n-1 do begin
      cspice_str2et, blk_arr[i], et_out
      if (et_out ge et_n[0,j]) and (et_out le et_n[1,j]) then begin
        ypol[i] = 1
      endif
    endfor
  endfor
  return,ypol
end
