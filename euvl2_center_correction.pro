;+
; NAME:
;      EUVL2_CENTER_CORRECTION
;
; PURPOSE:
;      Correct the center position of integrated (1day) or raw EUV-L2 data by Ycdata (long term).
;
; CALLING SEQUENCE:
;      EUVL2_CENTER_CORRECTION, p=l2path, yc=yclong, cp=corrl2path
;
; KEYWORDS:
;      p  - String giving the path of an integrated (1day) or raw EUV-L2 data file
;      yc - String giving the path of an Yc(long) data file
;      cp - String giving the path of an output data file (assign a directory or a file name)
;
; INPUTS:
;      Integrated (1day) or raw EUV-L2 data file
;      Yc(long) data file
;
; OUTPUTS:
;      Center corrected EUV-L2 FITS file.
;       ・Primary data header (add to Integrated (1day) or raw EUV-L2 data)
;         - String giving the path of an integrated (1day) or raw EUV-L2 data file
;         - String giving the path of an Yc(long) data file
;       ・Data header (add to Integrated (1day) or raw EUV-L2 data)
;         - Int giving the augmenter of Yc
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
;
; FUNCTIONS USED:
;      The following functions are contained in the main EUVL2_TIMEINTEGRAL program.
;          LOG_SETTING -- Get a name of log file path.
;
; EXAMPLE:
; 1)     euvl2_center_correction, p='*****/hoge/hogehoge.fits', yc='+++++/hoge/hoge.csv', cp='#####/hogehoge/hoge'
;
; MODIFICATION HISTORY:
;      Written by FJT) Hiroko Tada
;      Fujitsu Limited.
;      v1.0 2018/1/30 First Edition
;-

pro euvl2_center_correction, p=l2path, yc=yclong, cp=corrl2path

; IDLプロシージャでエラーを検出したらreturnする
   ON_ERROR,3

