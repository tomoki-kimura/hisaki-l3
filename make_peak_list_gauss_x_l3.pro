;+
; NAME:
;      MAKE_PEAK_LIST_GAUSS
;
; PURPOSE:
;      Make file of peak list with gaussian fitting.
;
; CALLING SEQUENCE:
;      MAKE_PEAK_LIST_GAUSS, lp=l2_intg_path, od=out_dir, md=[pixel/value], xr=xrange, yr=yrange, [cp=l2_cal_path]
;
; KEYWORDS:
;      lp - String giving the path of EUV-L2 integral data files
;      od - String giving the directry of output data files
;      md - String giving the image process mode [pixel/value]
;      cp - String giving the path of EUV-L2 cal data files
;      xr - float array[min,max] (pixel:1 - 1024 ,value:  469.903 - 1529.43)
;      yr - float array[min,max] (pixel:1 - 1024 ,value: -2345.20 - 1849.10)
;
; OUTPUTS:
;      Yc data file.
;
; RESTRICTIONS:
;      You can use only 1 EUV-L2 file including 1 day's data per 1 execution.
;
; LIBRARY:
;          IDL Astronomy User’s Library         <https://idlastro.gsfc.nasa.gov/>
;          Coyote IDL Program Libraries          <http://www.idlcoyote.com/programs/>
;          TDAS (THEMIS Data Analysis Software) + SPEDAS (Space Physics Environment Data Analysis Software)
;                                                <http://themis.ssl.berkeley.edu/software.shtml>
;
; FUNCTIONS USED:
;      The following functions are contained.
;          LOG_SETTING          -- Get a name of log file path.
;          CONVERT_VALUE2PIXEL  -- convert value to pixel
;          WRITE_LOG   -- Write log file
;          GET_LOCAL_TIME -- Get local machine time.
;
; EXAMPLE:
;   (1) pixel mode
;      IDL> l2_intg_path = '/XXX/XXX/XXX.fits'
;      IDL> out_dir = '/XXXX/XXXX'
;      IDL> mode   = 'pixel'
;      IDL> xrange = [0, 1023]
;      IDL> yrange = [570, 580]
;      IDL> make_peak_list_gauss, lp=l2_intg_path, od=out_dir, md=mode, xr=range, yr=yrange
;
;   (2) value mode
;      IDL> l2_intg_path = '/XXX/XXX/XXX.fits'
;      IDL> l2_cal_path  = '/XXX/XXX/l2caldata.fits'
;      IDL> out_dir = '/XXXX/XXXX'
;      IDL> mode   = 'value'
;      IDL> xrange = [500, 1023]
;      IDL> yrange = [570, 580]
;      IDL> make_peak_list_gauss, lp=l2_intg_path, od=out_dir, md=mode, cp=l2_cal_path, xr=xrange, yr=yrange
;
; MODIFICATION HISTORY:
;      Written by FJT) kitagawa
;      Fujitsu Limited.
;      v1.0 2018/01/30 First Edition
;-
pro make_peak_list_gauss_x_l3, lp=l2_intg_path, od=out_dir, md=mode, cp=l2_cal_path, xr=xrange, yr=yrange, ret=ret
loadct,39,/SILENT;;;HK
!p.multi=[0,2,2]

   on_error,2

   ; 処理時間計測開始
   p_start_time = systime(1)

   ; 定数
   TOOL_HOME       = "/home/fujitsu/work/tool"
   STR_PROC_TIME   = 'proc time : '
   KEY_NEXTEND     = 'NEXTEND'
   KEY_EXTNAME     = 'EXTNAME'
   TFORMAT_OUT     = 'xc_YYYYMMDD.csv'
   TFORMAT_LOG     = 'YYYYMMDDThhmmss'
   REC_HEADER      = '#datatime,yc,sigma,xc1,xc2,peak1,peak2,err1,err2'
   NUM_FILE_UNIT   = 1
   NUM_PRIM_EXTENT = 0
   IMG_SIZE        = [1024, 1024]
   KEYWORD_IP      = 'lp'
   KEYWORD_OD      = 'od'
   KEYWORD_MD      = 'md'
   KEYWORD_CP      = 'cp'
   KEYWORD_XRANGE  = 'xrange'
   KEYWORD_YRANGE  = 'yrange'
   MODE_PIXEL      = 'pixel'
   MODE_VALUE      = 'value'
   TYPE_INT        = 'INT'   
   TYPE_FLT        = 'FLOAT'   
   TRUE            = 1
   FALSE           = 0
   CM              = ','
   US              = '_'
   SL              = '/'
   EMP_STR         = ''
   SPACE_10        = '           '
   ERR_HEAD        = '% '
   PRO_NAME        = 'MAKE_PEAK_LIST_GAUSS'
   RANGE_MIN       = 1
   RANGE_MAX       = 1024
   FILE_TYPE_LOG   = '.log'
   INFO            = '[INFO] '
   ERR             = '[ERR ] '

   ; メッセージ定義
   MSG_ERR01 = 'msg_err01: Please input the following items.'
   MSG_ERR06 = 'msg_err06: Please input in the form of “pixel” or “value”.'
   MSG_ERR23 = 'msg_err08: Please input 1 ～ 1024'
   MSG_ERR04 = 'msg_err16: Make Yc file failed'
   MSG_ERR05 = 'msg_err07: There is no following key in primary header.'
   MSG_ERR08 = 'msg_err10: If pixel mode, you must range INT.'

   MSG_ERR96 = 'msg_wrn01: GAUSSFIT is failed. ExtensionNo.'
   MSG_ERR97 = 'msg_wrn02: Extension has bad image. ExtensionNo.'

   MSG_INF01 = 'msg_inf01: Process Start.'
   MSG_INF02 = 'msg_inf02: Process End.'

   ; ログの設定
   logdir  = log_setting() ;ログファイルを出力するディレクトリ名を取得する
   LOG_NAME = PRO_NAME + get_local_time(TFORMAT_LOG) + FILE_TYPE_LOG
   LOG_PATH = logdir + '/' + LOG_NAME

   ; ログ出力
   write_log, LOG_PATH, MSG_INF01

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
   ; 積分後EUV-L2データファイルパス
   if (keyword_set(l2_intg_path) eq FALSE) then err01 += '/' + KEYWORD_IP
   ; 出力ディレクトリ
   ;if (keyword_set(out_dir) eq FALSE) then err01 += '/' + KEYWORD_OD
   ; モード
   if (keyword_set(mode) eq FALSE) then err01 += '/' + KEYWORD_MD
   ; 必須項目がない場合は終了
   if(err01 ne EMP_STR) then $
      message, MSG_ERR01 + " " + err01

   ; 積分後L2のプライマリーヘッダから時刻エクステンション
   ; の数を取得し配列を作成
   im_prim    = mrdfits(l2_intg_path, NUM_PRIM_EXTENT, prim_hdr, /silent)
   n_intg_ext = fxpar(prim_hdr, KEY_NEXTEND)
   if (n_intg_ext eq 0) then $
      message, MSG_ERR05 + KEY_NEXTEND

   ; totalエクステンションの数を引く
   n_intg_ext -= 1

   ; 格納用の配列を作成
   arr_time_s   = strarr(n_intg_ext)
   arr_time     = strarr(n_intg_ext)
   arr_time_e   = strarr(n_intg_ext)
   arr_xc       = fltarr(n_intg_ext)
   arr_sigma    = fltarr(n_intg_ext)
   arr_xc1      = fltarr(n_intg_ext)
   arr_xc2      = fltarr(n_intg_ext)
   arr_xc_peak1 = fltarr(n_intg_ext)
   arr_xc_peak2 = fltarr(n_intg_ext)
   arr_err1     = fltarr(n_intg_ext)
   arr_err2     = fltarr(n_intg_ext)
   int_time   = fltarr(n_intg_ext)

   ; modeの値チェック
   case mode of
      ; (1)pixelモードの場合
      MODE_PIXEL : begin
         ; pixel番号=>配列番号　変換
         xrange = xrange - 1
         yrange = yrange - 1
         ; x,yの指定範囲が1~1024であるか確認
         if (xrange[0] lt RANGE_MIN -1 or xrange[0] gt RANGE_MAX -1)$
               or (xrange[1] lt RANGE_MIN or xrange[1] gt RANGE_MAX) then $
            message, MSG_ERR23 + '[Xrange]'
         if (yrange[0] lt RANGE_MIN - 1 or yrange[0] gt RANGE_MAX -1)$
               or (yrange[1] lt RANGE_MIN or yrange[1] gt RANGE_MAX) then $
            message, MSG_ERR23 + '[Yrange]'
         
         ; pixelの場合はl2_cal_pathを空文字で定義
         l2_cal_path = EMP_STR

         ; 範囲がINT型でない場合はエラー出力・終了
         type_xrange = size(xrange, /tname)
         type_yrange = size(yrange, /tname)
         if (type_xrange ne TYPE_INT) or (type_yrange ne TYPE_INT) then $
            message, MSG_ERR08 ;メッセージを考える
      end

      ; (2)valueモードの場合
      MODE_VALUE : begin

         ; EUV-L2補正データが指定されていない場合は終了
         if(keyword_set(l2_cal_path) eq FALSE) then $
            message, MSG_ERR01 + " /path_L2cal"

         ; ヘッダ記述ようにvalueの値を退避
         xrange_v = xrange
         yrange_v = yrange

         ; 値をFLOAT型に変換(INTで入力される可能性がある)
         xrange = float(xrange)
         yrange = float(yrange)

         ; value -> pixel 変換
         range_p = convert_value2pixel(l2_cal_path, xrange, yrange)
         xrange  = range_p[*, 0]
         yrange  = range_p[*, 1]
      end

      ; (3)pixel/value以外
      else : begin
         message, MSG_ERR06
      end
   endcase
   
   
   tot=dblarr(1024,1024)
