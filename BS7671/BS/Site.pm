package Site;


use feature 'say';
use lib qw(/home/twiki/lib/CPAN/lib);
use Switch;
use Moose;
use Moose::Util::TypeConstraints;
 
 
 
has 'name'    => (is => 'rw');
has 'pfc'      => (isa => 'Num', is => 'rw');
has 'ze'    => (isa => 'Num', is => 'rw');
has 'max_demand'     => (isa => 'Str', is => 'rw');
has 'phase'     => (isa => 'Int', is => 'rw');
#get device type--------------------------------
sub dev_type {
   my($self, $pfc) = @_;
	my $dtype;
    if ($pfc <= 6) {
    $dtype = "6ka";
    return $dtype;
 }
    if ($pfc <= 10){
    $dtype = "10ka";
    return $dtype;
 }
     if ($pfc <= 15) {
    $dtype = "15ka";
    return $dtype;
 }
      if ($pfc <= 20) {
    $dtype = "20ka";
    return $dtype;
 }
       if ($pfc <= 25) {
    $dtype = "25ka";
    return $dtype;
 }
	else{return "what?";}
}



1;
