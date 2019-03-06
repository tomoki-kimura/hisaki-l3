function remove_geocor_star,im,tablea_path,l2cal_path
  im2=im
  MSG_ERR05 = 'msg_err11: TableG data is empty. tablea_path='
  MSG_ERR06 = 'msg_err12: TableG data record is invalid. rec num:'

  ; �e�[�u��(�̈���)�̃f�[�^���擾
  n_file_lines = file_lines(tablea_path)
  if n_file_lines eq 0 then $
    message, MSG_ERR05 + tablea_path
  file_recs =  strarr(file_lines(tablea_path))
  openr, 1, tablea_path
  readf, 1, file_recs
  close, 1
  tablea_dataset_value = fltarr(1,4)

  ; �e�[�u���̃��R�[�h������
  for i = 0, n_elements(file_recs) - 1 do begin
    if stregex(file_recs[i], '^#',/boolean) eq 1 then continue
    rec = strsplit(file_recs[i], '[ ]+', /EXTRACT)

    ; �f�[�^�̌`���`�F�b�N
    if n_elements(rec) lt 4 then $
      message, MSG_ERR06 + strcompress(i+1, /remove_all)

    tbl_data_ptn = '^[-]{0,1}[0-9]'
    if stregex(strcompress(rec[0], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
      stregex(strcompress(rec[1], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
      stregex(strcompress(rec[2], /remove_all), tbl_data_ptn, /boolean) ne 1 or $
      stregex(strcompress(rec[3], /remove_all), tbl_data_ptn, /boolean) ne 1 then $
      message, MSG_ERR06 + strcompress(i+1, /remove_all)

    ; �C���[�W�擾�̈�ɕϊ�
    rec_tablea = fltarr(1,4)
    rec_tablea[0] = float(rec[0]) - float(rec[1]/2) ; X min
    rec_tablea[1] = float(rec[0]) + float(rec[1]/2) ; X max
    rec_tablea[2] = float(rec[2])            ; Y min
    rec_tablea[3] = float(rec[3])            ; Y max
    if (tablea_dataset_value[0,0] eq '') then begin
      tablea_dataset_value = rec_tablea
    endif else begin
      tablea_dataset_value = [tablea_dataset_value, rec_tablea]
    endelse
  endfor
  n_tablea_dataset = n_elements(tablea_dataset_value[*,0])
  n_tablea_dataset_str = strcompress(string(n_tablea_dataset))


  ; �̈悲�ƂɊe���������{����B
  for i = 0l, n_tablea_dataset - 1l do begin
;  for i = 0l, 0l do begin
    ; value=>pixel�ϊ�
    xrange = [tablea_dataset_value[i,0], tablea_dataset_value[i,1]]
    yrange = [tablea_dataset_value[i,2], tablea_dataset_value[i,3]]
    res = convert_value2pixel(l2cal_path, xrange, yrange)
    x_min = res[0,0]
    x_max = res[1,0]
    y_min = res[0,1]
    y_max = res[1,1]
    nx=n_elements(im2[*,0])
    ny=n_elements(im2[0,*])
    if i eq 0l then $
      for j=0l, nx-1l do $
        im2[j,*]=im2[j,*]-mean(im2[j,y_min:y_max])>0.d; subtraction of geocoronal lines from signal

    im2[x_min:x_max,*]=0.d; zero paddeing of geocoronal region
  endfor

  return,im2

end
