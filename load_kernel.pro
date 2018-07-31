pro load_kernel
  message, '>>> spice kernel loading started.', /info
  set_env
  path=!KERNELDATADIR
  kernels=file_search(path,'*/*.*')
  message, '>>> loaded kernels:', /info
  
  cspice_furnsh, kernels
  
  message, '>>> spice kernel loading finished.', /info
  
  return 
end

pro unload_kernel, light=light
  message, '>>> spice kernel unloading started.', /info
  path=!KERNELDATADIR
  kernels=file_search(path,'*/*.*')
  message, '>>> unloaded kernels:', /info

  cspice_unload, kernels
  message, '>>> spice kernel unloading finished.', /info
  
  return
end
