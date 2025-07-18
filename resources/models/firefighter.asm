//Version 2.0: Single obligation
// Sample SLEEC rules for a firefighter UAV
//CaseStudies/FireFighter/jss_running_example.sleec

asm firefighter

import ../libraries/StandardLibrary
import ../libraries/SLEECLibrary
import firefighterHeader

signature: 
	
definitions:
	

	/* DOMAIN-SPECIFIC CONTROL RULES*/
    
	 
    //default: no obligation to do
	rule r_doNothing = r_setObligation[doNothing]
	
	rule r_soundAlarm = r_setObligation[soundAlarm]
			
	rule r_soundAlarmWithinTwoSeconds = r_setObligation[soundAlarm,WITHIN,2,SEC,doNothing]
	
	rule r_goHome = r_setObligation[goHome]
		
	rule r_goHomeAfterFiveMinutes = r_setObligation[goHome,AFTER,5,MIN,doNothing]

	rule r_goHomeWithinOneMinute = r_setObligation[goHome,WITHIN,1,MIN,doNothing]
	
	
	//legal, social
	rule r_Rule1 =
		if cameraStart and personNearby then r_soundAlarm[] endif 
		//if cameraStart and personNearby then r_soundAlarm[] else r_doNothing[] endif //Added do_nothing to complete the spec
		
	
	//legal, ethical	
	rule r_Rule2 =
		if cameraStart and personNearby then r_soundAlarmWithinTwoSeconds[] endif
		//if cameraStart and personNearby then r_soundAlarmWithinTwoSeconds[] else r_doNothing[] endif //Added do_nothing to complete the spec
		
			
	//legal		
	rule r_Rule3 =
       if alarmRinging then r_goHomeAfterFiveMinutes[] endif 
		//if alarmRinging then r_goHomeAfterFiveMinutes[] else r_doNothing[] endif //Added do_nothing to complete the spec
		
	rule r_RuleA =
	   if batteryCritical and temperature < 25.0 then r_goHomeWithinOneMinute[] endif 
		//if batteryCritical and temperature < 25.0 then r_goHomeWithinOneMinute[] else r_doNothing[] endif //Added do_nothing to complete the spec
		
	//	
	//emphatatic	
	rule r_Rule4 =
		r_SLEEC[cameraStart, <<r_soundAlarm>>, personNearby, <<r_goHome>>, temperature > 35.0, <<r_doNothing>>]
		//r_SLEEC[cameraStart, <<r_soundAlarm>>, personNearby, <<r_goHome>>, temperature > 35.0, <<r_doNothing>>,<<r_doNothing>>] //Added do_nothing to complete the spec
	
	  
	/* CONSTANT (DOMAIN-GENERAL) RULES*/
	
	//NEW
	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				info($c) := (undef,undef,undef,undef,undef)
				outConstraint(id($c)) := (undef,undef,undef,undef)
				doObligation := undef
			    outObligation := undef
				constraint($c) := undef
				otherwiseC($c) := undef
			endpar
	
	//invariant inv_I0 over  doObligation, outObligation: (doObligation = outObligation)
	
	/* DOMAIN-SPECIFIC RULES*/
		
	main rule r_Main =  
		seq	
			r_Reset[] //reset of out locations in sequential order, otherwise the function resetting updates will not be visible to the other rules in one machine step
			//par 
			//Rule1 and Rule2 are redundant (inconsistent update on secondary attributes of the doOblication) 
			//r_Rule1[]
			//r_Rule2[]
			//r_Rule3[] //Rule1 and RuleA are in conflict (inconsistent update on doOblication: e.g. doObligation updated to soundAlarm and goHome) [From the source spec: they are conflicting rules: RuleA requires GoHome to take place, but Rule3 forbids it.
			//r_RuleA[]
			//r_Rule4[] 
			//example of SLEEC rule covering all modeling constructs
			r_SLEEC[cameraStart, <<r_soundAlarm>>, personNearby, <<r_goHomeWithinOneMinute>>, temperature > 35.0, <<r_goHomeAfterFiveMinutes>>]
			//endpar
		endseq

default init s0:


