pro cal_caldata_l2prime, incal=incal, outcal=outcal


  caldata=mrdfits(incal,0,phdr,/silent)
  xcal   =mrdfits(incal,1,xhdr,/silent)
  ycal   =mrdfits(incal,2,yhdr,/silent)
  aeffcal=mrdfits(incal,3,aeffhdr,/silent)
  nx=n_elements(aeffcal[*,0])
  ny=n_elements(aeffcal[0,*])

  ;tsuchiya calibration
  exc_cal_init
  jd_in = julday(1,1,2014)
  exc_cal_img, jd_in, aeffcal, outdata, outxcal, outycal
  aeffcal=outdata

  iyminout=where(abs(outycal) eq min(abs(outycal)))
  if iyminout[0] ne -1l then iymin=iyminout[0]
  iyminin=where(abs(ycal[0,*]) eq min(abs(ycal[0,*])))
  if iyminin[0] ne -1l then iyminin=iyminin[0]

  for i=0l, ny-1l do begin
    xcal[*,i]=outxcal[*]
    iin=i
    iout=i-iyminin+iyminout
    ;    if iin  gt ny-1l then iin=ny-1l
    ;    if iin  lt 0l    then iin=0l
    if iout gt ny-1l then iout=ny-1l
    if iout lt 0l    then iout=0l
    ycal[*,iin]=outycal[iout]
  endfor

  mwrfits, !NULL, outcal, phdr, /create, /silent
  mwrfits, xcal   , outcal, xhdr, /silent
  mwrfits, ycal   , outcal, yhdr, /silent
  mwrfits, aeffcal, outcal, aeffhdr, /silent

  return
end

