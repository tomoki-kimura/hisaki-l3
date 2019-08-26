;+
; NAME:
;      WRITE_LOG
;
; PURPOSE:
;      WRITE info or error message to log file.
;
; CALLING SEQUENCE:
;      EUVL2_TIMEINTEGRAL, LOG_PATH, MESSAGE
;
; ARGUMENTS:
;      LOG_PATH - String giving the log file path.
;      MESSAGE  - String giving the message.
;
; KEYWORD:
;      nontime - Flg to hide time.
;
; EXAMPLE:
;      IDL > log_path = "/XX/XX/XX.log"
;      IDL > message = "proccess start."
;      IDL > EUVL2_TIMEINTEGRAL, log_path, message
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/1/30 First Edition
;-
pro write_log, log_path, msg, nontime=nontime

   on_error, 2
   
   TFORMAT_LOG = 'YYYYMMDD-hhmmss' ; ログファイル中の時刻フォーマット

   append=1
   if file_search(log_path) eq '' then append=!NULL
   log_path=strtrim(log_path,2)
   openw, 1, log_path, append=append
   if (keyword_set(nontime) eq 0) then begin
      printf, 1, get_local_time(TFORMAT_LOG) + ' ' + msg
   endif else begin
      printf, 1, msg
   endelse
   close, 1
   return

end
