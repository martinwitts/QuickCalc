package SWA70;


use feature 'say';
use lib qw(/home/twiki/lib/CPAN/lib);
use lib qw(/home/workspace/BS7671/CircuitDesign/BS7671/BS);
use Switch;
use Moose;
use Moose::Util::TypeConstraints;
use Data::Dumper;
 
has 'name'    => (is => 'rw');
has 'ib'      => (isa => 'Int', is => 'rw');
has 'ref'    => (is => 'rw');
has 'cable_type'  => (isa => 'Int', is => 'rw');
has 'length'     => (isa => 'Int', is => 'rw');
has 'circuit_type' => (isa => 'Int', is => 'rw');
has 'ring' => (isa => 'Int', is => 'rw');
has 'distro' => (isa => 'Int', is => 'rw');
has 'ca'     => (isa => 'Num', is => 'rw');
has 'cs'     => (isa => 'Num', is => 'rw');
has 'cd'     => (isa => 'Num',is => 'rw');
has 'cg'     => (isa => 'Num',is => 'rw');
has 'ci'     => (isa => 'Num',is => 'rw');
has 'cc'     => (isa => 'Num',is => 'rw');
#--------------------------------------------------------------------------Current Carrying Capacities
              my %ccc_a = (1 => "11.5",
                           1.5 => "14.5",
                           2.5 => "20",
                             4 => "26",
                             6 => "32",
                            10 => "44",
                            16 => "57");# current It for method a*
              my %ccc_cd = (1 => "1",
                           1.5 => "21",
                           2.5 => "28",
                             4 => "38",
                             6 => "49",
                            10 => "67",
                            16 => "89",
			    25 => "118",
			    35 => "145",
                            50 => "175",
                            70 => "222",
                            95 => "269",
                           120 => "310",
                           150 => "356",
			   185 => "405",
                           240 => "476",
                           300 => "547",
			   400 => "621");# current It for method clipped direct
              my %ccc_100 = (1 => "13",
                           1.5 => "16",
                           2.5 => "21",
                             4 => "27",
                             6 => "34",
                            10 => "45",
                            16 => "57");# current It for method 100 It>=In
              my %ccc_101 = (1 => "10.5",
                           1.5 => "13",
                           2.5 => "17",
                             4 => "22",
                             6 => "27",
                            10 => "36",
                            16 => "46");# current It for method 101 It>=In
              my %ccc_102 = (1 => "13",
                           1.5 => "16",
                           2.5 => "21",
                             4 => "27",
                             6 => "35",
                            10 => "47",
                            16 => "63");# current It for method 102 It>=In
              my %ccc_103 = (1 => "8",
                           1.5 => "10",
                           2.5 => "13.5",
                             4 => "17.5",
                             6 => "23.5",
                            10 => "32",
                            16 => "42.5");# current It for method 103 It>=In 
             
#--------------------------------------------------------------------------Current Carrying Capacities  



