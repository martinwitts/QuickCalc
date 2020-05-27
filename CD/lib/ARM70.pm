package ARM70;

use strict;
use feature 'say';
use lib qw(/home/twiki/lib/CPAN/lib);
use Switch;
use Data::Dumper;
#---------------------------------------------------------------
require Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 0.02;

@ISA         = qw(Exporter);
@EXPORT      = qw(arm70);
%EXPORT_TAGS = ( );


@EXPORT_OK   = qw(arm70 $design_zs $fini $method $drop $perc $dev_maxzs $Ib $z $length $pscc $In $use $ring);

use vars qw();


#--------------------------------------------------------------------------Current Carrying Capacities
              my %ccc_c = (1.5 => "21",
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
                            400 => "621");# current It for method C
              my %ccc_e = (1.5 => "22",
                           2.5 => "31",
                             4 => "41",
                             6 => "53",
                            10 => "72",
                            16 => "97",
                            25 => "128",
                            35 => "157",
                            50 => "190",
                            70 => "241",
                            95 => "291",
                            120 => "336",
                            150 => "386",
                            185 => "439",
                            240 => "516",
                            300 => "592",
                            400 => "683");# current It for method E
              my %ccc_d = (1.5 => "22",
                           2.5 => "29",
                             4 => "37",
                             6 => "46",
                            10 => "60",
                            16 => "78",
                            25 => "99",
                            35 => "119",
                            50 => "140",
                            70 => "173",
                            95 => "204",
                            120 => "231",
                            150 => "261",
                            185 => "292",
                            240 => "336",
                            300 => "379",
                            400 => "379");# current It for method D It>=In !!no value for 400 so used 300 value

              my %ccc_c_3ph = (1.5 => "18",
                           2.5 => "25",
                             4 => "33",
                             6 => "42",
                            10 => "58",
                            16 => "77",
                            25 => "102",
                            35 => "125",
                            50 => "151",
                            70 => "192",
                            95 => "231",
                            120 => "267",
                            150 => "306",
                            185 => "348",
                            240 => "409",
                            300 => "469",
                            400 => "540");# current It for method C
          my %ccc_e_3ph = (1.5 => "19",
                           2.5 => "26",
                             4 => "35",
                             6 => "45",
                            10 => "62",
                            16 => "83",
                            25 => "110",
                            35 => "135",
                            50 => "163",
                            70 => "207",
                            95 => "251",
                            120 => "290",
                            150 => "332",
                            185 => "378",
                            240 => "445",
                            300 => "510",
                            400 => "590");# current It for method E
          my %ccc_d_3ph = (1.5 => "18",
                           2.5 => "24",
                             4 => "30",
                             6 => "38",
                            10 => "50",
                            16 => "64",
                            25 => "82",
                            35 => "98",
                            50 => "116",
                            70 => "143",
                            95 => "169",
                            120 => "192",
                            150 => "217",
                            185 => "243",
                            240 => "280",
                            300 => "316",
                            400 => "316");# current It for method D It>=In !!no value for 400 so used 300 value
            
