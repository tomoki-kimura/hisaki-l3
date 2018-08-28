function get_planet_radii, time=time,target=target,deg=deg
  if not keyword_set(target) then target='JUPITER'
  if target eq 'JUPITER' then rp=!RJ; km
  if not keyword_set(rp) then message, 'invalid input target'
  intarg=target
  inobs='SPRINTA'
  inframe='IAU_'+intarg
  quiet=1
  abcorr='LT+S'
  ltime=0.d
  orb=cal_orb(epoch=time, intarg=intarg, inobs=inobs, inframe=inframe, quiet=quiet, abcorr=abcorr, ltime=ltime)
  radii=orb.radii; km
  if keyword_set(deg) then begin
    return, atan(rp/radii)*cspice_dpr(); deg
  endif else begin
    return, radii
  endelse

end
