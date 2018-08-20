;+
; NAME:
;      TIME_NUM
;
; PURPOSE:
;      Check a size and range of date.
;
; CALLING SEQUENCE:
;      Result      = TIME_NUM(IntDate_Num)
;
; INPUTS:
;      IntDate_Num - Integer Scalar including required items. Can be between 1 and 1440.
;
; OUTPUTS:
;      TF_String   - Default string is 'false'. If all conditions are completed, string returns 'true'. 
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

function time_num, intdate_num
; エラーを検出したらreturnする
   ON_ERROR,3

;定数
   C_ZERO     = 0       ;初期値等の値0
   C_IT_MIN=1 ;積分時間の最小値(min)
   C_IT_MAX=1440 ;積分時間の最大値(=24*60)(min)
   M_ERR17   = 'msg_err17: Please correct the number of arrays or elements.'

   ;引数が定義されているか確認
   if(n_elements(intdate_num) eq C_ZERO) then begin
      return,M_ERR17
   endif


   tf_string='false'
   ;データ型がintか判定
   if(size(intdate_num, /tname) eq 'INT') then begin
      ;入力値が1~1440の間に含まれているか判定
      if((C_IT_MIN le fix(intdate_num)) and (fix(intdate_num) le C_IT_MAX)) then begin
         tf_string='true'
         return,tf_string
      endif
   endif
   ;データ型がintかつ入力値が1~1440の間に含まれている状態ではない場合、エラーメッセージ
   return,tf_string
end

