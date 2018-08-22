pro read_exeuvLV00,file,hdat=hdat,julday=jd,mjulday=mjd,image=image $
  ,shift_euv_ti=shift_euv_ti,euv_ti_ph=euv_ti_ph,cha=cha,chb=chb,chc=chc,chd=chd,smu_ti=smu_ti,euv_ti_hk=euv_ti_hk $
  ,quart1=quart1,quart2=quart2,quart3=quart3,quart4=quart4,method=method,object=object $
  ,bcnt1x=bcnt1x,bcnt1y=bcnt1y,bcnt2x=bcnt2x,bcnt2y=bcnt2y $
  ,slitsel=slitsel,slitpls=slitpls,sati1=sati1,sath1=sath1,sati2=sati2,sath2=sath2 $
  ,calflg=calflg,submod=submod,submst=submst,eclsts=eclsts,sttsts=sttsts $
  ,tmpama=tmpama,tmpamb=tmpamb,tmpacd=tmpacd,euvhvm=euvhvm

;file = 'C:\cygwin\home\ft\EXCEED\EUV_DATA\l0\exeuv.time.20131119000000-20131119235959.lv.00.vr.00_1.fits'
if not keyword_set(file) then file='C:\cygwin\home\ft\EXCEED\EUV_DATA\l0\exeuv.time.20131119000000-20131119235959.lv.00.vr.00_1.fits'
print,file

; read integrated image
fits_read,file,im,hdat,exten_no=1
image=im

;; read EUV-HK
;fits_read,file,dat,hdat,extname='HK_EUV_FULL'
;M = sxpar(hdat,'NAXIS2')
;ti  = ulong(reverse(dat[0:3,*]),0,M) ;TYPE1
;mdp_ti  = ulong(reverse(dat[4:7,*]),0,M) ;TYPE2
;fov_ti_hk  = ulong(reverse(dat[8:11,*]),0,M) ;TYPE3

; read Event
fits_read,file,dat,hdat,extname='Event'
N = sxpar(hdat,'NAXIS2')
shift_euv_ti  = ulong(reverse(dat[0:3,*]),0,N) ;TYPE1
euv_ti_ph = ulong(reverse(dat[4:7,*]),0,N)   ;TYPE2
cha       = uint(reverse(dat[8:9,*]),0,N)    ;TYPE3
chb       = uint(reverse(dat[10:11,*]),0,N)  ;TYPE4
chc       = uint(reverse(dat[12:13,*]),0,N)  ;TYPE5
chd       = uint(reverse(dat[14:15,*]),0,N)  ;TYPE6
smu_ti    = ulong(reverse(dat[16:19,*]),0,N) ;TYPE7
euv_ti_hk = ulong(reverse(dat[20:23,*]),0,N) ;TYPE8
quart1    = float(reverse(dat[24:27,*]),0,N) ;TYPE9
quart2    = float(reverse(dat[28:31,*]),0,N) ;TYPE10
quart3    = float(reverse(dat[32:35,*]),0,N) ;TYPE11
quart4    = float(reverse(dat[36:39,*]),0,N) ;TYPE12
method    = string(dat[40:42,*])             ;TYPE13
object    = string(dat[43:49,*])             ;TYPE14
bcnt1x    = float(reverse(dat[50:57,*]),0,N) ;TYPE15
bcnt1y    = float(reverse(dat[58:65,*]),0,N) ;TYPE16
bcnt2x    = float(reverse(dat[66:73,*]),0,N) ;TYPE17
bcnt2y    = float(reverse(dat[74:81,*]),0,N) ;TYPE18
slitsel   = fix(reverse(dat[82:83,*]),0,N)   ;TYPE19
slitpls   = fix(reverse(dat[84:85,*]),0,N)   ;TYPE20
sati1     = fix(reverse(dat[86:87,*]),0,N)   ;TYPE21
sath1     = fix(reverse(dat[88:89,*]),0,N)   ;TYPE22
sati2     = fix(reverse(dat[90:91,*]),0,N)   ;TYPE23
sath2     = fix(reverse(dat[92:93,*]),0,N)   ;TYPE24
calflg    = string(dat[94:96,*])             ;TYPE25
submod    = fix(reverse(dat[97:98,*]),0,N)   ;TYPE26
submst    = fix(reverse(dat[99:100,*]),0,N)  ;TYPE27
eclsts    = string(dat[101:103,*])           ;TYPE28
sttsts    = string(dat[104:106,*])           ;TYPE29
tmpama    = fix(reverse(dat[107:108,*]),0,N) ;TYPE30
tmpamb    = fix(reverse(dat[109:110,*]),0,N) ;TYPE31
tmpacd    = fix(reverse(dat[111:112,*]),0,N) ;TYPE32
euvhvm    = fix(reverse(dat[113:114,*]),0,N) ;TYPE33

;jd = julday(1,1,year,0,0,0) + DOY-1 + time/86400d
;mjd= jd-2400000.5d

end