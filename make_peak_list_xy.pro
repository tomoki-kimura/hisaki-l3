;+
; NAME:
;      MAKE_PEAK_LIST_SPLINE
;
; PURPOSE:
;      Make file of peak list with spline fitting.
;
; CALLING SEQUENCE:
;      MAKE_PEAK_LIST_SPLINE, yc_d=indir, st=start_dir, et_end_time, out_p=out_path, movmean_p=period
;
; KEYWORDS:
;      yc_d      - String giving the input directry(Yc directry).
;      st        - String giving start time.
;      et        - String giving end time.
;      out_p     - String giving the directry of output data file.
;      movmean_p - Integer giving the moving avarage period.
;
; OUTPUTS:
;
; RESTRICTIONS:
;      You can use Yc file including 1 day's data per 1 record.
;
; LIBRARY
;          IDL Astronomy User’s Library         <https://idlastro.gsfc.nasa.gov/>
;          Coyote IDL Program Libraries          <http://www.idlcoyote.com/programs/>
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software)
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; FUNCTIONS USED:
;      The following functions are contained.
;          LOG_SETTING -- Get a name of log file path.
;          WRITE_LOG   -- Write log file
;          GET_LOCAL_TIME -- Get local machine time.
;
; EXAMPLE:
;   (1) pixel mode
;      IDL> yc_dir  = '/XXX/XXX/XXX'
;      IDL> path_out = '/XXXX/XXXX'
;      IDL> start_time = ''
;      IDL> end_time = ''
;      IDL> period   = ''
;      IDL> make_peak_list_spline, yc_d=yc_dir, st=start_time, et=end_time, out_p=path_out, movmean_p=period
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/01/30 First Edition
;-
pro make_peak_list_xy, yc_d=yc_dir, st=start_time, et=end_time, out_p=path_out, movmean_p=period

   ; 定数
   PRO_NAME           = 'MAKE_PEAK_LIST_XY'
   KEYWORD_YC_DIR     = 'yc_dir'
   KEYWORD_START_TIME = 'start_time'
   KEYWORD_END_TIME   = 'end_time'
   KEYWORD_OUT_DIR    = 'path_out'
   KEYWORD_PERIOD     = 'period'
   ERR_HEAD           = '% '
   SL                 = '/'
   EMP_STR            = ''
   WIDE_CARD          = '*'
   TRUE               = 1
   FALSE              = 0
   SPACE_10           = '           '
   FILE_TYPE_LOG      = '.log'
   REC_HEADER      = '#datatime,yc'
   INFO               = '[INFO] '
   ERR                = '[ERR ] '
   TFORMAT_LOG = 'YYYY-MM-DDThh:mm:ss'

   ;ログファイルの名前を決める。
   logdir  = log_setting() ;ログファイルを出力するディレクトリ名を取得する
   LOG_NAME = PRO_NAME + get_local_time(TFORMAT_LOG) + FILE_TYPE_LOG
   LOG_NAME = repstr(LOG_NAME,':','_')
   LOG_PATH = logdir + LOG_NAME
   ;   LOG_PATH = logdir + '/' + LOG_NAME
   
   
   MSG_INF01 = 'msg_inf01: Process Start.'
   MSG_INF02 = 'msg_inf02: Process End.'

   MSG_ERR01 = 'msg_err01: Please input the following items. '

   ; ログ出力
   write_log, LOG_PATH, MSG_INF01
   p_start_time = systime(1)

   ; エラーのキャッチ
   err_flg = 0
   catch, err_flg
   if err_flg ne 0 then begin
      msg = !ERROR_STATE.MSG
      catch, /cancel
      write_log, LOG_PATH, msg
      write_log, LOG_PATH, MSG_INF02 
      print, msg
      return
   endif

   ; 必須項目チェック
   err01 = EMP_STR
   ; ycデータディレクトリ
   if (keyword_set(yc_dir) eq FALSE) then $
      err01 += SL + KEYWORD_YC_DIR
   ; フィッティング開始時刻
   if (keyword_set(start_time) eq FALSE) then $
      err01 += SL + KEYWORD_START_TIME
   ; フィッティング終了時刻
   if (keyword_set(end_time) eq FALSE) then $
      err01 += SL + KEYWORD_END_TIME
   ; 出力ディレクトリ
   if (keyword_set(path_out) eq FALSE) then $
      err01 += SL + KEYWORD_OUT_DIR
   ; 移動平均幅
   if (keyword_set(period) eq FALSE) then $
      err01 += SL + KEYWORD_PERIOD
   ; 必須項目がない場合はリターン
   if(err01 ne emp_str) then begin
      write_log, LOG_PATH, MSG_ERR01 + err01
      message, MSG_ERR01 + err01
   endif

   ; 開始終了時刻をdouble型に変換
   start_date   = time_string(start_time, tformat='YYYYMMDD')
   start_date_d = time_double(start_date)
   start_time_d = time_double(start_time)
   end_date     = time_string(end_time, tformat='YYYYMMDD')
   end_date_d   = time_double(end_date)
   end_time_d   = time_double(end_time)

   ; ycデータディレクトリのファイル一覧を取得
   yc_files      = file_search(yc_dir + SL + WIDE_CARD)
   size_yc_files = size(yc_files,/dimension)
   if size_yc_files eq 0 then $
      message, 'There is no file at Yc dir. '+yc_dir
   

   ; 取得したファイルのレコードを取得
   total_recs    = strarr(1)
   for i = 0, size_yc_files[0] - 1 do begin
      contents   = strsplit(yc_files[i],'_',/EXTRACT)
      n_contents = n_elements(contents)
      yc_date    = contents[n_contents - 1]
      date_ptn   = stregex(yc_date, '^[0-9]{8}',/boolean)
      if (date_ptn ne TRUE) then continue
      yc_date_d = time_double(yc_date)
      if (yc_date_d lt start_date_d) then continue
      if (yc_date_d gt end_date_d) then continue
      file_recs = strarr(file_lines(yc_files[i]))
      openr, 1, yc_files[i]
      readf, 1, file_recs
      close, 1
      if n_elements(file_recs) eq 8 then continue
      ;if (n_elements(total_recs) eq 1) then begin
      if total_recs[0] eq '' then begin
         total_recs = [file_recs[8:*]]
      endif else begin
         total_recs = [total_recs, file_recs[8:*]]
      endelse
   endfor

   ; レコードから時刻とピークの値を取得
   n_total_recs = n_elements(total_recs)
   arr_time     = strarr(n_total_recs)
   arr_time_d   = dblarr(n_total_recs)
   arr_yc       = dblarr(n_total_recs)
   arr_yc_peak  = dblarr(n_total_recs)
   arr_yc_err   = dblarr(n_total_recs)
   slit2        = dblarr(n_total_recs)
   slit3        = dblarr(n_total_recs)
   for j = 0, n_total_recs - 1 do begin
      rec = strsplit(total_recs[j], ',', /EXTRACT)
      arr_time_d[j] = time_double(rec[0])
      arr_time[j]   = rec[0]
      arr_yc[j]     = double(rec[1]);arr_yc[j]     = fix(rec[1])
      arr_yc_err[j] = double(rec[2])
