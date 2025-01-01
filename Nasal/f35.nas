    setlistener("/controls/engines/engine[0]/throttle", func(n) {
	position=n.getValue();
    setprop("/controls/engines/engine[0]/reheat",0);
        if(position >= 0.95){

               setprop("/controls/engines/engine[0]/reheat",1);
     };
   },1);

## LIGHTS

beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 1.2,], "/controls/lighting/beacon" );

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0.05, 3,], "/controls/lighting/strobe" );


beacon_switch = props.globals.getNode("controls/lighting/nav-lights", 1);
var strobe = aircraft.light.new( "/sim/model/lights/nav-lights", [0.5, 1,], "/controls/lighting/nav-lights" );

#DOORS, BAY DOORS, REFUELLING DOORS AND EMERGENCY ARREST HOOK
#CANOPY: f35.canopy.toggle();
canopy  = aircraft.door.new("/sim/model/door-positions/canopy", 4, 0 );

#BAYDOORS: f35.baydoor.toggle();
baydoor = aircraft.door.new("/sim/model/door-positions/baydoor", 3, 0 );

#REFUELLING DOORS: f35.fuel.toggle();
fuel  = aircraft.door.new("/sim/model/door-positions/fuel", 2, 0 );

#EMERGENCY ARREST HOOK: f35.hook.toggle();
hook = aircraft.door.new("/sim/model/door-positions/hook", 2, 0 );


