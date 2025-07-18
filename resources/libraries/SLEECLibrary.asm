// definition of SLEEC rule 
//version 2.0: Single obligation
module SLEECLibrary


import StandardLibrary
export *

signature:
	enum domain TimerUnit={NANOSEC, MILLISEC, SEC, MIN, HOUR}//lib
	enum domain TCType = {AFTER | WITHIN} //lib
	abstract domain Capability //lib
	dynamic abstract domain TimeConstraint //lib
	controlled value: TimeConstraint -> Integer //lib
	controlled unit: TimeConstraint -> TimerUnit //lib
	controlled type: TimeConstraint -> TCType //lib
	controlled otherwiseC: Capability -> Capability //lib, applicable only with WITHIN time constraint
	controlled constraint: Capability -> TimeConstraint //lib
	static doNothing : Capability //lib	
	static none : TimeConstraint //lib	
	
	//Obligation to act
	controlled doObligation: Capability //lib; one obligation as output
	

definitions:
			
															
	rule r_skip = skip // named rule for doing nothing
	
	//lib
	rule r_setTimeConstraint($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit) = 
	extend TimeConstraint with $tc do
		par
			value($tc) := $t
			unit($tc) := $u
			type($tc) := $type 
			constraint($c) := $tc
			//constraint($c) := append(constraint($c),$tc)
		endpar
		
	
										
	//SLEEC constructor for 1 condition
	rule r_SLEEC($c0 in Boolean, $o0 in Rule) =
	 if $c0 then $o0 endif
	 
	//SLEEC constructor for 2 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 then $o1 endif endif
	
	//SLEEC constructor for 3 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 and not $c2 then $o1 
	 else if $c0 and $c1 and $c2 then $o2 endif endif endif
	
	 //SLEEC constructor for 4 conditions
	 rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule) =
	 if ($c0 and not $c1) then $o0 
	 else if ($c0 and $c1 and not $c2) then $o1 
     else if ($c0 and $c1 and $c2 and not $c3) then $o2
     else if ($c0 and $c1 and $c2 and $c3) then $o3 endif endif endif endif
	 

	 //SLEEC constructor for 5 conditions
	 rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule, $c4 in Boolean, $o4 in Rule) =
	 	if $c0 and not $c1 then $o0 
		else if $c0 and $c1 and not $c2 then $o1 
		else if $c0 and $c1 and $c2 and not $c3 then $o2
		else if $c0 and $c1 and $c2 and $c3 and not $c4 then $o3
		else if $c0 and $c1 and $c2 and $c3 and $c4 then $o4
	    endif endif endif endif endif
	 
	 //SLEEC constructor for 1 condition
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $defaultO in Rule) =
	 if $c0 then $o0 else $defaultO endif
	 
	//SLEEC constructor for 2 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $defaultO in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 then $o1 else $defaultO endif endif
	
	//SLEEC constructor for 3 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $defaultO in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 and not $c2 then $o1 
	 else if $c0 and $c1 and $c2 then $o2 else $defaultO endif endif endif
	 
	 
	  rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule, $defaultO in Rule) =
	 if ($c0 and not $c1) then $o0 
	 else if ($c0 and $c1 and not $c2) then $o1 
     else if ($c0 and $c1 and $c2 and not $c3) then $o2
     else if ($c0 and $c1 and $c2 and $c3) then $o3 else $defaultO endif endif endif endif
	 

	 	//SLEEC constructor for 5 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule, $c4 in Boolean, $o4 in Rule, $defaultO in Rule) =
	 	if $c0 and not $c1 then $o0 
		else if $c0 and $c1 and not $c2 then $o1 
		else if $c0 and $c1 and $c2 and not $c3 then $o2
		else if $c0 and $c1 and $c2 and $c3 and not $c4 then $o3
		else if $c0 and $c1 and $c2 and $c3 and $c4 then $o4 else $defaultO
	    endif endif endif endif endif
	 