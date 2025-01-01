# Parachute for YASim by Tomaskom
# This code drives three thrusters which need to be defined in the YASim FDM definition. They point in the X, Y, Z axis direction. The thrusters should be placed where the parachute is attached, not where the top of the parachute is! Only this way, it can properly reflect different directions of airflow. 


### User defined variables ###
var chuteArea = 104; #size of the parachute in square meters
var Cd = 1.42; #coefficient of drag: 1.42 for hollow hemisphere (like parachute)
var loop = 0.02; #seconds for looping force calculation; tested for 0.05 (20Hz) or faster
var chuteUnfold = 3; #seconds of chute unfolding time
var chutePower = "/controls/flight/parachute"; #property used for slow applying of the force as chute unfolds
var listen = "/controls/flight/drag-chute"; #boolean property triggering the parachute deployment
var show = "surface-positions/chute-pos-norm"; #property used to show/hide parachute model
var animTheta = "/orientation/parachute-theta"; #property for parachute 3D model animation
var animPhi = "/orientation/parachute-phi"; #property for parachute 3D model animation
var forcePoint = {x:0, y:0, z:1}; #vector pointing from CG to the point where force is applied - must reflect thrusters position!
var thrustCoef = 10000; #nominal thruster thrust as defined in YASim - must be the same to get properly scaled force
var limit = 1500; #limit of drag force, in multiples of nominal thruster thrust in YASim


var ftTom = 0.3048; #ft to m
var degToRad = 3.141592654/180;

props.globals.initNode("/controls/engines/thruster[1]/throttle", 0, "DOUBLE");
props.globals.initNode("/controls/engines/thruster[2]/throttle", 0, "DOUBLE");
props.globals.initNode("/controls/engines/thruster[3]/throttle", 0, "DOUBLE");
props.globals.initNode(chutePower, 0, "DOUBLE");
props.globals.initNode(show, 0, "DOUBLE");
props.globals.initNode(animTheta, 0, "DOUBLE");
props.globals.initNode(animPhi, 0, "DOUBLE");


### Extended trigonometric functions by Ampere K. [Hardraade] ###
# Returns arccos(x), with -1 < x < 1.
math.arccos = func(x){
	return (3.141592654/2 - math.arcsin(x));
}
# Returns arcsin(x), with -1 < x < 1.
math.arcsin = func(x){
	# Find arcsin(x) by first doing a table look-up, then interopolate the value of the desire point using
	#  integration.  Accuracy could be achieved up to the 8th decimal place if necessary.
	
	factor = 1;
	power = math.pow(10, 6);	# Accuracy up to the nth decimal place.
	precision = math.pow(power, -1);
	tableSize = 100;		# Size of the look-up table.
	
	# Negative and positive angles yield the same result, only the signs are different.
	if (x < 0){
		factor = -1;
		x = x * factor;
	}
	
	# Look-up table for every 1.8 degrees, for a total of 180 degrees.
	table = [0,
		0.010000167, 0.020001334, 0.030004502, 0.040010674, 0.050020857,
		0.060036058, 0.070057293, 0.080085580, 0.090121945, 0.100167421,
		0.110223050, 0.120289882, 0.130368980, 0.140461415, 0.150568273,
		0.160690653, 0.170829669, 0.180986451, 0.191162147, 0.201357921,
		0.211574960, 0.221814470, 0.232077683, 0.242365851, 0.252680255,
		0.263022203, 0.273393031, 0.283794109, 0.294226838, 0.304692654,
		0.315193032, 0.325729487, 0.336303575, 0.346916898, 0.357571104,
		0.368267893, 0.379009021, 0.389796296, 0.400631593, 0.411516846,
		0.422454062, 0.433445320, 0.444492777, 0.455598673, 0.466765339,
		0.477995199, 0.489290778, 0.500654712, 0.512089753, 0.523598776,
		0.535184790, 0.546850951, 0.558600565, 0.570437109, 0.582364238,
		0.594385800, 0.606505855, 0.618728691, 0.631058841, 0.643501109,
		0.656060591, 0.668742703, 0.681553212, 0.694498266, 0.707584437,
		0.720818761, 0.734208787, 0.747762635, 0.761489053, 0.775397497,
		0.789498209, 0.803802319, 0.818321951, 0.833070358, 0.848062079,
		0.863313115, 0.878841152, 0.894665817, 0.910808997, 0.927295218,
		0.944152115, 0.961411019, 0.979107684, 0.997283222, 1.015985294,
		1.035269672, 1.055202321, 1.075862200, 1.097345170, 1.119769515,
		1.143284062, 1.168080485, 1.194412844, 1.222630306, 1.253235898,
		1.287002218, 1.325230809, 1.370461484, 1.429256853, 1.570796327];
		
	intPart = int(x * tableSize + 0.5);
	decPart = (x * tableSize - intPart) / tableSize ;
	
	area = 0;
	# Perform integration to calculate arcsin(x).
	# Positive case:
	for(i = intPart/tableSize; i < intPart/tableSize + decPart; i = i + precision){
		# Calculate the area of a trapezoid.
		a = 1 / math.sqrt(1 - math.pow(i, 2));
		b = 1 / math.sqrt(1 - math.pow(i + precision, 2));
		
		area = area + a + b;
	}
	# Negative case:
	for(i = (intPart - precision) / tableSize; i > intPart/tableSize + decPart; i = i - precision){
		# Calculate the area of a trapezoid.
		a = 1 / math.sqrt(1 - math.pow(i - precision, 2));
		b = 1 / math.sqrt(1 - math.pow(i, 2));
		
		area = area - a - b;
	}
	
	return ((table[intPart] + int(area + 0.5) * precision / 2) * factor);
}
### END OF Extended trigonometric functions ###



