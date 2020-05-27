#!/usr/bin/perl

use feature qw(say);
use lib qw(/home/workspace/BS7671/BS);
use Flat70;
use Site;
use Test::More 'no_plan';
use Switch;
use Moose;
#Site Parameters-------------------------------------------
#Site name
my $s_name = 'test';
#prospective fault current
my $pfc = 3.5;
#Ze
my $ze = '0.28';
#3 Phase
my $s_ph = 3;
#Cable Parameters---------------------------
#Circuit name
my $c_name = 'lights';
#Design Current Ib
my $c_Ib = 32;
#Reference Method
my $c_rm = '102';
#Cable Type 1=flat thermoplastic 70, 2=swa
my $c_ct = '1';
#Enter Cable Length
my $c_cl = 22;
#Ring 1=yes, 2=no
my $c_ring = 1;
#Circuit Type - eg. s/o lighting
#lighting=1,heating=2,cooking=3,motors=4,water-heater(inst)=5,water-heater(thermo)=6,floor-warming=7,thermal-storage-heating=8
#standard-final-circuits=9,socket-outlets=10
my $c_cir = 2;
#Distribution 1=yes, 2=no Only for SWA
my $c_dist = 2;
#Ca default = 1
my $c_ca = '1';
#Cs
my $c_cs = '1';
#Cd
my $c_cd = '1';
#Cg
my $c_cg = '1';
#Ci
my $c_ci = '1';
#Cc
my $c_cc = '1';

my $site = Site->new(   name => $s_name,
						pfc => $pfc,
						ze => $ze,
						max_demand => '0',
						phase => $s_ph

 );

my $cable1 = Flat70->new( name => $c_name,
						ib =>	$c_Ib,
						ref =>	$c_rm,
						cable_type => $c_ct,
						length => $c_cl,
						circuit_type => $c_cir,
						ring => $c_ring,
						distro => $c_dist,
						ca => $c_ca,
						cs => $c_cs,
						cd => $c_cd,
						cg => $c_cg,
						ci => $c_ci,
						cc => $c_cc
 );

my $cable2use = ();
            switch ($c_ct) {
    		case 1 {$cable2use = $cable1; say "Using Flat thermoplastic 70";}
    		case 2 {}

    		else     {say "Problem"}
            }


say "Site name: ".uc $site ->name;
say "PFC: ".$site ->pfc;
say "Device Type: ".$site ->dev_type($pfc);
say "Ze: ".$site ->ze;
say "Single or 3 Phase? : ".say $site ->phase;
#---------------
say "Circuit name: ".uc $cable2use ->name; 
say "Design current: ".uc $cable2use ->ib; 
say "Reference method: ".uc $cable2use ->ref; 
say "Cable type: ".uc $cable2use ->cable_type; 
say "Cable length: ".uc $cable2use ->length; 
say "Radial / Ring: ".uc $cable2use ->ring; 
say "Circuit type: ".uc $cable2use ->circuit_type; 
say "Distribution: ".uc $cable2use ->distro; 

say "Ca: ".uc $cable2use ->ca; 
say "Cs: ".uc $cable2use ->cs; 
say "Cd: ".uc $cable2use ->cd; 
say "Cg: ".uc $cable2use ->cg; 
say "Ci: ".uc $cable2use ->ci; 
say "Cc: ".uc $cable2use ->cc;

#get device (In)--------------------------
my $In = $cable2use ->getIn($cable2use ->ib);say "In:".$In;
#get device max Zs------------------------
my $dev_max_zs = $cable2use ->maxzs($cable2use ->ib, $site ->dev_type($pfc));say "Device Max Zs:".$dev_max_zs;
#get initial cable size based on maxZs-------
my $short_list = $cable2use->main($c_Ib, $c_rm);#get short list It
my %short_list = %{$short_list};
#get cable size and compare calculated zs with device max zs
my $init_mm = $cable2use->r1r2($c_ring, $ze, $dev_max_zs, $c_cl, \%short_list);say "Initial Cable size:".$init_mm." mm";
#get voltage drop of cable size and upgrade if needed
my ($final_mm, $drop, $perc, $vd_allowed) = $cable2use->vdrop($c_cl, $init_mm , $c_Ib, $c_cir);#length,size,Ib,lighting or other
say "Final Cable size:".$final_mm." mm";
say "Voltage Drop:".$drop." V";
print "Voltage Drop Percentage:".$perc." %";say " -  Allowed Voltage Drop Percentage:".$vd_allowed." %";
#get final zs for final cable size------
my $finalZs = $cable2use->final_zs($final_mm, $c_cl, $ze, $c_ring); say "Final Zs for cable:".$finalZs." ohms";


