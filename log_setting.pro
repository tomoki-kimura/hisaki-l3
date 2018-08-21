;+
; NAME:
;      LOG_SETTING
;
; PURPOSE:
;      Get a name of log file path.
;
; CALLING SEQUENCE:
;       Result   = LOG_SETTING()
;
; INPUTS:
;      Nothing.
;
; OUTPUTS:
;      Log_Place - a name of log file path
;
; MODIFICATION HISTORY:
;      Written by FJT) Hiroko Tada
;      Fujitsu Limited.
;      First Edition 2018/01/30
;-

function log_setting
; エラーを検出したらreturnする
   ON_ERROR,3

;定数
   log_place = !log_place ;ログファイルを出力するパスが記入されているファイル
   wait, 1
   return,log_place

end
