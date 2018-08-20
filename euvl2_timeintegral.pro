;+
; NAME:
;      EUVL2_TIMEINTEGRAL
;
; PURPOSE:
;      Integrate EUV-L2 data in the given term.
;
; CALLING SEQUENCE:
;      EUVL2_TIMEINTEGRAL, p=l2path, it=intgtime, ip=intgl2path, [st=intgstime, et=intgetime]
;
; KEYWORDS: 
;      p  - String giving the path of an EUV-L2 data file
;      it - Integer scalar giving the time to integrate EUV-L2 data between 1 and 1440 (min)
;      ip - String giving the path of an output data file (assign a directory or a file name)
;      st - String giving the start time of integrate EUV-L2 data in format 'YYYY-MM-DDThh:mm:ss'
;      et - String giving the end time of integrate EUV-L2 data in format 'YYYY-MM-DDThh:mm:ss'
; INPUTS:
;      EUV-L2 data file
;
; OUTPUTS:
;      Integrated EUV-L2 FITS file.
;
; RESTRICTIONS:
;      You can use only 1 EUV-L2 file including 1 day's data per 1 execution. 
;      More than 61 words of FITS header keywords and comments are deleted.
;
; LIBRARIES USED:
;      The following libraries are contained in the main EUVL2_CENTER_CORRECTION program.
;          IDL Astronomy User’s Library         <https://idlastro.gsfc.nasa.gov/>
;          tzoffset.pro in Markwaedt IDL Livrary <https://www.physics.wisc.edu/~craigm/idl/>
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software) 
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; FUNCTIONS USED:
;      The following functions are contained in the main EUVL2_TIMEINTEGRAL program.
;          LOG_SETTING -- Get a name of log file path.
;          DATE_REGEX  -- Check a format of date.
;          TIME_NUM    -- Check a size and range of date.
;
; EXAMPLE:
; 1)     euvl2_timeintegral, p='*****/hoge/hogehoge.fits', it=10, ip='#####/hogehoge/hoge',st='2017-12-01T01:00:00', et='2017-12-01T10:00:00'
; 2)     euvl2_timeintegral, p='*****/hoge/hogehoge.fits', it=10, ip='#####/hogehoge/hoge'
;        (If keywords do not include st and/or et, integrate EUV-L2 data from start time of observation to end time of observation.)
; 
; MODIFICATION HISTORY:
;      Written by FJT) Hiroko Tada
;      Fujitsu Limited.
;      v1.0 2018/1/30 First Edition
;-

pro euvl2_timeintegral, l2path=l2path, intgtime=intgtime, intgl2path=intgl2path, intgstime=intgstime, intgetime=intgetime

; IDLプロシージャでエラーを検出したらreturnする
   ON_ERROR,3

