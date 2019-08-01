pro load_kernel
  message, '>>> spice kernel loading started.', /info
  set_env

  path=!KERNELDATADIR
  kernels=file_search(path,'*/*.*')
;  path=!CXODATADIR+'kernel
;  others=file_search(path,'*/*.*')
;  path=!JUNODATADIR+'kernels
;  others=file_search(path,'*/*161027.bsp')
;  others=[others,file_search(path,'*/*160226.bsp')]
;  if strlen(others[0]) gt 1l then kernels=[kernels,others]
  message, '>>> loaded kernels:', /info
  
  cspice_furnsh, kernels
  
  message, '>>> spice kernel loading finished.', /info
  
  return 
end

pro unload_kernel, light=light
  message, '>>> spice kernel unloading started.', /info
  path=!KERNELDATADIR
  kernels=file_search(path,'*/*.*')
;  path=!CXODATADIR+'kernel
;  others=file_search(path,'*/*.*')
;  path=!JUNODATADIR+'kernels
;  others=file_search(path,'*/*161027.bsp')
;  others=[others,file_search(path,'*/*160226.bsp')]
;  if strlen(others[0]) gt 1l then kernels=[kernels,others]
  message, '>>> unloaded kernels:', /info

  cspice_unload, kernels
  message, '>>> spice kernel unloading finished.', /info
  
  return
end
