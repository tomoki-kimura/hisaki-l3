;----------------------------------------------------------
; Load SPICE kernels
; To use SPICE, set IDL_DLM path
;----------------------------------------------------------
PRO init_spice

  ; load SPICE kernels
  SPICE_DIR = '/home/hisaki/l2prime/spice/kernel/'

  ; load LSK file
  cspice_furnsh, SPICE_DIR+'lsk/naif0012.tls' 

  ; load SPK files
  cspice_furnsh, SPICE_DIR+'spk/de430.bsp'
  cspice_furnsh, SPICE_DIR+'spk/jup309.bsp'

  ; Load text PCK file.
  cspice_furnsh, SPICE_DIR+'pck/pck00010.txt'

end
