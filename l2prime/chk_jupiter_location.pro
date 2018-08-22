pro chk_jupiter_location, im_cmp=im_cmp, blk_arr=blk_arr, const=const, jupypix=jupypix, xspan=xspan, xcal=xcal, ycal=ycal, debug=debug
  
    if not keyword_set(xspan)  then xspan  = [1115.,1125.]; angstrom
  ;  if not keyword_set(xspan)  then xspan  = [1111.,1120.]; angstrom
  ;  if not keyword_set(xspan)  then xspan  = [1200,1232]; angstrom
    s3span = [ [0, 360], [0, 360] ]
  ;  s3span = [ [197, 217], [197, 217] ]
    xspansp=[1100.,1150.]
  
  
    ; composit image
    im = dblarr(const.m,const.n) ; composit image
    na = 0      ; number of image compositted
    im_l2=im_cmp
  
    n=n_elements(blk_arr[*])
    SLONPSC=dblarr(n)
    SLONPSC[*]=blk_arr[*].lon_j
    SLONPSC = ( SLONPSC + 360.0 ) mod 360.0
    
    if n gt 1l then begin
    for i=0L, n-1L do begin
      if ( ( SLONPSC[i] ge s3span[0,0] and SLONPSC[i] le s3span[1,0] ) or ( SLONPSC[i] ge s3span[0,1] and SLONPSC[i] le s3span[1,1] ) ) then begin
        im[*,*] += im_l2[*,*,i]
        na ++
      endif
    endfor
    endif else begin
      im[*,*]=im_l2[*,*]
    endelse
    total=na
  
  
    ; radial profile
    res = min(abs(xcal-xspan[0]), imin1)
    res = min(abs(xcal-xspan[1]), imin2)
    prof = fltarr(1024)
    if imin1 gt imin2 then begin
      buf=imin1
      imin1=imin2
      imin2=buf
    endif
    
    iaurora=where(xcal ge min(xspansp) and xcal le max(xspansp))
    
    for i = 0L, 1023L do begin
      prof[i] = total(im[iaurora,i])
  ;    prof[i] = total(im[imin1:imin2,i])
    endfor
    prof_err = sqrt(prof)
    
    if keyword_set(total) then begin
      prof/=(total*60.d); counts/s
      prof_err/=(total*60.d); counts/s
    endif
    
    ; spatial integration
;    pori=574l
;    spoff=80l

    pori=512l
    spoff=511l


    ret=max(prof[pori-spoff:pori+spoff], cpori)
    pori=cpori + pori-spoff
    spoff=4l
  ;  spoff=20l
    if pori - spoff lt 0l then pori=spoff
    if pori + spoff gt 1023l then pori=1023l -spoff
  
  ;  res = max(prof[pori-spoff:pori+spoff], jmax1)
    
    ;fitting
    ycalsp = ycal[pori-spoff:pori+spoff]
    profsp = prof[pori-spoff:pori+spoff]
    prof_esp = prof_err[pori-spoff:pori+spoff]
    pmaxsp = max(profsp, ipmaxsp)
    pminsp = min(profsp, ipminsp)
    a3sp = mean(prof[pori-100l:pori-80l])
  ;  a3sp = ( profsp[0] + profsp[n_elements(profsp)-1] ) * 0.5
    a0sp = prof[pori]
  ;  a0sp = pmaxsp-a3sp
    a1sp = ycal[pori]
    a2sp = 10.d; arcsec
  ;  a2sp = 1.0
    a4sp = 0.0
    estsp = [ a0sp, a1sp, a2sp, a3sp, a4sp ]
    coefsp=dblarr(5)
    ressp = gaussfit( ycalsp, profsp, coefsp, estimates=estsp, nterms=5, sigma=sgmsp )
  ;  res=min(abs(ycal-coefsp[1]),jmax1)
  ;  jmax1=pori-spoff+jmax1
  ;jmax1=pori
    foreach ele, coefsp[1] do begin
      if finite(ele) eq 0 then begin
        message, 'invalid fitting output coefsp', /info
        jupypix=-1l
        return
      endif
    endforeach
    ycalsp=interpol(ycalsp,1000,/spline)
    ressp=interpol(ressp,1000,/spline)
    
    ii=where(abs(ressp - max(ressp)) eq min(abs(ressp - max(ressp))) )
    if ii[0] ne -1l and n_elements(ii) eq 1l then coefsp[1]=ycalsp[ii]
    ;coefsp[1]=ycalsp[where(abs(ressp - max(ressp)) eq min(abs(ressp - max(ressp))) )]
    
    res=min(abs(prof-max(ressp)),jmax1)
    if jmax1 - spoff lt 0l then jmax1=spoff
    if jmax1 + spoff gt 1023l then jmax1=1023l -spoff
  
    prof_wl = fltarr(1024)
    prof_sky=prof_wl
    for i = 0L, 1023L do begin
      prof_wl[i] = total(im[i,jmax1-spoff:jmax1+spoff])
      prof_sky[i] = total(im[i,jmax1-spoff-30l>0l:jmax1+spoff-30l>0l])
    endfor  
    prof_wl_err = sqrt(prof_wl)
    prof_sky_err = sqrt(prof_sky)
  
    if keyword_set(total) then begin
      prof_wl/=(total*60.d); counts/s
      prof_sky/=(total*60.d); counts/s
      prof_wl_err/=(total*60.d); counts/s
      prof_sky_err/=(total*60.d); counts/s
    endif
    
    ; fit spectral profile
    xcal0 = xcal[imin1:imin2]
    prof0 = prof_wl[imin1:imin2]
    prof0_sky = prof_sky[imin1:imin2]
    prof_e0 = prof_wl_err[imin1:imin2]
    prof_e0_sky = prof_sky_err[imin1:imin2]
    pmax = max(prof0, ipmax) 
    pmin = min(prof0, ipmin) 
    a3 = ( prof0[0] + prof0[n_elements(prof0)-1] ) * 0.5
    a0 = pmax-a3
    a1 = mean(xspan)
  ;  a1 = xcal0[ipmax]
    a2 = 1.0
    a4 = 0.0
    est = [ a0, a1, a2, a3, a4 ]
    coef=dblarr(5)
    res = gaussfit( xcal0, prof0, coef, estimates=est, nterms=5, sigma=sgm )
