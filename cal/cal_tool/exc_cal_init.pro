pro exc_cal_init

  ; Directory of cal table data file (default)
  defsysv, '!exc_cal_dir', exists = ret
  if ret eq 1 then begin
    cal_dir = !exc_cal_dir
  endif else begin
    print, '!exc_cal_dir is not defined.'
    return
  endelse
  
  ; INITIALIZE EXCEED cal-table
  ; -----------------------------------------------------------------  
  ; X-table (uniform)
  ; -----------------------------------------------------------------  
  npix = 1024
  table0 = findgen(npix)
  x_table = fltarr(npix,npix)
  for i=0,npix-1 do begin
    x_table[*,i] = table0
  endfor
  defsysv, '!exc_cal_x_table', x_table

  ; -----------------------------------------------------------------  
  ; X-table : xtable_0.sav for Y-pol=0 (+)
  ;           xtable_1.sav for Y-pol=1 (-)
  ; -----------------------------------------------------------------  
  ;           ypol : y-axis pol
  ;           file : source data file name (Compositted Io plasma torus spectrum image)
  ;           x_table[1024,2014] 
  ;           wl[1024] : wavelength [A]
  ; -----------------------------------------------------------------  
  npix = 1024
  x_table0 = fltarr(npix,npix)
  x_table1 = fltarr(npix,npix)

  ; Y-pol +
  restore, cal_dir + 'xtable_0.sav'
  x_table0 = x_table
  ; Y-pol -
  restore, cal_dir + 'xtable_1.sav'
  x_table1 = x_table

  defsysv, '!exc_cal_x_table0', x_table0
  defsysv, '!exc_cal_x_table1', x_table1
  defsysv, '!exc_cal_x_wl', wl

  ; -----------------------------------------------------------------  
  ; Y-table : 'y_table.sav'
  ; -----------------------------------------------------------------  
  ;         y_table[1024,2014]
  ;         file_in     : source data file name (GD71)
  ;         ndeg, ndeg0 : degree of poly_line to fit GD71 data)
  ;         ref         : refernce pixel
  ;         x_valid_range, y_valid_range
  file_y =  cal_dir + 'y_table.sav'
  restore, filename=file_y
  defsysv, '!exc_cal_x_valid_range', x_valid_range
  defsysv, '!exc_cal_y_valid_range', y_valid_range
  defsysv, '!exc_cal_y_ref', ref
  defsysv, '!exc_cal_y_table', y_table
  
  ; -----------------------------------------------------------------  
  ; Jupiter position: 'jupiter_pos.sav'
  ; -----------------------------------------------------------------  
  ;        n_range   : number of julius day range
  ;        jd_range  : julius day range
  ;        coef      : 2nd-order line fit coeffienet
  file_j = cal_dir + 'jupiter_pos.sav'
  restore, filename=file_j
  defsysv, '!exc_cal_jup_jd', jd_range
  defsysv, '!exc_cal_jup_coef', coef
  ; -----------------------------------------------------------------  

end
  