sub cable_type_ret {
	my ($self, $type) = @_;
	            switch ($type) {
    		case "1" {return "flat sheathed thermoplastic 70degrees";}
    		case "2" {return "Armoured multicore thermoplastic 70degrees";}
    		else     {say "Problem with"}
    		}
}
sub main{
		my ($self, $In, $ref, $is_ring) = @_;

			say "test on SWA70 ------------------Ring or radial -".$is_ring;
	        #Pass design current and reference method table to subroutine Ib_list
            #my $ret_hash = Ib_list($ib, \%ccc_to_use);
            my @cable_sizes = qw(1 1.5 2.5 4 6 10 16 25 35 50 70 95 120 150 185 240 300 400);
            my @ref_list = qw(a cd 100 101 102 103);
            #Get method name and assign to new hash %ccc_to_use
            my %ccc_to_use = ();
            #switch
            switch ($ref) {
    		case 100 {%ccc_to_use = %ccc_100}
    		case 101 {%ccc_to_use = %ccc_101}
    		case 102 {%ccc_to_use = %ccc_102}
    		case 103 {%ccc_to_use = %ccc_103}
    		case "a" {%ccc_to_use = %ccc_a}
    		case "c"{%ccc_to_use = %ccc_cd}
    		else     {say "Problem with method can't get hash"}
}
            #Pass design current and reference method table to subroutine Ib_list
            my $ret_hash = Ib_list($In, \%ccc_to_use, $is_ring);
            my %tab = %{$ret_hash};
            #Returned new hash of It values equal to and above for calculations
            #Pass needed values to compare device Zs with cable Zs in hash table
            ###my $zs_compare = r1r2($ring, $z, $dev_maxzs, $length, \%tab);

            #say Dumper (%tab);
             
	return (\%tab);
}
sub Ib_list{
	my ($In, $list, $is_ring) = @_;#-----------------------------------------------In not Ib
	say "getting ccc list dependant on $In";
	say "Using ring is (yes:2) - $is_ring";
	my %ccc_to_work_on = %{$list};
	#Create a new hash with greater values than In not design current / current cable capacity protected by In 
	my %new = ();
	my %unused = ();
	my %new4ring = ();
	while (my ($key,$value) = each %ccc_to_work_on) {
    if ($value >= $In){

    	$new{"$key"} = $value;
    }
    else{$unused{"$key"} = $value;}
}
#Getting the heighest key/values from unused, so can be added to new hash - ring calculation
my @heights = sort { $unused{$a} <=> $unused{$b} } keys %unused;
 
my $highest = $heights[-1];
 
say "Highest key is: $highest";
say "highest value is: $unused{ $highest }\n";

	if ($is_ring == 2 ){
	$new4ring{"$highest"} = $unused{ $highest };
}

if ($is_ring == 2 ){
	return (\%new4ring);
}else{
    #Return new hash with values of ccc equal to or greater
    return (\%new);
}
}  
#Get maximum Zs for selected device
sub maxzs{
	my $self = [0];
	my $In = $_[1];
	my $dev_type = $_[2];
	say "Subroutine maxzs from SWA70 module";
	say "Passed In -".$In. " and dev type - ". $dev_type;
                      if ($dev_type =~ /B/i){
                     my $x5 = ($In * 5);
                     my $maxZs = ((230/$x5)* 0.95);
                     #say "Device maxzs is: ".$maxZs;       
                        return $maxZs;
                      }
                     elsif($dev_type =~ /C/i){
                     my $x10 = ($In * 10);
                     my $maxZs = ((230/$x10)* 0.95);
                     #say "Device maxzs is: ".$maxZs;       
                        return $maxZs;
                      }
                     elsif($dev_type =~ /D/i){
                     my $x10 = ($In * 20);
                     my $maxZs = ((230/$x10)* 0.95);
                     #say "Device maxzs is: ".$maxZs;       
                        return $maxZs;
                      }
}
sub getIn{
	my ($self, $I) = @_;
  #Get nearest device rating depending on Ib
  my @dev_In = qw(6 10 16 20 25 32 40 50 63 80 100 125);
  my @dev_choice_low = grep { $_ >= $I } @dev_In;
  my $In = $dev_choice_low[0];
  say "Chosen Device In Rating: $In";
  return ($In);
}
#------------------------------------------------------------

 sub r1r2{
 	say "testing r1r2-----------------------------------------";

	#Calculate Zs of new hash list starting with first value
	#Compare each value with maxzs and return if design Zs is equal or less
	my ($self, $ring, $ze, $dev_maxzs, $length, $short_list) = @_;
	my %short = %{$short_list};
	my %res_metre = (1 => "33.6",
                     1.5 => "22.4",
                     2.5 => "13.44",
                       4 => "8.4",
                       6 => "5.6",
                      10 => "3.36",
                      16 => "2.10",
                      25 => "1.344",
                      35 => "0.56",
                      50 => "0.672",
                      70 => "0.48",
                      95 => "0.35368",
                     120 => "0.28",
                     150 => "0.224",
		     185 => "0.18162",
                     240 => "0.14",
                     300 => "0.112",
	             400 => "0.084");

	foreach my $mm(sort {$a <=> $b} keys %short){

            my $ohms = $res_metre{$mm};
            my $design_zs = ((($length * $ohms)/1000) + $ze);
            if ($ring == 2){
            	$design_zs = (((($length * $ohms)/1000)/4 )+ $ze);
            	say "Calculate for Ring";
            }
            else{
            	say "Calculate for Radial";
            }
            next if($design_zs > $dev_maxzs);
            if ($design_zs <= $dev_maxzs){
            say "Calculating Zs for :".$mm."mm cable";
            say $mm."mm cable is sufficient at ".$design_zs." ohms";
            #exit;
            }
            #Return cable size(key) which was first to match criteria
            	  return $mm;
	  }

}   
#----------------------------------------------------------------        
sub vdrop{
	my ($self, $length, $cable_mm, $Ib_in, $use, $ring) = @_;   #length,size,Ib,lighting or other, ring

          #my $factor = "1.2"; 	#load factor
          my %res_metre_vd = (
		       1 => "44",
                     1.5 => "29",
                     2.5 => "18",
                       4 => "11",
                       6 => "7.3",
                      10 => "4.4",
                      16 => "2.8",
		      25 => "1.75",
                      35 => "1.25",
                      50 => "0.94",
                      70 => "0.65",
                      95 => "0.50",
                     120 => "0.41",
                     150 => "0.34",
                     185 => "0.29",
                     240 => "0.24",
                     300 => "0.21",
                     400 => "0.185");  
			say "Length- ".$length."-Cable mm- ". $cable_mm."-Design current - ". $Ib_in."-use - " .$use."-ring? - ".$ring;
            foreach my $mm(sort {$a <=> $b} keys %res_metre_vd){
          	next if ($mm < $cable_mm);            	
          	my $mvam = $res_metre_vd{$mm};
          	
          	my $vd = ((($mvam * $Ib_in * $length)/1000));
          	my $percentage;
          	if ($ring == 1){
          		$percentage = (($vd / 230) * 100);
          		
          	}
          		elsif ($ring == 2){
          			$percentage = ((($vd / 230) * 100)/4);	
          		}
          	
          	
          	if ($use == 1){
          		my $vd_max = 3;
          		say "lighting";
          		if ($percentage <= $vd_max){
          		say "Voltage drop is ".$vd." volts at ". $percentage . " percent for " . $mm."mm cable";	
          		return ($mm, $vd, $percentage, $vd_max);
          		exit;
          		#----------------only exit if voltage drop is in range
          	}
          	else{
          		#Failed Voltage Drop
				#continue loop until ok
          	}

          	}

          	elsif ($use >= 2){
          		my $vd_max = 5;
          		say "other";
          	
          		
          		if ($percentage <= $vd_max){
          		say "Voltage drop is ".$vd." volts at ". $percentage . " percent " . $mm."mm cable";	
          		return ($mm, $vd, $percentage, $vd_max);
          		exit;
          		
          	}
          	else{
          		#Failed Voltage Drop
          	}
          }


          
          	
          }
}
sub final_zs{
	my ($self, $final, $length, $ze, $ring) = @_;
	#Calculate final Zs
	my %res_metre = (1 => "33.6",
                     1.5 => "22.4",
                     2.5 => "13.44",
                       4 => "8.4",
                       6 => "5.6",
                      10 => "3.36",
                      16 => "2.10",
                      25 => "1.344",
                      35 => "0.56",
                      50 => "0.672",
                      70 => "0.48",
                      95 => "0.35368",
                     120 => "0.28",
                     150 => "0.224",
		     185 => "0.18162",
                     240 => "0.14",
                     300 => "0.112",
	             400 => "0.084");
	  my $ohms = $res_metre{$final};
            my $design_zs = ((($length * $ohms)/1000) + $ze);
            if ($ring == 2){
            	$design_zs = (((($length * $ohms)/1000)/4 )+ $ze);
            	#tsay "Calculate final Zs for Ring using ".$final." mm";


            }


            	  return $design_zs;
}
1;
