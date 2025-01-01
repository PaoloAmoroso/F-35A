#############################################################################
#### Helijah                                                     08-2020 ####
####                                                                     ####
#### Quelques propriétés utiles                                          ####
#############################################################################

var convert = func {
  ###########################################################################
  var rpm0 = getprop("/engines/engine[0]/rpm");
  if ( ! rpm0 ) {
    rpm0 = 0;
  }
  var cht0 = getprop("/engines/engine[0]/cht-degC");
  if ( ! cht0 ) {
    cht0 = 0;
  }
  var egt0 = getprop("/engines/engine[0]/egt-degC");
  if ( ! egt0 ) {
    egt0 = 0;
  }
  var mp0 = getprop("/engines/engine[0]/mp-osi");
  if (! mp0 ) {
    mp0 = 0;
  }
  var run0 = getprop("/engines/engine[0]/running");
  if (! run0 ) {
    run0 = 0;
  }
  var flow0 = getprop("/engines/engine[0]/fuel-flow-gph");
  if ( ! flow0 ) {
    flow0 = 0;
  }
  var oilt0 = getprop("/engines/engine[0]/oil-temperature");
  if ( ! oilt0 ) {
    oilt0 = 0;
  }
  ###########################################################################
  var rpm1 = getprop("/engines/engine[1]/rpm");
  if ( ! rpm1 ) {
    rpm1 = 0;
  }
  var cht1 = getprop("/engines/engine[1]/cht-degC");
  if ( ! cht1 ) {
    cht1 = 0;
  }
  var egt1 = getprop("/engines/engine[1]/egt-degC");
  if ( ! egt1 ) {
    egt1 = 0;
  }
  var mp1 = getprop("/engines/engine[1]/mp-osi");
  if (! mp1 ) {
    mp1 = 0;
  }
  var run1 = getprop("/engines/engine[1]/running");
  if (! run1 ) {
    run1 = 0;
  }
  var flow1 = getprop("/engines/engine[1]/fuel-flow-gph");
  if ( ! flow1 ) {
    flow1 = 0;
  }
  var oilt1 = getprop("/engines/engine[1]/oil-temperature");
  if ( ! oilt1 ) {
    oilt1 = 0;
  }
  ###########################################################################
  var oat = getprop("/environment/temperature-degc");
  if ( ! oat ) {
    oat = 0;
  }
  var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
  if ( ! ias ) {
    ias = 0;
  }

  var mb0 = getprop("/engines/engine[0]/torque-ftlb");
  if ( ! mb0 ) {
    mb0 = 0;
  }
  var mb1 = getprop("/engines/engine[1]/torque-ftlb");
  if ( ! mb1 ) {
    mb1 = 0;
  }

  var fuel_pres0 = 0.0;
  var oil_pres0 = 0.0;
  var fuel_pres1 = 0.0;
  var oil_pres1 = 0.0;
  ###########################################################################

  if ( mp0 < 10) {
     mp0 = 10;
  }
  if ( mp1 < 10) {
     mp1 = 10;
  }

  #Engine 0
  if (run0) {
    cht0  = cht0 + (mp0 * 8 + oat - ias/3 - cht0) / 250;
    egt0  = egt0 + ((mp0 * 30 + cht0 * 2) * mp0 / (flow0 * 2 + 1) - egt0) / 100;
    oilt0 = oilt0 +(rpm0 / 25 + oat - oilt0) / 250;
  } else {
    if ( ! cht0  ) {
      cht0 = oat;
    }
    if ( ! egt0  ) {
      egt0 = oat;
    }
    if ( ! oilt0 ) {
      oilt0 = oat;
    }
    cht0 = cht0 + (oat - cht0)/100;
    egt0 = egt0 + (oat - egt0)/100;
    oilt0 = oilt0 + (oat - oilt0)/100;
  }
  #Engine 1
  if (run1) {
    cht1  = cht1 + (mp1 * 8 + oat - ias/3 - cht1) / 250;
    egt1  = egt1 + ((mp1 * 30 + cht1 * 2) * mp1 / (flow1 * 2 + 1) - egt1) / 100;
    oilt1 = oilt1 +(rpm1 / 25 + oat - oilt1) / 250;
  } else {
    if ( ! cht1  ) {
      cht1 = oat;
    }
    if ( ! egt1  ) {
      egt1 = oat;
    }
    if ( ! oilt1 ) {
      oilt1 = oat;
    }
    cht1 = cht1 + (oat - cht1)/100;
    egt1 = egt1 + (oat - egt1)/100;
    oilt1 = oilt1 + (oat - oilt1)/100;
  }

  #Engine 0
  if (rpm0 > 100.0) {
    fuel_pres0 = rpm0 / 100;
    oil_pres0 = rpm0 / 25;
  }

  #Engine 1
  if (rpm1 > 100.0) {
    fuel_pres1 = rpm1 / 100;
    oil_pres1 = rpm1 / 25;
  }

  setprop("/engines/engine[0]/oil-pressure-psi", oil_pres0);
  setprop("/engines/engine[0]/fuel-pressure-psi", fuel_pres0);

  setprop("/engines/engine[1]/oil-pressure-psi", oil_pres1);
  setprop("/engines/engine[1]/fuel-pressure-psi", fuel_pres1);

  setprop("/engines/engine[0]/cht-degC", cht0);
  setprop("/engines/engine[0]/oil-temperature", oilt0);
  setprop("/engines/engine[0]/egt-degC", egt0);
  setprop("/engines/engine[0]/egt-degf-calc", egt0 * 9/5 + 32);

  setprop("/engines/engine[1]/cht-degC", cht1);
  setprop("/engines/engine[1]/oil-temperature", oilt1);
  setprop("/engines/engine[1]/egt-degC", egt1);
  setprop("/engines/engine[1]/egt-degf-calc", egt1 * 9/5 + 32);

  setprop("/systems/electrical/amp", (rpm0 + rpm1) / 100 );

  ##################################################
  # Torque -> Pourcent by Helijah : Max 4094 -> 100%
  ##################################################
  var torqpourcent = mb0  * 0.0244259892526;
  setprop("/engines/engine[0]/torque-pourcent", torqpourcent);
  var smb = sprintf("%03.f", torqpourcent);

  setprop("/engines/engine[0]/Torque/unit100", chr(smb[0]));
  setprop("/engines/engine[0]/Torque/unit10", chr(smb[1]));
  setprop("/engines/engine[0]/Torque/unit1", chr(smb[2]));

  torqpourcent = mb1  * 0.0244259892526;
  setprop("/engines/engine[1]/torque-pourcent", torqpourcent);
  smb = sprintf("%03.f", torqpourcent);

  setprop("/engines/engine[1]/Torque/unit100", chr(smb[0]));
  setprop("/engines/engine[1]/Torque/unit10", chr(smb[1]));
  setprop("/engines/engine[1]/Torque/unit1", chr(smb[2]));
  ##################################################

  setprop("/engines/engine[0]/egt-degC", convertTemp(getprop("/engines/engine[0]/egt-degf")));
  setprop("/engines/engine[0]/oil-temperature-degC", convertTemp(getprop("/engines/engine[0]/oil-temperature-degf")));

  setprop("/engines/engine[1]/egt-degC", convertTemp(getprop("/engines/engine[1]/egt-degf")));
  setprop("/engines/engine[1]/oil-temperature-degC", convertTemp(getprop("/engines/engine[1]/oil-temperature-degf")));

  setprop("/engines/engine[0]/itt-norm", getprop("/engines/engine[0]/cht-degC") / 100);
  setprop("/engines/engine[1]/itt-norm", getprop("/engines/engine[0]/cht-degC") / 100);
}

var convertTemp = func(degF) {
  var degC = 0;
  if ( degF != nil ) {
    #print(degF);
    degC = (degF - 32) * 5/9;
  }
  return degC;
}

###  Main loop ###
var update_convert = func {
  convert();
  settimer(update_convert, 0);
}
setlistener("/sim/signals/fdm-initialized", update_convert());
