pro set_env_l3_sample
  defsysv, '!KERNELDATADIR', 'C:\SPICE\kernel\'; spice kernel data directory
  defsysv, '!SPICEICYPATH' , 'C:\SPICE\icy\'
  if strlen(file_search(!SPICEICYPATH)) lt 1l then message, '>>> invalid environment setting '+!SPICEICYDIR
  if strlen(file_search(!KERNELDATADIR)) lt 1l then message, '>>> invalid environment setting '+!KERNELDATADIR

  dlm_register, !SPICEICYPATH+'lib/icy.dlm'
  help, 'icy', /dlm
  ;load_spice

  defsysv, '!RJ' , exists=exists
  if exists ne 1 then defsysv, '!RJ'      ,   71492.;//km one Jovian radii
  defsysv, '!AU' , exists=exists
  if exists ne 1 then defsysv, '!AU'      ,   149597871.;//km one AU
  defsysv, '!VC'      ,   299792458.d; m / s
  defsysv, '!EC'      ,   1.6021766208d-19; C
  defsysv, '!H'      , exists=exists
  if exists ne 1 then defsysv, '!H'      ,   6.62607004d-34; m2 kg / s
  defsysv, '!VC'      , exists=exists;
  if exists ne 1 then defsysv, '!VC'      ,   299792458.d; m / s
  defsysv, '!PI'      , exists=exists
  if exists ne 1 then defsysv, '!PI'      ,   3.14159265358979d


  defsysv, '!FITSDATADIR'   ,'F:\l2\'     ; L2 data directory
  defsysv, '!L2P_DIR'       ,'F:\l2prime\'; L2prime data directory
  defsysv, '!L2pa_DIR'      ,'F:\l2prime_aur\'
  defsysv, '!l2cal_path'    ,'F:\cal\'    ; cal table v1 data directory
  defsysv, '!l2cal_path2'   ,'F:\cal2\'   ; cal table v2 data directory
  defsysv, '!out_dir'       ,'F:\l3'      ; L3 data directory
  defsysv, '!tablea_path'   ,'C:\function\JX-PSPC-464448\etc\FJSVTOOL\table\'
  defsysv, '!geocorona_list','C:\function\JX-PSPC-464448\etc\FJSVTOOL\table\line_list_geocorona_v1.dat'
  defsysv, '!iptbat_list'   ,'C:\function\JX-PSPC-464448\etc\FJSVTOOL\table\line_list_iptbad_v1.dat'
  defsysv, '!log_place'     ,'C:\log_idl\'
  defsysv, '!DIR_SLIT'      ,'C:\function\JX-PSPC-464448\etc\FJSVTOOL\slit\'
  defsysv, '!BLACK_LIST'    ,'C:\function\JX-PSPC-464448\etc\FJSVTOOL\blacklist.csv'
  defsysv, '!exc_cal_dir'   ,'C:\function\hisaki_l2_caltool\cal_table\'

  device, decomposed = 0
  return  
end