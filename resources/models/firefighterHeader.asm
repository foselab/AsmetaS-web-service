module firefighterHeader //domain-specific signature

import ../libraries/StandardLibrary
import ../libraries/SLEECLibrary
export *

signature:	
 /* DOMAIN-SPECIFIC SIGNATURE */
    
    //domains
	domain Temperature subsetof Real
	enum domain WindScale = {LIGHT | MODERATE | STRONG}
	enum domain CapabilityID = {DONOTHING, SOUNDALARM, GOHOME}
	
	//Events and sensed variables
	monitored batteryCritical: Boolean
	monitored cameraStart: Boolean
	monitored alarmRinging: Boolean //To not confuse with the obligation soundAlarm
	monitored personNearby: Boolean
	monitored temperature: Temperature 
	monitored windSpeed: WindScale
	static alarmdeadline: Integer //constant
	
	//Capabilities
	static goHome: Capability
	static soundAlarm: Capability
	static id: Capability -> CapabilityID //not in lib, since it depends on CapabilityID that is model-specific
	
/* CONSTANT (DOMAIN-GENERAL) SIGNATURE */	
	//NEW (compact, aggregated output)
	controlled info: Capability -> Prod(CapabilityID,TCType,Integer,TimerUnit,CapabilityID) //examples: (GOHOME,AFTER,5,MIN,undef), (GOHOME,WITHIN,8,MIN,SOUNDALARM)
	out outObligation: CapabilityID 
	out outConstraint: CapabilityID -> Prod(TCType,Integer,TimerUnit,CapabilityID)

	
definitions:
		
/* DOMAIN-SPECIFIC DEFINITIONS*/
    
	domain Temperature = {-5.0:50.0}
	
	function alarmdeadline = 30
	
	function id($c in Capability) = 
		switch $c
			case doNothing : DONOTHING
			case goHome : GOHOME
			case soundAlarm : SOUNDALARM
		endswitch	
	
    
/* CONSTANT (DOMAIN-GENERAL) DEFINITIONS */	
    //with no time constraint
	rule r_setObligation($c in Capability) = 
	par 
		doObligation := $c
		constraint($c) := none
		info($c) := (id($c),undef,undef,undef,undef)
		//prepare out locations
		outObligation := id($c) 
		outConstraint(id($c)) := (undef,undef,undef,undef) 
	endpar
	
	//complete overloading
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		doObligation := $c
		r_setTimeConstraint[$c,$type,$t,$u]
		if isDef($alt) then otherwiseC($c) := $alt endif
		info($c) := (id($c),$type,$t,$u,id($alt))
		//prepare out locations
		outObligation := id($c)
		outConstraint(id($c)) := ($type,$t,$u,id($alt))
	endpar		
		
			

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		