;定数
   PRO_NAME   = 'EUVL2_CENTER_CORRECTION'

   C_TRUE     = 1       ;真偽判定で真（存在の有無で有）の場合の返り値
   C_FALSE    = 0       ;真偽判定で偽（存在の有無で無）の場合の返り値
   C_MAX      = 1       ;0から始まり最大nの値の、最大値の順番（n-1）を表すのに必要となる値
   C_LOGLUN   = 4       ;ログファイルの論理ユニット番号
   C_ARRLUN   = 40      ;CSVの値を入れる配列の論理ユニット番号
   C_ILPLUN   = 14      ;出力ファイルの論理ユニット番号
   TIME_FORM  = 'YYYY-MM-DDThh:mm:ss' ;時刻の出力形式
   C_PRI      = 0       ;プライマリデータエクステンションのエクステンション番号
   C_TOT      = 1       ;トータルエクステンションのエクステンション番号
   C_DA1      = 2       ;データエクステンションの最初のエクステンション番号
   C_NODATEXT = 1       ;FITSファイルに“YYYY-MM-DDThh:mm:ss”エクステンション（1分積分）が1つも無い場合のエクステンション数
   C_BADIMG   = 0       ;データエクステンションが存在しない場合のイメージ
   C_S0       = 0       ;size()の戻り値の要素番号（次元数）
   C_S0NUM    = 2       ;size()の戻り値（次元数）
   C_CEN      = 2       ;積分時間の代表時刻（中心時刻）を求める際に割る値
   C_INIT     = 0       ;初期値0
   C_ONE      = 1       ;配列の初期値を除いた最初の要素番号
   C_DINIT    = 0.0000000 ;double型の配列の要素の初期値
   C_CPFILE   = 'center.cor.' ;出力ファイル名の接頭語
   C_YCELM    = 1             ;CSVの値を入れる配列の要素数
   C_YCLOOP   = 1             ;CSVの値を配列に入れる際のループの値のずれ
   C_YCTIME   = 0     	      ;CSVに格納されている時刻の列番号
   C_YCPEAK   = 1             ;CSVに格納されているピーク値の列番号
   C_MINELM   = 1             ;EUV-L2データの時刻と差が一番小さいYc（長期）データの時刻の要素番号の数（1つのみの場合）
   C_ELMNUM   = 0             ;EUV-L2データの時刻と差が一番小さいYc（長期）データの時刻の要素番号の数が複数存在した時の最小の要素番号
   C_PIXC     = 573           ;惑星中心位置のピクセル番号（縦軸一番下から573番目）
   C_PIX      = 1024          ;FITSファイルのイメージのピクセルの最大値
   C_ZERO     = 0             ;大小関係の比較で用いる値0
   C_ARRDIF   = 1             ;要素数nの配列の最大要素番号n-1を表す時の、要素数nとの差
   C_YCINIELM = 1             ;Yc（長期）データファイルに値が1つもない場合の、Ycの時刻を格納する配列の全要素数
   C_ARRTYPE  = 2             ;size()関数の要素で型コードを選択する場合の、size()関数の要素数からの差
   C_SRTTYPE  = 7             ;string型の型コード

   C_PIXDIF   = 100           ;この要素数以上ピクセルをずらした場合はメッセージを出力
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
   KEYWORD_LP  = 'i1l2path'
   KEYWORD_YP  = 'tyc_path'
   KEYWORD_YR  = 'yc_corr'
   KEYWORD_DT  = 'date'

   ;キーワードのコメント
   CM_LP  = 'name of EUV-L2 data file per 1day'
   CM_YP  = 'name of Yc (total) data file per 1day'
   CM_YR  = 'Yc to correct the center of Jupiter'
   CM_DT  = 'Date of file creation (UTC)'

   ;メッセージ
   M_ERR01   = 'msg_err01: Please input the following items.'
   M_ERR02   = 'msg_err02: Please input the following items in the form of　"YYYY-MM-DDThh:mm:ss".'
   M_ERR03   = 'msg_err03: Please input start time before the end time.'
   M_ERR04   = 'msg_err04: Please input the integral time by an integer between '
   M_ERR04_2 = ' and '
   M_ERR04_3 = '.'
   M_ERR13   = 'msg_err13: There are no "YYYY-MM-DDThh:mm:ss" or TOTAL extensions in this FITS file.'
   M_ERR18   = 'msg_err18: This file already exists.'
   M_ERR19   = 'msg_err19: The following files or directories do not exist.'
   M_ERR20   = 'msg_err20: Read fits is failed.'
   M_ERR21   = 'msg_err21: There are no data or data header in this file.'
   M_ERR22   = 'msg_err09: This file includes string data.'

   M_INF01   = 'msg_inf01: Making a file is completed.'
   M_INF02   = 'msg_inf02: Skipped integrating no.'
   M_INF02_2 = ' data.'
   M_INF03   = 'msg_inf03: Skipped including no.'
   M_INF03_2 = ' integrated data to the file.'
   M_INF04   = 'msg_inf04: There is no data in the selection term.'
   M_INF05   = 'msg_inf05: Any data extensions are not made because there is no data in selected period of time.'
   M_INF06   = 'msg_inf06: Correct image more than '
   M_INF06_2   = ' pixel.'

   M_START = 'START'
   M_END   = 'END'
   M_LP    = 'l2_path / '
   M_YC    = 'yc_long_path / '
   M_CP    = 'center_corrected_l2_path / '

;ログファイルの名前を決める。
   logdir  = log_setting() ;ログファイルを出力するディレクトリ名を取得する
   LOGPATH = logdir+'EUVL2_CENTER_CORRECTION'+repstr(time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),':','_')+'.log' ;ログファイルの名前

