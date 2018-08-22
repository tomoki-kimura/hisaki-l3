;----------------------------------------------------------
; Check L2 image
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO get_roi_cnt, im, roi, val

  sz = size(im)
  m = sz[1]
  n = sz[2]
  
  val = 0
  for i=roi[0], roi[2] do begin
    for j=roi[1], roi[3] do begin
      val = val + im[i,j]
    endfor
  endfor

end
