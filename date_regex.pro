;+
; NAME:
;      DATE_REGEX
;
; PURPOSE:
;      Check a format of date.
;
; CALLING SEQUENCE:
;      Result        = DATE_REGEX(ArrDate_RG)
;
; INPUTS:
;      ArrDate_RG    - String array including required items.
;
; OUTPUTS:
;      DateRG_String - If some required items are not included in a res_arr, string giving error messages in format 'lacked item1 lacked item2 ... '
;
; LIBRARIES USED:
;      The following libraries are contained in the main EUVL2_CENTER_CORRECTION program.
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software)
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; MODIFICATION HISTORY:
;      Written by FJT) Hiroko Tada
;      Fujitsu Limited.
;      First Edition 2018/01/30
;-

function date_regex, arrdate_rg
; エラーを検出したらreturnする
   ON_ERROR,3

;定数
   C_NAM_ARR=0 ;配列の中のキーワード名
   C_VAL_ARR=1 ;配列の中の入力値
   C_TRUE=1 ;真偽判定で真（存在の有無で有）の場合の返り値
   C_FALSE=0 ;真偽判定で偽（存在の有無で無）の場合の返り値

   C_ZERO     = 0       ;初期値等の値0
   C_S0       = 0       ;size()の戻り値（次元数）
   C_S1       = 1       ;size()の戻り値（1次元の要素数）
   C_S2       = 2       ;size()の戻り値（型コード）
   C_S3       = 3       ;size()の戻り値（全要素数）
   C_DIM      = 1       ;次元数の値
   C_1EL      = 2       ;1次元の要素数の値
   C_STR      = 7       ;string型のType Code
   C_AEL      = 2       ;全要素数の値
   M_ERR17   = 'msg_err17: Please correct the number of arrays or elements.'
   ;引数が定義されているか確認
   if(n_elements(arrdate_rg) eq C_ZERO) then begin
      return,M_ERR17
   endif

   ;引数の型を確認
   input_size = size(arrdate_rg)
   if((input_size[C_S0] eq C_DIM) and (input_size[C_S1] eq C_1EL) and (input_size[C_S2] eq C_STR) and (input_size[C_S3] eq C_AEL)) then begin
      result=''
      daterg_string=''
   endif else begin
      return,M_ERR17
   endelse

   ;文字列と検索文字列が一致するか検索
   ;パターンマッチ
   date_pattern= stregex(arrdate_rg[C_VAL_ARR], '^[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]$',/boolean)
   ;falseなら
   if(date_pattern eq C_FALSE) then begin
      daterg_string=arrdate_rg[c_nam_arr]
      return, daterg_string
   endif

   ;11/31等、存在しない時刻の入力確認
      ;入力した値の実際の日時を表す
      ts=time_struct(arrdate_rg[C_VAL_ARR])
      date_ts=time_string(ts,tformat='YYYY-MM-DDThh:mm:ss')
     
      ;文字列の一致検索結果と実際の日時の計算結果が一致しなければエラーメッセージ
      if(strcmp(arrdate_rg[C_VAL_ARR],date_ts) eq C_FALSE) then begin
         daterg_string=arrdate_rg[C_NAM_ARR]
      endif

   return, daterg_string
end