;定数
   C_TRUE     = 1       ;真偽判定で真（存在の有無で有）の場合の返り値
   C_FALSE    = 0       ;真偽判定で偽（存在の有無で無）の場合の返り値
   C_MAX      = 1       ;0から始まり最大nの値の、最大値の順番（n-1）を表すのに必要となる値
   C_PRI      = 0       ;プライマリデータエクステンションのエクステンション番号
   C_TOT      = 1       ;トータルエクステンションのエクステンション番号
   C_DA1      = 2       ;“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の最初のエクステンション番号
   C_TN       = 1       ;トータルエクステンションのエクステンション数
   C_IT_MIN   = 1       ;積分時間の最小値(min)
   C_IT_MAX   = 1440    ;積分時間の最大値(=24*60)(min)
   C_NOALLEXT = 0       ;FITSファイルにエクステンションが1つも無い場合のエクステンション数
   C_NODATEXT = 1       ;FITSファイルに“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）が1つも無い場合のエクステンション数
   C_INIT     = 0       ;時間やエクステンション番号の初期値0
   C_ONE      = 1       ;整数1
   C_DIF      = 1.0     ;積分区間の開始・終了時間を更新する際の差分
   C_SEC      = 60.0    ;分を秒に変換するときかける値（60秒）
   C_PIX      = 1024    ;pixelスケールの値
   C_FLT      = 4       ;float型のType Code
   C_S0       = 0       ;size()の戻り値の要素番号（次元数）
   C_S0NUM    = 2       ;size()の戻り値（次元数）
   C_SRTN     = 5       ;size()の戻り値の要素数
   C_S1       = 1       ;size()の戻り値（1次元の要素数）
   C_S2       = 2       ;size()の戻り値（2次元の要素数）
   C_ST       = 3       ;size()の戻り値（型コード）
   C_CMP      = 2       ;大小関係を比較する関数の引数となる配列の要素数
   C_IPFILE   = 'intg.' ;出力ファイル名の接頭語
   C_CEN      = 2       ;積分時間の代表時刻（中心時刻）を求める際に割る値
   C_LORS     = 0       ;値の大小関係を比較する際に用いる、比較する値の差
   C_PLS      = 1       ;値を+1する際に使用する数字
   C_LOGLUN   = 1       ;ログファイルの論理ユニット番号
   C_ILPLUN   = 10       ;積分後EUV-L2ファイルの論理ユニット番号
   C_SIX      = 60      ;時間を分に、分を秒に変換する時にかける値60
   C_JST      = 9       ;JSTからの時刻のずれ
   TIME_FORM  = 'YYYY-MM-DDThh:mm:ss' ;時刻の出力形式

   ;エクステンションのキーワード名
   KEYWORD_IT  = 'tinttime'
   KEYWORD_LP  = 'l2path'
   KEYWORD_IDO = 'idate-o'
   KEYWORD_IDE = 'idate-e'
   KEYWORD_NE  = 'nextend'
   KEYWORD_EN  = 'extname'
   KEYWORD_DO  = 'date-obs'
   KEYWORD_DE  = 'date-end'
   KEYWORD_NI  = 'ninttime'
   KEYWORD_DT  = 'date'

   ;キーワードのコメント
   CM_IT  = 'time of integration'
   CM_LP  = 'name of EUV-L2 data file'
   CM_IDO = 'START time of integration'
   CM_IDE = 'END time of integration'
   CM_NE  = 'Number of standard extensions'
   CM_EN  = 'name of this HDU'
   CM_DO  = 'START time of integration in this extension'
   CM_DE  = 'END time of integration in this extension'
   CM_NI  = 'time of integration actually'
   CM_DT  = 'Date of file creation (UTC)'

   ;メッセージ
   M_ERR01   = 'msg_err01: Please input the following items.'
   M_ERR02   = 'msg_err02: Please input the following items in the form of　"YYYY-MM-DDThh:mm:ss".'
   M_ERR03   = 'msg_err03: Please input start time before the end time.'
   M_ERR04   = 'msg_err04: Please input the integral time by an integer between '
   M_ERR04_2 = ' and '
   M_ERR04_3 = '.'
   M_ERR13   = 'msg_err13: There are no "YYYY-MM-DDThh:mm:ss" or TOTAL extensions in this FITS file.'
   M_ERR17   = 'msg_err17: Please input a one-dimensional array with two string elements.'
   M_ERR18   = 'msg_err18: This file already exists.'
   M_ERR19   = 'msg_err19: The following files or directories do not exist.'
   M_ERR20   = 'msg_err20: Read fits is failed.'

   M_INF01   = 'msg_inf01: Making a file is completed.'
   M_INF02   = 'msg_inf02: Skipped integrating no.'
   M_INF02_2 = ' data.'
   M_INF03   = 'msg_inf03: Skipped including no.'
   M_INF03_2 = ' integrated data to the file.'
   M_INF04   = 'msg_inf04: There is no data in the selection term.'
   M_INF05   = 'msg_inf05: Any data extensions are not made because there is no data in selected period of time.'

   M_START = 'START'
   M_END   = 'END'
   M_P     = 'l2_path / '
   M_IT    = 'integer_time / '
   M_IP    = 'integer_l2_path / '
   M_ST    = 'integer_start_time / '
   M_ET    = 'integer_end_time'

;ログファイルの名前を決める。
   logdir  = log_setting() ;ログファイルを出力するディレクトリ名を取得する
   LOGPATH = logdir+'EUVL2_TIMEINTEGRAL'+time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM)+'.log' ;ログファイルの名前

