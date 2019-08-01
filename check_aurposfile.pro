pro check_aurposfile
;where(time_m eq list_cent0[i])を直す！！！
;
;
;
  !p.multi=0
  file=dialog_pickfile(PATH=!DIR_SLIT, FILTER = '*.csv', /FIX_FILTER)
  file_mkdir,!log_place+'\check_aurpos\
  
;  data = READ_CSV('C:\Users\hkita\Desktop\aur_pos_test.csv')
  data = READ_CSV(file)
  timearr=time_double(data.field01)
  timearr2=time_double(data.field03)
  for i=0.,n_elements(data.field01)-1 do begin
    timearr[i] = time_double(data.field01[i])
  endfor
  time_m = data.field02
  list_cent0=['2016-02-19T00:22:49','2016-02-19T00:29:49','2016-05-28T11:24:53',$
    '2016-06-30T21:05:00','2016-07-12T09:09:25','2016-11-03T07:56:39',$
    '2016-11-19T06:57:17','2016-11-20T04:02:00','2016-12-17T19:53:30',$
    '2017-01-19T20:02:14','2016-12-18T16:47:46',$
    '2017-01-22T10:13:30','2017-01-29T19:06:00','2017-02-06T11:00:53',$
    '2017-02-07T20:50:00','2017-02-08T10:49:32','2017-02-08T18:11:02',$
    '2017-02-10T10:53:28','2017-04-17T20:07:03','2017-07-06T13:03:30',$
    '2017-07-07T06:33:17','2017-07-08T11:02:29',$
    '2017-07-29T00:53:10','2017-07-31T21:35:50','2017-07-31T22:04:50',$
    '2017-07-31T23:30:50','2017-08-02T05:35:42','2017-08-03T03:00:05',$
    '2017-08-06T01:37:30','2017-08-16T23:43:10','2017-08-19T15:50:46',$
    '2017-08-20T03:40:30','2017-08-22T12:12:00','2017-09-05T03:56:18',$
    '2018-02-19T12:31:00','2018-02-19T13:22:30','2018-02-19T15:09:00',$
    '2018-02-20T17:41:49','2018-02-26T22:34:30','2018-03-05T06:36:00',$
    '2018-05-19T10:19:00',$
    '2018-05-20T04:01:17','2018-05-20T09:19:17','2018-05-25T22:04:11',$
    '2018-06-15T17:48:28','2018-06-19T11:46:53','2018-06-19T15:00:23',$
    '2018-06-19T15:19:23','2018-06-28T02:28:31','2018-07-01T14:02:30',$
    '2018-07-02T15:05:30','2018-07-02T23:03:00','2018-07-03T23:49:34',$
    '2018-07-18T15:11:04','2018-07-21T20:36:54','2018-07-22T01:27:00',$
    '2018-07-22T08:32:00','2018-07-23T04:08:10','2018-07-23T18:27:10',$
    '2018-07-23T23:55:50','2018-07-25T13:25:36','2018-07-26T22:22:57',$
    '2018-09-16T06:54:47','2018-09-18T02:30:50','2018-09-23T13:59:30',$
    '2018-10-06T21:42:39','2018-10-08T16:17:55']
  for i=0., n_elements(list_cent0)-1 do begin
    ;n1=where(time_m eq list_cent0[i])
    n1=where(time_double(list_cent0[i]) ge timearr and time_double(list_cent0[i]) le timearr2)
    if n1 ne -1 then data.field10[n1]=0 else print,list_cent0[i]
  endfor
  list_cent1=['2017-01-15T09:50:00','2017-01-13T09:12:00','2017-01-25T15:51:30',$
    '2017-01-26T02:32:18','2017-01-26T15:09:18','2017-02-05T00:00:03',$
    '2017-05-06T11:41:12','2017-08-19T11:54:16','2017-09-15T06:23:35',$
    '2018-02-28T07:06:00','2018-05-12T03:07:30','2018-05-13T00:21:52',$
    '2018-05-16T09:45:39','2018-05-16T20:22:39','2018-05-18T11:18:52',$
    '2018-05-18T14:50:52','2018-05-26T21:04:53']
  for i=0., n_elements(list_cent1)-1 do begin
    ;n1=where(time_m eq list_cent1[i])
    n1=where(time_double(list_cent1[i]) ge timearr and time_double(list_cent1[i]) le timearr2)
    if n1 ne -1 then data.field10[n1]=1 else print,list_cent1[i]
  endfor
  list_ipt10=['2016-10-24T16:09:41','2017-01-13T09:12:00','2017-02-07T10:00:00',$
    '2017-05-09T17:28:39','2018-02-23T06:48:16','2018-03-01T02:38:23',$
    '2018-06-30T17:04:14','2016-11-23T03:04:57','2018-07-22T10:20:00',$
    '2018-07-22T19:20:30','2018-07-22T19:27:00','2018-07-23T05:46:10',$
    '2018-07-23T07:32:10','2018-07-23T16:34:10']
  for i=0., n_elements(list_ipt10)-1 do begin
    ;n1=where(time_m eq list_ipt10[i])
    n1=where(time_double(list_ipt10[i]) ge timearr and time_double(list_ipt10[i]) le timearr2)
    if n1 ne -1 then begin
      data.field11[n1]=-1
      data.field13[n1]=-1
    endif else print,list_ipt10[i]
  endfor
  list_ipt20=['2016-06-23T19:10:00','2016-08-05T01:46:00','2016-10-24T16:09:41',$
    '2017-03-18T21:06:30','2017-03-20T08:20:00','2017-05-09T17:28:39',$
    '2017-07-30T23:14:30','2017-08-29T21:11:30','2017-09-06T04:52:33',$
    '2017-09-06T23:52:33','2017-09-08T02:40:17','2017-09-10T09:38:47',$
    '2017-09-16T07:05:00','2018-05-18T20:09:22','2018-05-19T06:47:00',$
    '2018-06-30T17:04:14','2018-07-22T05:07:30','2018-07-22T06:45:30',$
    '2018-07-23T02:13:40','2018-09-19T03:57:00']
  for i=0., n_elements(list_ipt20)-1 do begin
    ;n1=where(time_m eq list_ipt20[i])
    n1=where(time_double(list_ipt20[i]) ge timearr and time_double(list_ipt20[i]) le timearr2)
    if n1 ne -1 then begin
      data.field11[n1]=-1
      data.field14[n1]=-1
    endif else print,list_ipt20[i]
  endfor


  buff=findgen(n_elements(data.field01))
  nn1=where(data.field10 eq 0 and data.field11 eq -1 and data.field13 eq -1 and data.field14 eq -1)
  buff[nn1]=0
