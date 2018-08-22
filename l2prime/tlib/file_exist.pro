function file_exist, file

    openr, 1, file, ERROR = err
    if err eq 0 then begin
      close, 1
      return, 1
    endif else begin
      close, 1
      return, 0
    endelse

end
