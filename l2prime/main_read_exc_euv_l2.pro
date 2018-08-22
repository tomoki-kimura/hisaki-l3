; usage : IDL > main_read_exc_euv_l2, '20150101', '20150601'
pro main_read_exc_euv_l2, start_date, end_date, dl=dl, lt_range=lt_range,  target=target

;  if not keyword_set(start_date) then beign
;     print, "usage IDL>main_read_exc_euv_l2, '20160101', '20160103', lt_range=[20.0,4.0], dl=10.0, target='jupiter.mod.20'"
;     return
;  endif

  if not keyword_set(dl) then dl=30.0
  if not keyword_set(lt_range) then lt_range=[0.0,24.0]
  if not keyword_set(target) then target = 'jupiter.mod.03'

  ltc = string(lt_range,format='(i2.2,"-",i2.2)')
  dlc = string(dl,format='(i3.3)')

  ;--- Init spice (load kernels)
  ;init_spice

  iys = strmid(start_date,0,4)
  ims = strmid(start_date,4,2)
  ids = strmid(start_date,6,2)
  iye = strmid(end_date,0,4)
  ime = strmid(end_date,4,2)
  ide = strmid(end_date,6,2)
  
  jd_s = julday(ims, ids, iys)
  jd_e = julday(ime, ide, iye)
  
  jd = jd_s

  while (jd le jd_e) do begin

    caldat, jd, mn, dy, yr
    stdate = string(yr,mn,dy,format='(i4.4,i2.2,i2.2)')

    print, stdate
    read_exc_euv_l2, stdate, status=status, dl=dl, lt_range=lt_range, target=target
    
    jd ++
    
  endwhile
  
end
