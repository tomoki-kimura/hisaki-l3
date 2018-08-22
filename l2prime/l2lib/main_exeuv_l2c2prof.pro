pro main_exeuv_l2c2prof

  sta_date = '20141201'
  end_date = '20150510'

  iys = strmid(sta_date,0,4)
  ims = strmid(sta_date,4,2)
  ids = strmid(sta_date,6,2)
  iye = strmid(end_date,0,4)
  ime = strmid(end_date,4,2)
  ide = strmid(end_date,6,2)
  jd_s = julday(ims, ids, iys, 0, 0, 0)
  jd_e = julday(ime, ide, iye, 0, 0, 0)
  
  md = fix( jd_e - jd_s ) + 1

  jd_set = jd_s
  while ( 1 ) do begin

    caldat, jd_set,      im1, id1, iy1
    date = string(iy1,im1,id1,format='(i4.4,i2.2,i2.2)')

    exeuv_l2c2prof, date, wl=[670,690], /jpg
    exeuv_l2c2prof, date, wl=[755,775], /jpg

    jd_set ++
    if jd_set gt jd_e then break    

  endwhile

end
