pro orbit__define
  tmp={orbit, $
    time   : bytarr(19), $;YYYY-MM-DDThh:mm:ss
    cml    : 0.d, $;//deg west magnetic longitude of target seen from observer
    mlat   : 0.d, $;//deg magnetic latitude of target seen from observer
    glon   : 0.d, $;//deg east longitude of target seen from observer
    glat   : 0.d, $;//deg geographic latitude of target seen from observer
    radii  : 0.d, $;//km  radial distance of target seen from observer
    rad_sun: 0.d, $;//km  radial distance of sun seen from observer
    lon_sun: 0.d, $;//deg east longitude of earth seen from observer
    ssl    : 0.d, $;//deg west longitude of sun seen from observer
    lat_sun: 0.d, $;//deg latitude of sun seen from observer
    lt_s   : 0.d, $;//hr  sun-based local time of target seen from observer
    ang_sot: 0.d, $;//deg angle of Sun-Observer-Target
    rad_ear: 0.d, $;//km  radial distance of earth seen from observer
    lon_ear: 0.d, $;//deg east longitude of earth seen from observer
    sel    : 0.d, $;//deg west longitude of earth seen from observer
    lat_ear: 0.d, $;//deg latitude of earth seen from observer
    lt_e   : 0.d, $;//hr  earth-based local time of target seen from observer
    ang_eot: 0.d, $;//deg angle of Earth-Observer-Target
    appdia : 0.d, $;//arcsec apparent diameter of Target
    abr_ra : 0.d, $;//deg    aberration of target in RA direction
    abr_dec: 0.d  $;//deg    aberration of target in DEC direction
    }
end