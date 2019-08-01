pro make_peak_frommax, data_time,  im, l2_cal_path, xrange, yrange, slit_profile_s, slit1, slit2, slit3, slit4, ret=ret
  range_p = convert_value2pixel(l2_cal_path, xrange, [-1,1])
  xrange  = range_p[*, 0]

  ; イメージを指定領域に切り取る
  im_target      = im[xrange[0]:xrange[1],yrange[0]:yrange[1]]
  size_im_target = size(im_target, /dimension)

  ; 波長方向の積分
  im_y_intg = fltarr(size_im_target[1])
  for j = 0, size_im_target[0] - 1 do begin
    im_y_intg = im_y_intg + transpose(im_target[j,*])
  endfor

  y_range    = [yrange[0]:yrange[1]]
  r1=min(where(y_range ge slit1))
  r2=max(where(y_range le slit2))
  r3=min(where(y_range ge slit3))
  r4=max(where(y_range le slit4))

  im_y_intg=smooth(im_y_intg,4)
  max1=max(im_y_intg[r1:r2],sub)
  rms1=stddev(im_y_intg[r1:r2])
  sub=sub+r1
  peakpos1=sub+yrange[0]
  if sub-5 le 0 then sub=5
  ave1=mean(im_y_intg[sub-5:sub+5])
  ;  thr1=ave1+rms1
  thr1=mean(im_y_intg[r2:r3])+stddev(im_y_intg[r2:r3])
  max2=max(im_y_intg[r3:r4],sub)
  sub=sub+r3
  rms2=stddev(im_y_intg[r3:r4])
  peakpos2=sub+yrange[0]
  if sub +5 ge n_elements(im_y_intg)-1 then sub= n_elements(im_y_intg)-1-5
  ave2=mean(im_y_intg[sub-5:sub+5])
  thr2=thr1
  center=(peakpos1+peakpos2)/2.
  
  pscale=4.1 ;[asec/pix]
  intarg='JUPITER'
  inobs='SPRINTA'
  inframe='J2000'
  quiet=1
  abcorr='LT+S'
  ltime=0.d
  orb=cal_orb(epoch=data_time, intarg=intarg, inobs=inobs, inframe=inframe, quiet=quiet, abcorr=abcorr, ltime=ltime)
  toruspos=orb.appdia / 2. * 5.9 / pscale ;torus position [pix]
  
  if abs(peakpos1 - (slit1+slit2)/2.) le abs(peakpos2 - (slit3+slit4)/2.) then begin
    center2 = peakpos1 + toruspos
  endif else begin
    center2 = peakpos2 - toruspos
  endelse
  
  imgdisp_2,im,roi=[xrange[0],xrange[1],yrange[0]-30,yrange[1]+30],title=data_time,charsize=2
  oplot,!x.crange,[1,1]*yrange[0]
  oplot,!x.crange,[1,1]*yrange[1]
  oplot,!x.crange,[1,1]*peakpos1,color=fsc_color('red'),linestyle=1
  oplot,!x.crange,[1,1]*peakpos2,color=fsc_color('red'),linestyle=1
  oplot,!x.crange,[1,1]*slit1,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit2,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit3,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit4,color=fsc_color('green'),linestyle=1
  imgdisp_2,im,roi=[xrange[0],xrange[1],yrange[0]-30,yrange[1]+30],title=data_time,charsize=2,range=0.9
  oplot,!x.crange,[1,1]*yrange[0]
  oplot,!x.crange,[1,1]*yrange[1]
  oplot,!x.crange,[1,1]*peakpos1,color=fsc_color('red'),linestyle=1
  oplot,!x.crange,[1,1]*peakpos2,color=fsc_color('red'),linestyle=1
  oplot,!x.crange,[1,1]*slit1,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit2,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit3,color=fsc_color('green'),linestyle=1
  oplot,!x.crange,[1,1]*slit4,color=fsc_color('green'),linestyle=1
  plot, slit_profile_s,xrange=[yrange[0]-10,yrange[1]+10],charsize=2,/noerase
  oplot,!x.crange,[0.5,0.5],color=fsc_color('gray')
  oplot,slit1*[1,1],!y.crange,color=fsc_color('green')
  oplot,slit2*[1,1],!y.crange,color=fsc_color('green')
  oplot,slit3*[1,1],!y.crange,color=fsc_color('green')
  oplot,slit4*[1,1],!y.crange,color=fsc_color('green')
  oplot,peakpos1*[1,1],!y.crange,color=fsc_color('red'),linestyle=1
  oplot,peakpos2*[1,1],!y.crange,color=fsc_color('red'),linestyle=1
  oplot,center*[1,1],!y.crange,color=fsc_color('Orange'),linestyle=2
  ;oplot,center2*[1,1],!y.crange,color=fsc_color('Blue'),linestyle=2
  plot, y_range,im_y_intg,xrange=[yrange[0]-10,yrange[1]+10],charsize=2 $
    ,title='cent' +string(center,format='(f6.1)')$
