;----------------------------------------------------------
; Check Primary header of fits file
; fn: file name of input fits file 
; n_ext : number of extension in the file (exclude first 2 extenstion)
; for read_exc_euv_l2.pro
;----------------------------------------------------------  
PRO chk_fits_pri_hdr, fits_arr, n_ext

  n = n_elements(fits_arr)
  n_ext = 0
  for i=0,n-1 do begin
    
    ; check file_exist
    openr, lun, fits_arr[i].file, ERROR = err, /get_lun
    if err ne 0 then begin
      ; fitsファイルが存在しない場合
      fits_arr[i].n_ext = -1
      continue
    endif else begin
      ; fitsファイルが存在する場合
      close, lun
      free_lun, lun
      hd = headfits(fits_arr[i].file,exten=0,/SILENT)
      fits_arr[i].n_ext = fix(fxpar(hd,'NEXTEND')) - 1;2;;;;;;;;;;;;;;;;;;;;;;;;間違い？？hk
      if fits_arr[i].n_ext gt 0 then n_ext = n_ext +  fits_arr[i].n_ext
    endelse
    
  endfor

end
