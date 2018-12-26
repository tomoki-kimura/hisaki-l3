;----------------------------------------------------------
; Composit image
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO img_composit, blk_arr, extn_arr, fits_arr, im_cmp, no_cal = no_cal, rej = rej, submod=submod, const=const

;  openw, lun, 'c:\Doc\hisaki\lt_check.txt', /get_lun

  n_blk = n_elements(blk_arr)

  for i=0,n_blk-1 do begin
 
    blk_arr[i].acm = 0
  
    ; block ENA/DIS selection
    if (blk_arr[i].ena eq 0) then begin
      im_cmp[*,*,i] = 0.0
      continue
    endif
    
    ; no data in block
    if (blk_arr[i].ind_sta eq 0) and (blk_arr[i].ind_end eq 0) then begin
      im_cmp[*,*,i] = 0.0
      continue
    endif  

    j=(blk_arr[i].ind_sta+blk_arr[i].ind_end)/2l
    im = mrdfits(fits_arr[extn_arr[j].fn].file,extn_arr[j].ext,hd,/SILENT)
    blk_arr[i].hdr=ptr_new(hd)
    for j=blk_arr[i].ind_sta,blk_arr[i].ind_end do begin

;      printf, lun, i, j, extn_arr[j].ltesc, extn_arr[j].lt_ena, extn_arr[j].rejflg  

      ; skip data
      if keyword_set(no_cal) then if extn_arr[j].calflg eq 1 then continue
      if keyword_set(submod) then begin
        if ( (extn_arr[j].submod ne 4) or (extn_arr[j].submst ne 1) ) then continue
      endif
      if keyword_set(rej) then begin
        if extn_arr[j].rejflg eq 1 then continue
      endif
      if extn_arr[j].lt_ena eq 0 then continue    ; Local time selection
      
      
      ; read extension
      im = mrdfits(fits_arr[extn_arr[j].fn].file,extn_arr[j].ext,hd,/SILENT)
      
      ;;; skip if jupiter located outside the slit ;; TK
      ret=ck_aurpos(fxpar(hd,'EXTNAME'),!SLIT_POS)
      jupypix=ret.yc
      blk_arr[i].juploc=ret.flag
      blk_arr[i].ycpxjup=ret.yc
      if jupypix ne -1l then begin
        ; offset Jupiter location to y=572 pixel ;;; TK
        offset_one_image, im=im, jupypix=jupypix
      endif

      ; filtering based on radiation monitor
      radloc=blk_arr[i].radloc
      if keyword_set(radloc) then begin
        ix0=radloc[0]
        ix1=radloc[2]
        iy0=radloc[1]
        iy1=radloc[3]
        buf = total(im[ix0:ix1,iy0:iy1]); counts/min
        if buf ge blk_arr[i].radthr then continue   ; counts/min
      endif
      
      
      ; composit data
      im_cmp[*,*,i] = im_cmp[*,*,i] + im
      blk_arr[i].acm ++
    endfor

    if blk_arr[i].acm ne 0 then begin
      im_cmp[*,*,i] = im_cmp[*,*,i]/blk_arr[i].acm;   [count/min/pixel]
      ;; reverse y-pixel if the Y-axis polarization is south
      if blk_arr[i].ypol eq 1 then begin
        buf = reform(im_cmp[*,*,i])
        buf =buf[*,reverse(indgen(const.n))]; counts/pixel/min
        jupypix=const.n - jupypix
        offset_one_image, im=buf, jupypix=jupypix
        im_cmp[*,*,i]=buf
      endif      
    endif else begin
      im_cmp[*,*,i] =0.0
    endelse
    
    radloc=blk_arr[i].radloc
    if keyword_set(radloc) then begin
      ix0=radloc[0]
      ix1=radloc[2]
      iy0=radloc[1]
      iy1=radloc[3]
      buf = total(im_cmp[ix0:ix1,iy0:iy1,i]); counts/min
      blk_arr[i].radmon=buf; counts/min
    endif
    

  endfor

;  free_lun, lun
  
end