;    +', cent2' +string(center2,format='(f6.1)')$
    +', max1' +string(max1,format='(f6.3)')$
    +', ave1' +string(ave1,format='(f6.3)')$
    +', thr1' +string(thr1,format='(f6.3)')$
    +', max2' +string(max2,format='(f6.3)')$
    +', ave2' +string(ave2,format='(f6.3)')$
    +', thr2' +string(thr2,format='(f6.3)')$
    +', widt' +string(peakpos2-peakpos1,format='(i3)')

  ;  if center le slit2 or center ge slit3 then begin
  ;    print, 'outside 20asec',data_time
  ;    xyouts,900,500,'x',charsize=2,/device
  ;    ret=-1
  ;  endif
  d=4.5
  if peakpos1 le slit1+d or peakpos1 ge slit2-d then begin
    ;print, 'peakpos1 near edge',data_time
    xyouts,900,550,'pos1 x',charsize=1,/device
    center   = -1
    peakpos1 = -1
  endif
  if peakpos2 le slit3+d or peakpos2 ge slit4-d then begin
    ;print, 'peakpos1 near edge',data_time
    xyouts,900,600,'pos2 x',charsize=1,/device
    center   = -1
    peakpos2 = -1
  endif
  if ave1 le thr1 or ave2 le thr2 then begin
    ;print, 'ave < thr ',data_time
    xyouts,900,500,'x t',charsize=1,/device
    center   = -1
    peakpos1 = -1
    peakpos2 = -1
  endif
  if peakpos2-peakpos1 ge toruspos*1.2*2 or peakpos2-peakpos1 le toruspos*0.8*2 then begin
    if center ne -1 then begin
      ;print, 'peakpos',peakpos2-peakpos1,toruspos*2
      xyouts,900,500,'x p',charsize=1,/device
      center   = -1
      peakpos1 = -1
      peakpos2 = -1
    endif
  endif
  ret=[center, center2, peakpos1, peakpos2]
end



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
pro make_peak_list_gauss, lp=l2_intg_path, od=out_dir, md=mode, cp=l2_cal_path, xr=xrange, yr=yrange, ret=ret
  loadct,39,/SILENT;;;HK
  !p.multi=[0,1,3]

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
;   logdir  = log_setting() ;ログファイルを出力するディレクトリ名を取得する
;   LOG_NAME = PRO_NAME + get_local_time(TFORMAT_LOG) + FILE_TYPE_LOG
;   LOG_PATH = logdir + '/' + LOG_NAME
;
;   ; ログ出力
;   write_log, LOG_PATH, MSG_INF01
;
;   ; エラーのキャッチ
;   err_flg = 0
;   catch, err_flg
;   if err_flg ne 0 then begin
;      msg = !ERROR_STATE.MSG
;      catch, /cancel
;      write_log, LOG_PATH, msg
;      write_log, LOG_PATH, MSG_INF02
;      print, msg
;      return
;   endif

   ; 必須項目チェック
   err01 = EMP_STR
   ; 積分後EUV-L2データファイルパス
   if (keyword_set(l2_intg_path) eq FALSE) then err01 += '/' + KEYWORD_IP
   ; 出力ディレクトリ
;   if (keyword_set(out_dir) eq FALSE) then err01 += '/' + KEYWORD_OD
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
   
   ;------------------------------hk
   if n_intg_ext eq 0 then begin
    print,'no extension'
    ret  =create_struct('time_s',-1,'time_m',-1,'time_e',-1,'yc',-1,'peak',-1,$
      'fwhm',-1,'sig',-1,'slit1',-1,'slit2',-1,'slit3',-1,'slit4',-1)
    return
   endif
   
   
   ; 格納用の配列を作成
   arr_time   = strarr(n_intg_ext)
   arr_time_s = strarr(n_intg_ext)
   arr_time_e = strarr(n_intg_ext)
   arr_yc     = fltarr(n_intg_ext)
   arr_yc_peak= fltarr(n_intg_ext)
   arr_fwhm   = fltarr(n_intg_ext)
   arr_sigma  = fltarr(n_intg_ext)
   arr_thrd   = fltarr(n_intg_ext)
   int_time   = fltarr(n_intg_ext)
   arr_yc2    = fltarr(n_intg_ext)
   arr_yc3    = fltarr(n_intg_ext)
   iptpos1    = fltarr(n_intg_ext)
   iptpos2    = fltarr(n_intg_ext)

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
   
   buff=read_csv(!DIR_SLIT+'\slit_move2.csv')
   ;;;;;;from KOGA result
