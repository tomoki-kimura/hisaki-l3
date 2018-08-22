; 
; EXCEED EUV CALデータ読込
; errキーワードを指定しない場合：fitsデータを読む
; errキーワードを指定した場合：村上excelから取り出したテキストデータ読む(変換係数のエラーも読む)
;    但し、ycalは村上excel内にデータがないので,fitsデータから読む
;
; 使用例1 : CALデータをcalib_v1.0.fitから読む
; IDL> read_exeuv_cal, xcal, ycal, zcal
; 使用例2 : データアーカイブにあるCALデータ(calib_yyyymmdd_v1.0.fit)から読む
; IDL> read_exeuv_cal, xcal, ycal, zcal, date='20150101'        ;dateキーワードを指定した時は該当日付のfitsファイルを読む
; 使用例3 : データアーカイブにあるCALデータ(calib_v1.0.fit)から読む
; IDL> read_exeuv_cal, xcal, ycal, zcal, save='cal_ver1_0.asc'  ;saveキーワードを指定した時は, dir+saveのファイル名のテキストファイルにCALデータのX,Z較正値を保存する
; 使用例4　：　村上excelから取り出したテキストデータの較正テーブル読む(変換係数のエラー:zerrも読む)　/errキーワードを付けること。
;　　　　　　　　　ver=1.0の時：2013-2014シーズン用較正値　ver=1.1の時：2014-2015シーズン用較正値
;　　　　　　　　　村上excelにはY(空間方向)較正値が入っていないので、Y較正値はfitsファイル(をcalib_vX.X.fit)から読む
; IDL> read_exeuv_cal, xcal, ycal, zcal, zerr=zerr, ver=1.1, /err 
;
PRO read_exeuv_cal, xcal, ycal, zcal, dir=dir, xpos=xpos, ypos=ypos, zerr=zerr, $
                    ver=ver, err=err, save=save, date=date, silent=silent

  ; デフォルトキーワード設定（必要に応じて変更する）
  if not keyword_set(dir) then dir='/home/hisaki/l2prime/cal/z/'
  if not keyword_set(ver) then ver=1.0
  if not keyword_set(xpos) then xpos = 512
  if not keyword_set(ypos) then ypos = 512

  ;CAL fitsファイルの読込
  if keyword_set(date) then begin
    file =  dir + 'calib_'+date+'_v' + string(ver, format='(f3.1)') + '.fits'    
  endif else begin
    file =  dir + 'calib_v' + string(ver, format='(f3.1)') + '.fits'
  endelse
  if not keyword_set(silent) then print, 'read '+file 

  x_coord = mrdfits(file,1,hd,/SILENT)
  y_coord = mrdfits(file,2,hd,/SILENT)
  zcal_fits    = mrdfits(file,3,hd,/SILENT)
  m = fxpar(hd,'NAXIS1')
  n = fxpar(hd,'NAXIS2')

  if keyword_set(err) and ~keyword_set(date) then begin

    ; テキストCalファイルの読込
    file = dir + 'calib_v' + string(ver, format='(f3.1)') + '.txt'
    print, 'read '+file 
    n_hdr = 2 ; number of lines for header
    nd = 1024

    xcal = fltarr(nd)
    ycal = fltarr(nd)
    zcal0 = fltarr(nd)
    zerr0 = fltarr(nd)
    zcal = fltarr(nd,nd)
    zerr = fltarr(nd,nd)

    ; open data file
    openr, lun, file, /get_lun

    ; read header
    cline=''
    for i=0, n_hdr-1 do begin
      readf, lun, cline
    endfor

    ; read data
    ii = 0
    for i=0,nd-1 do begin
      readf, lun, cline
      vals = strsplit(cline, /extract)
      xcal[i] = float(vals[1])
      zcal0[i] = float(vals[2])
      zerr0[i] = float(vals[3])
      if zcal0[i] ne 0.0 then begin
        zerr0[i] = 0.712363042 * zerr0[i] / ( zcal0[i] * zcal0[i] )
        zcal0[i] = 0.712363042 / zcal0[i]
      endif
    endfor
  
    ; close file
    free_lun, lun
    
    for i=0,nd-1 do begin
      zcal[*,i] = zcal0
      zerr[*,i] = zerr0
    endfor

    ycal[*] = y_coord[ypos,*]

  endif else begin
  
    xcal = fltarr(m)
    ycal = fltarr(n)
  
    xcal[*] = x_coord[*,xpos]
    ycal[*] = y_coord[ypos,*]
    zcal    = zcal_fits
  
  endelse

  ; save cal table to ascii data file
  if keyword_set(save) then begin
  
    ; open file
    openw, lun, dir+save, /get_lun
    print, 'Save cal table to ' + dir + save
    printf, lun, '# Source :' + file    
    printf, lun, '# x[A] z[R/(count/min)]'
    
    ns = n_elements(xcal)
    for i=0,ns-1 do begin
      printf, lun, xcal[i], zcal[i,xpos]
    endfor
    
    free_lun, lun
  
  endif

end