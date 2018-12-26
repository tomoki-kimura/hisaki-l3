;+
; NAME:
;      MAKE_FITS_BINTABLE
;
; PURPOSE:
;      Make L3 data file(BINARY TABLE EXTENTION).
;
; CALLING SEQUENCE:
;      MAKE_PEAK_LIST_SPLINE, l2_path=l2_path, l2cal_path=l2cal_path, tablea_path=tablea_path, out_path=out_path
;
; KEYWORDS:
;      l2_path     - String giving the input directry or input file path.
;      l2cal_path  - String giving L2cal file path.
;      tablea_path - String giving tableA.
;      out_path    - String giving the output directry or output file path.
;
; OUTPUTS:
;      L3 data file(BINARY TABLE EXTENTION).
;
; RESTRICTIONS:
;      You can use L2 file including 1day's data per 1 extension.
;
; LIBRARY:
;          IDL Astronomy User’s Library         <https://idlastro.gsfc.nasa.gov/>
;          Coyote IDL Program Libraries          <http://www.idlcoyote.com/programs/>
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software)
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; FUNCTIONS USED:
;      The following functions are contained
;         LOG_SETTING -- Get a name of log file path.
;         CONVERT_VALUE2PIXEL  -- convert value to pixel.
;         FUNCTION_A           -- 
;         WRITE_LOG   -- Write log file
;         GET_LOCAL_TIME -- Get local machine time.
;
; EXAMPLE:
;   (1) pixel mode
;      IDL> l2_path     = '/XXX/XXX/XXX'
;      IDL> l2cal_path  = '/XXXX/XXXX'
;      IDL> tablea_path = ''
;      IDL> out_path    = ''
;      IDL> period   = ''
;      IDL> make_fits_bintable, l2path=l2_path, l2cal_path=l2cal_path, tablea_path=tablea_path, out_path=out_path
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/01/30 First Edition
;      v1.1 2018/03/01 - 引数と出力データに使用する画像のX,Y範囲はすべて配列番号に修正
;                      - 関数内の変数にpixel値なのかvalue値なのか明記する。(_pか_vを付ける)
;                      - L3データのカウント値の算出方法を修正
;                      - L3データの時刻情報は[年、dayofyear、secofday]に修正
;-
pro make_fits_bintable, l2_p=l2_path, l2cal_p=l2cal_path, tablea_p=tablea_path, out_p=out_path, planet_radii_deg=planet_radii_deg

  on_error,2

   ; 定数
   SPECTRESOL=16l
   PRO_NAME = 'MAKE_FITS_BINTABLE'
   STR_EMP = ''
   TRUE  = 1
   FALSE = 0
   TFORMAT_LOG = 'YYYYMMDDThhmmss'
   TFORMAT_EXT = 'YYYY-MM-DDThh:mm:ss'
   INFO = '[INFO] '
   ERR  = '[ERR ] '
   FILE_TYPE_LOG = '.log'

   KEY_L2PATH    = 'L2PATH'
   KEY_TBLAPATH = 'TBLAPATH'
   KEY_CALPATH  = 'CALPATH'
   KEY_DATE     = 'DATE'
   KEY_NEXTEND  = 'NEXTEND'
   KEY_EXTNAME  = 'EXTNAME'
