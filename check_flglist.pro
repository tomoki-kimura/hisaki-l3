pro check_flglist
  file=dialog_pickfile()

  data = READ_CSV(file)
  err=0
  for i=0, n_elements(data.field1)-2 do begin
    if data.field2[i]+1 ne data.field2[i+1] and data.field2[i+1] ne 2 then begin
      print, data.field1[i+1],' extension missing'
    endif
;    if string(data.field2[i]) eq '*' then print, data.field1[i]
;    if string(data.field3[i]) eq '*' then print, data.field1[i]
    if string(data.field4[i]) eq '*' then begin
      if err eq 0 then print, data.field1[i], ' calflg err from--'
      err=1
    endif else if string(data.field7[i]) eq '**' then begin
      if err eq 0 then print, data.field1[i], ' submst err from--'
      err=2
    endif else begin
      if err eq 1 then print, data.field1[i-1], ' --to'
      if err eq 2 then print, data.field1[i-1], ' --to'
      err=0
    endelse    
  endfor 
end