;   dd=buff.field1
;   s1=buff.field2 + 0.3
;   s2=buff.field3 + 3.0
;   s3=buff.field4 + 3.0
;   s4=buff.field5 + 5.0
   ;;;;;;no offset for lp2 tsuchiya calibrated
   dd=buff.field1
   s1=buff.field2
   s2=buff.field3
   s3=buff.field4
   s4=buff.field5
   
   
   tot=mrdfits(l2_intg_path, 1, hdr_tot, /silent)
   extot=0;1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
   
   ; 積分エクステンション毎にガウシアンフィッティング
   for i = 2, n_intg_ext + 1 do begin;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
   ;for i = 2, 2 do begin

      ; イメージを取得
      im = mrdfits(l2_intg_path, i, hdr, /silent);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
      if extot eq 1 then im=float(tot) ;byHK
      im2=im
      
      ; イメージがfltarr(1024,1024)でない場合はループを飛ばす
      size_im = size(im, /dimension)
      if (size_im[0] ne IMG_SIZE[0]) or (size_im[1] ne IMG_SIZE[1])$
           or (size(im,/tname) ne TYPE_FLT)  then begin
         print, MSG_ERR97 + i
         continue
      endif
      
      ;;;mask geocorona
      im=remove_geocor(im,!geocorona_list,l2_cal_path)
      
      ;;;mask torus
      im=remove_geocor(im,!iptbat_list,l2_cal_path)
            
      ; イメージを指定領域に切り取る
      im_target      = im[xrange[0]:xrange[1],yrange[0]:yrange[1]]
      size_im_target = size(im_target, /dimension)

      ; 波長方向の積分
      im_y_intg = fltarr(size_im_target[1])
      for j = 0, size_im_target[0] - 1 do begin
         im_y_intg = im_y_intg + transpose(im_target[j,*])
      endfor
     
      ; ガウシアンフィッティング
      y_range    = [yrange[0]:yrange[1]]
      yfit       = GAUSSFIT(y_range, im_y_intg, coeff, NTERMS=4, YERROR=YERROR);;;byHK
      
      ; GAUSSFITが失敗した場合はループを飛ばす
      if (size(coeff, /dimension) ne 4) then begin;;;byHK
         print, MSG_ERR96 + i
         continue
      endif 
      
      ; データ時刻を取得
      ;data_time = fxpar(hdr,KEY_EXTNAME)
;      data_time_s = fxpar(hdr_tot,'DATE-OBS');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
;      data_time_e = fxpar(hdr_tot,'DATE-END');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
;      data_time_s = fxpar(hdr,'DATE-OBS');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
;      data_time_e = fxpar(hdr,'DATE-END');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
      data_time_s = fxpar(hdr,'EFFEXP01');;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0227
      effextarr='EFFEXP'+string(indgen(99)+1,format='(i02)')
      for l=0, n_elements(effextarr)-1 do begin
        if fxpar(hdr,effextarr[l]) eq 0 then break
      endfor
      data_time_e = fxpar(hdr,effextarr[l-1])
      data_time   = time_string((time_double(data_time_s) + $
                                  time_double(data_time_e))/2.)
      data_time   = repstr(data_time,'/','T')