;ライブラリの関数の標準エラーをcatchしてログファイルに出力する
   err_flg=C_FALSE
   catch,err_flg
   if(err_flg ne C_FALSE) then begin
      msg=!ERROR_STATE.MSG
      print,msg
      catch,/cancel
     ;ログファイルのユニット番号1が標準エラーメッセージに含まれる(=ログファイル出力に標準エラーが生じる)場合以外はログファイルに標準エラーを出力
      if(stregex(msg, 'File unit is not open: 1.',/boolean) eq C_FALSE) then begin 
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',msg
         ;処理時間の計測終了
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
         ;ログファイルを閉じる
         close,C_LOGLUN
      endif
      return
   endif
;ログの出力開始
   if(file_test(LOGPATH) eq C_TRUE) then begin
      print,M_ERR18,LOGPATH
      return
      ;file_delete,logpath
   endif else begin
      close,C_LOGLUN
      openw, C_LOGLUN, LOGPATH
   endelse
;処理時間の計測開始
   p_start_time=systime(1)-tzoffset(/now)
   printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_START

;【前処理】
;必須項目の有無確認
   err01=''
   ;EUV-L2データファイルパス
   if(keyword_set(l2path) eq C_FALSE) then err01 += M_P
   ;積分時間
   if(keyword_set(intgtime) eq C_FALSE) then err01 += M_IT
   ;積分後EUV-L2データファイルパス
   if(keyword_set(intgl2path) eq C_FALSE) then err01 += M_IP
   if(err01 ne '') then begin
      print,M_ERR01
      print,'           '+err01
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR01,'           '+err01
   ;処理時間の計測終了
   printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
   ;ログファイルを閉じる
   close,C_LOGLUN
      return
   endif

;フォーマット確認（積分開始・終了時刻の形式）
   arrdate_rg=strarr(2)
   err02_start=''
   err02_end=''
   ;積分開始時刻が入力されている場合にフォーマット確認
   if(keyword_set(intgstime) eq C_TRUE) then begin
      arrdate_rg=[M_ST,intgstime]
      ;フォーマット確認の関数実行
      err02_start=date_regex(arrdate_rg)

      ;入力値が要素数2の1次元のstring型配列ではない場合、エラー
      if((err02_start eq M_ERR17)) then begin
         print,err02_start
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',err02_start
         ;処理時間の計測終了
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
         ;ログファイルを閉じる
         close,C_LOGLUN
         return
      endif
   endif

   ;積分終了時刻が入力されている場合にフォーマット確認
   if(keyword_set(intgetime) eq C_TRUE) then begin
      arrdate_rg=[M_ET,intgetime]
      ;フォーマット確認の関数実行
      err02_end=date_regex(arrdate_rg)

      ;入力値が要素数2の1次元のstring型配列ではない場合、エラー
      if((err02_end eq M_ERR17)) then begin
         print,err02_end
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',err02_end
         ;処理時間の計測終了
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
         ;ログファイルを閉じる
         close,C_LOGLUN
         return
      endif
   endif

   ;フォーマットが正しくない場合、エラーメッセージ
   err02=err02_start + err02_end
   if(err02 ne '') then begin
      print,M_ERR02
      print,'           '+err02
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR02,'           '+err02
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;フォーマット確認（積分開始・終了時刻の前後関係）
   err03='true'
   if((keyword_set(intgstime) eq C_TRUE) and (keyword_set(intgetime) eq C_TRUE)) then begin
      if(time_double(intgstime) gt time_double(intgetime)) then begin
         err03='false'
      endif
      if(err03 eq 'false') then begin
         print,M_ERR03
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR03
         ;処理時間の計測終了
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
         ;ログファイルを閉じる
         close,C_LOGLUN
         return
      endif
   endif

   ;フォーマット確認（積分時間の数字／範囲）
   err04=time_num(intgtime)
   if(err04 eq 'false') then begin
      print,M_ERR04 + strcompress(string(c_it_min),/remove_all) + M_ERR04_2 + strcompress(string(c_it_max),/remove_all)+ M_ERR04_3
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR04 + strcompress(string(c_it_min),/remove_all) + M_ERR04_2 + strcompress(string(c_it_max),/remove_all)+ M_ERR04_3
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

