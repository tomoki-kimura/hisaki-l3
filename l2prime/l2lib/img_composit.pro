pro outputlist,fout,hd,extn_arr,totext,reason,log=log
  if keyword_set(log) eq 0 then return
  print,fxpar(hd,'EXTNAME'),',',string(extn_arr.ext,format='(i03)'),'/',string(totext+1,format='(i03)'),reason;Totは個数、extensionは2始まりなので+1する
  printf,fout,fxpar(hd,'EXTNAME'),','$
    ,string(extn_arr.ext,   format='(i03)'),','$;0始まり
    ,string(totext+1,       format='(i03)'),','$
    ,string(extn_arr.calflg,format='(i1)' ),','$
    ,string(extn_arr.rejflg,format='(i1)' ),','$
    ,string(extn_arr.submod,format='(i1)' ),','$
    ,string(extn_arr.submst,format='(i2)' ),','$
    ,string(extn_arr.rad_val,format='(f8.2)'),','$
    ,reason
end

;;;;;;;;;



;----------------------------------------------------------
; Composit image
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO img_composit, blk_arr, extn_arr, fits_arr, im_cmp, no_cal = no_cal, rej = rej, $
                    submod=submod, const=const, effexp=effexp, log=log
print,fits_arr.n_ext

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

    ;tsuchiya calibration
    exc_cal_init
    jd_in = julday(1,1,2014)
;    exc_cal_img, jd_in, im, outdata, xcal, ycal
;    im=outdata


    blk_arr[i].hdr=ptr_new(hd)
    e_cnt=0
    ave_rad_val=0.
    for j=blk_arr[i].ind_sta,blk_arr[i].ind_end do begin

;      printf, lun, i, j, extn_arr[j].ltesc, extn_arr[j].lt_ena, extn_arr[j].rejflg  

      ; read extension
      im = mrdfits(fits_arr[extn_arr[j].fn].file,extn_arr[j].ext,hd,/SILENT)
      exc_cal_img, jd_in, im, outdata, xcal, ycal
      im=outdata
      
      ;calculate radiation
      radloc=blk_arr[i].radloc
      ix0=radloc[0]
      ix1=radloc[2]
      iy0=radloc[1]
      iy1=radloc[3]
      radval = total(im[ix0:ix1,iy0:iy1]); counts/min
      ;print, fxpar(hd,'EXTNAME'), 'radmon', buf, 'radthr', blk_arr[i].radthr 
      extn_arr[j].rad_val=radval
      
      ; skip data
      if keyword_set(no_cal) then if extn_arr[j].calflg eq 1 then begin
        outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'calflg',log=log
        continue
      endif
      if keyword_set(submod) and extn_arr[j].et le const.cal_enadis_period then begin
        if ( (extn_arr[j].submod ne 4) or (extn_arr[j].submst ne 1) ) then begin
          outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'smod_mst',log=log
          continue
        endif
      endif
      if keyword_set(rej) then begin
        if extn_arr[j].rejflg eq 1 then begin
          outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'HV_on/off',log=log
          continue
        endif
        if extn_arr[j].rejflg eq 2 then begin;do not work
          outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'radmon',log=log
          continue
        endif
      endif
      if extn_arr[j].lt_ena eq 0 then begin
        outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'lt ena',log=log
        continue    ; Local time selection
      endif
      
      ; filtering based on radiation monitor
      if radval ge blk_arr[i].radthr then begin
        outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'radmon2',log=log
        continue
      endif
      
      ;;; skip if jupiter located outside the slit ;; TK
      ret=ck_aurpos2(fxpar(hd,'EXTNAME'),!SLIT_POS)
      jupypix=ret.yc
      if jupypix eq -1l then begin
        outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'no peak',log=log
        continue;
      endif
      blk_arr[i].juploc=ret.flag
      blk_arr[i].ycpxjup=ret.yc
      blk_arr[i].slit1=ret.slit1
      blk_arr[i].slit2=ret.slit2
      blk_arr[i].slit3=ret.slit3
      blk_arr[i].slit4=ret.slit4
      blk_arr[i].fwhm=ret.fwhm
      
      ave_rad_val+=radval
      
      if not keyword_set(start_extname) then start_extname=fxpar(hd,'EXTNAME')
      if strlen(start_extname) lt 1l then start_extname=fxpar(hd,'EXTNAME')

      ; offset Jupiter location to y=572 pixel ;;; TK
      offset_one_image, im=im, jupypix=jupypix
      
      ; composit data
      im_cmp[*,*,i] = im_cmp[*,*,i] + im
      blk_arr[i].acm ++
      outputlist,2,hd,extn_arr[j],fits_arr[extn_arr[j].fn].n_ext,'good',log=log
      effexp[i,e_cnt]=fxpar(hd,'EXTNAME')
      e_cnt++
    endfor

    if blk_arr[i].acm ne 0 then begin
      im_cmp[*,*,i] = im_cmp[*,*,i]/blk_arr[i].acm;   [count/min/pixel]
      
      ; radiation background monitor      
;      radloc=blk_arr[i].radloc;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;modify0523hk
;      if keyword_set(radloc) then begin
;        ix0=radloc[0]
;        ix1=radloc[2]
;        iy0=radloc[1]
;        iy1=radloc[3]
;        buf = total(im_cmp[ix0:ix1,iy0:iy1,i]); counts/min
;        blk_arr[i].radmon=buf; counts/min
;      endif
      ;print, fxpar(hd,'EXTNAME'), 'cmp radmon', blk_arr[i].radmon
      blk_arr[i].radmon=ave_rad_val/blk_arr[i].acm
      
      ;; reverse y-pixel if the Y-axis polarization is south
      if blk_arr[i].ypol eq 1 then begin
        buf = reform(im_cmp[*,*,i])
        buf =buf[*,reverse(indgen(const.n))]; counts/pixel/min
        jupypix=const.n - 572
        offset_one_image, im=buf, jupypix=jupypix
        im_cmp[*,*,i]=buf
      endif      
    endif else begin
      im_cmp[*,*,i] =0.0
    endelse
    

  endfor

;  free_lun, lun
  
end