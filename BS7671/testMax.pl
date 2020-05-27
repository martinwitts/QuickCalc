#!/usr/bin/perl

use feature qw(say);
use lib qw(/home/workspace/BS7671/BS);
use MaxDemand;
use Test::More 'no_plan';
use Switch;
use Moose;
use Data::Dumper;

my $c_type = 3;
my $p_type = 1;
my @key = (1,1,2,2,1,3,4,5,6,6,10,10,10,7,3,8,9,5,5,4,4,9);
my @value = (12,6,15,1,10,22,6,55,25,15,32,32,32,44,23,30,32,20,22,10,5,2);
my %ib_list = (1 => "12",
			1 => "6",
            2 => "3",
            1 => "6",
            1 => "10",
            3 => "22",
            4 => "4",
            5 => "55",
            6 => "25",
            6 => "15",
            10 => "32",
            10 => "32", 
            10 => "32",
            7 => "44");

my $demand = MaxDemand->new(   circuit_type => $c_type,
						premise_type => $p_type,
						keys_in => \@key,
						values_in =>\@value,
 );
 
use_ok('MaxDemand');#module load

isa_ok($demand, 'MaxDemand');
#say Dumper $demand ->keys_in; 
#say Dumper $demand ->values_in;

say "circuit type: ".$demand ->data_check();
my $max = $demand ->main();
say $max;

            
