;----------------------------------------------------------
; Calculate paraemters of Jupiter
; Use SPICE
; for read_exc_euv_l2.pro
;----------------------------------------------------------
PRO get_param_jupiter, extn, const

  ; reference frame
  ref  = 'IAU_JUPITER'
  ; light time correction
  corr = 'LT+S'
  ; targets
  trg1 = 'JUPITER'
  ; origin (observer)
  org  = 'EARTH'
  
  ; Get state vector : Earth to Jupiter
  cspice_spkezr, trg1, extn.et, ref, corr, org, state_j , lt_j
  cspice_vpack, state_j[0], state_j[1], state_j[2], vec_j

  ; CML
  extn.lon_j = -atan(-state_j[1],-state_j[0]) * cspice_dpr();
  if extn.lon_j lt 0.0 then extn.lon_j = extn.lon_j + 360.0
 
end