;  nn1=where(data.field10 eq -1)
;  buff[nn1]=0
  flag=[['2017-02-06T23:45:53', '2017-02-06T23:56:53'],$
        ['2017-02-08T21:37:32', '2017-02-08T23:54:32'],$
        ['2017-03-17T04:14:46', '2017-03-17T04:16:46'],$
        ['2017-07-10T01:44:00', '2017-07-10T02:03:00'],$
        ['2017-08-19T05:24:46', '2017-08-19T08:05:46'],$
        ['2017-08-19T22:14:46', '2017-08-20T00:22:00'],$
        ['2017-09-17T22:02:02', '2017-09-17T22:15:02'],$
        ['2017-09-19T21:49:21', '2017-09-19T22:00:21'],$
        ['2018-02-10T14:08:00', '2018-02-10T14:21:00'],$
        ['2018-02-16T13:13:24', '2018-02-16T23:49:24']]
  for i=0., n_elements(flag[1,*])-1 do begin
    n1=where(timearr ge time_double(flag[0,i]) and timearr le time_double(flag[1,i]))
    if n1[0] ne -1 then begin
      buff[n1]=0
    endif
  endfor
  buff=buff[where(buff ne 0)]
  
  timearr= timearr[buff]
  time_s = data.field01[buff]
  time_m = data.field02[buff]
  time_e = data.field03[buff]
  pos    = data.field04[buff]
  fwhm   = data.field05[buff]
  slit1  = data.field06[buff]
  slit2  = data.field07[buff]
  slit3  = data.field08[buff]
  slit4  = data.field09[buff]
  flag   = data.field10[buff]
  pos2   = data.field11[buff]
  ipt1   = data.field13[buff]
  ipt2   = data.field14[buff]
  flagold=flag
