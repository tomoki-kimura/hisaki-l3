; usage : IDL > main_exeuv_l2c2roi_jup_R, '20150101', '20150601'
pro main_exeuv_l2c2roi_jup_R, start_date, end_date, skip_l2=skip_l2, dl=dl, lt_range=lt_range, target=target

  if not keyword_set(start_date) or not keyword_set(end_date) then begin
    print, 'usage : IDL> main_exeuv_l2c2roi_jup_R, start_date, end_date, skip_l2=skip_l2, dl=dl, lt_range=lt_range, target=target'
    print, "   ex)  IDL> main_exeuv_l2c2roi_jup_R, '20150101', '20150301', /skip_l2, dl=30.0, lt_range=[20.0,4.0], target='jupiter.mod.03'"
    return
  endif


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
    syy = string(yr,format='(i4.4)')

    print, stdate
    if not keyword_set(skip_l2) then begin
      read_exc_euv_l2, stdate, status=status, dl=dl, lt_range=lt_range, target=target
    endif else begin
      infile = !OUTQLDIR+'../l2prime/'+syy+'/'+'exeuv.'+stdate+'_LT'+ltc+'_d'+dlc+'.fits'
      print, infile
      if file_exist(infile) then begin
        status=1
      endif else begin
        print, 'file not found'
        status=0
      endelse
    endelse
    if status eq 1 then begin
      exeuv_l2c2roi_jup_r, stdate, ltc, dlc
    endif
    
    jd ++
    
  endwhile
  
end
