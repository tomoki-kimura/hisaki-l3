pro date2juldat, date,jd

  iyy = strmid(date,0,4)
  imm = strmid(date,4,2)
  idd = strmid(date,6,2)
  jd  = julday(imm,idd,iyy,0,0,0)

end