package Flat;

use strict;
use feature 'say';
use lib qw(/home/twiki/lib/CPAN/lib);
use Switch;
#---------------------------------------------------------------
require Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 0.02;

@ISA         = qw(Exporter);
@EXPORT      = qw(init);
%EXPORT_TAGS = ( );


@EXPORT_OK   = qw(init $design_zs $fini $method $drop $perc $dev_maxzs $Ib $z $length $pscc $In $use $ring);

use vars qw();

sub double{
	my $integer_in = shift;
	my $integer_out = $integer_in * 4;
	
	return $integer_out;
	
	
	
}
#--------------------------------------------------------------------------Current Carrying Capacities
              my %ccc_a = (1 => "11.5",
                           1.5 => "14.5",
                           2.5 => "20",
                             4 => "26",
                             6 => "32",
                            10 => "44",
                            16 => "57");# current It for method a*
              my %ccc_cd = (1 => "16",
                           1.5 => "20",
                           2.5 => "27",
                             4 => "37",
                             6 => "47",
                            10 => "64",
                            16 => "85");# current It for method clipped direct
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
            my @cable_sizes = qw(1 1.5 2.5 4 6 10 16 25 35 50);
            my @ref_list = qw(a cd 100 101 102 103);
            #start
            sub init{
            my ($z, $pfc, $dev_type) = @_;
          
            #Collect user defined values and passing methods in array then print
            my ($Ib, $In, $method, $length, $dev_maxzs, $use, $ring) = collect($dev_type, \@ref_list);


                   
            #Get method name and assign to new hash %ccc_to_use
            my %ccc_to_use = ();
            #switch
            switch ($method) {
    		case 100 {%ccc_to_use = %ccc_100}
    		case 101 {%ccc_to_use = %ccc_101}
    		case 102 {%ccc_to_use = %ccc_102}
    		case 103 {%ccc_to_use = %ccc_103}
    		case "a" {%ccc_to_use = %ccc_a}
    		case "cd"{%ccc_to_use = %ccc_cd}
    		else     {say "Problem with method can't get hash"}
}

            #switch
            #say Dumper (%ccc_to_use);
            #tsay "Using method ".$method. " to determine max It";
            #Pass design current and reference method table to subroutine Ib_list
            my $ret_hash = Ib_list($Ib, \%ccc_to_use);
            my %tab = %{$ret_hash};
            #Returned new hash of It values equal to and above for calculations
            #say Dumper (%tab);
            #Pass needed values to compare device Zs with cable Zs in hash table
            my $zs_compare = r1r2($ring, $z, $dev_maxzs, $length, \%tab);
            #Return cable size for voltage drop check
            #tsay "Checking Voltage Drop for ".$zs_compare." mm";
            #Checking voltage drop against 3% and 5%
            my ($fini, $drop, $perc) = vdrop($length, $zs_compare, $Ib, $use);
            #my $device_type = $pscc;
			#tsay "Finished with cable size :". $fini." mm";
			#Get final Zs for chosen cable
			my $fini_zs = final_zs($fini, $length, $z, $ring);
			#tsay "Recalculated Zs for upgraded cable size at ".$fini_zs." mm (".$dev_maxzs.")max";
			return ($fini_zs, $fini, $method, $drop, $perc, $dev_maxzs, $Ib, $length, $In, $use, $ring);
            #End
sub vdrop{
	my ($length, $cable_mm, $Ib_in, $use) = @_;
          my $factor = "1.2"; 	#load factor
          my %res_metre_vd = (1 => "36.20",
                     1.5 => "24.20",
                     2.5 => "14.83",
                       4 => "9.22",
                       6 => "6.16",
                      10 => "3.66",
                      16 => "2.30",
                      25 => "1.454",
                      35 => "1.048",
                      50 => "0.774");  
say $length." ". $cable_mm." ". $Ib_in." " .$use;
          foreach my $mm(sort {$a <=> $b} keys %res_metre_vd){
          	next if ($mm < $cable_mm);            	
          	my $ohms = $res_metre_vd{$mm};
          	my $resistance = (($length * $ohms)/1000);
          	#say $resistance;
          	my $vd = (($resistance * $factor) * $Ib_in);
          	my $p = (($vd / 230) * 100);
          	
          	if ($use == 1){
          		my $vd_max = 3;
          		#say "lighting";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent for " . $mm."mm cable";	
          		return ($mm, $vd, $p);
          		exit;
          		#----------------only exit if voltage drop is in range
          	}
          	else{
          		#Failed Voltage Drop
				#continue loop until ok
          	}

          	}

          	elsif ($use == 2){
          		my $vd_max = 5;
          		#say "other";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent " . $mm."mm cable";	
          		return ($mm, $vd, $p);
          		exit;
          		
          	}
          	else{
          		#tsay "Failed Voltage Drop";
          		#tsay "Upgrading!!!";
          	}
          	}


          
          	
          }
}
sub final_zs{
	my ($final, $length, $ze, $ring) = @_;
	#Calculate final Zs
		my %res_metre = (1 => "36.20",
                     1.5 => "30.20",
                     2.5 => "19.51",
                       4 => "16.71",
                       6 => "10.49",
                      10 => "6.44",
                      16 => "4.23",
                      25 => "2.557",
                      35 => "1.674",
                      50 => "1.114");
	  my $ohms = $res_metre{$final};
            my $design_zs = ((($length * $ohms)/1000) + $ze);
            if ($ring == 2){
            	$design_zs = (((($length * $ohms)/1000)/4 )+ $ze);
            	#tsay "Calculate final Zs for Ring using ".$final." mm";
            }


            	  return $design_zs;
}
sub r1r2{
	#Calculate Zs of new hash list starting with first value
	#Compare each value with maxzs and return if design Zs is equal or less
	my ($ring, $ze, $dev_maxzs, $length, $short_list) = @_;
	my %short = %{$short_list};
	my %res_metre = (1 => "36.20",
                     1.5 => "30.20",
                     2.5 => "19.51",
                       4 => "16.71",
                       6 => "10.49",
                      10 => "6.44",
                      16 => "4.23",
                      25 => "2.557",
                      35 => "1.674",
                      50 => "1.114"); 

	foreach my $mm(sort {$a <=> $b} keys %short){

            my $ohms = $res_metre{$mm};
            my $design_zs = ((($length * $ohms)/1000) + $ze);
            if ($ring == 2){
            	$design_zs = (((($length * $ohms)/1000)/4 )+ $ze);
            	#tsay "Calculate for Ring";
            }
            else{
            	#tsay "Calculate for Radial";
            }
            next if($design_zs > $dev_maxzs);
            if ($design_zs <= $dev_maxzs){
            #tsay "Calculating Zs for :".$mm."mm cable";
            #tsay $mm."mm cable is sufficient at ".$design_zs." ohms";
            #exit;
            }
            #Return cable size(key) which was first to match criteria
            	  return $mm;
	  }

}
sub Ib_list{
	my ($Ib, $list) = @_;
	my %ccc_to_work_on = %{$list};
	#Create a new hash with greater values than design current
	my %new = ();
	while (my ($key,$value) = each %ccc_to_work_on) {
    if ($value >= $Ib){
    	$new{"$key"} = $value;
    }
}
    #say Dumper (%new);
    #Return new hash
    return (\%new);
}      
sub collect{
	
  my ($dev_type, $ref_list) = @_;
  my @ref_list = @{$ref_list};

  say "what is the design current? ";
  my $IB = <STDIN>; #read stdin and put it in $userinput
  chomp $IB;
  #Get nearest device rating depending on Ib
  my @dev_In = qw(6 10 16 20 25 32 40 50 63 80 100 125);
  my @dev_choice_low = grep { $_ >= $IB } @dev_In;
  my $In = $dev_choice_low[0];
  say "Chosen Rating: $In";
  #---------------------------------------

  REF:
  say "-----------------------------Available methods:@ref_list--------------------------";
  say "---------------------------------------------------------------------------------------------";
  say "Method 100---Above a plasterboard ceiling, covered by thermal insulation, not exceeding 100mm";
  say "Method 101---Above a plasterboard ceiling, covered by thermal insulation, exceeding 100mm----";
  say "Method 102---In a thermally insulated stud wall with cable touching inner wall---------------";
  say "Method 103---In a thermally insulated stud wall with cable NOT touching inner wall-----------";
  say "Method cd----Clipped diect-------------------------------------------------------------------";
  say "Method a-----Enclosed in conduit in a thermal insulated wall---------------------------------";
  say "What is the Reference Method? ";
  my $ref = <STDIN>;
  chomp $ref;
  if (grep { $ref eq $_ } @ref_list){
   say "Reference Method $ref is in the list";
  }
     else{
   say "Reference Method $ref is not in the list";
   goto REF;
  }
  say "What is the length? ";
  my $length = <STDIN>;
  chomp $length;
  LENGTH:
  say "Lighting or other? (1/2)";
  my $use = <STDIN>;
  chomp $use;
      if (($use !=1) && ($use !=2)){
    goto LENGTH;
 }
  RING:
  say "Radial or ring? (1/2)";
  my $ring = <STDIN>;
  chomp $ring;
      if (($ring !=1) && ($ring !=2)){
    goto RING;
 }

  my $method = $ref;
  say $method;
  my $dev_maxzs = maxzs($In, $dev_type);#Getting maxZs for chosen Device using function maxzs
  return ($IB, $In, $method, $length, $dev_maxzs, $use, $ring);
  
}
#Get maximum Zs for selected device
sub maxzs{
	my $In = $_[0];
	my $dev_type = $_[1];
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
                      
}
            }
END { }       # module clean-up code here (global destructor)

1;