;【本処理】
   ;データエクステンション（1分積分）の個数（+ totalの1個分）を取得
   priimg = mrdfits(l2path, C_PRI, pri,/silent)
   nextend = fxpar(pri, KEYWORD_NE)

   ;データエクステンション（1分積分）（+ totalエクステンション）が存在しなければエラー
   totimg = mrdfits(l2path, C_TOT, tot,/silent)
   dat_checkimg   = mrdfits(l2path, C_DA1, dat_check,/silent)
   s_totimg       = size(totimg)
   s_dat_checkimg = size(dat_checkimg)
   if ((s_totimg[C_S0] ne C_S0NUM) or (s_dat_checkimg[C_S0] ne C_S0NUM)) then begin
      print,M_ERR13
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR13
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;入力EUV-L2データファイルにおいて、プライマリデータヘッダ記載のデータエクステンションの数>（NEXTEND）と実際の数が一致するか確認する。
   ;最後のデータエクステンションが存在するか確認
   dat_nimg   = mrdfits(l2path, nextend, dat_n,/silent)
   s_dat_nimg = size(dat_nimg)
   if (s_dat_nimg[C_S0] ne C_S0NUM) then begin
      print,M_ERR20
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR20
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;空のFITSファイルを作成
   ;出力先がファイル名指定の場合
   if(stregex(intgl2path, '.fits$',/boolean) eq C_TRUE) then begin
      output=intgl2path ;出力ファイル名

      ;出力ディレクトリのパスが正しいものか確認するために、ファイルが格納されているディレクトリ名を取得する。
      intg_l2path_elm=strsplit(intgl2path,/extract, '/') ;intgl2pathを/で分割した値
      n_intg_l2path_elm=n_elements(intg_l2path_elm) ;l2dir_elmの要素数
      max_intg_l2path_elm = n_intg_l2path_elm - C_MAX
      n_intg_l2dir_elm=indgen(max_intg_l2path_elm) ;ディレクトリの数分の要素数の配列を作成する。
      intg_l2dir_elm =intg_l2path_elm[n_intg_l2dir_elm] ;ディレクトリの配列をディレクトリの数分作成する。
      intg_l2_dir='/'+strjoin(intg_l2dir_elm[C_INIT:max_intg_l2path_elm - C_MAX],'/') ;出力ディレクトリ

   endif else begin ;出力先がディレクトリ指定の場合
      ;出力ファイル名を決定する。
      ;入力FITSファイル名を取得する。
      l2path_elm=strsplit(l2path,/extract, '/') ;入力ファイルパスを/で分割した値
      n_l2path_elm=n_elements(l2path_elm) ;l2path_elmの要素数
      l2_fits=l2path_elm[n_l2path_elm -C_MAX] ;入力FITSファイル名

      ;出力ディレクトリの末尾が/の時（****/****/****/のように指定した場合）
      if(stregex(intgl2path, '/$',/boolean) eq C_TRUE) then begin
         output=intgl2path+C_IPFILE+l2_fits ;出力ファイル名（出力ディレクトリ/intg.入力FITSファイル名）
      endif else begin ;出力ディレクトリの末尾が/でない時（****/****/****のように指定した場合）
         output=intgl2path+'/'+C_IPFILE+l2_fits ;出力ファイル名（出力ディレクトリ/intg.入力FITSファイル名）
      endelse

      intg_l2_dir=intgl2path
   endelse

   ;ファイルパスが正しいものか確認
   err19=''
   ;EUV-L2データファイルパス
   if(file_test(l2path) eq C_FALSE) then  err19 += M_P
   ;積分後EUV-L2データファイルパス
   if(file_test(intg_l2_dir) eq C_FALSE) then  err19 += M_IP

   if(err19 ne '') then begin
      print,M_ERR19
      print,'           '+err19
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR19,'           '+err19
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;出力ファイルの有無を確認する。
   if(file_test(output) eq C_TRUE) then begin
      print,M_ERR18,output
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR18
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;入力FITSファイル名を取得する。
   l2path_elm_splt=strsplit(l2path,/extract, '/') ;入力ファイルパスを/で分割した値
   l2_fits_splt=l2path_elm_splt[-C_MAX] ;入力FITSファイル名

   ;プライマリデータエクステンションのキーワードを追加・編集
   sxaddpar, pri, KEYWORD_IT, intgtime, CM_IT
   sxaddpar, pri, KEYWORD_LP, l2_fits_splt, CM_LP
   if(keyword_set(intgstime) eq C_TRUE) then begin
      sxaddpar, pri, KEYWORD_IDO, intgstime, CM_IDO
   endif
   if(keyword_set(intgetime) eq C_TRUE) then begin
      sxaddpar, pri, KEYWORD_IDE, intgetime, CM_IDE
   end

   ;指定していない場合の積分開始時刻(intgstime)は、トータルエクステンションに記載されている観測開始時刻とする。
   if(keyword_set(intgstime) eq C_FALSE) then begin
      intgstime = fxpar(tot, KEYWORD_DO)
   endif
   ;指定していない場合の積分終了時刻(intgetime)は、トータルエクステンションに記載されている観測終了時刻とする。
   if(keyword_set(intgetime) eq C_FALSE) then begin
      intgetime = fxpar(tot, KEYWORD_DE)
   endif
   ;全ての“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の画像データ取得開始時刻（単位は秒）を取得
   nextend0 = C_INIT
