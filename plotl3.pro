pro plotl3
  set_env_l3
  load_spice
  loadct,39
  
  l3dir=''
  l3=file_search('D:\L3\*2016*.aurora.lv.03.fits')
  ref_year=2016
  
  cspice_utc2et,'1 1, '+string(ref_year,format='(i4)'),et
  cspice_et2utc, et,'J',10,buff
  ref_jd=double(strmid(buff,3))
  
  doy1=0.
  uv1=0.
  n_file=n_elements(l3)
  for i=0, n_file-1 do begin
    print,l3[i]
    im_pri   = mrdfits(l3[i], 0, hdr_pri, /silent)
    im_total = mrdfits(l3[i], 1, hdr_total, /silent)
    data     = mrdfits(l3[i], 2, hdr, /silent)
    for j = 0, n_elements(data) -1 do begin      
      ydn2md,data[j].year,data[j].dayofyear,m,d
      jd=double(ymd2jd(data[j].year,m,d))+data[j].secofday/60./60./24.-0.5
 
;      cspice_utc2et,data[j].datatime,et
;      cspice_et2utc, et,'J',10,buff
;      jd=double(strmid(buff,3))
      
      doy1=[doy1,jd-ref_jd+1]
;      uv1=[uv1,data[j].LINT1190A]
      uv1=[uv1,data[j].TPOW1190A]
;      uv1=[uv1,data[j].TIME_SERIES_C_0]
    endfor
    
  endfor
  doy1=doy1[1:*]
  uv1=uv1[1:*]
  
  ;get_variation_l3, /ps, doyrange=[0,600], ref_year=2016,inxarr=inxarr,inyarr=inyarr,inyerr=inyarr_err
  
  ;!p.multi=[0,1,2]
  ;plot,inxarr,inyarr,xrange=[20,30]
  plot,doy1,uv1,xrange=[20,30]
  stop
  
  ;!p.multi=0
  ;plot,doy1,uv1,xrange=[20,30],color=fsc_color('red')
  ;plot,inxarr,inyarr,xrange=[20,30],linestyle=1,/noerase
  ;stop
  ;stop
end
