;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function getID, instr

    outid=0
    found=0
    tail=''
;    if instr eq 'JUPITER' or $
;       instr eq 'SATURN'  or $
;       instr eq 'NEPTUNE' or $
;       instr eq 'URANUS'  or $
;       instr eq 'PLUTO'   then begin
;       tail=' BARYCENTER'
;    endif
    cspice_bodn2c, instr+tail, outid, found
    if instr eq 'SPRINTA' then begin
        outid=-750;
    endif
    if instr eq 'CHANDRA' then begin
        outid=-151;
    endif
    if instr eq 'JUNO' then begin
      outid=-61;
    endif
    if found eq 0 then begin
        outid=-750;
        message, '>>> ERROR: invalid input string '+instr, /info
        message, '    default value selected SPRINTA', /info
    endif

    return, outid;
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function cal_orb, epoch=epoch, intarg=intarg, inobs=inobs, inframe=inframe, quiet=quiet, abcorr=abcorr, ltime=ltime
  
  ;////// Define parameters for a state lookup:
  plarad=1.
  plarad=!AU
  if intarg eq 'MERCURY' then plarad=!RME
  if intarg eq 'VENUS'   then plarad=!RV
  if intarg eq 'EARTH'   then plarad=!RE
  if intarg eq 'MOON'    then plarad=!RMO
  if intarg eq 'MARS'    then plarad=!RMA
  if intarg eq 'JUPITER' then plarad=!RJ
  if intarg eq 'SATURN'  then plarad=!RS
  if intarg eq 'SPRINTA' then plarad=!RSPRINTA
  
  normr=1.d
  theta=0.d & phi=0.d
  ;//normalization radius for observer-target distance
  frame = ''
  if not (inobs eq 'SPRINTA' or inobs eq 'EARTH' or inobs eq 'CHANDRA') and not keyword_set(quiet) then begin
    message, '>>> WARNING. Input observer is NOT a near-earth object:'+string(inobs), /info
    message, '>>> WARNING. Are you sure to get ephemeris at the time before photon arrival at near-earth space??', /info
  endif
  if inobs eq 'JUPITER' and inframe eq 'IAU_JUPITER' then begin
      frame=inframe
      theta=(20.5d*2.d*!PI/360.d)
      phi=(9.5d*2.d*!PI/360.d)
  endif else begin
      frame=inframe
  endelse
  
;  if not keyword_set(abcorr) then abcorr='LT+S'

;  abcorr = 'LT+S'
  ; with one-way light time and stellar aberration correction;
;  abcorr = 'LT'
  ; with one-way light time and stellar aberration correction;
