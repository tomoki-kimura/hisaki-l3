pro offset_image, im_cmp=im_cmp, blk_arr=blk_arr, const=const, jupypix=jupypix
  nd=n_elements(im_cmp[0,0,*])
  nx=n_elements(im_cmp[*,0,0])
  ny=n_elements(im_cmp[0,*,0])
  
  iy0=572l
  dely=200l
  
  for k=0l, nd-1l do begin
    for i=0l, nx-1l do begin
      buf=reform(im_cmp[i,*,k])
      im_cmp[i,*,k]=0.d
      for j=0l, ny-1l do begin
        ic=j-jupypix+iy0
        if ic gt ny-1l then ic=ny-1l
        if ic le 0l    then ic=0l
;        if ic ge iy0-dely and ic le iy0+dely then begin
          im_cmp[i,ic,k]=buf[j]
;        endif else begin
;          im_cmp[i,ic,k]=0.d
;        endelse
      endfor
    endfor
  endfor
  
  return
end