stop
  pos_old=pos
  for i=0., n_elements(time_m)-1 do begin
    if flag[i] eq 0 then begin
      print,time_m[i]
      for j=i+1, n_elements(time_m)-1 do begin
        if pos2[j] eq -1 and ipt1[j] eq -1 and ipt2[j] eq -1 then begin
          print,'pos ipt -1'
          pos2[j]=pos2[j-1]
          ipt1[j]=ipt1[j-1]
          ipt2[j]=ipt2[j-1]
          j=j-1
          continue
        endif
        if flag[j] ne 0 then break
      endfor
      ;i-1-j
      if (where(pos2[i-1:j] eq -1))[0] eq -1 then begin
        buff=pos2
        color1=fsc_color('red')
        flag[i:j-1]=1
      endif else if (where(ipt1[i-1:j] eq -1))[0] eq -1 then begin
        buff=ipt1
        color1=fsc_color('green')
        flag[i:j-1]=1
      endif else if (where(ipt2[i-1:j] eq -1))[0] eq -1 then begin
        buff=ipt2
        color1=fsc_color('blue')
        flag[i:j-1]=1
      endif else if n_elements(where(pos2[i-1:j] eq -1)) eq 1 and pos2[i-1] eq -1 and pos2[j] ne -1 then begin
        print,'pos beg -1'
        buff=pos2
        color1=fsc_color('red')
        buff[i-1] =pos[i-1] - ( pos[j  ]-buff[j  ])
        flag[i:j-1]=1
;        stop
      endif else if n_elements(where(pos2[i-1:j] eq -1)) eq 1 and pos2[i-1] ne -1 and pos2[j] eq -1 then begin
        print,'pos end -1'
        buff=pos2
        color1=fsc_color('red')
        buff[j] =pos[j] - ( pos[i-1]-buff[i-1])
        flag[i:j-1]=1
;        stop
      endif else if n_elements(where(ipt1[i-1:j] eq -1)) eq 1 and ipt1[i-1] eq -1 and ipt1[j] ne -1 then begin
        print,'ipt1 beg -1'
        buff=ipt1
        color1=fsc_color('green')
        buff[i-1] =pos[i-1] - ( pos[j  ]-buff[j  ])
        flag[i:j-1]=1
;        stop & stop & stop
      endif else if n_elements(where(ipt1[i-1:j] eq -1)) eq 1 and ipt1[i-1] ne -1 and ipt1[j] eq -1 then begin
        print,'ipt1 end -1'
        buff=ipt1
        color1=fsc_color('green')
        buff[j] =pos[j] - ( pos[i-1]-buff[i-1])
        flag[i:j-1]=1
;        stop & stop & stop
      endif else if n_elements(where(ipt2[i-1:j] eq -1)) eq 1 and ipt2[i-1] eq -1 and ipt2[j] ne -1 then begin
        print,'ipt2 beg -1'
        buff=ipt2
        color1=fsc_color('blue')
        buff[i-1] =pos[i-1] - ( pos[j  ]-buff[j  ])
        flag[i:j-1]=1
;        stop & stop & stop
     endif else if n_elements(where(ipt2[i-1:j] eq -1)) eq 1 and ipt2[i-1] ne -1 and ipt2[j] eq -1 then begin
        print,'ipt2 end -1'
        buff=ipt2
        color1=fsc_color('blue')
        buff[j] =pos[j] - ( pos[i-1]-buff[i-1])
        flag[i:j-1]=1