;   for i=1, n_intg_ext + 1 do begin
   for i=2, n_intg_ext + 1 do begin
     tot+=mrdfits(l2_intg_path, i, hdr, /silent)
   endfor
   buff=mrdfits(l2_intg_path, 1, tothdr, /silent)
   
   buff=read_csv('C:\function\JX-PSPC-464448\etc\FJSVTOOL\slit\slit_move2.csv')
   s2=buff.field3
   s3=buff.field4

   extot=0; extot=1
   
   
   ; 積分エクステンション毎にガウシアンフィッティング
   for i = 2, n_intg_ext + 1 do begin;;;byHK

      ; イメージを取得
      im = mrdfits(l2_intg_path, i, hdr, /silent)
      if extot eq 1 then im=float(tot) ;byHK
      im2=im
      
      ; イメージがfltarr(1024,1024)でない場合はループを飛ばす
      size_im = size(im, /dimension)
      if (size_im[0] ne IMG_SIZE[0]) or (size_im[1] ne IMG_SIZE[1])$
           or (size(im,/tname) ne TYPE_FLT) then begin
         print, MSG_ERR97 + i
         continue
      endif
      
      
      ;find geocorona
      range_p = convert_value2pixel(l2_cal_path, [1216,1216+10], [-10,10])
      geocr  = range_p[0, 0]
      range_p = convert_value2pixel(l2_cal_path, [1025,1025+10], [-10,10])
      geocr2 = range_p[0, 0]
      
      ;----------
      ;Dawn side
      ;----------
      ; イメージを指定領域に切り取る
      im_target      = im[xrange[0]:xrange[1],yrange[0]:(yrange[1]+yrange[0])/2.]
