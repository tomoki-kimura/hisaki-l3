;+
; NAME:
;      DIR_CHECK
;
; PURPOSE:
;      Check if the directory exsists.
;
; CALLING SEQUENCE:
;      DirCheck_String = REQUIRED_ITEM(req_arr)
;
; INPUTS:
;      Path - String Scalar including required items.
;
; OUTPUTS:
;      DirCheck_String - If required item does not exist, string giving error message.
;
; MODIFICATION HISTORY:
;      Written by Hiroko Tada
;      Fujitsu Limited.
;      First Edition 2017/12/01
;      Last Modified ****/**/**
;-

function dir_check, path
; エラーを検出したらreturnする
   ON_ERROR,3

;定数
   C_TRUE=1 ;真偽判定で真（存在の有無で有）の場合の返り値
   C_FALSE=0 ;真偽判定で偽（存在の有無で無）の場合の返り値

   ;ディレクトリの有無確認
   if(file_test(path) eq C_FALSE) then begin
      return,C_FALSE
   endif
   return, C_TRUE
end