;  abcorr = 'NONE'
  ; WITHOUT one-way light time and stellar aberration correction;
  target   = getID(intarg)
  observer = getID(inobs)
  sun      = getID('SUN');//Sun
  earth    = getID('EARTH');//earth
  
  et=0.d
  cspice_str2et, epoch, et
  
  lighttime=0.d;
  state     =[0.d,0.d,0.d,0.d,0.d,0.d]
  state_tar =[0.d,0.d,0.d]
  state_sun =[0.d,0.d,0.d]
  state_ear =[0.d,0.d,0.d]
  IAUpos_tar=[0.d,0.d,0.d]
  
  ;//////// calculate spacecraft position seen from the planet
  cspice_spkez, target, et, frame, abcorr, observer, state,  lighttime
  ltime=lighttime

  for  i=0l, 2l do state_tar [i]=state[i]
  for  i=0l, 2l do IAUpos_tar[i]=state[i]
  for  i=0l, 2l do state     [i]=0.d
  cspice_spkez, sun,    et, frame, abcorr, observer, state,  lighttime_buf
  for  i=0l, 2l do state_sun[i]=state[i]
  for  i=0l, 2l do state    [i]=0.d
  cspice_spkez, earth,  et, frame, abcorr, observer, state,  lighttime_buf
  for  i=0l, 2l do state_ear[i]=state[i]


  ;    ////////////////////////////////////////////////////////////////
  ;    // stellar aberration correction for the input RA/DEC direction
  ;    ////////////////////////////////////////////////////////////////
  ostate_tar=[0.d,0.d,0.d]
  obsvel=[0.d,0.d,0.d]
  rotaxi=[0.d,0.d,0.d]
  rotang=0.d
  cspice_spkez, observer,et,frame,abcorr,sun,state,lighttime_buf
  for i=0l, 3l-1l do obsvel[i]=state[3+i]
  if intarg eq 'MOON' then begin
    cspice_spkez, observer  ,et,frame,abcorr,earth,state2,lighttime_buf
    for i=0l, 3l-1l do obsvel[i]=state2[3+i]
  endif
  rotang=cspice_vsep(obsvel,state_tar);//radian
  rotang=asin( cspice_vnorm(obsvel) * sin(rotang) / cspice_clight());
  cspice_vcrss, state_tar,obsvel,rotaxi;
  cspice_vrotv, $
    state_tar,$;//vector to be rotated
    rotaxi,$;//axis of the rotation
    rotang,$;//angle of the rotation (radians)
    ostate_tar;//Result of rotating v about axis by theta.

  for i=0l, 3l-1l do state_tar[i]=ostate_tar[i];
  abr_radii=0.d & abr_ra=0.d & abr_dec=0.d;
  cspice_reclat, state_tar, abr_radii, abr_ra, abr_dec;
  abr_ra *=cspice_dpr();
  abr_dec*=cspice_dpr();
  if abr_ra ge 360.d then abr_ra = abr_ra mod 360.d;///*convert range(0=<longi<=360. */
  if abr_ra lt 0.d   then abr_ra = abr_ra + 360.d;


  
  
  radii=0.d & glat=0.d & glon=0.d & lt_s=0.d & lt_e=0.d
  rad_sun=0.d & lat_sun=0.d & lon_sun=0.d
  rad_tar=0.d & lat_tar=0.d & lon_tar=0.d 
  rad_ear=0.d & lat_ear=0.d & lon_ear=0.d 
  mlat=0.d & mlon=0.d
  ang_sot=0.d & ang_eot=0.d
  ;// angle between sun-observer-target or earth-observer-target
  ang_sot=cspice_vsep( state_sun,state_tar)
  ang_eot=cspice_vsep( state_ear,state_tar)
  
  ;//////// convert from cartetian to spherical cooridnate
  cspice_reclat,  IAUpos_tar,radii,   glon,     glat  
  cspice_reclat,  state_sun, rad_sun, lon_sun,  lat_sun
  cspice_reclat,  state_tar, rad_tar, lon_tar,  lat_tar
  cspice_reclat,  state_ear, rad_ear, lon_ear,  lat_ear
  
  cspice_rotvec,  IAUpos_tar, -theta, 3, IAUpos_tar
  cspice_rotvec,  IAUpos_tar,   -phi, 2, IAUpos_tar
  cspice_rotvec,  IAUpos_tar,  theta, 3, IAUpos_tar
  cspice_reclat,  IAUpos_tar,  radii,  mlon, mlat
   
  radii =radii/normr
  glat  =glat*!RADEG
  glon  =glon*!RADEG
  mlat  =mlat*!RADEG
  mlon  =mlon*!RADEG
  lat_sun=lat_sun*!RADEG
  lon_sun=lon_sun*!RADEG
  lat_tar=lat_tar*!RADEG
  lon_tar=lon_tar*!RADEG
  lat_ear=lat_ear*!RADEG
  lon_ear=lon_ear*!RADEG
  ang_sot=ang_sot*!RADEG
  ang_eot=ang_eot*!RADEG
  
  if mlon ge  360.d then   mlon = (mlon mod 360.d);///*convert ran>=(0=<longi<=360.d */
  if mlon lt  0.d   then   mlon = mlon + 360.d;//
  mlon = abs(mlon - 360.d);// /*trans<e west longitude*/
  
  if glon ge  360.d then   glon = (glon mod 360.d);///*convert ran>=(0=<longi<=360.d */
  if glon lt  0.d   then   glon = glon + 360.d;//

  if lon_tar ge 360.d then  lon_tar = (lon_tar mod 360.d);///*convert range(0=<longi<=360.d */
  if lon_tar lt 0.d   then  lon_tar = lon_tar + 360.d;
  wlon_tar = abs(lon_tar - 360.d);///*translte west longitude*/
  
  if lon_sun ge 360.d then  lon_sun = (lon_sun mod 360.d);///*convert range(0=<longi<=360.d */
  if lon_sun lt 0.d   then  lon_sun = lon_sun + 360.d;
  wlon_sun = abs(lon_sun - 360.d);
  
  if lon_ear ge 360.d then  lon_ear = (lon_ear mod 360.d);///*convert range(0=<longi<=360.d */
  if lon_ear lt 0.d   then  lon_ear = lon_ear + 360.d;
  wlon_ear = abs(lon_ear - 360.d);
  
  lt_s = 12.d - (lon_sun - lon_tar)*24.d/360.d
  if lt_s lt 0.d  then  lt_s = lt_s + 24.d
  if lt_s ge 24.d then  lt_s = lt_s - 24.d
  
  lt_e = 12.d - (lon_ear - lon_tar)*24.d/360.d
  if lt_e lt 0.d  then  lt_e = lt_e + 24.d
  if lt_e ge 24.d then  lt_e = lt_e - 24.d
  
  
  utcstr=''
  cspice_et2utc, et,'ISOC',0,utcstr
  appdia=3600.d*180.d/!PI*atan(2.d*plarad/radii)
  
  orb={orbit}
  orb.time   =byte(utcstr);//YYYY-DDDThh:mm:ss
  orb.cml    =mlon    ;//deg west magnetic longitude of target seen from observer
  orb.mlat   =mlat    ;//deg magnetic latitude of target seen from observer
  orb.glon   =glon    ;//deg east longitude of target seen from observer
  orb.glat   =glat    ;//deg geographic latitude of target seen from observer
  orb.radii  =radii   ;//km  radial distance of target seen from observer
  orb.rad_sun=rad_sun ;//km  radial distance of sun seen from observer
  orb.lon_sun=lon_sun ;//deg east longitude of sun seen from observer
  orb.ssl    =wlon_sun;//deg west longitude of sun seen from observer
  orb.lat_sun=lat_sun ;//deg latitude of sun seen from observer
  orb.lt_s   =lt_s    ;//hr  sun-based local time of target seen from observer
  orb.ang_sot=ang_sot ;//deg angle of Sun-Observer-Target
  orb.rad_ear=rad_ear ;//km  radial distance of earth seen from observer
  orb.lon_ear=lon_ear ;//deg east longitude of earth seen from observer
  orb.sel    =wlon_ear;//deg west longitude of earth seen from observer
  orb.lat_ear=lat_ear ;//deg latitude of earth seen from observer
  orb.lt_e   =lt_e    ;//hr  earth-based local time of target seen from observer
  orb.ang_eot=ang_eot ;//deg angle of Earth-Observer-Target
  orb.appdia =appdia  ;//arcsec apparent diameter of Target
  orb.abr_ra =abr_ra  ;//deg RA including steller abberation
  orb.abr_dec=abr_dec ;//deg DEC including steller abberation
  
  return, orb
end