;      data_time   = data_time_s

      if ck_blacklist(data_time,!BLACK_LIST) eq -1 then continue
      n1=ck_slitmove(data_time, dd)


      ; データ時刻が取得できない場合はループを飛ばす
      if (data_time eq 0) then begin
         print, MSG_ERR05 + KEY_EXTNAME
         continue
      endif

      ; 値を配列に格納(データ時刻、ピーク位置、σ)
      k  = i - 2
      arr_time[k]   = data_time
      arr_time_s[k] = data_time_s
      arr_time_e[k] = data_time_e
      arr_yc_peak[k]= coeff[0]
      arr_yc[k]     = coeff[1]; + 1 ;配列番号=>pixel番号
      arr_fwhm[k]   = 2*coeff[2]*sqrt(2*alog(2))
      arr_sigma[k]  = YERROR ;coeff[2]
      arr_thrd[k]   = 3.5*arr_sigma[k]
      int_time[k]   =fxpar(hdr,'INT_TIME')
      
      slit1=s1[n1]
      slit2=s2[n1]
      slit3=s3[n1]
      slit4=s4[n1]
      
      fits_read,!DIR_SLIT+'\'+string(n1,format='(i03)')+'.fits',data_slit,header
      line=1025;588
      range_p = convert_value2pixel(l2_cal_path, [line,line+10], [-10,10])
      geocr  = range_p[0, 0]
      slit_profile_b=data_slit[geocr:geocr+7,*]
      slit_profile   = total(slit_profile_b,1)
      slit_profile   = slit_profile/max(smooth(slit_profile,7))
      slit_profile_s = smooth(slit_profile,6)/max(smooth(slit_profile,6))      
      ;;;byHK
      imgdisp_2,im,roi=[xrange[0],xrange[1],yrange[0]-30,yrange[1]+30],title=data_time,charsize=2
      oplot,!x.crange,[1,1]*yrange[0]
      oplot,!x.crange,[1,1]*yrange[1]
      oplot,!x.crange,[1,1]*coeff[1],color=fsc_color('red'),linestyle=1
      oplot,!x.crange,[1,1]*slit1,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit2,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit3,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit4,color=fsc_color('green'),linestyle=1
      imgdisp_2,im2,roi=[xrange[0],xrange[1],yrange[0]-30,yrange[1]+30],title=data_time,charsize=2,range=0.9
      oplot,!x.crange,[1,1]*yrange[0]
      oplot,!x.crange,[1,1]*yrange[1]
      oplot,!x.crange,[1,1]*coeff[1],color=fsc_color('red'),linestyle=1
      oplot,!x.crange,[1,1]*slit1,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit2,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit3,color=fsc_color('green'),linestyle=1
      oplot,!x.crange,[1,1]*slit4,color=fsc_color('green'),linestyle=1
      plot, slit_profile_s,xrange=[yrange[0]-10,yrange[1]+10],charsize=2,/noerase
      oplot,slit_profile,psym=1
      oplot,!x.crange,[0.5,0.5],color=fsc_color('gray')
      oplot,slit1*[1,1],!y.crange,color=fsc_color('green')
      oplot,slit2*[1,1],!y.crange,color=fsc_color('green')
      oplot,slit3*[1,1],!y.crange,color=fsc_color('green')
      oplot,slit4*[1,1],!y.crange,color=fsc_color('green')
      oplot,coeff[1]*[1,1],!y.crange,color=fsc_color('red'),linestyle=1
      plot, y_range,im_y_intg,xrange=[yrange[0]-10,yrange[1]+10],charsize=2 $
        ,title=' slit2'+string(slit2,format='(f6.1)')$
              +', width'+string(slit3-slit2,format='(f6.1)')$
              +', slit3'+string(slit3,format='(f6.1)') $
              +', yc '  +string(arr_yc[k],format='(f5.1)')$
              +', fwhm' +string(arr_fwhm[k],format='(f5.1)')$
              +', peak' +string(arr_yc_peak[k],format='(f5.1)')$
              +', 3sig'  +string(arr_thrd[k],format='(f5.1)')
      oplot,y_range,yfit,color=fsc_color('red')
      oplot,[1,1]*yrange[0],!y.crange
      oplot,[1,1]*yrange[1],!y.crange
      path_elm=strsplit(l2_intg_path,/extract, '\')
      if arr_yc_peak[k] le 0 or arr_yc[k] le yrange[0] or arr_yc[k] ge yrange[1] or $
         arr_fwhm[k] ge 10. or arr_fwhm[k] le 3 or arr_yc_peak[k] le arr_thrd[k] then $
           xyouts,900,500,'x',charsize=2,/device
      xyouts,900,460,'Int '+strtrim(string(fix(int_time[k])),2),charsize=1,/device
      write_png, !log_place+'/plot_yc_'+path_elm[n_elements(path_elm)-1]+string(i,format='(i03)')+'.png', TVRD(/TRUE)
      if arr_yc_peak[k] le 0 or arr_yc[k] le yrange[0] or arr_yc[k] ge yrange[1] or $
        arr_fwhm[k] ge 20. or arr_fwhm[k] le 1 or arr_yc_peak[k] le arr_thrd[k] then begin
        print, 'GAUSSFIT is failed.', arr_time_s[k]
        if arr_fwhm[k] ge 10. then print, 'FWHM ge 10'
        if arr_fwhm[k] le 1   then print, 'FWHM le 3'
        if arr_yc_peak[k] le arr_thrd[k] then print, 'peak < 3rms'
      endif
      if int_time[k] le 0 then print,data_time,'int_time = 3m'
      make_peak_frommax, data_time, im, l2_cal_path, [630,920], yrange, slit_profile_s, slit1, slit2, slit3, slit4, ret=ret2 ;[650,770]
      arr_yc2[k]=ret2[0]
      arr_yc3[k]=0;ret2[1]
      iptpos1[k]=ret2[2]
      iptpos2[k]=ret2[3]
      write_png, !log_place+'/plot_yc_'+path_elm[n_elements(path_elm)-1]+string(i,format='(i03)')+'_2.png', TVRD(/TRUE)

      if extot eq 1 then break      
   endfor

;   ; ファイル出力処理
;   out_name = time_string(arr_time[1], tformat=TFORMAT_OUT);;;;;;;byHK
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
;      if arr_yc[k] gt yrange[1] then continue
;      if arr_yc[k] lt yrange[0] then continue
;      rec = arr_time[k] + CM + strcompress(string(arr_yc[k])) $
;                        + CM + strcompress(string(arr_sigma[k])) $
;                        + CM + strcompress(string(arr_yc_peak[k])) $
;                      + CM + strcompress(string(slit1))$
;                      + CM + strcompress(string(slit2))$
;                      + CM + strcompress(string(slit3))$
;                      + CM + strcompress(string(slit4))
;      printf, NUM_FILE_UNIT, rec
;   endfor
;   close, NUM_FILE_UNIT
   
   
   ;Fitting error => return -1
   if (where(arr_yc ne 0))[0] eq -1 then begin
;       ret  =create_struct('time_s',-1,'time_m',-1,'time_e',-1,'yc',-1,'peak',-1,$
;                    'fwhm',-1,'sig',-1,'slit1',-1,'slit2',-1,'slit3',-1,'slit4',-1)
     return
   endif

   nn=where(arr_time ne 0)
   for i = 0, n_elements(nn) - 1 do begin
     k=nn[i]
     if arr_yc_peak[k] le 0 or arr_yc[k] le yrange[0] or arr_yc[k] ge yrange[1] or $
        arr_fwhm[k] ge 10. or arr_fwhm[k] le 3 or arr_yc_peak[k] le arr_thrd[k] then begin
       ;print, 'GAUSSFIT is failed.', arr_time_s[k]
       ;if extot ne 1 then continue
       buff =create_struct('time_s',arr_time_s[k],$
                           'time_m',arr_time[k],$
                           'time_e',arr_time_e[k],$
                           'yc'    ,arr_yc[k]  ,$
                           'peak'  ,arr_yc_peak[k],$
                           'fwhm'  ,arr_fwhm[k],$
                           'sig'   ,arr_sigma[k],$
                           'slit1' ,slit1,$
                           'slit2' ,slit2,$
                           'slit3' ,slit3,$
                           'slit4' ,slit4,$
                           'flag'  ,0,$
                           'yc2'   ,arr_yc2[k],$
                           'yc3'   ,arr_yc3[k],$
                           'ipt1'  ,iptpos1[k],$
                           'ipt2'  ,iptpos2[k])

;       buff  =create_struct('time_s',-1,'time_m',-1,'time_e',-1,'yc',-1,'peak',-1,$
;                    'fwhm',-1,'sig',-1,'slit1',-1,'slit2',-1,'slit3',-1,'slit4',-1)
     endif else begin
       buff =create_struct('time_s',arr_time_s[k],$
                           'time_m',arr_time[k],$
                           'time_e',arr_time_e[k],$
                           'yc'    ,arr_yc[k]  ,$
                           'peak'  ,arr_yc_peak[k],$
                           'fwhm'  ,arr_fwhm[k],$
                           'sig'   ,arr_sigma[k],$
                           'slit1' ,slit1,$
                           'slit2' ,slit2,$
                           'slit3' ,slit3,$
                           'slit4' ,slit4,$
                           'flag'  ,1,$
                           'yc2'   ,arr_yc2[k],$
                           'yc3'   ,arr_yc3[k],$
                           'ipt1'  ,iptpos1[k],$
                           'ipt2'  ,iptpos2[k])
     endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;if int_time[k] le 1 then buff.flag=-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;if buff.flag eq 0 and buff.yc2 eq -1 and buff.ipt1 eq -1 and buff.ipt2 eq -1 then continue
     if keyword_set(ret) eq 0 then ret=buff else ret = [ret, buff]
   end
   
   ;処理時間計算終了
   p_end_time = systime(1)
;   write_log, LOG_PATH, PRO_NAME+STR_PROC_TIME+string(p_end_time - p_start_time)

   ; ログ出力
;   write_log, LOG_PATH, MSG_INF02
;   write_log, LOG_PATH, 'proc time:'+strcompress(p_end_time - p_start_time)
end

