;+
; NAME:
;      CONVERT_VALUE2PICEL
;
; PURPOSE:
;      Convert value range to pixel range.
;
; CALLING SEQUENCE:
;      CONVERT_VALUE2PICEL, l2cal_path, xrange_v, yrange_v
;
; ARGUMENT:
;      l2cal_path  - String giving the path of EUV-L2 cal data files.
;      xrange_v    - float array[min,max]
;      yrange_v    - float array[min,max]
;
; OUTPUTS:
;      converted pixel range.[[xmin,ymin][xmax,ymax]]
;
; RESTRICTIONS:
;
; LIBRARY:
;          IDL Astronomy User’s Library         <https://idlastro.gsfc.nasa.gov/>
;          Coyote IDL Program Libraries          <http://www.idlcoyote.com/programs/>
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software)
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; EXAMPLE:
;      IDL> l2cal_path  = '/XXX/XXX/l2caldata.fits'
;      IDL> xrange = [500, 1023]
;      IDL> yrange = [570, 580]
;      IDL> range = convert_value2pixel(l2cal_path, xrange_v, yrange_v)
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/01/30 First Edition
;-
function convert_value2pixel, l2cal_path, xrange_v, yrange_v, waveshift=waveshift

   on_error,2    

   NAME_MODULE = 'CONVERT_VALUE2PIXEL'
   TNAME_STR   = 'STRING'
   N_RANGE     = 2

   MSG_02 = 'No such file. l2cal_path: '
   MSG_03 = 'Prease input range float or doube or int array. [min, max]'
   MSG_04 = 'Format Error. Prease input range. [min, max]'
   MSG_05 = 'L2caldata is bad.'
   MSG_06 = 'Please input'

   range_p = intarr(2,2)

   ; 入力チェック
   if (size(l2cal_path, /tname) ne TNAME_STR) $
         or (n_elements(l2cal_path) ne 1) then $
      message, MSG_01

   if (file_test(l2cal_path) eq 0) then $
      message, MSG_02 + l2cal_path

   if (n_elements(xrange_v) ne 2) $
         or (size(xrange_v, /tname) eq TNAME_STR) then $
      message, MSG_03

   if (n_elements(yrange_v) ne 2)$
         or (size(yrange_v, /tname) eq TNAME_STR) then $
      message, MSG_03

   if (xrange_v[0] ge xrange_v[1]) then $
      message, MSG_04

   if (yrange_v[0] ge yrange_v[1]) then $
      message, MSG_04
   
   ; x,yの校正表を取得
   img_xcoord = mrdfits(l2cal_path, 1, hdr_xcoord, /silent)
   img_ycoord = mrdfits(l2cal_path, 2, hdr_ycoord, /silent)


   
   ; 校正表を取得できない場合はエラー
   if (n_elements(img_xcoord) eq 1) or (n_elements(img_ycoord) eq 1) then $
      message, MSG_05 + ' ' + l2cal_path

   size_img_xcoord = size(img_xcoord)
   size_img_ycoord = size(img_ycoord)

   if (size_img_xcoord[1] ne 1024) or (size_img_xcoord[2] ne 1024)$
        or (size_img_xcoord[1] ne 1024) or (size_img_xcoord[2] ne 1024) then $
      message, MSG_05


   ;wave calibration
   exc_cal_init
   jd_in = julday(1,1,2014)
   exc_cal_img, jd_in, dblarr(1024,1024)+1., outdata, xcal, ycal
   if keyword_set(waveshift) then begin
    xcal+=waveshift
   endif
   for i=0l, size_img_xcoord[1]-1l do img_xcoord[*,i]=xcal
;   for i=0l, size_img_ycoord[2]-1l do img_ycoord[i,*]=ycal
   
   xcoord = img_xcoord[*, 0]
   ycoord = transpose(img_ycoord[0, *])
   
   xcoord_max_str = strcompress(string(xcoord[0]))
   xcoord_min_str = strcompress(string(xcoord[1023]))
   ycoord_max_str = strcompress(string(ycoord[1023]))
   ycoord_min_str = strcompress(string(ycoord[0]))

   if (xrange_v[1] gt xcoord[0]) or (xrange_v[0] lt xcoord[1023]) then $
      message, MSG_06+' xrange.'+ xcoord_min_str+ ' - '+ xcoord_max_str

   if (yrange_v[0] lt ycoord[0]) or (yrange_v[1] gt ycoord[1023]) then $
      message, MSG_06+ ' yrange.'+ ycoord_min_str+ ' - '+ ycoord_max_str
 
   ; value => pixel変換
   xrange_v = reverse(xrange_v)    
   for i = 0, 1 do begin
      value_x = xrange_v[i]
      diff    = xcoord - value_x
      pixel_x = where(abs(diff) eq min(abs(diff)))
      range_p[i, 0] = pixel_x
   endfor      
   
   for j = 0, 1 do begin
      value_y = yrange_v[j]
      diff    = ycoord - value_y
      pixel_y = where(abs(diff) eq min(abs(diff)))
      range_p[j, 1] = pixel_y
   endfor      
   return, range_p 
end
