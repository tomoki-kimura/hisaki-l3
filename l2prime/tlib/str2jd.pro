;----------------------------------------------------------------------------------------------
;日時文字列(YYYY-MM-DDTHH:NN:SS)をユリウス日に変換する
;----------------------------------------------------------------------------------------------
function str2jd, utcstr
  year  = fix(strmid(utcstr,0,4))
  month = fix(strmid(utcstr,5,2))
  day   = fix(strmid(utcstr,8,2))
  hour = fix(strmid(utcstr,11,2))
  minute = fix(strmid(utcstr,14,2))
  second = fix(strmid(utcstr,17,2))
  jd = julday(month, day, year, hour, minute, second)
  return, jd
end
;----------------------------------------------------------------------------------------------