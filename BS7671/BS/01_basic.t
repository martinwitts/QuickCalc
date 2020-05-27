use feature qw(say);
use lib qw(/home/workspace/BS7671/BS);
use Flat70;
use Site;
use Test::More 'no_plan';
#Site Parameters-------------------------------------------
#Site name
my $s_name = 'barn';
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
my $c_rm = 'c';
#Cable Type 1=flat thermoplastic 70, 2=swa
my $c_ct = '1';
#Enter Cable Length
my $c_cl = 22;
#Ring 1=yes, 2=no
my $c_ring = 2;
#Circuit Type - eg. s/o lighting
my $c_cir = 1;
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

my $site = Site->new(   name => "Test name",
						pfc => "3.5",
						ze => "0.28",
						max_demand => '0',
						phase => "3"

 );
 
use_ok('Site');#module load
use_ok('Flat70');#module load
isa_ok($site, 'Site');
#test device type B------------------------------
say "Test return device type 6/10ka";
is(
 $site->dev_type(1),#
 "6ka",
 'Device type 6ka'
);
#test device type C------------------------------
is(
 $site->dev_type(6.5),#
 "10ka",
 'Device type 10ka'
);
#test initial device (In)--------------------------
say "Test return protective device In";
is(
 Flat70->getIn(51),#
 "63",
 'Device In'
);
#test max zs for chosen device (In)--------------------------
say "Test return max zs for devices C/D";
is(
 Flat70->maxzs($c_Ib, "b"),#
 "1.365625",
 'Device maxzs for B is 1.365625'
);
is(
 Flat70->maxzs($c_Ib, $c_rm),#
 "0.6828125",
 'Device maxzs for C is 0.6828125'
);
#-------------------Get cable initial cable size based on maxZs--------------------------
my $dev_maxzs = Flat70->maxzs($c_Ib, $c_rm);#get maxzs for device
my $short_list = Flat70->main($c_Ib, $c_rm);#get short list It
my %short_list = %{$short_list};

is(
 Flat70->r1r2($c_ring, $ze, $dev_maxzs, $c_cl, \%short_list),#
 "4",
 'Return cable size 4 after zs comparison'
);
 #Pass needed values to compare device Zs with cable Zs in hash table
#my $zs_compare = r1r2($ring, $z, $dev_maxzs, $length, \%tab);
#--------------------------------------------------------------------------------------
#Checking voltage drop against 3% and 5%
my $cable_mm = Flat70->r1r2($c_ring, $ze, $dev_maxzs, $c_cl, \%short_list);#returns 4
my ($final_mm, $drop, $perc, $vd_allowed) = Flat70->vdrop($c_cl, $cable_mm, $c_Ib, $c_cir);
say $final_mm."-".$drop."-".$perc."-".$vd_allowed;
#--------------------------------------------------------------------------------------
#Get final Zs for chosen cable (It)
is(
 Flat70->final_zs($final_mm, $c_cl, $ze, $c_ring),#
 "0.337695",
 'Return final Zs for final cable size'
);