;      arr_yc_peak[j]= double(rec[3])
;      slit2[j]      = fix(rec[4])
;      slit3[j]      = fix(rec[5])
   endfor

   ; データのsmoothing処理
   arr_yc_smooth = dblarr(n_total_recs)
;   for k = 0, n_total_recs - 1 do begin
;       arr_yc_smooth[k] = mean(arr_yc(where((arr_time_d lt arr_time_d[k] + period/2)$
;                                              and (arr_time_d ge arr_time_d[k] - period/2))))
;   endfor

   arr_yc_smooth=arr_yc
   
   ; 補完する時刻の配列を作成
   arr_req_time = dblarr(1) 
   t = start_time_d
   arr_req_time[0] = t
   while (t lt end_time_d) do begin
      t = t + 600
      arr_req_time = [arr_req_time, t]
   endwhile

   ; スプライン補間
   res = spline(arr_time_d,arr_yc_smooth,arr_req_time) 

   ; ファイル出力
   out_name = start_date + "_" + end_date
   out_path = path_out + "/" + out_name
   openw, 1, out_path
   printf,1, 'yc_dir     = ' + yc_dir
   printf,1, 'start_time = ' + start_time
   printf,1, 'end_time   = ' + end_time 
   printf,1, 'out_path   = ' + out_path 
   printf,1, 'movemean_period  = ' , period
   printf,1, REC_HEADER
   for k=0, n_elements(res)-1 do begin
      rec = time_string(arr_req_time[k],tformat='YYYY/MM/DDThh:mm:ss')+','+strcompress(string(res[k]))
      printf,1,rec
   endfor
   close,1
   
   jd=dblarr(n_elements(arr_time_d))
   cspice_utc2et,'2016-01-01T00:00:00',et
   cspice_et2utc, et,'J',10,buff
   ref_jd=double((strsplit(buff,/extract))[1])
   for k=0, n_elements(arr_time_d)-1 do begin
     buff = time_string(arr_time_d[k],tformat='YYYY-MM-DDThh:mm:ss')
     cspice_utc2et,buff,et
     cspice_et2utc, et,'J',10,buff
     jd[k]=double((strsplit(buff,/extract))[1])
   endfor
   jd=jd-ref_jd
   plot,jd,arr_yc,/ysty
   ;plot, arr_req_time,res,yrange=[565,576]
stop
stop
   !p.multi=[0,1,2]
   whitebg
   plot,jd,arr_yc,/ysty,xrange=[0,366],title='2016',psym=-1
   oplot,jd,slit2,color=fsc_color('red'),psym=-1
   oplot,jd,slit3,color=fsc_color('red'),psym=-1
   plot,jd-366,arr_yc,/ysty,xrange=[0,366],title='2017',psym=-1
   oplot,jd-366,slit2,color=fsc_color('red'),psym=-1
   oplot,jd-366,slit3,color=fsc_color('red'),psym=-1
stop
stop
;   !p.multi=[0,1,2]
;   whitebg
   plot,jd,arr_yc,/ysty,xrange=[0,366],/xsty,yrange=[530,600],title='2016'
   oplot,jd,slit2,color=fsc_color('red'),psym=-1
   oplot,jd,slit3,color=fsc_color('red'),psym=-1
   plot,jd-366,arr_yc,/ysty,xrange=[0,366],/xsty,yrange=[530,600],title='2017'
   oplot,jd-366,slit2,color=fsc_color('red'),psym=-1
   oplot,jd-366,slit3,color=fsc_color('red'),psym=-1

stop
stop

   openw, 1, 'D:\L2\spline\output_xc.csv'
   size_arr_time = size(arr_time_d)
   for k = 0, size_arr_time[1] - 1 do begin
     rec = arr_time[k] + ',' + strcompress(string(arr_yc[k])) 
     printf, 1, rec
   endfor
   close, 1




   ; ログ出力
   write_log, LOG_PATH, MSG_INF02
   p_end_time = systime(1)

   write_log, LOG_PATH, 'proc time:'+strcompress(p_end_time - p_start_time)


end
