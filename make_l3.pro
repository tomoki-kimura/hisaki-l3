pro make_l3
  set_env_l3
  
  ;;; Aurora
  tablea_path_arr = file_dirname(!tablea_path)+'/line_list_aurora_v1.dat' 
  pattern='*201{8}*dt00010*'
  
  ;;; Torus
  ;tablea_path_arr = file_dirname(!tablea_path)+'/line_list_torus_v1.dat'
  ;pattern='*201{8}*dt00106*'
  

  foreach tablea_path, tablea_path_arr do begin  
     planet_radii_deg=!NULL; deg/Rp
    make_fits_bintable_dir, l2_d=!l2p_dir, l2cal_p=!l2cal_path2, tablea_p=tablea_path, out_d=!out_dir, pattern=pattern, planet_radii_deg=planet_radii_deg, lightyear=lightyear
  endforeach
  
end