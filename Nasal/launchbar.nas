# ====================================#
# Launchbar BARANGER Emmanuel 05/2023 #
# ====================================#

var autolaunchbar = func {
  var lb = getprop("/controls/gear/launchbar");
  var ge = getprop("/gear/gear[0]/wow");

  if ( lb == 1 ) {
    if ( ge == 0 ) {
      setprop("/controls/gear/launchbar", 0);
    }
  }

  settimer(autolaunchbar, 0);
}

autolaunchbar();