;   KEY_NINTTIME = 'NINTTIME';L2
   KEY_NINTTIME = 'INT_TIME';L2prime
   KEY_RADMON   = 'RADMON'
   KEY_JUPLOC   = 'JUPLOC'
   
   COMMENT_L2PATH    = 'Path/Dir of Input L2 file.'
   COMMENT_TBLAPATH = 'Path of TableA.'
   COMMENT_CALPATH  = 'Path of L2cal file.'
   COMMENT_DATE     = 'Date of file creation (UTC)'

   LOG_DIR  = log_setting()
   LOG_NAME = PRO_NAME + get_local_time(TFORMAT_LOG) + FILE_TYPE_LOG
   LOG_PATH = LOG_DIR + '/' + LOG_NAME 

   MSG_INF01 = 'msg_inf01: Process Start.'
   MSG_INF02 = 'msg_inf02: Process End'
   MSG_INF03 = 'msg_inf03: Read TableA data.'
   MSG_INF04 = 'msg_inf04: Get TableA data. n_recs='
   MSG_INF05 = 'msg_inf05: Make time series.'
   MSG_INF06 = 'msg_inf06: Make FITS file. '
   
   MSG_ERR01 = 'msg_err01: Please input the following items. '
   MSG_ERR02 = 'msg_err05: No such file or directory. '
   MSG_ERR03 = 'msg_err15: Permission denied. Can not read. '
   MSG_ERR04 = 'msg_err18: This file already exists. out_path='
   MSG_ERR05 = 'msg_err11: TableA data is empty. tablea_path='
   MSG_ERR06 = 'msg_err12: TableA data record is invalid. rec num:'

   ; ログ出力
   write_log, LOG_PATH, MSG_INF01
   p_start_time = systime(1)

   ; エラーのキャッチ
   err_flg = 0
   catch, err_flg
   if err_flg ne 0 then begin
      msg = !ERROR_STATE.MSG
      write_log, LOG_PATH, msg
      write_log, LOG_PATH, MSG_INF02
      catch, /cancel
      message, msg
   endif

   ; 引数チェック(l2_path/l2cal_path/tablea_path/out_path)
   err01 = STR_EMP
   if keyword_set(l2_path)     eq FALSE then err01 += '/l2_path'
   if keyword_set(l2cal_path)  eq FALSE then err01 += '/l2cal_path'
   if keyword_set(tablea_path) eq FALSE then err01 += '/tablea_path'
   if keyword_set(out_path)    eq FALSE then err01 += '/out_path '
   if(err01 ne STR_EMP) then begin
      message, MSG_ERR01 + err01
   end

   ; 出力パスの生成
   l2_name = FILE_BASENAME(l2_path)
   if stregex(tablea_path,'aurora',/fold_case) ge 0 then extname='aurora'
   if stregex(tablea_path,'torus',/fold_case) ge 0 then extname='torus'
   if stregex(tablea_path,'geocorona',/fold_case) ge 0 then extname='torus'
   if stregex(FILE_BASENAME(out_path),'fits$',/boolean) ne 1 then begin
      ; out_pathがディレクトリ指定の場合、ファイル名生成
      out_dir = out_path
      name_l2_elm = strsplit(FILE_BASENAME(l2_path), '.', /extract)
      for i = 0, n_elements(name_l2_elm) - 1 do begin
         if name_l2_elm[i] eq 'fits' then begin
            name_l2_elm[i-1] += '.'+extname+'.lv.03'
            break
         endif
      endfor
      name_out = strjoin(name_l2_elm, '.')
      out_path = out_dir + '/' + name_out
   endif else begin
      out_dir = out_path
   endelse


   ; 入力パスの存在確認
   check_target = [l2_path, l2cal_path, tablea_path, out_dir]
   for i = 0, n_elements(check_target) - 2 do begin
      if file_test(check_target[i]) eq FALSE then $
         message, MSG_ERR02 + check_target[i]
   endfor

   ; 入力パスのパーミッション確認
   for i = 0, n_elements(check_target) - 2 do begin
      if file_test(check_target[i], /read) eq FALSE then $
         message, MSG_ERR03 + check_target[i]
   endfor
   
   ; 引数をログに出力
   write_log, LOG_PATH, '  l2_path     = ' + l2_path,     /nontime
   write_log, LOG_PATH, '  l2cal_path  = ' + l2cal_path,  /nontime
   write_log, LOG_PATH, '  tablea_path = ' + tablea_path, /nontime
   write_log, LOG_PATH, '  out_path    = ' + out_path,    /nontime

   ; 出力FITSパス名のファイルが存在したらエラー
