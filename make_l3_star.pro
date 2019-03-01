pro make_l3_star

  set_env_l3
;  load_spice
  
  tablea_path_arr=[$
    '/Users/moxon/dropbox/private/exapi/l3/hisaki-l3/line_list_star_v1.dat'$
    ]

  foreach tablea_path, tablea_path_arr do begin
    l2_dir      = !l2_dir
    l2cal_path  = !l2cal_path
    tablea_path = tablea_path
    out_dir     = !out_dir
  
    pattern='*201{81115,81116}*d006*'
;   pattern='*2018*'
    
    planet_radii_deg=40.d/3600.; deg/Rp  
    lightyear=168.d; lightyear
    waveshift=-4.0d; angstrom
        
    make_fits_bintable_dir, l2_d=l2_dir, l2cal_p=l2cal_path, tablea_p=tablea_path, out_d=out_dir, pattern=pattern, planet_radii_deg=planet_radii_deg, lightyear=lightyear, waveshift=waveshift
  endforeach
end
