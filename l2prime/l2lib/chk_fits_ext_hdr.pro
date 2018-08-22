;----------------------------------------------------------
; Check Extension header of fits file
; fn: file name of input fits file 
; n_ext : number of extension in the file
; nd : number of extension which contains Jupiter data
; extn_arr : structure array 
;
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO chk_fits_ext_hdr, fits_arr, extn_arr

  n = n_elements(fits_arr)     ; number of L2 fits data file

  nj = 0L
  for j=0L,n-1L do begin
  
    if fits_arr[j].n_ext le 0 then continue
  
    for i=0L,fits_arr[j].n_ext-1L do begin

      hd = headfits(fits_arr[j].file,exten=2L+i,/SILENT)
      if n_elements(hd) eq 1 then if hd eq -1 then continue

      ; cal (sky obs) ena/dis
      obj_name = fxpar(hd,'CALFLG')
      if obj_name eq 'ena     ' then begin
        extn_arr[nj].calflg = 1
      endif else if obj_name eq 'dis     ' then begin
        extn_arr[nj].calflg = 0
      endif else begin
        extn_arr[nj].calflg = -1
      endelse
      extn_arr[nj].tarra  = fxpar(hd,'TARRA')
      extn_arr[nj].tardec = fxpar(hd,'TARDEC')

      extn_arr[nj].submod = fxpar(hd,'SUBMOD')
      extn_arr[nj].submst = fxpar(hd,'SUBMST')
 
      ; HISAKI local time
      extn_arr[nj].ltesc  = fxpar(hd,'LTESC')

      ; FOV centroid position
      gstr = fxpar(hd,'BC1XAVE') & if strpos(gstr,'nan') eq -1 then extn_arr[nj].gc_uh = float(gstr)
      gstr = fxpar(hd,'BC1YAVE') & if strpos(gstr,'nan') eq -1 then extn_arr[nj].gc_uv = float(gstr)
      gstr = fxpar(hd,'BC2XAVE') & if strpos(gstr,'nan') eq -1 then extn_arr[nj].gc_lh = float(gstr)
      gstr = fxpar(hd,'BC2YAVE') & if strpos(gstr,'nan') eq -1 then extn_arr[nj].gc_lv = float(gstr)

      ; observation time
      extn_arr[nj].fn = j    ; save fits data number
      extn_arr[nj].ext = 2L+i ; save extention number
      sta_time = fxpar(hd,'DATE-OBS')
      end_time = fxpar(hd,'DATE-END')
      cspice_str2et, sta_time, sta_et
      cspice_str2et, end_time, end_et
      extn_arr[nj].et = (sta_et + end_et) * 0.5
    
      nj ++
      
    endfor
  endfor

end