;   if file_test(out_path) eq 1 then $
;      message, MSG_ERR04 + out_path
   
   ; テーブルＡ(領域情報)のデータを取得
   write_log, LOG_PATH, MSG_INF03
   n_file_lines = file_lines(tablea_path)
   if n_file_lines eq 0 then $
      message, MSG_ERR05 + tablea_path
   file_recs =  strarr(file_lines(tablea_path))
   openr, 1, tablea_path
   readf, 1, file_recs
   close, 1
   tablea_dataset_value = fltarr(1,4)

   ; テーブルＡのレコードを処理
   for i = 0, n_elements(file_recs) - 1 do begin
      if stregex(file_recs[i], '^#',/boolean) eq 1 then continue
      rec = strsplit(file_recs[i], '[ ]+', /EXTRACT)
      com = (strsplit(file_recs[i], '#', /EXTRACT))[1]

      ; データの形式チェック
      if n_elements(rec) lt 4 then $
         message, MSG_ERR06 + strcompress(i+1, /remove_all)

      tbl_data_ptn = '^[-]{0,1}[0-9]'
      if stregex(strcompress(rec[0], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
            stregex(strcompress(rec[1], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
            stregex(strcompress(rec[2], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
            stregex(strcompress(rec[3], /remove_all), tbl_data_ptn, /boolean) ne 1 then $
         message, MSG_ERR06 + strcompress(i+1, /remove_all)

      ; イメージ取得領域に変換
      rec_tablea = fltarr(1,4)
      rec_tablea[0] = float(rec[0]) - float(rec[1]/2) ; X min
      rec_tablea[1] = float(rec[0]) + float(rec[1]/2) ; X max
      rec_tablea[2] = float(rec[2])            ; Y min
      rec_tablea[3] = float(rec[3])            ; Y max
      
      ;; bitary table tag names;;;;;;;;;;;;;;;;;;;;;;;;;TK
      ddtag=''
      if stregex(file_recs[i],'dawn',/fold_case) ge 0 then ddtag='DAWN'
      if stregex(file_recs[i],'dusk',/fold_case) ge 0 then ddtag='DUSK'
      if not keyword_set(bintabtag) then begin
        bintabtag=string(round(double(rec[0])),form='(i04)')+'A'
        bintabtag+=ddtag
      endif else begin
        cbintabtag=string(round(double(rec[0])),form='(i04)')+'A'
        cbintabtag+=ddtag
        bintabtag = [bintabtag, cbintabtag]
      endelse

      if not keyword_set(tablea_comarr) then begin
        tablea_comarr=string(com,form='(a)')
      endif else begin
        tablea_comarr=[tablea_comarr,string(com,form='(a)')]
      endelse

      
      if (tablea_dataset_value[0,0] eq '') then begin
         tablea_dataset_value = rec_tablea
      endif else begin
         tablea_dataset_value = [tablea_dataset_value, rec_tablea]
      endelse
   endfor
   n_tablea_dataset = n_elements(tablea_dataset_value[*,0])
   n_tablea_dataset_str = strcompress(string(n_tablea_dataset))

   ; ログ出力
   write_log, LOG_PATH, MSG_INF04 + n_tablea_dataset_str 
   print, MSG_INF04 + n_tablea_dataset_str

   ; L2のprimary EXTENTIONとtotal EXTENTIONを取得 
   im_pri   = mrdfits(l2_path, 0, hdr_pri, /silent)
   im_total = mrdfits(l2_path, 1, hdr_total, /silent)

   ; 領域情報格納用の配列を用意する。
   range_info = strarr(n_tablea_dataset)
  
   ; 領域ごとに各処理を実施する。
   for i = 0, n_tablea_dataset - 1 do begin
      n_proc_str = strcompress(string(i + 1))
      write_log, LOG_PATH, MSG_INF05 + '(' + n_proc_str + '/' + n_tablea_dataset_str + ')'
      print, MSG_INF05 + '(' + n_proc_str + '/' + n_tablea_dataset_str + ')'

      ; value=>pixel変換
      xrange_v = [tablea_dataset_value[i,0], tablea_dataset_value[i,1]]
      yrange_v = [tablea_dataset_value[i,2], tablea_dataset_value[i,3]]
      
      ; convert spatial integration region in unit of Rj to in arcsec;;; TK
      buf = mrdfits(l2_path, 2, hdr, /silent)
      time  = fxpar(hdr, KEY_EXTNAME)      
      if not keyword_set(planet_radii_deg) then planet_radii_deg=get_planet_radii(time=time,target=!NULL,/deg); deg/rp
      yrange_v *= planet_radii_deg*3600.d; arcsec
      
      res = convert_value2pixel(l2cal_path, xrange_v, yrange_v)
      x_min_p = res[0,0]
      x_max_p = res[1,0]
      y_min_p = res[0,1]
      y_max_p = res[1,1]

      xrange_p = [x_min_p, x_max_p]
      yrange_p = [y_min_p, y_max_p]
      
      ; FITSのデータヘッダ用に領域情報格納を格納
      x_min_p_str = strcompress(x_min_p, /remove_all) 
      x_max_p_str = strcompress(x_max_p, /remove_all)
      y_min_p_str = strcompress(y_min_p, /remove_all)
      y_max_p_str = strcompress(y_max_p, /remove_all)
      range_info[i] = '['+x_min_p_str+','+x_max_p_str+ ','+ y_min_p_str+','+y_max_p_str+']'

      ; L2ファイルの時刻エクステションから指定領域のカウント分布を取得
      value_nextend = fxpar(hdr_pri, KEY_NEXTEND)
      im_target_integral = dblarr(x_max_p - x_min_p + 1)
      distribution_count = dblarr(x_max_p - x_min_p + 1, value_nextend - 1)
      distribution_count_rate = dblarr(x_max_p - x_min_p + 1, value_nextend - 1)
      radiation_monitor = dblarr(value_nextend - 1)
      jupiter_location_monitor = lonarr(value_nextend - 1)
      value_extname_list = strarr(value_nextend - 1)
      value_ninttime_list = dblarr(value_nextend - 1)
      year_list = strarr(value_nextend - 1)      ;;;;;TK
      dayofyear_list = strarr(value_nextend - 1) ;;;;;TK
      secofday_list = strarr(value_nextend - 1)  ;;;;;TK

      ; イメージEXTENTIONごとに処理
      for j = 2, value_nextend do begin
         im = mrdfits(l2_path, j, hdr, /silent)
         ;remove geocorona;;;;;;;;;;;;;;;;;;;;;;byhk
         im=remove_geocor(im,!geocorona_list ,l2cal_path)
         
         if i eq 0l then begin; radiation minitor ;; TK
            crad=double(fxpar(hdr,KEY_RADMON))
            radiation_monitor[j-2] = crad; counts/min
            cjloc=double(fxpar(hdr,KEY_JUPLOC))
            jupiter_location_monitor[j-2] = cjloc
         endif
         
         im_target = im[x_min_p : x_max_p, y_min_p : y_max_p]
         value_extname  = fxpar(hdr, KEY_EXTNAME)
         print, value_extname
         value_ninttime = double(fxpar(hdr, KEY_NINTTIME))
         daytime = strsplit(value_extname, 'T', /EXTRACT);;;;;TK

         ;; mac osx date command
;         spawn, 'date -j -f "%Y-%m-%d" '+daytime[0]+' "+%Y"' , year;;;;;TK
;         spawn, 'date -j -f "%Y-%m-%d" '+daytime[0]+' "+%-j"', dayofyear;;;;;TK
;         spawn, 'date -j -f "%H:%M:%S" '+daytime[1]+' "+%-H"', hour;;;;;TK
;         spawn, 'date -j -f "%H:%M:%S" '+daytime[1]+' "+%-M"', min;;;;;TK
;         spawn, 'date -j -f "%H:%M:%S" '+daytime[1]+' "+%-S"', sec;;;;;TK
         ;; UNIX/LINUX date command
;         spawn,'date "+%Y"  -d' + daytime[0], year;;;;;TK
;         spawn,'date "+%-j" -d' + daytime[0], dayofyear;;;;;TK
;         spawn,'date "+%-H" -d' + daytime[1], hour;;;;;TK
;         spawn,'date "+%-M" -d' + daytime[1], min;;;;;TK
;         spawn,'date "+%-S" -d' + daytime[1], sec;;;;;TK
         ;win
         dateyear = strsplit(daytime[0], '-', /EXTRACT)
         hhmmss   = strsplit(daytime[1], ':', /EXTRACT)
         year     =dateyear[0]
         dayofyear=ymd2dn(dateyear[0],dateyear[1],dateyear[2])
         hour     =hhmmss[0]
         min      =hhmmss[1] 
         sec      =hhmmss[2]
         
         csecofday = (double(hour))*60*60 + (double(min))*60 + (double(sec))      ;;;;;TK  
         value_extname_list[j - 2]  = value_extname
         value_ninttime_list[j - 2] = value_ninttime         
         year_list[j - 2] = year
         dayofyear_list[j - 2] = dayofyear
         secofday_list[j - 2] = csecofday

         ; 空間方向へ積分
         target_integration = n_elements(im_target[0,*])
         im_target_integral[*]=0.d; initialization
         for k = 0, target_integration - 1 do begin
            im_target_integral += im_target[*,k]
         endfor
         distribution_count[* ,j - 2] = im_target_integral*value_ninttime; counts ; this is used for l2prime
         distribution_count_rate[* ,j - 2] = im_target_integral;/value_ninttime; counts/min;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;byHK
      endfor

      ; 関数Ａから係数αkを取得する。
      size_distribution_count = size(distribution_count)
      coeff = dblarr(size_distribution_count[1], size_distribution_count[2])
      if SIZE(distribution_count, /N_DIMENSIONS) eq 1 then size_distribution_count[2]=1;;;;;;;;;;;;;;;;;;;;;;;byhk
      for j = 0, size_distribution_count[2] - 1 do begin
         coeff[*,j] = function_a(value_extname_list[j], xrange_v, yrange_v, xrange_p, yrange_p, l2_path, l2cal_path)
      endfor
 
      ;smoothing of spectrum
      nwave=size_distribution_count[1]
      ntime=size_distribution_count[2]
      for j=0l, ntime-1l do begin
        filt_var, xarr=indgen(nwave), yarr=reform(distribution_count_rate[*,j]), outarr=outarr, window=SPECTRESOL, /ave
        distribution_count_rate[*,j]=outarr
        filt_var, xarr=indgen(nwave), yarr=reform(coeff[*,j]                  ), outarr=outarr, window=SPECTRESOL, /ave
        coeff[*,j]=outarr
      endfor
      ; カウント分布と係数αkをかけ合わせ放射エネルギー分布を取得する。
      distribution_radiant_energy = distribution_count_rate * coeff


      ; 放射エネルギー分布時系列を取得する。
      series_distribution_radiant_energy = dblarr(size_distribution_count[2])
      series_distribution_count_rate = dblarr(size_distribution_count[2])
      for j = 0, size_distribution_count[2] - 1 do begin
         series_distribution_radiant_energy[j] = total(distribution_radiant_energy[*,j])
         series_distribution_count_rate [j] = total(distribution_count_rate[*,j])
      endfor

      ; 誤差時系列を取得する。
      ; カウント分布の平方根(sqrt(Nk))を取得
      sqrt_distribution_count = sqrt(distribution_count)

      ; sqrt(Nk)/tを取得
      size_distribution_count = size(distribution_count)
      sqrt_distribution_count_rate = dblarr(size_distribution_count[1], size_distribution_count[2])
      if SIZE(distribution_count, /N_DIMENSIONS) eq 1 then size_distribution_count[2]=1;;;;;;;;;;;;;;;;;;;;;;;byhk
      for j = 0, size_distribution_count[2] - 1 do begin
         sqrt_distribution_count_rate[*,j] = sqrt_distribution_count[*,j]/value_ninttime_list[j]; counts/min
      endfor

      ;smoothing of spectrum;;;;; TK
      for j=0l, ntime-1l do begin
        filt_var, xarr=indgen(nwave), yarr=reform(sqrt_distribution_count_rate[*,j]), outarr=outarr, window=SPECTRESOL, /ave
        sqrt_distribution_count_rate[*,j]=outarr
      endfor
      ; (sqrt(Nk)/t)×αkを取得
      distribution_sigma = sqrt_distribution_count_rate * coeff

      ; 誤差時系列を取得
      series_distribution_sigma = dblarr(size_distribution_count[2])
      for j = 0, size_distribution_count[2] - 1 do begin
         series_distribution_sigma[j] = total(distribution_sigma[*,j])
      endfor

      ; カウントレート時系列を取得
      series_distribution_count = dblarr(size_distribution_count[2])
      for j = 0, size_distribution_count[2] - 1 do begin
         series_distribution_count[j] = total(distribution_count[*,j])
      endfor

      ; 構造体に時系列を格納する。
      if i eq 0 then begin
         structure = {year:long(year_list), dayofyear:long(dayofyear_list), secofday:long(secofday_list)}
      endif
      tag_series_distribution_radiant_energy = 'TPOW'+bintabtag[i]
      tag_series_distribution_sigma          = 'TERR'+bintabtag[i]
      tag_series_distribution_count          = 'CONT'+bintabtag[i];;;; TK
      tag_series_distribution_count_rate     = 'LINT'+bintabtag[i]
;      tag_series_distribution_radiant_energy = "series_distribution_radiant_energy_" + strcompress(i,/remove_all)
;      tag_series_distribution_sigma = "series_distribution_sigma_" + strcompress(i,/remove_all)
;      tag_series_distribution_count = "series_distribution_count_" + strcompress(i,/remove_all)
      structure_distribution_radiant_energy = create_struct(tag_series_distribution_radiant_energy,series_distribution_radiant_energy)
      structure_distribution_sigma = create_struct(tag_series_distribution_sigma,series_distribution_sigma)
      structure_distribution_count = create_struct(tag_series_distribution_count,series_distribution_count)
      structure_distribution_count_rate = create_struct(tag_series_distribution_count_rate,series_distribution_count_rate)
      structure   = create_struct(structure, structure_distribution_radiant_energy, structure_distribution_sigma, structure_distribution_count, structure_distribution_count_rate)
   endfor
   structure_radiation_monitor = create_struct('RADMON',radiation_monitor)
   structure   = create_struct(structure, structure_radiation_monitor)
   structure_jupiter_location_monitor = create_struct('JUPLOC',jupiter_location_monitor)
   structure   = create_struct(structure, structure_jupiter_location_monitor)

   ; binary table用に構造体を変換
   n_time_series      = n_elements(structure.year)
   n_tag_structure    = n_tags(structure)
   tag_name_structure = tag_names(structure)
   for i = 0, n_time_series - 1 do begin
      for j = 0, n_tag_structure - 1 do begin
         tag_name = tag_name_structure[j]
         value_list = structure.(j)
         if j eq 0 then begin
            bintable_struct = create_struct(tag_name,value_list[i])
         endif else begin
            bintable_elm = create_struct(tag_name,value_list[i])
            bintable_struct  = create_struct(bintable_struct,bintable_elm)
         endelse
      endfor
      if i eq 0 then begin
         bintable = bintable_struct
      endif else begin
         bintable = [bintable, bintable_struct]
      endelse
   endfor

   ; 出力FITSファイルの作成
   ; ログ出力
   write_log, LOG_PATH, MSG_INF06
   write_log, LOG_PATH, '   out_path='+out_path, /nontime

   ; 空のファイルを作成
   message, 'output file:'+out_path,/info
   openw, 1, out_path
   close, 1

   ; ファイル作成時刻を取得
   time_create = time_string(systime(1),tformat=TFORMAT_EXT)

   ; プライマリーヘッダを編集
   sxaddpar, hdr_pri, KEY_L2PATH,   l2_name,     COMMENT_L2PATH 
   sxaddpar, hdr_pri, KEY_TBLAPATH, tablea_path, COMMENT_TBLAPATH
   sxaddpar, hdr_pri, KEY_CALPATH,  l2cal_path , COMMENT_CALPATH
   sxaddpar, hdr_pri, KEY_DATE,     time_create, COMMENT_DATE

   ; FITSファイルに書き出し
   writefits, out_path,  im_pri,   hdr_pri
   writefits, out_path,  im_total, hdr_total, tot, /append
   mwrfits,   bintable,  out_path, /silent

   ;modify bintable header
   tunit=strarr(n_tag_structure)
   hdrcom=tunit
   tunit[*]='GW' & tunit[0]='years' & tunit[1]='days' & tunit[2]='sec' & tunit[-2]='counts/min' & tunit[-1]=''
   tdisp=strarr(n_tag_structure)   
   tdisp[*]='D10.1' & tdisp[0]='I5' & tdisp[1]='I5' & tdisp[2]='E15.6' & tdisp[-1]='I3'
   bin_table = mrdfits(out_path, 2, hdr_bin_table, /silent)
   if stregex(tablea_path,'aurora',/fold_case) ge 0 then extname='aurora'
   if stregex(tablea_path,'torus',/fold_case) ge 0 then extname='torus'
   if stregex(tablea_path,'geocorona',/fold_case) ge 0 then extname='torus'
   extname='LineInt-'+extname
   sxaddpar, hdr_bin_table, 'EXTNAME', extname, 'extension name', after='TFIELDS'
   indcom=0l
   for i = 1l, n_tag_structure do begin
     ccom=''
     ckey3=strtrim('TTYPE'+string(i,form='(i-)'),2)
     ckey0=strtrim('TFORM'+string(i,form='(i-)'),2)
     ckey1=strtrim('TUNIT'+string(i,form='(i-)'),2)
     ckey2=strtrim('TDISP'+string(i,form='(i-)'),2)
     if tag_name_structure[i-1l] eq 'YEAR' then ccom='year'
     if tag_name_structure[i-1l] eq 'DAYOFYEAR' then ccom='day of year'
     if tag_name_structure[i-1l] eq 'SECOFDAY' then ccom='sec of day'
     if tag_name_structure[i-1l] eq 'RADMON' then ccom='Radiation monitor'
     if tag_name_structure[i-1l] eq 'JUPLOC' then ccom='Jupiter location'
     if stregex(tag_name_structure[i-1l],'[0-9]{1,4}') ge 0l then begin
      ccom=tablea_comarr[indcom/4l]
      indcom++
     endif
     sxaddpar, hdr_bin_table, ckey3, fxpar(hdr_bin_table,ckey3), ccom
     sxaddpar, hdr_bin_table, ckey0, fxpar(hdr_bin_table,ckey0), ccom
     sxaddpar, hdr_bin_table, ckey1, tunit[i-1l], ccom, after=ckey0   
     sxaddpar, hdr_bin_table, ckey2, tdisp[i-1l], ccom, after=ckey1
   endfor
   
   ; データヘッダに領域情報を追記
   for i = 0, n_elements(range_info) - 1 do begin
      key_range_info = "RINFO" + strcompress(i,/remove_all)
      sxaddpar, hdr_bin_table, key_range_info, range_info[i], 'pixal range:[xmin,xmax,ymin,ymax]'
   endfor
   sxaddpar, hdr_bin_table, KEY_DATE, time_create, COMMENT_DATE
   modfits, out_path, bin_table, hdr_bin_table, EXTEN_NO=2

   ; ログ出力
   write_log, LOG_PATH, MSG_INF02
   p_end_time = systime(1)

   write_log, LOG_PATH, 'proc time:'+strcompress(p_end_time - p_start_time)

end

