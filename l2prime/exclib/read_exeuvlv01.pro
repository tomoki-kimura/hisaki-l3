; Load procedure for EXCEED EUV Level-1 data
;
;(IN)
;file               Level-1 file name (with path)
;cadence=cadence    if set, data cube (dcb) is generated
;
;(OUT)
;hdat=hdat          last fits header red
;julday=jd          julius day of each photon
;mjulday=mjd        modified julius day of each photon
;jdBIN=jdBIN        time information of the data cube
;TIbin=TIbin        time information of the data cube
;dcb=dcb            data cube
;image=image        N.A.
;pposw=pposw        data in Level-1 binary data (see fits header)
;pposs=pposs
;pposx=pposx
;pposy=pposy
;slstat=slstat
;object=object
;sunlit=sunlit
;bcnt1x=bcnt1x
;bcnt1y=bcnt1y
;bcnt2x=bcnt2x
;bcnt2y=bcnt2y
;calflg=calflg
;

pro read_exeuvLV01,file,hdat=hdat,julday=jd,mjulday=mjd,jdBIN=jdBIN,TIbin=TIbin,dcb=dcb,image=image $
  ,pposw=pposw,pposs=pposs,pposx=pposx,pposy=pposy,slstat=slstat,object=object,sunlit=sunlit $
  ,bcnt1x=bcnt1x,bcnt1y=bcnt1y,bcnt2x=bcnt2x,bcnt2y=bcnt2y,calflg=calflg $
  ,cadence=cadence, err_cnt=err_cnt

err_cnt = 0

;file = 'D:\data\exceed\fits\euv\l1\exeuv.jupiter.mod.03.20131229.lv.01.vr.00.fits'
if not keyword_set(file) then file='C:\cygwin\home\ft\EXCEED\EUV_DATA\l1\exeuv.jupiter.mod.03.20140101.lv.01.vr.00.fits'
print,file
fits_read,file,im,hdat,exten_no=1
image=im
fits_read,file,dat,hdat,extname='Event';,exten_no=2
N = sxpar(hdat,'NAXIS2')
year   = fix(reverse(dat[0:1,*]),0,N)      ;TYPE1
doy    = fix(reverse(dat[2:3,*]),0,N)      ;TYPE2
time   = float(reverse(dat[4:7,*]),0,N)    ;TYPE3
pposw  = float(reverse(dat[8:11,*]),0,N)  ;TYPE4
pposs  = float(reverse(dat[12:15,*]),0,N) ;TYPE5
pposx  = float(reverse(dat[16:19,*]),0,N) ;TYPE6
pposy  = float(reverse(dat[20:23,*]),0,N) ;TYPE7
slstat = dat[24,*]                       ;TYPE8 slit status
quart1 = float(reverse(dat[25:28,*]),0,N);TYPE9
quart2 = float(reverse(dat[29:32,*]),0,N);TYPE10
quart3 = float(reverse(dat[33:36,*]),0,N);TYPE11
quart4 = float(reverse(dat[37:40,*]),0,N);TYPE12
method = string(dat[41:43,*])            ;TYPE13
object = string(dat[44:50,*])            ;TYPE14
bcnt1x = double(reverse(dat[51:58,*]),0,N);TYPE15
bcnt1y = double(reverse(dat[59:66,*]),0,N);TYPE16
bcnt2x = double(reverse(dat[67:74,*]),0,N);TYPE17
bcnt2y = double(reverse(dat[75:82,*]),0,N);TYPE18
sunlit = dat[83,*] ;0:sunlit 0:shadow    ;TYPE19
calflg = string(dat[84:86,*])            ;TYPE20
submod = fix(reverse(dat[87:88,*]),0,N)  ;TYPE21
submst = fix(reverse(dat[89:90,*]),0,N)  ;TYPE22
eclsts = string(dat[91:93,*]) ;TYPE23
sttsts = string(dat[94:96,*]) ;TYPE24

jd = julday(1,1,year,0,0,0) + DOY-1 + time/86400d
mjd= jd-2400000.5d

;img=lonarr(1024,1024)
;pposy=pposy>0<1023
;pposx=pposx>0<1023
;for i=0L,N-1 do img[pposx[i]+0.5,pposy[i]+0.5]=img[pposx[i]+0.5,pposy[i]+0.5]+1

;imgdisp,img,range=[0,10],roi=[0,1023,378+128,640],/color,aspect=.5
;imgdisp,im-img,range=[-1,1]*5.,roi=[0,1023,378+128,640],/color,aspect=.5

if keyword_set(cadence) then begin
  tick = long64(JD*(86400d/cadence)+0.5)  ;
  tn = max(tick)-min(tick)
  TIbin = min(tick)+lindgen(tn+1)
  JDbin = (double(TIbin)*cadence)/86400d

  dcb=lonarr(1024,1024,TN)
  for t=0L,TN-1 do begin
    idx=where(tick ge TIbin[t] and tick lt TIbin[t+1])
    img=lonarr(1024,1024)
    if idx[0] ne -1 then begin
      for i=0L,N_elements(idx)-1 do begin
        if pposx[idx[i]] ge 0 and pposx[idx[i]] le 1023 and pposy[idx[i]] ge 0 and pposy[idx[i]] le 1023 then begin
          img[pposx[idx[i]]+0.5,pposy[idx[i]]+0.5]=img[pposx[idx[i]]+0.5,pposy[idx[i]]+0.5]+1L
        endif else begin
          err_cnt ++
        endelse
      endfor
    endif
    dcb[*,*,t]=img
;  !P.multi=[0,1,2]
;  roi=[0,1023,378+128,640]
;  imgdisp,im,range=[0,10],roi=roi,/color,aspect=0.5,margin=0.05
;  if total(img) ne 0 then $
;    imgdisp,img,tit=datecnv(jdbin[t],/UT)+' --- '+datecnv(jdbin[t+1],/UT)+'  TTL='+strtrim(total(img),2),aspect=0.5,roi=roi $
;      ,range=[0,10],/color,margin=0.05
  endfor

endif

end