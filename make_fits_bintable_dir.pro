;+
; NAME:
;      MAKE_FITS_BINTABLE_DIR
;
; PURPOSE:
;      Make L3 data file(BINARY TABLE EXTENTION).
;
; CALLING SEQUENCE:
;      MAKE_PEAK_LIST_SPLINE, l2_d=l2_dir, l2cal_path=l2cal_path, tablea_path=tablea_path, out_path=out_path
;
; KEYWORDS:
;      ld     - String giving the input directry.
;      cp     - String giving L2cal file path.
;      tp     - String giving tableA path.
;      od     - String giving the output directry
;
; OUTPUTS:
;      L3 data file(BINARY TABLE EXTENTION).
;
; FUNCTIONS USED:
;      The following functions are contained.
;          MAKE_FITS_BINTABLE  -- make l3data.
;
; EXAMPLE:
;   (1) pixel mode
;      IDL> l2_dir     = '/XXX/XXX/XXX'
;      IDL> l2cal_path  = '/XXXX/XXXX'
;      IDL> tablea_path = ''
;      IDL> out_path    = ''
;      IDL> period   = ''
;      IDL> make_fits_bintable_dir, l2_d=l2_dir, l2cal_path=l2cal_path, tablea_path=tablea_path, out_path=out_path
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/01/30 First Edition
;-
pro make_fits_bintable_dir, l2_d=l2_dir, l2cal_p=l2cal_path, tablea_p=tablea_path, out_d=out_dir, pattern=pattern, planet_radii_deg=planet_radii_deg, lightyear=lightyear

   on_error,2
   
   if not keyword_set(pattern) then pattern='*'
   l2_files   = file_search(l2_dir ,'*'+pattern+'*.fits');;;;;;;;byhk
   n_l2_files = n_elements(l2_files)

   ; 指定されたディレクトリのファイル一覧を取得し、各ファイルごとにL3データを生成する。
   for i = 0, n_l2_files - 1 do begin
      print,i
      
      if stregex(FILE_BASENAME(out_dir),'fits$',/boolean) eq 1 then out_dir = FILE_DIRNAME(out_dir)
      
;      file_elm=strsplit(FILE_BASENAME(l2_files[i]),/extract, '[._]');--------byhk
      l2cal_path2=l2cal_path+'/calib_'+stregex(FILE_BASENAME(l2_files[i]),'20[0-9]{6}',/ext)+'_v1.0.fits'    ;--------byhk
      
      make_fits_bintable, l2_p=l2_files[i], l2cal_p=l2cal_path2, tablea_p=tablea_path, out_p=out_dir, planet_radii_deg=planet_radii_deg, lightyear=lightyear
   endfor
end