;        stop & stop & stop
      endif else begin
        print,time_m[i]
        print,'!!!'
        print, where(pos2[i-1:j] eq -1)
        print, where(ipt1[i-1:j] eq -1)
        print, where(ipt2[i-1:j] eq -1)
        flag[i:j-1]=-1
;        stop & stop & stop & stop
      endelse
      del1=pos[i-1]-buff[i-1]
      del2=pos[j  ]-buff[j  ]
      del =(del1+del2)/2.
      print,'before',pos[i:j-1]
      pos[i:j-1]=buff[i:j-1]+del
      plot, timearr[i-5:j+5],pos[i-5:j+5],psym=-1,yrange=[520,620],title=time_m[i]+'  '+time_m[j-1],xrange=[timearr[i]-6000,timearr[j]+6000]
      oplot,timearr[i-5:j+5],pos_old[i-5:j+5],psym=-6,color=fsc_color('orange'),linestyle=1
      oplot,timearr[i-5:j+5],buff[i-5:j+5],psym=-6,color=color1,linestyle=1
      oplot,timearr,slit1,linestyle=1
      oplot,timearr,slit2,linestyle=1
      oplot,timearr,slit3,linestyle=1
      oplot,timearr,slit4,linestyle=1
      oplot,[timearr[i],timearr[i]]-300,!y.crange,linestyle=2;-2000
      oplot,[timearr[j-1],timearr[j-1]]+300,!y.crange,linestyle=2
      oplot,timearr[where(flagold le 0)],pos_old[where(flagold le 0)],psym=2  
      print,'after',buff[i:j-1]+del
      ;stop
      write_png, !log_place+'\check_aurpos_'+repstr(time_m[i],':','-')+'.png', TVRD(/TRUE)
      i=j
    endif
  endfor
  ;2017-05-23T19:32:01 OK
  ;2016-8-05 2016-8-7 OK
  ;'2018-05-15T05:19:00',OK
  
  stop
  stop
  stop
  
  buff=where(flag eq 1)
  timearr= timearr[buff]
  time_s = time_s[buff]
  time_m = time_m[buff]
  time_e = time_e[buff]
  pos    = pos[buff]
  fwhm   = fwhm[buff]
  slit1  = slit1[buff]
  slit2  = slit2[buff]
  slit3  = slit3[buff]
  slit4  = slit4[buff]
  flag   = flag[buff]
  pos2   = pos2[buff]
  ipt1   = ipt1[buff]
  ipt2   = ipt2[buff]

  plot, timearr,pos,psym=-1,yrange=[520,620];,xrange=[time_double('2017-01-01T00:00:00'),time_double('2017-12-31T00:00:00')]
  oplot,timearr,pos_old,psym=-6,color=fsc_color('orange'),linestyle=1
  ;oplot,timearr,pos2,psym=-6,linestyle=1
  oplot,timearr,slit1,linestyle=1
  oplot,timearr,slit2,linestyle=1
  oplot,timearr,slit3,linestyle=1
  oplot,timearr,slit4,linestyle=1
  
  stop
  stop
  stop
  stop

  fout=dialog_pickfile(PATH=!DIR_SLIT,file='aur_pos_2016.csv')  
  openw, 1, fout
  printf, 1, '#time_s,time_m,time_e,pos,fwhm,slit1,slit2,slit3,slit4'
  for k = 0., n_elements(time_s) - 1 do begin
    rec = time_s[k]+','+time_m[k]+','+time_e[k] $
      + ',' + strcompress(string(pos[k])) $
      + ',' + strcompress(string(fwhm[k])) $
      + ',' + strcompress(string(slit1[k])) $
      + ',' + strcompress(string(slit2[k])) $
      + ',' + strcompress(string(slit3[k])) $
      + ',' + strcompress(string(slit4[k]))
    printf, 1, rec
  endfor
  close, 1

end
