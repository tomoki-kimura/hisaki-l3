; $Id: IMGDISP.pro,v 0.10 Mar 31 2004 $
; 
; 2011.11.14 update: Rename by Takeru UNO
; Copyright (c) 1988-2004, PPARC, TOHOKU Universiy. All rights reserved.
; Unauthorized reproduction prohibited.
;+
; NAME:
; IMGDISP
;
; PURPOSE:
; plot an image and a contour.
;
; CATEGORY:
; General graphics.
;
; CALLING SEQUENCE:
; datecnv()
;
; INPUTS:
; A:  The two-dimensional array to display or Andor SIF type strducture.
;
; KEYWORD PARAMETERS:
; RANGE:  	Max-min range array; [min,max]
; ROI:  		Reigon of interest array; [x1,x2,y1,y2]
; colorbar_u2: If this keyword is set, a color scalebar is shown.
; CONTOUR: 	If this keyword is set, a contour map is shown.
; TITLE, XTITLE,YTITLE:
; FILENAME: If this keyword is set, filename is added to title words.
;
; OUTPUTS:
; No explicit outputs.
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; The currently selected display is affected.
;
; RESTRICTIONS:
; None.
;
; PROCEDURE:
; If the device has scalable pixels, then the image is written over
; the plot window.
;
; MODIFICATION HISTORY:
; DMS, Dec, 2004.
;-
PRO IMGDISP_2,A,xrange=xrange,yrange=yrange,aspect=aspect,roi=roi $
           ,range=range,_EXTRA=EXTRA_KEYWORDS,contour=contour $
           ,colorbar_u2=colorbar_u2,DIVISIONS=DIVISIONS,horizontal=horizontal $
           ,header=header,format=format $
           ,mouse=mouse,cursor_x, cursor_y, cursor_value $
           ,noimage=noimage,pos=pos, ccharsize=ccharsize
;ON_ERROR,1;On error, return all the way back to the main program level.
;on_error,2                      ;Return to caller if an error occurs

inf=size(A)
if keyword_set(xrange) then ckxrange=1
;when A is 1d array
if inf[0] eq 1 then begin
  ;when A is ANDOR CCD image type
  IF A.type eq 'IMAGE' or a.type eq 'ANDOR' THEN BEGIN
    if not keyword_set(roi) then begin
      roi=A.roi
      image=a.img
      endif $
    else image=A.img[roi[0]:roi[1],roi[2]:roi[3]]
    if not keyword_set(xrange) and not keyword_set(yrange) then begin
      xrange=roi[0:1]+[-0.5,.5] & yrange=roi[2:3]+[-0.5,.5]
      endif
    if tag_exist('midtime') then midtime=a.midtime $
    else midtime=a.sttime+a.exptime/86400d/2d
    if not keyword_set(title) then $
      title=datecnv(midtime)+' '+strtrim(a.bin[0],2)+'X'+strtrim(a.bin[1],2)+' '+strtrim(fix(a.tm),2)+'��'
    ENDIF $
  ELSE print,'Data is 1-dimension and not IMAGE structure.'
  endif $
;when A is 2d-array
else if inf[0] eq 2 then begin
  if keyword_set(header) then  begin
    roi=intarr(4)
    reads,sxpar(header,'SUBRECT'),ROI
    midtime=sxpar(header,'MIDTIME')
  endif
  if not keyword_set(roi) then roi=[0,inf[1]-1,0,inf[2]-1];+[-1.5,-.5,-1.5,-.5]
  if keyword_set(roi) then begin
    if not keyword_set(xrange) and not keyword_set(yrange) then begin
      xrange=roi[0:1]+[-0.5,.5] & yrange=roi[2:3]+[-0.5,.5]
      endif
    image=A[roi[0]:roi[1],roi[2]:roi[3]]
    endif $
  else image=A
  endif $
else print,'Data is neither 2-dimension nor IMAGE structure.'
if not keyword_set(over) then erase=1
if not keyword_set(range) then range=[min(image),max(image)]

if n_elements(range) eq 1 then begin
  range=range<0.9999
   IMDISP,sigrange(image,fraction=range,range=range),/axis,xrange=xrange,yrange=yrange $
    ,erase=erase,out_pos=pos,aspect=aspect,_extra=EXTRA_KEYWORDS
  endif $
else if n_elements(range) eq 2 then begin
  IMDISP,image,/axis,xrange=xrange,yrange=yrange,range=range $
    ,erase=erase,out_pos=pos,aspect=aspect,_EXTRA=EXTRA_KEYWORDS
  endif

if keyword_set(contour) then $
  if keyword_set(ckxrange) then begin
    inf=size(image)
    contour,image $
      ,indgen(inf[1])*(xrange[1]-xrange[0])/float(inf[1])+xrange[0] $
      ,indgen(inf[2])*(yrange[1]-yrange[0])/float(inf[2])+yrange[0] $
      ,position=pos,/xstyle,/ystyle,_EXTRA=EXTRA_KEYWORDS,/over
  endif else $
    contour,image,position=pos,/xstyle,/ystyle,_EXTRA=EXTRA_KEYWORDS,/over

if keyword_set(colorbar_u2) then $
  if keyword_set(horizontal) then $
    colorbar_u2,DIVISIONS=DIVISIONS,range=range,position=[pos[0],pos[1]-0.05,pos[2],pos[1]-0.04],format=format ,charsize=ccharsize $
  else colorbar_u2,DIVISIONS=DIVISIONS,range=range,/vert,/right,position=[pos[2]+0.005,pos[1],pos[2]+0.02,pos[3]],format=format,charsize=ccharsize
if keyword_set(mouse) then begin
  !mouse.button=0
  print,'Click the mouse'
  CURSOR, cursor_x, cursor_y, /data,/down
  cursor_value=image(cursor_x,cursor_y)
  while !mouse.button ne 4 do begin
    print,string(format='("X:",f6.1," Y:",f6.1," Value:")',cursor_x,cursor_y)+strtrim(cursor_value,2)
    CURSOR, cursor_x, cursor_y, /data,/down
    cursor_value=image(cursor_x,cursor_y)
    endwhile
  endif


end

