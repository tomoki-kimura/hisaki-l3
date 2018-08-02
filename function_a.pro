function function_a, time,  xrange_v, yrange_v, xrange_p, yrange_p, l2_path, l2cal_path
  common aeff_block, aefffile0, data
  if not keyword_set(l2cal_path) then l2cal_path='/Users/moxon/moxonraid/spa/data/fits/euv/cal/exeuv.jupiter.mod.20.20170706.lv.02.vr.00.fits'
  if not keyword_set(l2_path)    then l2_path='/Users/moxon/moxonraid/spa/data/fits/euv/l2/exeuv.jupiter.mod.20.20170706.lv.02.vr.00.fits'
  if not keyword_set(time)       then time='2017-07-06T10:00:00'
  
  aeffarr=file_search(file_dirname(l2cal_path)+'/alpha*.csv')
  if (strlen(aeffarr))[0] eq 0 then message, 'invalid calibration file directory.'
  aefffile=aeffarr[0]; alpha.csv
  idate=long((strsplit(l2_path, '.',/ext))[4])
  foreach caeff, aeffarr do begin
    if not stregex(caeff, '[0-9]{4}_[0-9]{4}') ge 0l then continue
    cdates=long((strsplit(file_basename(caeff),'_',/ext))[1:2])
    if idate ge cdates[0] and idate le cdates[1] then begin
      aefffile=caeff
      break
    endif
  endforeach
  
  if keyword_set(aefffile0) then begin
;    message, '>>> Current calibration file is  : '+aefffile0, /info
    if aefffile0 ne aefffile or not keyword_set(data) then begin
;      message, '>>> now changed to: '+aefffile, /info
      data=read_ascii(aefffile,delim=',',comment_symbol='#')
      aefffile0=aefffile
    endif
  endif else begin
;    message, '>>> Current calibration file is  : '+aefffile, /info
    data=read_ascii(aefffile,delim=',',comment_symbol='#')
    aefffile0=aefffile    
  endelse
  
  if n_elements(data.field1) lt 8*1024 then message, '>>> invalid input effective area data (alpha.csv)'
  wave=reform(data.field1[1,*]); Angstrom
  energy=!H*!VC/(wave*1.d-10); Joule
  aeff=reform(data.field1[2,*])*10.d*10.d*!PI/1.d+4; m^2
  intarg=strupcase((strsplit(l2_path, '.',/ext))[1])
  inobs='SPRINTA'
  inframe='IAU_'+intarg
  quiet=1
  abcorr='LT+S'
  ltime=0.d
  orb=cal_orb(epoch=time, intarg=intarg, inobs=inobs, inframe=inframe, quiet=quiet, abcorr=abcorr, ltime=ltime)
  radii=orb.radii * 1.d+3; m
  
  nx=n_elements(wave)
  a=dblarr(nx)
  a[*]=0.d
  for i=0l, nx-1l do begin
    if aeff[i] le 0.d or aeff[i] eq !values.d_nan then continue
    a[i]=energy[i] * 1.d/60.d * 1.d/aeff[i]; J/count min/sec 1/m^2 = W/m^2 * min/count
    a[i]*=4.d * !PI * radii * radii /1.d+9; GW/(4pi str) * min/counts
  endfor
  x_min_p=min(xrange_p)
  x_max_p=max(xrange_p)
  a=a[x_min_p:x_max_p]
  return, a
end
