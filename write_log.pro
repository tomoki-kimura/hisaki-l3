pro write_log, log_path, msg, nontime=nontime

   on_error, 2

   TFORMAT_LOG = 'YYYYMMDD-hhmmss'
   
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