;      im_target      = im[xrange[0]:xrange[1],yrange[0]:!slit2]
      size_im_target = size(im_target, /dimension)

      ; 空間方向の積分 ;;byHK
      im_x_intg = fltarr(size_im_target[0]);
      for j = 0, size_im_target[1] - 1 do begin
         im_x_intg = im_x_intg + im_target[*,j]
      endfor
     
      ; ガウシアンフィッティング
      x_range    = [xrange[0]:xrange[1]]
      xfit1       = GAUSSFIT(x_range, im_x_intg, coeff1, NTERMS=4, yerror=yerror1)
      
      ; GAUSSFITが失敗した場合はループを飛ばす
      if (size(coeff1, /dimension) ne 4) then begin
         print, MSG_ERR96 + i
         continue
      endif 

      ; データ時刻を取得
      data_time = fxpar(hdr,KEY_EXTNAME)

      ; データ時刻が取得できない場合はループを飛ばす
      if (data_time eq 0) then begin
         print, MSG_ERR05 + KEY_EXTNAME
         continue
      endif
      im_x_intg1=im_x_intg
      
      ;----------
      ;Dusk side
      ;----------
      ; イメージを指定領域に切り取る
      im_target      = im[xrange[0]:xrange[1],(yrange[1]+yrange[0])/2.:yrange[1]]
      size_im_target = size(im_target, /dimension)

      ; 空間方向の積分 ;;byHK
      im_x_intg = fltarr(size_im_target[0]);
      for j = 0, size_im_target[1] - 1 do begin
        im_x_intg = im_x_intg + im_target[*,j]
      endfor

      ; ガウシアンフィッティング
      x_range    = [xrange[0]:xrange[1]]
      xfit2       = GAUSSFIT(x_range, im_x_intg, coeff2, NTERMS=4, yerror=yerror2)

      ; GAUSSFITが失敗した場合はループを飛ばす
      if (size(coeff2, /dimension) ne 4) then begin
        print, MSG_ERR96 + i
        continue
      endif

      ; データ時刻を取得
      data_time = fxpar(hdr,KEY_EXTNAME)


      ; データ時刻が取得できない場合はループを飛ばす
      if (data_time eq 0) then begin
        print, MSG_ERR05 + KEY_EXTNAME
        continue
      endif
      im_x_intg2=im_x_intg
      
      data_time_s = fxpar(hdr,'EFFEXP01');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
      effextarr='EFFEXP'+string(indgen(99)+1,format='(i02)')
      for l=0, n_elements(effextarr)-1 do begin
        if fxpar(hdr,effextarr[l]) eq 0 then break
      endfor
      data_time_e = fxpar(hdr,effextarr[l-1])
      data_time   = time_string((time_double(data_time_s) + time_double(data_time_e))/2.)
      data_time   = repstr(data_time,'/','T')


      if extot eq 1 then begin
        stdate=fxpar(tothdr, 'DATE-OBS')
        eddate=fxpar(tothdr, 'DATE-END')
        data_time = time_string((time_double(stdate)+time_double(eddate))/2,TFORMAT='YYYY-MM-DDThh:mm:ss')
      endif

      
      ; 値を配列に格納(データ時刻、ピーク位置、σ)
      num_data  = i - 2
      arr_time_s[num_data]= data_time_s
      arr_time[num_data]  = data_time
      arr_time_e[num_data]= data_time_e
      arr_xc[num_data]    = (coeff1[1]+coeff2[1])/2.; + 1 ;配列番号=>pixel番号　　はやめる
      arr_sigma[num_data] = (coeff1[2]+coeff2[2])/2.
      arr_xc1[num_data]   =  coeff1[1]
      arr_xc2[num_data]   =  coeff2[1]
      arr_xc_peak1[num_data]   =  coeff1[0]
      arr_xc_peak2[num_data]   =  coeff2[0]
      arr_err1[num_data]  = yerror1
      arr_err2[num_data]  = yerror2
      int_time[num_data]   =fxpar(hdr,'INT_TIME')
      
      ;;;byHK
      n1=ck_slitmove(data_time, buff.field1)
      slit2=s2[n1]
      slit3=s3[n1]

      
      plot,x_range,im_x_intg1,title=data_time+' lower'
      oplot,x_range,xfit1,color=fsc_color('red')
      plot,x_range,im_x_intg2,title=data_time+' upper'
      oplot,x_range,xfit2,color=fsc_color('red')
      imgdisp_2,im,roi=[xrange[0]-30,xrange[1]+30,yrange[0]-30,yrange[1]+30]
      range_p = convert_value2pixel(l2_cal_path, [679.2,679.2+50], [0,10])
      s3x  = range_p[1, 0]-1;短波長側で1pixくらいずれる
