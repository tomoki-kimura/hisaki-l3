pro set_env

  ;; environment setting

  defsysv, '!KERNELDATADIR', '/Volumes/moxonraid/spa/data/kernel/'; spice kernel data directory
  setenv, 'IDL_DLM_PATH=/Applications/exelis/idl/lib:<IDL_DEFAULT>'
  defsysv, '!SPICEICYPATH' , '/usr/local/exelis/icy/'
  dlm_register, !SPICEICYPATH+'lib/icy.dlm'
  help, 'icy', /dlm
;  print, cspice_tkvrsn( 'TOOLKIT' )
  
  defsysv, '!RME'     ,   2440.;//km one Mercury radii
  defsysv, '!RV'      ,   6051.;//km one Venus radii
  defsysv, '!RE'      ,   6371.;//km one Earth radii
  defsysv, '!RMO'     ,   1738.;//km one Moon radii
  defsysv, '!RMA'     ,   3397.;//km one Mars radii
  defsysv, '!RJ' , exists=exists
  if exists ne 1 then $
    defsysv, '!RJ'      ,   71492.;//km one Jovian radii
  defsysv, '!RS' , exists=exists
  if exists ne 1 then $
    defsysv, '!RS'      ,   60268.;//km one Saturnian radii
  defsysv, '!RSPRINTA',   0.0038;//km one Saturnian radii
  defsysv, '!AU' , exists=exists
  if exists ne 1 then $
    defsysv, '!AU'      ,   149597871.;//km one AU
  defsysv, '!PARSEC'  ,   3.08567758d+13;//km
  ;defsysv, '!SPACE'  ,    (24.E+9 * !PARSEC);//km
  defsysv, '!SPACE'   ,   (1.);//km
  defsysv, '!MP'      ,   1.67262178d-27; kg
  defsysv, '!ME'      ,   9.10938356d-31; kg
  defsysv, '!VC'      ,   299792458.d; m / s
  defsysv, '!EC'      ,   1.6021766208d-19; C
  defsysv, '!MU'      ,   (4.d * !PI * 1.d-7); H/m
  defsysv, '!EPS'     ,   (8.854187817d-12) ; F/m
  defsysv, '!KB'      ,   (1.3806488d-23);m2 kg s-2 K-1
  defsysv, '!NU'      ,   6.62607004d-34; m2 kg / s
  defsysv, '!H'      , exists=exists
  if exists ne 1 then defsysv, '!H'      ,   6.62607004d-34; m2 kg / s
  defsysv, '!VC'      , exists=exists
  if exists ne 1 then defsysv, '!VC'      ,   299792458.d; m / s
  defsysv, '!PI'      , exists=exists
  if exists ne 1 then defsysv, '!PI'      ,   3.14159265358979d;

  device, decomposed = 0
  
  return
end