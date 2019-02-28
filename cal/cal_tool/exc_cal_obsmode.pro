pro exc_cal_obsmode, jd_in, ypol=ypol, mode=mode

  ; period of Y-axis south
  ypol_s = [['2014-01-17T00:00:00','2014-01-19T23:59:59'], $ ; mode-3/Y-axis south
            ['2014-01-28T00:00:00','2014-04-30T23:59:59'], $ ; mode-3/Y-axis south
            ['2015-02-13T00:00:00','2015-05-31T23:59:59'], $ ; mode-3/Y-axis south
            ['2016-04-02T00:00:00','2016-08-31T23:59:59']  $ ; mode-3/Y-axis south
           ]

  ; period of mode-4 observations
  mode4 = [['2016-03-05T00:00:00','2016-03-17T23:59:59'], $ ; mode-4 (Y-axis north)
           ['2017-01-02T00:00:00','2017-01-01T23:59:59'] $
           ]

  sz = size(ypol_s)  & m=sz[1]   & n=sz[2]
  jd_ypol = dblarr(m,n)
  sz_m = size(mode4) & m_m=sz_m[1] & n_m=sz_m[2]
  jd_mode = dblarr(m_m,n_m)
  
  for i=0,m-1 do begin
    for j=0,n-1 do begin
      vals = strsplit(ypol_s[i,j], '-T:', /extract)
      jd_ypol[i,j] = julday(vals[1], vals[2], vals[0], vals[3], vals[4], vals[5])
    endfor
  endfor

  for i=0,m_m-1 do begin
    for j=0,n_m-1 do begin
      vals = strsplit(mode4[i,j], '-T:', /extract)
      jd_mode[i,j] = julday(vals[1], vals[2], vals[0], vals[3], vals[4], vals[5])
    endfor
  endfor

  ypol=0
  for i=0,n-1 do begin
    if jd_in ge jd_ypol[0,i] and jd_in le jd_ypol[1,i] then ypol = 1
  endfor

  mode=3
  for i=0,n_m-1 do begin
    if jd_in ge jd_mode[0,i] and jd_in le jd_mode[1,i] then mode = 4
  endfor

end  