#--------------------------------------------------------------------------Current Carrying Capacities           
            my @cable_sizes = qw(1.5 2.5 4 6 10 16 25 35 50 70 95 120 150 185 240 300 400);
            my @ref_list = qw(c e d c3 e3 d3);
            #start
            sub arm70{
            my ($z, $pfc, $dev_type) = @_;
          
            #Collect user defined values and passing methods in aarray then print
            my ($Ib, $In, $method, $length, $dev_maxzs, $use, $dist, $factored_In, $ca, $cs, $cd) = collect($dev_type, \@ref_list);


            #say "Refactored It is: ".$factored_In;       
            #Get method name and assign to new hash %ccc_to_use
            my %ccc_to_use = ();
            #switch
            switch ($method) {
    		case "c3" {%ccc_to_use = %ccc_c_3ph}
    		case "e3" {%ccc_to_use = %ccc_e_3ph}
    		case "d3" {%ccc_to_use = %ccc_d_3ph}
    		case "c" {%ccc_to_use = %ccc_c}
    		case "e" {%ccc_to_use = %ccc_e}
    		case "d" {%ccc_to_use = %ccc_d}
    		else     {say "Problem with method can't get hash"}
}

            #switch
            #say Dumper (%ccc_to_use);
            #tsay "Using method ".$method. " to determine max It";
            #Pass design current and reference method table to subroutine Ib_list
            my $ret_hash = Ib_list($factored_In, \%ccc_to_use);
            my %tab = %{$ret_hash};
            #Returned new hash of It values equal to and above for calculations
            #say Dumper (%tab);
            #Pass needed values to compare device Zs with cable Zs in hash table
            my $zs_compare = r1r2($z, $dev_maxzs, $length, \%tab);
            #Return cable size for voltage drop check
            #tsay "Checking Voltage Drop for ".$zs_compare." mm";
            #Checking voltage drop against 3% and 5%
            my ($fini, $drop, $perc, $vd_max) = vdrop($length, $zs_compare, $Ib, $use, $dist);
            #my $device_type = $pscc;
			#tsay "Finished with cable size :". $fini." mm";
			#Get final Zs for chosen cable
			my $fini_zs = final_zs($fini, $length, $z);
			#tsay "Recalculated Zs for upgraded cable size at ".$fini_zs." mm (".$dev_maxzs.")max";
			return ($fini_zs, $fini, $method, $drop, $perc, $dev_maxzs, $Ib, $length, $In, $use, $dist, $factored_In, $vd_max, $ca, $cs, $cd);
            #End
sub vdrop{
	my ($length, $cable_mm, $Ib_in, $use, $dist) = @_;
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
                      say "dist - ".$dist;
say $length." ". $cable_mm." ". $Ib_in." " .$use;
          foreach my $mm(sort {$a <=> $b} keys %res_metre_vd){
          	next if ($mm < $cable_mm);            	
          	my $ohms = $res_metre_vd{$mm};
          	my $resistance = (($length * $ohms)/1000);
          	#say $resistance;
          	my $vd = (($resistance * $factor) * $Ib_in);
          	my $p = (($vd / 230) * 100);
          	
          	#if lighting and not distribution-----------3%---------------
          	if ($use == 1 && $dist eq "n"){
          		my $vd_max = 3;#3% max BS7671
          		say "lighting only - final circuit";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent for " . $mm."mm cable";	
          		return ($mm, $vd, $p, $vd_max);
          		exit;
          	}
          	else{
          		#tsay "Failed Voltage Drop";
          		#tsay "Upgrading!!!";
          	}

          	}
                #if lighting and is distribution-------------6%-----------------	
          	    if ($use == 1 && $dist eq "y"){
          		my $vd_max = 6;#6% max BS7671
          		say "lighting only - distribution";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent for " . $mm."mm cable";	
          		return ($mm, $vd, $p, $vd_max);
          		exit;
          	}
          	else{
          		#tsay "Failed Voltage Drop";
          		#tsay "Upgrading!!!";
          	}

          	}
			#if other and not distribution-------------5%----------------------
          	elsif ($use == 2 && $dist eq "n"){
          		my $vd_max = 5;#5% max BS7671
          		say "other";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent " . $mm."mm cable";	
          		return ($mm, $vd, $p, $vd_max);
          		exit;
          		
          	}
          	else{
          		#tsay "Failed Voltage Drop";
          		#tsay "Upgrading!!!";
          	}
          	}
          	#if other and id distribution--------------8%-------------------------------
          	elsif ($use == 2 && $dist eq "y"){
          		my $vd_max = 8;#8% max BS7671
          		say "other";
          		if ($p <= $vd_max){
          		#tsay "Voltage drop is ".$vd." volts at ". $p . " percent " . $mm."mm cable";	
          		return ($mm, $vd, $p, $vd_max);
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
	my ($final, $length, $ze) = @_;
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

            	  return $design_zs;
}
sub r1r2{
	#Calculate Zs of new hash list starting with first value
	#Compare each value with maxzs and return if design Zs is equal or less
	my ($ze, $dev_maxzs, $length, $short_list) = @_;
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
	my ($newI, $list) = @_;
	my %ccc_to_work_on = %{$list};
	#Create a new hash with greater values than design current
	my %new = ();
	while (my ($key,$value) = each %ccc_to_work_on) {
    if ($value >= $newI){
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
  say "-----------Available methods:@ref_list--------------------------";
  say "----------------------------------------------------------------";
  say "Method c3------Clipped diect 3 phase----------------------------";
  say "Method e3------Free air or cable tray 3 phase-------------------";
  say "Method d3------Direct in the ground or duct 3 phase-------------";
  say "Method c-------Clipped diect------------------------------------";
  say "Method e-------Free air or cable tray---------------------------";
  say "Method d-------Direct in the ground or duct---------------------";
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
  #if method is D, buried in ground - get user input for factoring
  my ($factored_In, $ca, $cs, $cd);
  if ($ref eq "d" || $ref eq "d3"){ ($factored_In, $ca, $cs, $cd) = d_factors($In);}

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
  DIST:
  say "Distribution to private DB? (Y/N)";
  my $dist = <STDIN>;
  chomp $dist;
      if (($dist ne "y") && ($dist ne "n")){
    goto DIST;
 }

  my $method = $ref;
  #say $method;
  #say $dist;
  my $dev_maxzs = maxzs($In, $dev_type);#Getting maxZs for chosen Device using function maxzs
  return ($IB, $In, $method, $length, $dev_maxzs, $use, $dist, $factored_In, $ca, $cs, $cd);
  
}
#method d factor
sub d_factors{
	my ($In) = shift;
	say "Additional factors for Ambient Ground Temp(Ca), Soil Thermal Resistivity(Cs), Depth(Cd)";
	say "Assuming that they are tabulated, they are defaulted a unity (1)";
	say "---------------------------------------------------------------------------------------";
	CA:
	my $ambient = "ca.txt";

my $document = do{
	local $/ = undef;
	open (my $fh,'<',$ambient) or die "couldnt open '$ambient'$!";
	my $amb = <$fh>;
	say $amb; 
	close $fh;
	
};
	say "What is the Ambient Ground Temp (Ca)? default 20deg - 1";
	my $ca = <STDIN>;
	chomp $ca;
	if ($ca !~ /\d/){goto CA;}
	CS:
		my $resistivity = "cs.txt";

my $document1 = do{
	local $/ = undef;
	open (my $fh,'<',$resistivity ) or die "couldnt open '$resistivity '$!";
	my $res = <$fh>;
	say $res; 
	close $fh;
	
};
    say 'What is the Soil Thermal Resistivity(Cs)? default 2.5 K.m/W - 1';
	my $cs = <STDIN>;
	chomp $cs;
	if ($cs !~ /\d/){goto CS;}
	CD:
	my $depth = "cd.txt";
	my $document2 = do{
	local $/ = undef;
	open (my $fh,'<',$depth ) or die "couldnt open '$depth'$!";
	my $dep = <$fh>;
	say $dep; 
	close $fh;
	
};
	say 'What is the Depth(Cd)? default 0.7m - 1';
	my $cd = <STDIN>;
	chomp $cd;
    if ($cd !~ /\d/){goto CD;}
	my $total = ($ca*$cs*$cd);
	my $factored_In = ($In/$total);

	return ($factored_In, $ca, $cs, $cd);
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