;    foreach ele, coef do begin
;      if finite(ele) eq 0 then begin
;        message, 'invalid fitting output coef', /info
;        jupypix=-1l
;        return
;      endif
;    endforeach

    xcal0=interpol(xcal0,1000,/spline)
    res=interpol(res,1000,/spline)
    ii=where(abs(res - max(res)) eq min(abs(res - max(res))) )
    if ii[0] ne -1l and n_elements(ii) eq 1l then coef[1]=xcal0[ii]
  
  
    ; debug output (plot)
    if keyword_set(debug) then begin
  
      print, coef
      print, sgm
  
  ;    window, 0
      !P.MULTI = [0,1,3]     ; set up 1x2 plot window 
      loadct, 39
      !p.charsize=2.5
      plot, ycal,prof,xr=[-200,200], xtitle='[arcsec]', $
            ytitle='[count/sec] '+string(xspansp, format='("(",i4.4,"-",i4.4,"[A])")'), $
            title=' Peak:'+string(coefsp[1],sgmsp[1],format='(f7.2,"+/-",f7.2,"[arcsec]")')
      errplot, ycal,prof-prof_err, prof+prof_err
      oplot, [ycal[jmax1-spoff],ycal[jmax1-spoff]],!y.crange, color=240
      oplot, [ycal[jmax1+spoff],ycal[jmax1+spoff]],!y.crange, color=240
      oplot, ycalsp, ressp, color=240
      
  ;    !p.multi[0]+=1l
      plot, xcal,prof_wl,xr=[min(xspan)-10.d,max(xspan)+10.d], xstyle=1, xtitle='[angstrom]', ytitle='[count/sec]', $
          title='Peak:'+string(coef[1],sgm[1],format='(f7.2,"+/-",f4.2,"[A]")')+' Radial range:'+string(ycal[jmax1-spoff],ycal[jmax1+spoff], $
          format='(f+7.1,"-",f+7.1,"[asec]")')
      errplot, xcal,prof_wl-prof_wl_err, prof_wl+prof_wl_err
      oplot, xcal, prof_sky, color=128
      errplot, xcal,prof_sky-prof_sky_err, prof_sky+prof_sky_err, color=128
      oplot, xcal0, res, color=240
  
      !p.multi[0]+=1l
      plot, xcal,prof_wl,xr=[min(xspan)-10.d,max(xspan)+10.d], xstyle=1, xtitle='[angstrom]', ytitle='[count/sec]', yrange=[0.d,max([prof0,prof0_sky])],$
        title='Peak:'+string(coef[1],sgm[1],format='(f7.2,"+/-",f4.2,"[A]")')+' Radial range:'+string(ycal[jmax1-spoff],ycal[jmax1+spoff], $
        format='(f+7.1,"-",f+7.1,"[asec]")')
      errplot, xcal,prof_wl-prof_wl_err, prof_wl+prof_wl_err
      oplot, xcal, prof_sky, color=128
      errplot, xcal,prof_sky-prof_sky_err, prof_sky+prof_sky_err, color=128
      oplot, xcal0, res, color=240
  
    endif
    
;    ret = fltarr(6)
;    ret[0] = coef[1]; parameter A1 central wavelength
;    ret[1] = sgm[1]; fitting error for A1 central wavelength
;    ret[2] = coefsp[1]; 
;    ret[3] = sgmsp[1];
;  
;  ;       F(x) = A0*EXP(-z^2/2) + A3 + A4*x + A5*x^2
;  ;           and
;  ;       z=(x-A1)/A2
;    ret[4] = max(res); parameter A0
;    ret[5] = sqrt(ret[4]*total*60.d)/(total*60.d); fitting error for A0

    jupypix=coefsp[1]
    ii=where(abs(ycal-jupypix) eq min(abs(ycal-jupypix)))
    if ii[0] eq -1l then message, 'invalid input data'
    jupypix=ii[0]
end