;ライブラリの関数の標準エラーをcatchしてログファイルに出力する
   err_flg=C_FALSE
   catch,err_flg
   if(err_flg ne C_FALSE) then begin
      msg=!ERROR_STATE.MSG
      print,msg
      catch,/cancel
     ;ログファイルのユニット番号1が標準エラーメッセージに含まれる(=ログファイル出力に標準エラーが生じる)場合以外はログファイルに標準エラーを出力
      if(stregex(msg, '^OPENW: Error opening file. Unit: 4',/boolean) eq C_FALSE) then begin
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
      print,M_ERR18
      return
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
   ;積分後（1日分）または積分前EUV-L2データファイルパス
   if(keyword_set(l2path) eq C_FALSE) then err01 += M_LP
   ;Yc（長期）データファイルパス
   if(keyword_set(yclong) eq C_FALSE) then err01 += M_YC
   ;中心補正済EUV-L2データファイルパス
   if(keyword_set(corrl2path) eq C_FALSE) then err01 += M_CP

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

;【本処理】
;データエクステンション（1分積分）の個数（+ totalの1個分）を取得
   priimg    = mrdfits(l2path, C_PRI, pri,/silent)
   nextend   = fxpar(pri, KEYWORD_NE)

   ;データエクステンション（+ totalエクステンション）が存在しなければエラー
   totimg    = mrdfits(l2path, C_TOT, tot,/silent)
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

   ;入力EUV-L2データファイルにおいて、プライマリデータヘッダ記載のデータエクステンションの数（NEXTEND）と実際の数が一致するか確認する。
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
   ;出力ファイルのパスを決める。
   ;出力先がファイル名指定の場合
   if(stregex(corrl2path, '.fits$',/boolean) eq C_TRUE) then begin
      output=corrl2path ;出力ファイル名

      ;出力ディレクトリのパスが正しいものか確認するために、ファイルが格納されているディレクトリ名を取得する。
      corr_l2path_elm=strsplit(corrl2path,/extract, '\') ;corrl2pathを/で分割した値
;      corr_l2path_elm=strsplit(corrl2path,/extract, '/') ;corrl2pathを/で分割した値
      n_corr_l2path_elm=n_elements(corr_l2path_elm) ;l2dir_elmの要素数
      max_corr_l2path_elm = n_corr_l2path_elm - C_MAX
      n_corr_l2dir_elm=indgen(max_corr_l2path_elm) ;ディレクトリの数分の要素数の配列を作成する。
      corr_l2dir_elm =corr_l2path_elm[n_corr_l2dir_elm] ;ディレクトリの配列をディレクトリの数分作成する。
      corr_l2_dir=strjoin(corr_l2dir_elm[C_INIT:max_corr_l2path_elm - C_MAX],'\') ;出力ディレクトリ
;      corr_l2_dir='/'+strjoin(corr_l2dir_elm[C_INIT:max_corr_l2path_elm - C_MAX],'/') ;出力ディレクトリ

   endif else begin ;出力先がディレクトリ指定の場合
      ;出力ファイル名を決定する。
      ;入力FITSファイル名を取得する。
      l2path_elm=strsplit(l2path,/extract, '/') ;入力ファイルパスを/で分割した値
      l2_fits=l2path_elm[-C_MAX] ;入力FITSファイル名

      ;出力ディレクトリの末尾が/の時（****/****/****/のように指定した場合）
      if(stregex(corrl2path, '/$',/boolean) eq C_TRUE) then begin
         output=corrl2path+C_CPFILE+l2_fits ;出力ファイル名（出力ディレクトリ/center.cor.入力FITSファイル名）
      endif else begin ;出力ディレクトリの末尾が/でない時（****/****/****のように指定した場合）
         output=corrl2path+'/'+C_CPFILE+l2_fits ;出力ファイル名（出力ディレクトリ/center.cor.入力FITSファイル名）
      endelse

      corr_l2_dir=corrl2path
   endelse

;ファイルパスが正しいものか確認する。
   err19=''
   ;積分後（1日分）または積分前EUV-L2データファイルパス
   if(file_test(l2path) eq C_FALSE) then  err19 += M_LP
   ;Yc（長期）データファイルパス
   if(file_test(yclong) eq C_FALSE) then  err19 += M_YC
   ;中心補正済EUV-L2データディレクトリ
   if(file_test(corr_l2_dir) eq C_FALSE) then  err19 += M_CP

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
      print,M_ERR18
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR18
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif

   ;入力FITSファイル名とYc（長期）データファイルを取得する。
   l2path_elm_splt=strsplit(l2path,/extract, '/') ;入力ファイルパスを/で分割した値
   l2_fits_splt=l2path_elm_splt[-C_MAX] ;入力FITSファイル名
   yclong_elm_splt=strsplit(yclong,/extract, '/') ;入力ファイルパスを/で分割した値
   yclong_splt=yclong_elm_splt[-C_MAX] ;入力FITSファイル名


   ;プライマリデータエクステンションのキーワードを追加する。
   sxaddpar, pri, KEYWORD_LP, l2_fits_splt, CM_LP
   sxaddpar, pri, KEYWORD_YP, yclong_splt, CM_YP

   ;プライマリデータエクステンション、トータルエクステンションを出力ファイルに書き出す。
   openw, C_ILPLUN, output
   ;エクステンション作成日編集と書き出し
   sxaddpar, pri, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
   writefits, output, priimg, pri

   sxaddpar, tot, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
   writefits, output, totimg, tot,/append


   ;Yc（長期）データファイルの値を配列yc_arrに入れる。
   yc_time = dblarr(C_YCELM)
   yc_peak = dblarr(C_YCELM)
   yc_line  = file_lines(yclong)
   yc_arr  = strarr(yc_line)
   openr, C_ARRLUN, yclong
   readf, C_ARRLUN, yc_arr
   close, C_ARRLUN
   ;配列yc_arrから、ヘッダを除いた時刻とピークの値を取得する。
   data_flg = C_FALSE
   for i = C_INIT,yc_line - C_YCLOOP do begin
      yc_elm = strsplit(yc_arr[i], ',', /EXTRACT)
      ;データ部の処理
      if (data_flg eq C_TRUE) then begin
         ;空白を除去する
         yc_time_elm = strcompress(yc_elm[C_YCTIME],/remove_all)
         yc_peak_elm = strcompress(yc_elm[C_YCPEAK],/remove_all)

         ;Yc(長期)データの時刻、ピーク位置Ycのどちらかにstring型の値が含まれていた場合、msg_err22を出力する。
         if ((stregex(yc_time_elm,'^[0-9]',/boolean) eq C_FALSE) or $
         (stregex(yc_peak_elm,'^[0-9]',/boolean)  eq C_FALSE)) then begin
            print,M_ERR22
            printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR22
            ;処理時間の計測終了
            printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
            ;ログファイルを閉じる
            close,C_LOGLUN
            return
         endif

         ;時刻とピークの値を取得
         yc_time = [yc_time,time_double(yc_time_elm)]
         yc_peak = [yc_peak,double(yc_peak_elm)]
      endif
      if (stregex(yc_arr[i],'^#',/boolean)) then begin
         data_flg=C_TRUE
      endif
   endfor

   ;Yc（長期）データファイルに値が1つもないまたはデータヘッダがない場合、エラーメッセージmsg_err21を出力する。
   s_yc_time = size(yc_time)
   if((s_yc_time[n_elements(s_yc_time) - C_ARRDIF] eq C_YCINIELM) and (yc_time[C_INIT] eq C_DINIT)) then begin
   ;if (yc_time eq C_DINIT) then begin
      print,M_ERR21
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_ERR21
      ;処理時間の計測終了
      printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_END
      ;ログファイルを閉じる
      close,C_LOGLUN
      return
   endif
   ;double型の配列を宣言する時は、初期値0.0000000の要素が入るため、この要素を除去する。
   yc_time = yc_time[C_ONE:*]  ;Yc（長期）データ内の時刻（秒）
   yc_peak = yc_peak[C_ONE:*]  ;Yc（長期）データ内のピーク

   ;EUV-L2データの全データエクステンションを取得する。
   for i = C_DA1,nextend do begin
      ;各データエクステンションの代表時刻（秒）を取得する。
      datimg  = mrdfits(l2path, i, dat,/silent)
      l2dateo = fxpar(dat, KEYWORD_DO) 
      l2datee = fxpar(dat, KEYWORD_DE)
      l2date  = (time_double(l2dateo)+time_double(l2datee))/C_CEN ;各データエクステンションの代表時刻（秒）

      ;EUV-L2データの時刻と一番近いYc（長期）データの時刻を見つける。
      mintime_elm = where(abs(l2date-yc_time) eq min(abs(l2date-yc_time))) ;EUV-L2データの時刻と差が一番小さいYc（長期）データの時刻の要素番号
      ;EUV-L2データの時刻と差が一番小さいYc（長期）データの時刻の要素番号が複数存在する場合、最小の要素番号をその時の要素番号とする。
      if (n_elements(mintime_elm) ne C_MINELM) then mintime_elm = mintime_elm[C_ELMNUM]
     
      mintime = yc_time[mintime_elm] ;EUV-L2データの時刻と一番近いYc（長期）データの時刻
      minpeak = yc_peak[mintime_elm] ;ピクセル番号（1-1024）

      ;EUV-L2データの時刻と一番近いYc（長期）データの時刻におけるピーク値と惑星中心位置のピクセル差を求める。
      ;ピクセルは整数なので差を四捨五入する。
      center_dif = round(minpeak - C_PIXC) ;573もピクセル番号（1-1024）

      ;EUV-L2データの空間位置の内、y軸方向の値が最小値のものに値0のピクセルを、ピーク値Ycと惑星中心位置の差の分追加する。
      ;ピーク値Ycと惑星中心位置の差が0以上の時
      if (center_dif gt C_ZERO) then begin
         ;y軸方向の値が最小のものからピーク値Ycと惑星中心位置の差の分だけイメージを削除する。
         datimg = datimg[*,center_dif:*]
         ;y軸方向の値が最大のものにピーク値Ycと惑星中心位置の差の分だけ値が0のイメージを追加する。
         addpix = fltarr(C_PIX, center_dif)
         datimg = [[datimg],[addpix]]
         
         ;C_PIXDIF pix以上ずらした場合はメッセージ
         if (abs(center_dif) ge C_PIXDIF) then begin
            print,M_INF06 +  string(strcompress(C_PIXDIF,/remove_all)) + M_INF06_2
            printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF06 + string(strcompress(C_PIXDIF,/remove_all)) + M_INF06_2
         endif
      endif 
      if (center_dif lt C_ZERO) then begin 
      ;ピーク値Ycと惑星中心位置の差が0未満の時
      ;ピーク値Ycと惑星中心位置の差の分だけ値が0のイメージを追加する。
         addpix = fltarr(C_PIX, abs(center_dif))
         datimg = [[addpix],[datimg]]
         ;y軸方向の値が最大のものからピーク値Ycと惑星中心位置の差の分だけイメージを削除する。
         datimg = datimg[*,C_INIT:C_PIX-C_ARRDIF]
         ;C_PIXDIF pix以上ずらした場合はメッセージ
         if (abs(center_dif) ge C_PIXDIF) then begin
            print,M_INF06 + string(strcompress(C_PIXDIF,/remove_all)) + M_INF06_2
            printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF06 + string(strcompress(C_PIXDIF,/remove_all)) + M_INF06_2
         endif
      endif
      ;補正したデータエクステンションを出力ファイルに書き出す
      sxaddpar, dat, KEYWORD_YR, center_dif[0], CM_YR;;;hk
;      sxaddpar, dat, KEYWORD_YR, center_dif, CM_YR
      ;エクステンション作成日を編集する。
      sxaddpar, dat, KEYWORD_DT, time_string(systime(1),tformat=TIME_FORM), CM_DT
      writefits, output, datimg, dat,/append
   endfor

   ;出力ファイルを閉じる
   close,C_ILPLUN

   print,M_INF01
   printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ',M_INF01

;処理時間の計測終了
   p_end_time=systime(1)-tzoffset(/now)
   print,'proc time: ',(p_end_time - p_start_time)
   printf,C_LOGLUN, time_string((systime(1)-tzoffset(/now)),tformat=TIME_FORM),' ', 'END'
   ;ログファイルを閉じる
   close,C_LOGLUN
end
