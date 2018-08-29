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
pro make_slitpos, lp=l2_intg_path, od=out_dir,pattern=pattern;, cp=l2_cal_path ;, md=mode, xr=xrange, yr=yrange
  loadct,39,/SILENT;;;HK

   on_error,2

   ; 処理時間計測開始
   p_start_time = systime(1)

   ; 定数
   TOOL_HOME       = "/home/fujitsu/work/tool"
   STR_PROC_TIME   = 'proc time : '
   KEY_NEXTEND     = 'NEXTEND'
   KEY_EXTNAME     = 'EXTNAME'
   TFORMAT_OUT     = 'yc_YYYYMMDD.csv'
   TFORMAT_LOG     = 'YYYYMMDDThhmmss'
   REC_HEADER      = '#datatime,yc,sigma'
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
   if (keyword_set(out_dir) eq FALSE) then err01 += '/' + KEYWORD_OD
;   ; モード
;   if (keyword_set(mode) eq FALSE) then err01 += '/' + KEYWORD_MD
   ; 必須項目がない場合は終了
   if(err01 ne EMP_STR) then message, MSG_ERR01 + " " + err01
    
    buff=read_csv(!dir_slit+'slit_move.csv')
    slitmove=buff.field1[where(buff.field2 ne '#')]
    n=-1
    
    if not keyword_set(pattern) then pattern='*'
    file=file_search(l2_intg_path + '/*'+pattern+'*.fits')

    tot=dblarr(1024,1024)
    ;window,1,xsize=1000,ysize=1000
    nn1='' & s1=0 & s2=0 & s3=0 & s4=0 & m=0
    
    for j=0, n_elements(file)-1 do begin
      ; 積分後L2のプライマリーヘッダから時刻エクステンション
      ; の数を取得し配列を作成
      im_prim    = mrdfits(file[j], NUM_PRIM_EXTENT, prim_hdr, /silent)
      n_intg_ext = fxpar(prim_hdr, KEY_NEXTEND)
      if (n_intg_ext eq 0) then message, MSG_ERR05 + KEY_NEXTEND

      ; イメージを取得
      im = mrdfits(file[j], 1, hdr, /silent)
      ; イメージがfltarr(1024,1024)でない場合はループを飛ばす
      size_im = size(im, /dimension)
      if (size_im[0] ne IMG_SIZE[0]) or (size_im[1] ne IMG_SIZE[1]) or n_intg_ext eq 1 then begin
        print, MSG_ERR97 + string(j)
        continue
      endif
      ; データ時刻を取得
      data_time = fxpar(hdr,'DATE-OBS')
      ; データ時刻が取得できない場合はループを飛ばす
      if (data_time eq 0) then begin
        print, MSG_ERR05 + KEY_EXTNAME
        continue
      endif

      if ck_blacklist(data_time,!dir_slit+'/blacklist.csv') eq -1 then continue
      if n eq -1 then n=ck_slitmove(data_time,slitmove)
      list_n = ck_slitmove(data_time,slitmove)
      if list_n ne n or ( j eq n_elements(file)-1) then begin
        print,'output'
        fits_write,out_dir+string(m,format='(i03)')+'.fits',tot/mean(tot)

        line=588;1025
        file_elm=strsplit(FILE_BASENAME(file[j]),/extract, '[._]')
        l2cal_path2=!l2cal_path+'calib_'+file_elm[4]+'_v1.0.fits'
        range_p = convert_value2pixel(l2cal_path2, [line,line+10], [-10,10])
        geocr  = range_p[0, 0]
;        slit_profile_b=tot[geocr:geocr+7,*]
        slit_profile_b=tot[geocr:geocr+23,*]

        slit_profile   = total(slit_profile_b,1)
        slit_profile   = slit_profile/max(slit_profile)
        slit_profile_l = slit_profile
        x1=indgen(n_elements(slit_profile))
        x2=findgen(n_elements(slit_profile)*100)/100.
        slit_profile   = INTERPOL(slit_profile, x1, x2)
        slit1 = min(where(slit_profile ge 0.5))
        slit4 = max(where(slit_profile ge 0.5))
        slit2 = min(where(slit_profile[slit1:slit4] lt 0.5))+slit1-1
        slit3 = max(where(slit_profile[slit1:slit4] lt 0.5))+slit1+1

        if (slit3-slit2)/100. lt 22. then begin
          for i=0, 3000 do begin
            if (slit3-slit2)/100. ge 22. then break
            if slit_profile[slit2] le slit_profile[slit3] then slit2=slit2-1. $
            else slit3=slit3+1.
          endfor
        endif else begin
          for i=0, 3000 do begin
            if (slit3-slit2)/100. le 22. then break
            if slit_profile[slit2] le slit_profile[slit3] then slit2=slit2+1. $
            else slit3=slit3-1.
          endfor
        endelse
        if (slit3-slit2)/100. ne 22. then begin
          print, 'err slit2-3 pos'
          stop
        endif
        
        
        buff=min(abs(slit_profile[0:slit1+1000] - slit_profile[slit2]),min_subscript)
        slit1=min_subscript
        buff=min(abs(slit_profile[slit4-1000:*] - slit_profile[slit3]),min_subscript)
        slit4=min_subscript+slit4-1000
        
        s1    = [s1,slit1/100.]
        s2    = [s2,slit2/100.]
        s3    = [s3,slit3/100.]
        s4    = [s4,slit4/100.]

        !p.multi=[0,1,2]
        plot, x2,slit_profile,xrange=[500,650],charsize=2,$
          title=string(slit1/100.,format='(f6.2)')+'  '$
               +string(slit2/100.,format='(f6.2)')+'  '$
               +string((slit3-slit2)/100.,format='(f6.2)')+'  '$
               +string(slit3/100.,format='(f6.2)')+'  '$
               +string(slit4/100.,format='(f6.2)')
        oplot,x1,slit_profile_l,psym=1
        oplot,x2,slit_profile,linestyle=1
        oplot,!x.crange,[0.5,0.5],color=fsc_color('gray')
        oplot,slit1/100.*[1,1],!y.crange,color=fsc_color('green')
        oplot,slit2/100.*[1,1],!y.crange,color=fsc_color('green')
        oplot,slit3/100.*[1,1],!y.crange,color=fsc_color('green')
        oplot,slit4/100.*[1,1],!y.crange,color=fsc_color('green')

        print,(slit3-slit2)/100.
        imgdisp_2,transpose(slit_profile_b[*,500:650]),title=slitmove[n]
        nn1=[nn1,slitmove[n]]

        write_png,out_dir+string(m,format='(i03)')+'.png',tvrd(/true)
        tot=0
        n=list_n
        m+=1
      endif
      tot+=im
      print,data_time,list_n
    endfor
    
    nn1=nn1[1:*]
    s1 =s1[1:*]
    s2 =s2[1:*]
    s3 =s3[1:*]
    s4 =s4[1:*]
    write_csv, !dir_slit+'/slit_move2.csv' ,nn1,s1,s2,s3,s4
    
    
    ;処理時間計算終了
    p_end_time = systime(1)
    write_log, LOG_PATH, PRO_NAME+STR_PROC_TIME+string(p_end_time - p_start_time)

    ; ログ出力
    write_log, LOG_PATH, MSG_INF02
    write_log, LOG_PATH, 'proc time:'+strcompress(p_end_time - p_start_time)

end