#the main loop computing force
var chute = func {
	var heading = degToRad * getprop("/orientation/heading-deg"); #right is positive
	var pitch = degToRad * getprop("/orientation/pitch-deg"); #up is positive
	var roll = degToRad * getprop("/orientation/roll-deg"); #right is positive
	
	#get velocity components
	var speedUp = -getprop("/velocities/speed-down-fps");
	var speedEast = getprop("/velocities/speed-east-fps");
	var speedNorth = getprop("/velocities/speed-north-fps");
	var windUp = getprop("/environment/wind-from-down-fps");
	var windEast = -getprop("/environment/wind-from-east-fps"); #wind TO east
	var windNorth = -getprop("/environment/wind-from-north-fps"); # winf TO north
	
	#subtract wind components
	var up = speedUp - windUp;
	var east = speedEast - windEast;
	var north = speedNorth - windNorth;
	
	var up_mps = ftTom * up;
	var east_mps = ftTom * east;
	var north_mps = ftTom * north;
	
	#take heading in account
	var fwd_mps = math.cos(heading) * north_mps + math.sin(heading) * east_mps;
	var left_mps = math.sin(heading) * north_mps - math.cos(heading) * east_mps;
	
	#transform speed components to local up, fwd and side
	var up_local = up_mps * math.cos(pitch) * math.cos(roll) - fwd_mps * math.sin(pitch) * math.cos(roll) - left_mps * math.sin(roll);
	var fwd_local = fwd_mps * math.cos(pitch) + up_mps * math.sin(pitch);
	var left_local = left_mps * math.cos(roll) + up_mps * math.sin(roll) * math.cos(pitch) - fwd_mps * math.sin(pitch) * math.sin(roll);
	
	var pitchRateFix = (abs(getprop("/orientation/roll-deg"))<90 ? 1 : -1);
	
	var pitchRate = degToRad * getprop("/orientation/pitch-rate-degps");
	var rollRate = degToRad * getprop("/orientation/roll-rate-degps");
	var yawRate = degToRad * getprop("/orientation/yaw-rate-degps") * pitchRateFix;
	
	
	#forcePoint speed components relative to air - add components caused by rotation of hanging aircraft (dampens oscillations if I don't omit this)
	var upPoint = 
		up_local 
		+ forcePoint.x * pitchRate * pitchRateFix 
		+ forcePoint.y * rollRate 
		+ math.sin(roll) * forcePoint.x * yawRate * math.cos(pitch);
		
	var fwdPoint = 
		fwd_local 
		- forcePoint.z * pitchRate * pitchRateFix 
		+ forcePoint.y * yawRate * math.cos(pitch) 
		- math.sin(roll) * forcePoint.y * pitchRate;
		
	var leftPoint = 
		left_local 
		- forcePoint.x * yawRate * math.cos(pitch) 
		- forcePoint.z * rollRate 
		+ math.sin(roll) * forcePoint.x * pitchRate;
	
	#debugging output
	#print("up_local:"~up_local~" fwd_local:"~fwd_local~" left_local:"~left_local);
	#print("upPoint:"~upPoint~ " fwdPoint:"~fwdPoint~" leftPoint:"~leftPoint); print("");
	
	#get normalized vector
	var vectSize = math.sqrt(upPoint*upPoint + fwdPoint*fwdPoint + leftPoint*leftPoint);
	var direction = {x:fwdPoint/vectSize, y:leftPoint/vectSize, z:upPoint/vectSize};
	
	#get total drag force
	var airDensity = 515.4 * getprop("/environment/density-slugft3");
	var force = 0.5 * airDensity * vectSize*vectSize * Cd * chuteArea;
	var forcelb = 0.2248 * force;
	
	
	var xThrust = -forcelb * direction.x / thrustCoef;
	var yThrust = -forcelb * direction.y / thrustCoef;
	var zThrust = -forcelb * direction.z / thrustCoef;
	
	
	setprop("/controls/engines/thruster[1]/throttle", (abs(xThrust)>limit?limit*math.sgn(xThrust):xThrust)*getprop(chutePower));
	setprop("/controls/engines/thruster[2]/throttle", (abs(yThrust)>limit?limit*math.sgn(yThrust):yThrust)*getprop(chutePower));
	setprop("/controls/engines/thruster[3]/throttle", (abs(zThrust)>limit?limit*math.sgn(zThrust):zThrust)*getprop(chutePower));
	
	
	#parachude 3D model orientation calculation
	setprop(animTheta, math.arccos(-direction.z)/degToRad);
	setprop(animPhi, math.atan2(direction.x,-direction.y)/degToRad);
	
}



#cycle the main loop only when chute is deployed
var chuteTimer = maketimer(loop, chute);
chuteTimer.singleShot = 0;

setlistener(listen, 
	func {
		if(getprop(listen)) {
			setprop(chutePower, 0);
			interpolate(chutePower, 1, chuteUnfold);
			setprop(show, 1);
			print("Deploying parachute!");
			chuteTimer.start();
		}
		else {
			interpolate(chutePower, 0, 0);
			print("Parachute cut away!");
			setprop(show, 0);
			chuteTimer.stop();
			setprop("/controls/engines/thruster[1]/throttle", 0);
			setprop("/controls/engines/thruster[2]/throttle", 0);
			setprop("/controls/engines/thruster[3]/throttle", 0);
			setprop(chutePower, 0);
		}
	}
);



