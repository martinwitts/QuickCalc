package MaxDemand;


use feature 'say';
use lib qw(/home/twiki/lib/CPAN/lib);
use Switch;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper; 
 
 
has 'circuit_type'    => (isa => 'Num', is => 'rw');
has 'premise_type'      => (isa => 'Num', is => 'rw');
has 'keys_in'      => (isa => 'ArrayRef', is => 'rw');
has 'values_in'      => (isa => 'ArrayRef', is => 'rw');

#get device type--------------------------------
sub data_check {
   my $self = shift;
	my $ret = $self->circuit_type;
	return $ret;
}

sub main{
	my $self = shift;
	my $keys_ref = $self->keys_in;
	my $vals_ref = $self->values_in;
    my (@md1, @md2,@md3, @md4, @md5, @md6, @md7, @md8, @md9, @md10) = ();#initialise 10 circuit types
    
for my $k (@$keys_ref) {
    my $v = shift @$vals_ref;
    say "";
    say "circuit type - ".$k .":". "design current - ".$v;
                #switch
            switch ($k) {# if key is in case then push into relevant array
    		case 1 {push @md1, $v;}
    		case 2 {push @md2, $v;}
    		case 3 {push @md3, $v;}
    		case 4 {push @md4, $v;}
    		case 5 {push @md5, $v;}
    		case 6 {push @md6, $v;}
    		case 7 {push @md7, $v;}
    		case 8 {push @md8, $v;}
    		case 9 {push @md9, $v;}
    		case 10 {push @md10, $v;}
            }
    		
}
    	my @sorted1 = sort { $a <=> $b } @md1;
	my @sorted2 = sort { $a <=> $b } @md2;
	my @sorted3 = sort { $a <=> $b } @md3;
	my @sorted4 = sort { $a <=> $b } @md4;
	my @sorted5 = sort { $a <=> $b } @md5;
	my @sorted6 = sort { $a <=> $b } @md6;
	my @sorted7 = sort { $a <=> $b } @md7;
	my @sorted8 = sort { $a <=> $b } @md8;
	my @sorted9 = sort { $a <=> $b } @md9;
	my @sorted10 = sort { $a <=> $b } @md10;
	
			say Dumper @sorted10;
			#say Dumper @sorted2;			
                #switch
            switch ($self->premise_type) {
            case 1 {
#---------------------------------------------------------------------------            	
            my $sum1 = ();
	    grep { $sum1 += $_ } @sorted1;
	    if (not defined $sum1){say "NO CIRCUIT TYPE 1 - Lighting";
	    	$sum1 = 0;
	    }
	    else{
            say "--------------------------------";		
            say "Total for lighting circuits: ".$sum1;
	    }
	    
	    my $md1 = (($sum1*66)/100);
            say "--------------------------------";	
	        say "Maximum demand with Diversity for lighting(dwellings) : ".$md1;
	        say "--------------------------------";
	    
	    
#---------------------------------------------------------------------------	        
    	    #Heating
		my $heating = scalar(map {1 .. $_} @sorted2);
		say "Total for all heating circuits :$heating";
		say "--------------------------------";
		my $md2 = 0;
		if (not defined $heating){say "NO CIRCUIT TYPE 2 - Heating";
		$heating = 0;
		say "Maximum demand with diversity for heating(dwellings) : 0";
		my $md2 = 0;
		}
		elsif (defined $heating){
		say "Heating defined as:".$heating;
		
		}
    	    
    			    if ($heating > 10){
    			    	my $rem = ($heating-10);
    			    	my $whole = ($heating-$rem);
    			    	$md2 = (($whole)+($rem/2));
    			    	say "Maximum demand with diversity for heating(dwellings) : ". $md2;
    			    	say "--------------------------------";
    			    }
		
#---------------------------------------------------------------------------
    			    
			   my $cooking = scalar(map {1 .. $_} @sorted3);
    		say "Total for cooking(dwellings): ".$cooking;
    		say "--------------------------------";
		my $md3 = 0; 
		if (not defined $cooking){say "NO CIRCUIT TYPE 3 - Cooking";
		$cooking = 0;
		}
		elsif (defined $cooking){
		say "Cooking defined as:".$cooking;
		
		}
    			        
    			        
    			  if ($cooking > 10){
    			  	    my $rem = ($cooking-10);
    			    	my $whole = ($cooking-$rem);
    			    	$md3 = (($whole)+($rem*30)/100);
    			    	say "Max for cooking(dwellings) : ". $md3;
    			    	say "--------------------------------";
    			  }
#---------------------------------------------------------------------------
						my $sum4;grep { $sum4 += $_ } @sorted4;
						if (not defined $sum4){say "NO CIRCUIT TYPE 4 - motors";
	    				$sum4 = 0;
	    				}
						else{}
    			  		my $md4 = $sum4;say "Maximum demand for motors : ".$md4;
    			        say "--------------------------------";
						
#---------------------------------------------------------------------------  			    
    			    my $sum5;grep { $sum5 += $_ } @sorted5;
    			    my $md5 = 0; 
    			    	if (not defined $sum5){say "NO CIRCUIT TYPE 5 - inst water heaters";
    			    	say "--------------------------------";
	    				$sum5 = 0;
	    				}
	    				else{
    			    say "Total for inst water heaters is ". $sum5;
     			    say "--------------------------------";
	    				}
     			       	
     			    @sorted5 = sort { $b cmp $a } @sorted5;#reverse sort
     			    for my $i (@sorted5){
     			    	#say $i;
     			    if (scalar @sorted5 > 1 && scalar @sorted5 < 3){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					$md5 = $first + $second;#say $md5;
					say "Max for inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted5 > 2){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					my $rest;grep { $rest += $_ } @sorted5;#say $rest;
					$md5 = ((($first + $second)+($rest*25)/100));
					say "Max for all inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted5 == 1){
					my $first = shift(@sorted5); #say $first;
					$md5 = $first;say "Max for inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    }		    
#---------------------------------------------------------------------------   
    			    my $sum6;grep { $sum6 += $_ } @sorted6;
    			    if (not defined $sum6){say "NO CIRCUIT TYPE 6 - thermostatic water heaters";
	    				$sum6 = 0;
	    				}
	    				else{}
    			    say "Total for thermo water heaters is ". $sum6;
     			    say "--------------------------------";
     			    my $md6 = $sum6;   			    
#---------------------------------------------------------------------------   
    			    my $sum7;grep { $sum7 += $_ } @sorted7;
    			    if (not defined $sum7){say "NO CIRCUIT TYPE 7 - floor warming";
	    				$sum7 = 0;
	    				}
	    				else{}
    			    say "Total for floor warming is ". $sum7;
     			    say "--------------------------------";   		
     			    my $md7 = $sum7;	    
#---------------------------------------------------------------------------   
    			    my $sum8;grep { $sum8 += $_ } @sorted8;
    			    if (not defined $sum8){say "NO CIRCUIT TYPE 8 - storage space heating";
	    				$sum8 = 0;
	    				}
	    				else{}
    			    say "Total for storage space heating is ". $sum8;
     			    say "--------------------------------";   
     			    my $md8 = $sum8;			    
#---------------------------------------------------------------------------   
    			    
    			    my $md9;
    			    my $sum9;grep { $sum9 += $_ } @sorted9;
    			    if (not defined $sum9){say "NO CIRCUIT TYPE 9 - standard final circuits";
	    				$sum9 = 0;
	    				$md9 = 0;
	    				}
	    				elsif(defined $sum9){
    			    say "Defined - standard final circuits ". $sum9;
     			    say "--------------------------------";
     			    
	    				}   
	    				    			    
    			    say "Total for standard final circuits is ". $sum9;
     			    say "--------------------------------"; 
     			    
     			    
     			    @sorted9 = sort { $b cmp $a } @sorted9;#reverse sort
     			    if (scalar @sorted9 ==1){
     			    	say "sorted9 array contains = ".scalar @sorted9;
     			    	my $sum91;grep { $sum91 += $_ } @sorted9;
     			    	say "sum is :".$sum91;
     			    	$md9 = $sum91;
     			    	say "Max for standard final circuits is for 1 :".$md9;
     			    	}
     			    if (scalar @sorted9 > 1){
     			    	say "sorted9 array contains = ".scalar @sorted9;
     			    	my $first = shift(@sorted9);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted9;#say $rest;
     			    	$md9 = ($first + ($rest*40)/100);
     			    	say "Max for standard final circuits is for more than 1 :".$md9;
     			    }
     			    say "--------------------------------"; 		    
#---------------------------------------------------------------------------   
    			    
    			    my $md10;
    			    my $sum10;grep { $sum10 += $_ } @sorted10;
    			    if (not defined $sum10){
    			    	say "NO CIRCUIT TYPE 10 - socket outlets";
	    				$sum10 = 0;
	    				$md10 = 0;
	    				}
	    				elsif(defined $sum10){
    			    say "Defined - Total for socket outlets ". $sum10;
     			    say "--------------------------------";
     			    
	    				}     			    

    			      
     			    @sorted10 = sort { $b cmp $a } @sorted10;#reverse sort
     			    if (scalar @sorted10 ==1){
     			    	say "sorted10 array contains = ".scalar @sorted10;
     			    	my $sum;grep { $sum += $_ } @sorted10;
     			    	$md10 = $sum;
     			    	say "Max for socket outlets is for 1 :".$md10;
     			    	}
     			    if (scalar @sorted10 > 1){
     			    	say "sorted10 array contains = ".scalar @sorted10;
     			    	my $first = shift(@sorted10);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted10;#say $rest;
     			    	$md10 = ($first + ($rest*40)/100);
     			    	say "Max for socket outlets is for more than 1 :".$md10;
     			    }
     			    say "--------------------------------";   
     			    			    
#--------------------------------------------------------------------------- 

my $total = ($md1 + $md2 +  $md3 + $md4 + $md5 + $md6 +$md7 + $md8 +  $md9 + $md10);
return ($total);

  			    
    		}
    		case 2 {
#---------------------------------------------------------------------------            	
            my $sum1;grep { $sum1 += $_ } @sorted1;
            say "--------------------------------";		
            say "total for lighting(2): ".$sum1;my $md1 = (($sum1*90)/100);
            say "--------------------------------";	
	        say "max for lighting(2) : ".$md1;
	        say "--------------------------------";
#---------------------------------------------------------------------------	        
    	    my $sum2;grep { $sum2 += $_ } @sorted2;
    	    say "total for heating(2): ". $sum2;
    	    say "--------------------------------";
    	    my $md2 = $sum2;
    			     @sorted2 = sort { $b cmp $a } @sorted2;#reverse sort
     			    if (scalar @sorted2 ==1){#say scalar @sorted2;
     			    	my $sum;grep { $sum += $_ } @sorted2;
     			    	$md2 = $sum;
     			    	}
     			    if (scalar @sorted2 > 1){#say scalar @sorted2;
     			    	my $first = shift(@sorted2);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted2;#say $rest;
     			    	$md2 = ($first + ($rest*75)/100);
     			    	say "Max for heating is (2): ".$md2;
     			   	say "--------------------------------";     			    	
     			    }    

#---------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<cooking>>>>>>>>>>>>>>>>>>
    			    my $sum3;grep { $sum3 += $_ } @sorted3;
    			   say "total for cooking(3): ".$sum3;
    			   	say "--------------------------------"; 
    			    my $md3 = $sum3;
     			    @sorted3 = sort { $b cmp $a } @sorted3;#reverse sort
     			    for my $i (@sorted3){
     			    	#say $i;
     			    if (scalar @sorted3 > 1 && scalar @sorted3 < 3){
					my $first = shift(@sorted3); #say $first;
					my $second = shift(@sorted3); #say $second;
					my $total = (($first + ($second*80)/100));#say "1+2= ".$total;
					
					$md3 = $total;
					say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted3 >2){
					my $first = shift(@sorted3); #say $first;
					my $second = shift(@sorted3); #say $second;
					my $remainder = (($sum3 - $first)-$second); #say $remainder;
					my $total = (($first + ($second*80)/100)+($remainder*60)/100);say "1+2+rest= ".$total;
					
					$md3 = $total;
					say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
     			    }

     			    if (scalar @sorted3 == 1){
					my $first = shift(@sorted3); #say $first;
					say "----------------------------------------------";
					$md3 = $first;say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
     			    }
     			    }
#---------------------------------------------------------------------------<<<<<<<<<<<<<<<<motors>>>>>>>>>>>>>>>>
						
						my $sum4;grep { $sum4 += $_ } @sorted4;
    			  		my $md4 = $sum4;say "total for motors(2) : ". $md4;
    			  		@sorted4 = sort { $b <=> $a } @sorted4;#reverse sort
    			  		
    			  		#say Dumper @sorted4;
    			  	for my $i (@sorted4){
     			    	#say $i;
     			    #1
    			  	if (scalar @sorted4 == 1){
					my $first = shift(@sorted4); #say $first;
					say "----------------------------------------------";
					$md4 = $first;say "Max for motors(2) is ".$md4;
					say "--------------------------------";  
     			    }
     			    #2
    			  	if (scalar @sorted4 > 1 && scalar @sorted4 < 3){
					my $first = shift(@sorted4); say "first: ".$first;
					my $second = shift(@sorted4); say "second: ".$second;
					my $total = (($first + ($second*0)/100));#say "1+2= ".$total;
					
					$md4 = $total;
					say "Max for motors(2) is ".$md4;
					say "--------------------------------";  
     			    }
     			    #3>
     			    if (scalar @sorted4 >2){
     			    
					my $first = shift(@sorted4); #say "first: ".$first;
					my $second = shift(@sorted4); #say "second: ".$second;
					my $remainder = (($sum4 - $first)-$second); #say "remainder :".$remainder;
					my $total = (($first + ($second*0)/100)+($remainder*60)/100);#say "1+2+rest= ".$total;
					say "--------------------------------"; 
					$md4 = $total;
					say "Max for motors(2) is ".$md4;
					say "--------------------------------";  
     			    }
    			  	}

#---------------------------------------------------------------------------<<<<<<<<<<<<<<water heater inst>>>>>>>>>>>>>>  			    
    			    my $sum5;grep { $sum5 += $_ } @sorted5;
    			    say "total for inst water heaters is ". $sum5;
     			    say "--------------------------------";   	
     			    my $md5;
     			    @sorted5 = sort { $b cmp $a } @sorted5;#reverse sort
     			    for my $i (@sorted5){
     			    	#say $i;
     			    if (scalar @sorted5 > 1 && scalar @sorted5 < 3){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					$md5 = $first + $second;#say $md5;
					say "Max for inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted5 > 2){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					my $rest;grep { $rest += $_ } @sorted5;#say $rest;
					$md5 = ((($first + $second)+($rest*25)/100));say "Max for inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted5 == 1){
					my $first = shift(@sorted5); #say $first;
					$md5 = $first;say "Max for inst water heaters is ".$md5;
					say "--------------------------------";  
     			    }
     			    }		    
#---------------------------------------------------------------------------<<<<<<<<<<<<<<water heater thermo>>>>>>>>>>>>>>  
    			    my $sum6;grep { $sum6 += $_ } @sorted6;
    			    say "max for thermo water heaters is ". $sum6;
     			    say "--------------------------------";  
     			     my $md6 = $sum6;			    
#---------------------------------------------------------------------------<<<<<<<<<<<<<<<<floor warming>>>>>>>>>>>>>>>>   
    			    my $sum7;grep { $sum7 += $_ } @sorted7;
    			    say "max for floor warming is ". $sum7;
     			    say "--------------------------------"; 
     			    my $md7 = $sum7; 			    
#---------------------------------------------------------------------------<<<<<<<<<<<<<space storage heating>>>>>>>>>>>>>   
    			    my $sum8;grep { $sum8 += $_ } @sorted8;
    			    say "max for storage space heating is ". $sum8;
     			    say "--------------------------------";  
     			    my $md8 = $sum8;		    
#---------------------------------------------------------------------------<<<<<<<<<<<<<<final circuits>>>>>>>>>>>>>>   
    			    my $sum9;grep { $sum9 += $_ } @sorted9;
    			    say "total for standard final circuits is ". $sum9;
     			    say "--------------------------------"; 
     			    my $md9;
     			    @sorted9 = sort { $b <=> $a } @sorted9;#reverse sort
     			    if (scalar @sorted9 ==1){#say scalar @sorted9;
     			    	my $sum;grep { $sum += $_ } @sorted9;
     			    	my $md9 = $sum;
     			    	say "Max for standard final circuits is ".$md9;
     			    	}
     			    if (scalar @sorted9 > 1){#say scalar @sorted9;
     			    	my $first = shift(@sorted9);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted9;#say $rest;
     			    	$md9 = ($first + ($rest*50)/100);
     			    	say "Max for standard final circuits is ".$md9;
     			    }
     			    say "--------------------------------"; 		    
#---------------------------------------------------------------------------<<<<<<<<<<<<<<<<socket outlets>>>>>>>>>>>>>>>>  
 					my $md10;
    			    my $sum10;grep { $sum10 += $_ } @sorted10;
    			    say "total for socket outlets is ". $sum10;
    			      say "--------------------------------"; 
     			    @sorted10 = sort { $b <=> $a } @sorted10;#reverse sort
     			    if (scalar @sorted10 ==1){say scalar @sorted10;
     			    	my $sum;grep { $sum += $_ } @sorted10;
     			    	my $md10 = $sum;
     			    	}
     			    if (scalar @sorted10 > 1){#say scalar @sorted10;
     			    	my $first = shift(@sorted10);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted10;#say $rest;
     			    	$md10 = ($first + ($rest*70)/100);
     			    	say "Max for socket outlets is ".$md10;
     			    }
     			    say "--------------------------------";   			    
#---------------------------------------------------------------------------  
my $total = ($md1 + $md2 +  $md3 + $md4 + $md5 + $md6 +$md7 + $md8 +  $md9 + $md10);
return ($total);
    		}

    		case 3 {
    			#-----------------------------------------<<<<<<<<<<<<<<<<<<lighting>>>>>>>>>>>>>>>>>>
    			my $sum;grep { $sum += $_ } @sorted1;
    			my $md1 = (($sum*75)/100);#say $md1;
    		say "total for lighting(3) is ".$sum;
    		say "--------------------------------";
    		say "Max for lighting(3) is ".$md1;
    		say "--------------------------------";
    		#----------------------------------------------------<<<<<<<<<<<<<<<<<<<<<<<heating>>>>>>>>>>>>>>>>>>>>>>>
    		  my $sum2;grep { $sum2 += $_ } @sorted2;
    			   say "total for heating(3): ".$sum2;
    			   	say "--------------------------------";
    			   	my $md2 = $sum2;  
     			    @sorted2 = sort { $b <=> $a } @sorted2;#reverse sort
     			    for my $i (@sorted2){
     			    	#say $i;
     			    if (scalar @sorted2 > 1 && scalar @sorted2 < 3){
					my $first = shift(@sorted2); #say $first;
					my $second = shift(@sorted2); #say $second;
					my $total = (($first + ($second*80)/100));#say "1+2= ".$total;
					
					$md2 = $total;
					say "Max for heating(3) is ".$md2;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted2 >2){
					my $first = shift(@sorted2); #say $first;
					my $second = shift(@sorted2); #say $second;
					my $remainder = (($sum2 - $first)-$second); #say $remainder;
					my $total = (($first + ($second*80)/100)+($remainder*60)/100);say "1+2+rest= ".$total;
					
					$md2 = $total;
					say "Max for heating(3) is ".$md2;
					say "--------------------------------";  
     			    }

     			    if (scalar @sorted2 == 1){
					my $first = shift(@sorted2); #say $first;
					say "----------------------------------------------";
					$md2 = $first;say "Max for heating(3) is ".$md2;
					say "--------------------------------";  
     			    }
     			    }
    		#------------------------------------------------------------<<<<<<<<<<<<<<<<<<<cooking 3>>>>>>>>>>>>>>>>>>>
    		    			    my $sum3;grep { $sum3 += $_ } @sorted3;
    			   say "total for cooking(3): ".$sum3;
    			   	say "--------------------------------";
    			   	my $md3 = $sum3; 
     			    @sorted3 = sort { $b <=> $a } @sorted3;#reverse sort
     			    for my $i (@sorted3){
     			    	#say $i;
     			    if (scalar @sorted3 > 1 && scalar @sorted3 < 3){
					my $first = shift(@sorted3); #say $first;
					my $second = shift(@sorted3); #say $second;
					my $total = (($first + ($second*80)/100));#say "1+2= ".$total;
					
					$md3 = $total;
					say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
					
     			    }
     			    if (scalar @sorted3 >2){
					my $first = shift(@sorted3); #say $first;
					my $second = shift(@sorted3); #say $second;
					my $remainder = (($sum3 - $first)-$second); #say $remainder;
					my $total = (($first + ($second*80)/100)+($remainder*60)/100);say "1+2+rest= ".$total;
					
					$md3 = $total;
					say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
     			    }

     			    if (scalar @sorted3 == 1){
					my $first = shift(@sorted3); #say $first;
					say "----------------------------------------------";
					$md3 = $first;say "Max for cooking(3) is ".$md3;
					say "--------------------------------";  
     			    }
     			    }
     			    #-----------------------------------------------<<<<<<<<<<<<<<<<<<<motors 3>>>>>>>>>>>>>>>>>>>
     			    my $sum4;grep { $sum4 += $_ } @sorted4;
    			    say "total for motors (3) is ". $sum4;
     			    say "--------------------------------";
     			    my $md4 = $sum4;
     			    @sorted4 = sort { $b <=> $a } @sorted4;#reverse sort
     			    if (scalar @sorted4 ==1){#say scalar @sorted4;
     			    	my $sum;grep { $sum += $_ } @sorted4;
     			    	$md4 = $sum;
     			    	say "Max for motors (3) is ".$md4;
     			    	}
     			    if (scalar @sorted4 > 1){#say scalar @sorted4;
     			    	my $first = shift(@sorted4);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted4;#say $rest;
     			    	$md4 = ($first + ($rest*50)/100);
     			    	say "Max for motors (3) is ".$md4;
     			    }
     			    say "--------------------------------"; 
     			    #--------------------------------------------------<<<<<<<<<<<<<<<<<<<<inst heaters 3>>>>>>>>>>>>>>>>>>>>
     			    my $sum5;grep { $sum5 += $_ } @sorted5;
    			    say "total for inst water heaters(3) is ". $sum5;
     			    say "--------------------------------";
     			    my $md5;   	
     			    @sorted5 = sort { $b <=> $a } @sorted5;#reverse sort
     			    for my $i (@sorted5){
     			    	#say $i;
     			    if (scalar @sorted5 == 1){
					my $first = shift(@sorted5); #say $first;
					$md5 = $first;say "Max for inst water heaters(3) is ".$md5;
					say "--------------------------------";  
     			    }	
     			    if (scalar @sorted5 > 1 && scalar @sorted5 < 3){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					$md5 = $first + $second;#say $md5;
					say "Max for inst water heaters(3) is ".$md5;
					say "--------------------------------";  
     			    }
     			    if (scalar @sorted5 > 2){
					my $first = shift(@sorted5); #say $first;
					my $second = shift(@sorted5); #say $second;
					my $rest;grep { $rest += $_ } @sorted5;#say $rest;
					$md5 = ((($first + $second)+($rest*25)/100));say "Max for inst water heaters(3) is ".$md5;
					say "--------------------------------";  
     			    }
     			    }	
#---------------------------------------------------------------------------<<<<<<<<<<<<<<water heater thermo>>>>>>>>>>>>>>  
    			    my $sum6;grep { $sum6 += $_ } @sorted6;
    			    say "max for thermo water heaters is ". $sum6;
     			    say "--------------------------------";
     			    my $md6 = $sum6;  			    
#---------------------------------------------------------------------------<<<<<<<<<<<<<<<<floor warming>>>>>>>>>>>>>>>>   
    			    my $sum7;grep { $sum7 += $_ } @sorted7;
    			    say "max for floor warming is ". $sum7;
     			    say "--------------------------------";
     			    my $md7 = $sum7;  			    
#---------------------------------------------------------------------------<<<<<<<<<<<<<space storage heating>>>>>>>>>>>>>   
    			    my $sum8;grep { $sum8 += $_ } @sorted8;
    			    say "max for storage space heating is ". $sum8;
     			    say "--------------------------------";   	
     			    my $md8 = $sum8;		    
#---------------------------------------------------------------------------<<<<<<<<<<<<<final circuits 3>>>>>>>>>>>>>   
    			    my $sum9;grep { $sum9 += $_ } @sorted9;
    			    say "max for final is ". 0;
     			    say "--------------------------------"; 
     			    my $md9 = 0;
  #-----------------------------------------------------<<<<<<<<<<<<<<<<<<socket outlets>>>>>>>>>>>>>>>>>>    			      		
     			    my $sum10;grep { $sum10 += $_ } @sorted10;
    			    say "total for socket outlets is ". $sum10;
    			      say "--------------------------------"; 
    			     
     			    @sorted10 = sort { $b <=> $a } @sorted10;#reverse sort
     			    my $md10;
     			    if (scalar @sorted10 ==1){say scalar @sorted10;
     			    	my $sum;grep { $sum += $_ } @sorted10;
     			    	$md10 = $sum;
     			    	}
     			    if (scalar @sorted10 > 1){#say scalar @sorted10;
     			    	my $first = shift(@sorted10);#say $first;
     			    	my $rest;grep { $rest += $_ } @sorted10;#say $rest;
     			    	$md10 = ($first + ($rest*75)/100);
     			    	say "Max for socket outlets is ".$md10;
     			    }
     			    say "--------------------------------";   
     			    my $total = ($md1 + $md2 +  $md3 + $md4 + $md5 + $md6 +$md7 + $md8 +  $md9 + $md10);
     			    return $total;

    		}

            }
            
}
1;