;実際の積分開始時刻を決定する
   stime = C_INIT
   intgtime=intgtime*c_sec ;積分時間を秒に直す
   intgstime=time_double(intgstime) ;積分開始時刻を秒に直す
   intgetime=time_double(intgetime) ;積分終了時刻を秒に直す
   for i=C_DA1,nextend do begin
      one_img = mrdfits(l2path, i, data,/silent) ;L2ファイルの各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）のイメージ（one_omg）とヘッダ（data）の情報
      maintime=fxpar(data,KEYWORD_DO) ;L2ファイルの各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の開始時刻
      maintime_sec=time_double(maintime) ;L2ファイルの各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の開始時刻を秒に直す
      ;引数で入力した積分開始時刻 <= 各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の開始時刻 <= 引数で入力した積分終了時刻
      if((C_LORS le maintime_sec - intgstime) and (C_LORS le intgetime - maintime_sec)) then begin
         stime = maintime_sec ;実際の積分開始時刻（積分開始時刻以降で、EUV-L2データファイル内に1分積分データが存在する最初の時刻）
         nextend0 = i ;実際の積分開始時刻を取る時のエクステンション番号
         break
      endif
   endfor
   ;実際の積分開始時刻が指定期間内に存在しない場合（=初期値のままの場合）、エラー
   if(stime eq C_INIT) then begin
      print,M_INF04
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF04
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif
   ;プライマリデータエクステンション（編集済み）、トータルエクステンションを出力ファイルに書き出し、エクステンション作成日を編集する。
   close,C_ILPLUN
   openw, C_ILPLUN, output

   sxaddpar, pri, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
   writefits, output, priimg, pri

   sxaddpar, tot, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
   writefits, output, totimg, tot,/append

   ;各積分区間の開始・終了時刻、積分結果の初期値
   sitime = stime ;各積分区間の開始時刻の初期値
   eitime = stime + (intgtime - C_DIF) ;各積分区間の終了時刻の初期値
   citime = (sitime + eitime) / C_CEN ;各積分区間の代表時刻（中心の時刻）の初期値
   intg_img = fltarr(C_PIX,C_PIX) ;各積分区間の積分結果の初期値
   img_size = intarr(C_SRTN)
   timecount = C_INIT ;引数で入力した時間の内、1分積分のデータが存在し、実際に積分した時間の総計の初期値
   count = C_INIT ;積分後のデータエクステンションヘッダ（"YYYY-MM-DDThh:mm:ss_Integral"）の個数の初期値

   ;時間積分を実施する。
   for i=nextend0,nextend do begin
      ;L2ファイルの各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の時刻（単位は秒）を取得
      one_img = mrdfits(l2path, i, data,/silent)
      maintime=fxpar(data,KEYWORD_DO)        
      maintime_sec=time_double(maintime)
      if(C_LORS le intgetime - maintime_sec) then begin
         ;各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の時刻 <= 各積分区間の終了時刻
         if(C_LORS le eitime - maintime_sec) then begin
            img_size = size(one_img)
            if((img_size[C_S1] eq C_PIX) and (img_size[C_S2] eq C_PIX) and (img_size[C_ST] eq C_FLT)) then begin
               intg_img = intg_img + one_img
               timecount = timecount +C_PLS
            endif else begin
            ;データが型に合わない時は、時間積分に含めずメッセージを出力する。
               print,M_INF02 + string(strcompress(i,/remove_all)) + M_INF02_2
               printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF02 + string(strcompress(i,/remove_all)) + M_INF02_2
            endelse
         endif else begin ;各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の時刻 > 各積分区間の終了時刻  
            ;積分区間外にデータが存在した場合、ファイルへ書き出し
            intgimg_size = size(intg_img)
            if((intgimg_size[C_S1] eq C_PIX) and (intgimg_size[C_S2] eq C_PIX) and (intgimg_size[C_ST] eq C_FLT)) then begin
               citime=(sitime + eitime) / C_CEN
               count = count+C_PLS
               sxaddpar, data, KEYWORD_EN, time_string(citime,tformat=TIME_FORM), CM_EN
               sxaddpar, data, KEYWORD_DO, time_string(sitime,tformat=TIME_FORM), CM_DO
               sxaddpar, data, KEYWORD_DE, time_string(eitime,tformat=TIME_FORM), CM_DE
               sxaddpar, data, KEYWORD_NI, timecount, CM_NI
               ;エクステンション作成日を編集する。
               sxaddpar, data, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
               writefits, output, intg_img, data,/append
            endif else begin
            ;データが型に合わない時は、時間積分に含めずメッセージを出力する。
               print,M_INF03 + string(strcompress(count,/remove_all)) + M_INF03_2
               printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF03 + string(strcompress(count,/remove_all)) + M_INF03_2
            endelse
            ;maintime_sec > eitime
            while(maintime_sec - eitime gt C_LORS) do begin
               sitime = sitime + intgtime ;各積分区間の開始時刻を計算する。
               eitime = sitime + (intgtime - C_DIF) ;積分区間の終了時刻を計算する。
            endwhile
              
            ;intg_imgとtimecountの初期化
            if((img_size[C_S1] eq C_PIX) and (img_size[C_S2] eq C_PIX)  and (img_size[C_ST] eq C_FLT)) then begin
               intg_img = one_img
               timecount = C_ONE
            endif
            ;実際の積分終了時刻を決定する。
            ;各積分区間の終了時刻 >= 引数で入力した積分終了時刻
            if(eitime - intgetime ge C_LORS) then begin
               eitime = intgetime
            endif
         endelse
         ;ループが最後のデータまできたらファイルへ書き出し
         if (i eq nextend) then begin
            ;timecount = timecount + C_PLS
            citime = (sitime + maintime_sec) / C_CEN
            count = count + C_PLS
            sxaddpar, data, KEYWORD_EN, time_string(citime,tformat=TIME_FORM), CM_EN
            sxaddpar, data, KEYWORD_DO, time_string(sitime,tformat=TIME_FORM), CM_DO
            sxaddpar, data, KEYWORD_DE, time_string(maintime_sec,tformat=TIME_FORM), CM_DE
            sxaddpar, data, KEYWORD_NI, timecount, CM_NI
            ;エクステンション作成日を編集する。
            sxaddpar, data, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
            writefits, output, intg_img, data,/append
            print,M_INF01
            printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF01
            break
         endif
      endif else begin
         ;各“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）の時刻 > 引数で入力した積分終了時刻の時
         ;積分区間内にデータが存在した場合、ファイルへ書き出し
         citime = (sitime + eitime) / C_CEN
         count = count + C_PLS
         sxaddpar, data, KEYWORD_EN, time_string(citime,tformat=TIME_FORM), CM_EN
         sxaddpar, data, KEYWORD_DO, time_string(sitime,tformat=TIME_FORM), CM_DO
         sxaddpar, data, KEYWORD_DE, time_string(eitime,tformat=TIME_FORM), CM_DE
         sxaddpar, data, KEYWORD_NI, timecount, CM_NI
         ;エクステンション作成日を編集する。
         sxaddpar, data, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
         writefits, output, intg_img, data,/append
         print,M_INF01
         printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF01
         break
      endelse
   endfor
   ;出力ファイルのプライマリデータエクステンションにあるNEXTENDの値を編集する。
   sxaddpar, pri, KEYWORD_NE, count + C_TN, CM_NE
   modfits, output, C_PRI, pri

   ;指定した領域にデータが無い場合、メッセージとログを出力
   if(count eq C_INIT) then begin
      print,M_INF05
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF05
   endif
   ;出力ファイルを閉じる
   close,C_ILPLUN
   ;処理時間の計測終了
   p_end_time=systime(1)-tzoffset(/now)
   print,'proc time: ',(p_end_time - p_start_time)
   printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ', 'END'
   ;ログファイルを閉じる
   close,C_LOGLUN
end
