;
; GET_LOCAL_TIME
;   ローカルマシンタイムを取得する。
;
;     arg : tformat    - String 表示時刻フォーマット
;     ret : local_time - String ローカルマシンタイム
;
function get_local_time, tformat

   local_time = time_string((systime(1)-tzoffset(/now)),tformat=tformat)
   local_time = strjoin(strsplit(local_time,':',/ext))
   return, local_time

end
