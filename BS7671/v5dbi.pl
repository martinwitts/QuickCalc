#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);
use JSON::XS;
use DBI;
 
my $dbfile = "/home/workspace/Database/circuitDB.db";
 
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";
my $dbh = DBI->connect($dsn, $user, $password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
});
 
# ...
my $sql = 'SELECT * FROM site';
my $sth = $dbh->prepare($sql);
$sth->execute();
my @json = ();
while (my @row = $sth->fetchrow_array) {
#unshift @json, $_;
    #say "$row[0]";
    #say "$row[1]";
    #say "$row[2]";
    #say "$row[3]"; 
    #say "$row[4]";
    #say "$row[5]";
    #say "$row[6]"; 
    #say "$row[7]";
    push @json, ($row[0],$row[1],$row[2],$row[3],$row[4],$row[5],$row[6],$row[7]);
   
}
  to_json(\@json);

#say @json;
my $name = 'Foo';
my $email = 'Bar',
my $phone = 'foo@bar.com';
$dbh->do('INSERT INTO site (name, email_address, phone_number) VALUES (?, ?, ?)',
  undef,
  $name, $email, $phone);

  
  
  $dbh->disconnect;
sub to_json{
	my $jsonin = shift;
my $student_json = encode_json $jsonin;
say $student_json;
  }