;      s3y  = range_p[0, 1];(slit2+slit3)/2.;
      s3y  = (slit2+slit3)/2.
      oplot,[s3x-1,s3x-1  ,s3x-7   ,s3x-7,      s3x+7,       s3x+7,  s3x+1 , s3x+1   ,s3x+7  ,s3x+7       ,s3x-7       ,s3x-7  ,s3x-1,s3x-1]$
            , [s3y  ,s3y-11.2,s3y-11.2,s3y-11.2-32.7,s3y-11.2-32.7,s3y-11.2,s3y-11.2,s3y+11.2,s3y+11.2,s3y+11.2+32.7,s3y+11.2+32.7,s3y+11.2,s3y+11.2,s3y]
      oplot,coeff1[1]*[1,1],[yrange[0]-30,yrange[1]+30],linestyle=1
      oplot,coeff2[1]*[1,1],[yrange[0]-30,yrange[1]+30],linestyle=1
;      imgdisp_2,im,roi=[geocr-30,geocr+30,yrange[0]-30,yrange[1]+30]
      imgdisp_2,[tot[geocr-30:geocr+30,yrange[0]-30:yrange[1]+30],10*tot[geocr2-30:geocr2+30,yrange[0]-30:yrange[1]+30]],range=0.99
;      oplot,!x.crange,[1,1]*(!nslit_1-yrange[0]+30)
;      oplot,!x.crange,[1,1]*(!nslit_2-yrange[0]+30)
;      range_p = convert_value2pixel(l2_cal_path, [1216,1216+10], [0,10])
;      s3x  = range_p[0, 0]+10
;      s3y  = range_p[0, 1];(!slit2+!slit3)/2.;
;      oplot,[s3x-1,s3x-1  ,s3x-7   ,s3x-7,      s3x+7,       s3x+7,  s3x+1 , s3x+1   ,s3x+7  ,s3x+7       ,s3x-7       ,s3x-7  ,s3x-1,s3x-1]$
;        , [s3y  ,s3y-11.2,s3y-11.2,s3y-11.2-32.7,s3y-11.2-32.7,s3y-11.2,s3y-11.2,s3y+11.2,s3y+11.2,s3y+11.2+32.7,s3y+11.2+32.7,s3y+11.2,s3y+11.2,s3y]     
      path_elm=strsplit(l2_intg_path,/extract, '\')
      file_elm=strsplit(path_elm[n_elements(path_elm)-1],/extract, '._')
      write_png, !log_place+'/plot_xc_'+file_elm[1]+'.'+string(i,format='(i03)')+'.png', TVRD(/TRUE)
            
      if extot eq 1 then break
   endfor
   
   
   ;Fitting error => return -1
   if (where(arr_xc ne 0))[0] eq -1 then begin
     return
   endif

;   arr_time[num_data]  = data_time
;   arr_xc[num_data]    = (coeff1[1]+coeff2[1])/2.; + 1 ;配列番号=>pixel番号　　はやめる
;   arr_sigma[num_data] = (coeff1[2]+coeff2[2])/2.
;   arr_xc1[num_data]   =  coeff1[1]
;   arr_xc2[num_data]   =  coeff2[1]
;   arr_xc_peak1[num_data]   =  coeff1[0]
;   arr_xc_peak2[num_data]   =  coeff2[0]
;   arr_err1[num_data]  = yerror1
;   arr_err2[num_data]  = yerror2
;   int_time[num_data]   =fxpar(hdr,'INT_TIME')
;
;
;   rec = arr_time[k] + CM + strcompress(string(arr_xc[k])) $
;     + CM + strcompress(string(arr_sigma[k]))$
;     + CM + strcompress(string(arr_xc1[k]))$
;     + CM + strcompress(string(arr_xc2[k]))$
;     + CM + strcompress(string(arr_xc_peak1[k]))$
;     + CM + strcompress(string(arr_xc_peak2[k]))$
;     + CM + strcompress(string(arr_err1[k]))$
;     + CM + strcompress(string(arr_err2[k]))

   nn=where(arr_time ne 0)
   for i = 0, n_elements(nn) - 1 do begin
     k=nn[i]
     if arr_xc_peak1[k] le 0 or arr_xc_peak2[k] le 0 or arr_xc[k] le xrange[0] or arr_xc[k] ge xrange[1] then begin
       print, 'GAUSSFIT is failed.', arr_time_s[k]
       if extot ne 1 then continue
     endif else begin
       buff1 =create_struct($
         'time_s',arr_time_s[k],$
         'time_m',arr_time[k],$
         'time_e',arr_time_e[k],$
         'xc'    ,arr_xc[k],$
         'sig'   ,arr_sigma[k],$
         'xc1'   ,arr_xc1[k],$
         'xc2'   ,arr_xc2[k],$
         'peak1' ,arr_xc_peak1[k],$
         'peak2' ,arr_xc_peak2[k],$
         'err1'  ,arr_err1[k],$
         'err2'  ,arr_err2[k],$
         'int'   ,int_time[k])
     endelse
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;if int_time[k] le 1 then buff.flag=-1
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;if buff.flag eq 0 and buff.yc2 eq -1 and buff.ipt1 eq -1 and buff.ipt2 eq -1 then continue
     if keyword_set(ret) eq 0 then ret=buff1 else ret = [ret, buff1]
   end

      
;   ; ファイル出力処理
;   out_name = time_string(arr_time[1], tformat=TFORMAT_OUT);;;;;;;;;;;;;;;byhk
;   out_path = out_dir + SL + out_name
;   openw, NUM_FILE_UNIT, out_path
;   size_arr_time = size(arr_time)
;
;   ; ヘッダ部出力
;   printf, NUM_FILE_UNIT, 'EUV-L2 Integral   = ' + l2_intg_path
;   printf, NUM_FILE_UNIT, 'EUV-L2 calc       = ' + l2_cal_path
;   printf, NUM_FILE_UNIT, 'mode              = ' + mode
;   printf, NUM_FILE_UNIT, 'xrange_min(pixel) = ' + string(xrange[0]) 
;   printf, NUM_FILE_UNIT, 'xrange_max(pixel) = ' + string(xrange[1]) 
;   printf, NUM_FILE_UNIT, 'yrange_min(pixel) = ' + string(yrange[0]) 
;   printf, NUM_FILE_UNIT, 'yrange_max(pixel) = ' + string(yrange[1]) 
;
;   ; データ部出力
;   printf, NUM_FILE_UNIT, REC_HEADER
;   for k = 0, size_arr_time[1] - 1 do begin
;      if arr_xc[k] gt xrange[1] then continue;;byHK
;      if arr_xc[k] lt xrange[0] then continue;;byHK
;      rec = arr_time[k] + CM + strcompress(string(arr_xc[k])) $
;                        + CM + strcompress(string(arr_sigma[k]))$
;                        + CM + strcompress(string(arr_xc1[k]))$
;                        + CM + strcompress(string(arr_xc2[k]))$
;                        + CM + strcompress(string(arr_xc_peak1[k]))$
;                        + CM + strcompress(string(arr_xc_peak2[k]))$
;                        + CM + strcompress(string(arr_err1[k]))$
;                        + CM + strcompress(string(arr_err2[k]))
;      printf, NUM_FILE_UNIT, rec
;   endfor
;   close, NUM_FILE_UNIT
   
   ;処理時間計算終了
   p_end_time = systime(1)
   write_log, LOG_PATH, PRO_NAME+STR_PROC_TIME+string(p_end_time - p_start_time)

   ; ログ出力
   write_log, LOG_PATH, MSG_INF02
   write_log, LOG_PATH, 'proc time:'+strcompress(p_end_time - p_start_time)

end
