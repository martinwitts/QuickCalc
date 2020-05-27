#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);
use lib qw(/home/twiki/lib/CPAN/lib);
use lib qw(/home/martin/workspace/CD/lib);
use Switch;
use Flat;
use ARM70;
#1. new site
#2. append
#3. maximum demand
my $welcome = "welcome.txt";

my $document = do{
	local $/ = undef;
	open (my $fh,'<',$welcome) or die "couldnt open '$welcome'$!";
	my $header = <$fh>;
	say $header; 
	close $fh;
	
};
say "Site Name?";
my $site = <STDIN>;
chomp $site;
my $file = "../sites/$site";#Create data in sites folder
  #---------------------------------------
  say "What is the prospective fault current? ";
  my $pfc = <STDIN>;
  chomp $pfc;
  my $dtype;
    if ($pfc <= 6) {
    $dtype = "B";
 }
    elsif ($pfc >= 6) {
    $dtype = "C";
 }
  say "What is Ze? ";
  my $z = <STDIN>;
  chomp $z;
      				open (my $fh,'>',$file) or die "couldnt open '$file' $!";
      				say $fh "Site name : " .uc $site;
      				say $fh "------------------------------------------------------------";
      				say $fh "Ze = ".$z." ohms";
          			say $fh "PFC = ".$pfc." KA";  				 
      				close $fh;
START:
CHOICE:
say "Circuit name?";
my $circuit_name = <STDIN>;
chomp $circuit_name;
say "What is the Cable type? (1 = flat sheathed thermoplastic 70degrees)";
say "                        (2 = Armoured multicore thermoplastic 70degrees)";
my $ct =<STDIN>;
chomp $ct;
            #switch
            switch ($ct) {
    		case "1" {
    			my ($rzs, $rmm, $rmethod, $rdrop, $rperc, $rmaxzs, $rIb, $rlength, $rIn, $rUse, $rRing) = init($z, $pfc, $dtype);
    			say "------------------------------------------------------------";
    			say "Finished Cable size = ".$rmm." mm";
    			say "Zs = ".$rzs."ohms (max for device = ".$rmaxzs.")";
    			say "Reference method = ".$rmethod."#"; 			
    			say "Voltage Drop = ".$rdrop."v at ".$rperc." %";
    			say "Design current Ib = ".$rIb." amps";
      			say "Ze = ".$z." ohms";  	
      			say "Length = ".$rlength." metres";
      			say "PSCC = ".$pfc." KA";
      			say "In = ".$rIn." A";
      			say "Device Type = ".$dtype." ";
      			say "Use :(Lighting 1, Other 2) = ".$rUse;
      			say "(Radial 1, Ring 2) = ".$rRing;
      			say "--------------------------------";
      			say "Submit results to site data? Y/N";
      			my $confirm = <STDIN>;	
      			if ($confirm =~ /Y/i){
      				open (my $fh,'>>',$file) or die "couldnt open '$file' $!";
       			say $fh "------------------------------------------------------------";     				
      				say $fh $circuit_name;
      			say $fh "------------------------------------------------------------";
    			say $fh "Finished Cable size = ".$rmm." mm";
    			say $fh "Zs = ".$rzs."ohms (max for device = ".$rmaxzs.")";
    			say $fh "Reference method = ".$rmethod."#";
    			say $fh "Voltage Drop = ".$rdrop."v at ".$rperc." %";
    			say $fh "Design current Ib = ".$rIb." amps";  	
      			say $fh "Length = ".$rlength." metres";
      			#say $fh "PFC = ".$pfc." KA";
      			say $fh "In = ".$rIn." A";
       			say $fh "Device Type = ".$dtype." ";     			
      			say $fh "Use :(Lighting 1, Other 2) = ".$rUse;
      			say $fh "(Radial 1, Ring 2) = ".$rRing;
      			say $fh "------------------------------------------------------------";
      				close $fh;
      				say"saved";
      				goto CHOICE;
      			}
      			else{goto START;}	
    			 }
			case "2" {say "Armoured Multicore 70deg";
				my ($rzs, $rmm, $rmethod, $rdrop, $rperc, $rmaxzs, $rIb, $rlength, $rIn, $rUse, $rDist, $factored_In, $vd_max, $ca, $cs, $cd) = arm70($z, $pfc, $dtype);
    			say "------------------------------------------------------------";
    			say "Finished Cable size = ".$rmm." mm";
    			say "Zs = ".$rzs."ohms (max for device = ".$rmaxzs.")";
    			say "Reference method = ".$rmethod."#";
    			say "Factored It = ".$factored_In." for given values - Ca ". $ca. " Cs ".$cs." Cd " .$cd;  
    			say "Voltage Drop = ".$rdrop."v at ".$rperc." %"." Max permissible is ". $vd_max." %";
    			say "Design current Ib = ".$rIb." amps";
      			say "Ze = ".$z." ohms";  	
      			say "Length = ".$rlength." metres";
      			say "PSCC = ".$pfc." KA";
      			say "In = ".$rIn." A";
      			say "Device Type = ".$dtype." ";
      			say "Use :(Lighting 1, Other 2) = ".$rUse;
      			say "(Distribution Y/N) = ". uc $rDist;
      			say "--------------------------------";
      			say "Submit results to site data? Y/N";
      			my $confirm = <STDIN>;	
      			if ($confirm =~ /Y/i){
      				open (my $fh,'>>',$file) or die "couldnt open '$file' $!";
       			say $fh "------------------------------------------------------------";     				
      			say $fh "Circuit name : ". $circuit_name;
      			say $fh "------------------------------------------------------------";
    			say $fh "Finished Cable size = ".$rmm." mm";
    			say $fh "Zs = ".$rzs."ohms (max for device = ".$rmaxzs.")";
    			say $fh "Reference method = ".$rmethod."#";
    	    	say $fh "Design current Ib = ".$rIb." amps";		
    			say $fh "Factored It = ".$factored_In." for given values - Ca ". $ca. " Cs ".$cs." Cd " .$cd; 
    			say $fh "In = ".$rIn." A";
       			say $fh "Device Type = ".$dtype." ";
    			say $fh "Voltage Drop = ".$rdrop."v at ".$rperc." %"." Max permissible is ". $vd_max."%";
      			say $fh "Length = ".$rlength." metres";
      			say $fh "Use :(Lighting 1, Other 2) = ".$rUse;
      			say $fh "(Distribution Y/N) = ".uc $rDist;
      			say $fh "------------------------------------------------------------";
      				close $fh;
      				say"saved";
      				goto CHOICE;
      			}
      			else{
      				goto START;
      			}	
    			 }
    		else {
    			say "select again";
    			goto CHOICE;
    		}
}
			#switch
			
