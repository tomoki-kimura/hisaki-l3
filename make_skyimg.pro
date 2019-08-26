pro make_skyimg
  
  set_env_l3
  pattern='mars*'
  l2path=!FITSDATADIR
  
  file=file_search(l2path, '*'+pattern+'*.fits')
  openw,/append,2,!log_place+'skylist_'+get_local_time('YYYYMMDDThhmmss')+'.txt'
  
  for j=00, n_elements(file)-1 do begin
    print,(strsplit(file_basename(file[j]), /extract, '[._]'))[6];4
    im_prim    = mrdfits(file[j], 0, prim_hdr, /silent)
    n_ext = fxpar(prim_hdr, 'NEXTEND')
    if (n_ext eq 0) then continue
    im_tot = mrdfits(file[j], 1, tot_hdr, /silent)
    
    im=0
    count=0
    for i=2, n_ext do begin
      buff = mrdfits(file[j], i, hdr, /silent)
;      if fxpar(hdr, 'SLITMODE') ne '140asec ' then begin
;        print, 'slit is not 140asec'
;        break
;      endif
;      if fxpar(hdr, 'CALFLG') eq 'ena     ' then begin
        im+=buff
        count++
        data_time = fxpar(hdr,'DATE-OBS') & if (data_time eq 0) then continue
        ;print,data_time,i
        printf,2,data_time,',',string(i,format='(i03)'),',',fxpar(hdr, 'OBJECT')
;      endif else continue
    endfor
    if count eq 0 then continue
    print,'sky:',data_time,count
    
    sxaddpar,tot_hdr, 'T_ITIME', count, 'total integtime[sec]'
    fout=(strsplit(file_basename(file[j]), /extract, '[._]'))[6];4
    fits_write,!FITSDATADIR+'/sky/'+fout+'m.fits',im,tot_hdr
  endfor
  
  close,2
end 