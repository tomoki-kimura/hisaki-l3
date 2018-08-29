pro offset_one_image, im=im, jupypix=jupypix
  nx=n_elements(im[*,0])
  ny=n_elements(im[0,*])
  
  iy0=572l
  dely=200l
  
    for i=0l, nx-1l do begin
      buf=reform(im[i,*])
      im[i,*]=0.d
      for j=0l, ny-1l do begin
        ic=j-jupypix+iy0
        if ic gt ny-1l then ic=ny-1l
        if ic le 0l    then ic=0l
;        if ic ge iy0-dely and ic le iy0+dely then begin
          im[i,ic]=buf[j]
;        endif else begin
;          im[i,ic,k]=0.d
;        endelse
      endfor
    endfor
  
  return
end