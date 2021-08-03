#TEST
#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Plack::Request;
use Plack::App::Directory;
use Plack::App::File;
use Plack::Builder;
use Plack::App::File;
use Plack::Middleware::Static;
use JSON qw(to_json);
use DBI;
use JSON::XS;
use CGI qw(:standard);
use JSON;
use lib qw(/usr/local/www/apache24/cgi-bin/res_circuit/BS7671/BS);
use lib qw(BS7671/BS);
use Flat70;
use SWA70;
use Site;
use MaxDemand;
use Test::More 'no_plan';
use Switch;
use Moose;
use Data::Dumper;
####################################
#use Config::Simple;
#my $cfg = new Config::Simple();
#   $cfg->read('config/circuit.cfg');
#my $hostname = $cfg->param("host");
#my $dbname = $cfg->param("database");
#my $username = $cfg->param("username");
#my $password = $cfg->param("password");

my $hostname = "localhost";
my $dbname = "circuitDB.db";
my $username = "";
my $password = "";


####################################
sub open_db{
#my $dbfile = "";
my $dbfile = "/$dbname";
 
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";
my $dbh = DBI->connect($dsn, $user, $password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
});
return $dbh;
}

my %ROUTING = (
    '/'        =>   \&serve_root,
    '/customer'=>   \&serve_customer,#----------------------------populate customer grid
    '/site'    =>   \&serve_site,#--------------------------------populate site grid
    '/circuit' =>   \&serve_circuit,#-----------------------------populate circuit grid
    '/cus_id'  =>   \&serve_cus_id,#------------------------------dropdown control for add/edit----site table
    '/site_id' =>   \&serve_site_id,#-----------------------------dropdown control for add/edit----customer table
    '/getMax'  =>   \&serve_max_demand, 
	'/ddl'        =>   \&serve_ddl,#
	'/circuits' =>   \&serve_circuits,#-----------------------------
    '/sites' =>   \&serve_sites,#-----------------------------
	'/customers' =>   \&serve_customers,#-----------------------------
    '/equations' =>   \&serve_equations,#-----------------------------
);
 
 
my $app = sub {
    my $env = shift;
    my $request = Plack::Request->new($env);
    my $route = $ROUTING{$request->path_info};
    if ($route) {
        return $route->($env);
    }
    return [
        '404',
        [ 'Content-Type' => 'text/html' ],
        [ '404 Not Found' ],
    ];
};
 
sub serve_root {
    my $html = get_html();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
sub serve_sites {
    my $html = get_sites();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 

sub serve_circuit {
    my $html = get_circuit();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
sub serve_paging {
    my $html = get_paging();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
sub serve_customers {
    my $html = get_customers();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
sub serve_circuits {
    my $html = get_circuits();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
sub serve_equations {
    my $html = get_equations();

    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
} 
#----------------------dropdown control for add/edit----site table------------------------- 
sub serve_cus_id {
    my $env = shift;
    my $request = Plack::Request->new($env);
    my $dbh = open_db();
# ...
my $sql1 = 'SELECT * FROM customer';
my $sth1 = $dbh->prepare($sql1);
$sth1->execute();
my @json3 = ();
while (my $row1 = $sth1->fetchrow_hashref) {
    push (@json3, $row1);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json3 ],
    ];

}
#----------------------dropdown control for add/edit----customer table------------------------- 
sub serve_site_id {
    my $env = shift;
    my $request = Plack::Request->new($env);
    my $dbh = open_db();
# ...
my $sql1 = 'SELECT * FROM site';
my $sth1 = $dbh->prepare($sql1);
$sth1->execute();
my @json4 = ();
while (my $row1 = $sth1->fetchrow_hashref) {
    push (@json4, $row1);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json4 ],
    ];

} 
#----------------------selector for site dropdown----circuit table------------------------- 
sub serve_ddl {
    my $env = shift;
    my $request = Plack::Request->new($env);
    my $dbh_state = open_db();
# ...

     my $sql_state = "SELECT * FROM site WHERE active = 'Y'";
		my $sth_state = $dbh_state->prepare($sql_state);
		$sth_state->execute();
		my @sc = ();
		while (my @row = $sth_state->fetchrow_array) {
    	push (@sc, $row[0]);
		}      
		#say "id of Active state is= ".$sc[0];  
        #sleep 5;
        
        $sth_state->finish();
		$dbh_state->disconnect();

# ...
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@sc ],
    ];

} 
#----------------------get max demand--------------------------------------------------------------- 
sub serve_max_demand {
    my $env = shift;
    my $request = Plack::Request->new($env);
        if ($request->param('id')) {
        my $id = ($request->param('id'));
    say "-----------------received id from getMax request : " . $id;
    
    #-----------------------open site table and get premise_type-----------------------
my $dbh0 = open_db();
# ...
my $sql0 = "SELECT * FROM site WHERE id = $id";
my $sth0 = $dbh0->prepare($sql0);
$sth0->execute();
my @pt = ();
while (my @row = $sth0->fetchrow_array) {
say "Pushing row[4] into array premise type, 4th in the table----------------------------".$row[4];
    push (@pt, $row[4]);
}   
say "------------------------premise_type selected " . $pt[0];
my $premise = $pt[0];

#-----------------------open site table and get premise_type-----------------------  
          my $dbh7 = open_db();
# ...
my $sql7 = "SELECT * FROM circuit WHERE circuit_site = $id";
my $sth7 = $dbh7->prepare($sql7);
$sth7->execute();
my @ct = ();
my @ct_ib = ();
while (my @row = $sth7->fetchrow_array) {
    push (@ct, $row[10]);#Circuit type(1 - 10)
    push (@ct_ib, $row[4]);
}      
say Dumper @ct;  
say Dumper @ct_ib;  
#----------------------------------------------------
my $p_type = $premise;
my $c_type = 3;
my @ib = @ct_ib;
my $demand = MaxDemand->new(   circuit_type => $c_type,
						premise_type => $p_type,
						keys_in => \@ct,
						values_in =>\@ib,
 );


my $max = $demand ->main();
say $max;
#----------------------------------------------------
 my $dbh9 = open_db();
 
 #------------------update site details-------------------------------------------------
say "UPDATE request with id: $id----------------------------------------------";
my $sql9 = qq(UPDATE site SET demand='$max' WHERE id= $id);
my $sth9 = $dbh9->prepare($sql9);
$sth9->execute();
#---------------------------------------------------
    my $dbh = open_db();         
# ...
my $sql1 = 'SELECT * FROM site';
my $sth1 = $dbh->prepare($sql1);
$sth1->execute();
my @json4 = ();
while (my $row1 = $sth1->fetchrow_hashref) {
    push (@json4, $row1);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json4 ],
    ];
}
}
#-------------------------------------------------------------------------
sub serve_site {
    my $env = shift;
    my $request = Plack::Request->new($env);
    
    
    
    
    
    
    
    
              if ($request->param('_search') && ($request->param('_search') eq 'true')) {
        my $searchField = ($request->param('searchField'));
        my $string = ($request->param('searchString'));
        my $searchOper = ($request->param('searchOper'));    

        say "search request ----------------------------------------------";
        say $searchField;
        say $string;
        say $searchOper;
        my $dbh = open_db();
# ...
my $sql0 = "SELECT * FROM site WHERE $searchField == $string";
my $sth0 = $dbh->prepare($sql0);
$sth0->execute();
my @json0 = ();
while (my $row0 = $sth0->fetchrow_hashref) {
    push (@json0, $row0);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json0 ],
    ];
    
    
    }
    

        #--------------------------------------------------------add
    if ($request->param('oper') && ($request->param('oper') eq 'add')) {
        my $name = ($request->param('name'));
        my $pfc = ($request->param('pfc'));    
        my $ze = ($request->param('ze'));
        my $p_t = ($request->param('premise_type'));
        my $phase = ($request->param('phase'));
        my $demand = ($request->param('demand'));
        my $address = ($request->param('address'));
        my $postcode = ($request->param('postcode'));
        my $site_customer = ($request->param('site_customer'));
    
 my $dbh = open_db();
 # ...
         say "INSERT request ----------------------------------------------";
my $sql = qq(INSERT INTO site (name, pfc, ze, premise_type, phase, demand, address, postcode, site_customer)
             VALUES ('$name', '$pfc', '$ze', '$p_t', '$phase', '$demand', '$address', '$postcode', '$site_customer'));
my $sth = $dbh->prepare($sql);
$sth->execute();
 
 } 
      if ($request->param('oper') && ($request->param('oper') eq 'del')) {
        say "Delete request ----------------------------------------------";
        say "id = " .($request->param('id'));
        my $id = ($request->param('id'));
my $dbh = open_db();
# ...DELETE
my $sql = "DELETE FROM site WHERE id = $id; PRAGMA foreign_keys = ON;";
my $sth = $dbh->prepare($sql);
$sth->execute(); 
$sth->finish();
$dbh->disconnect();
my $dbha = open_db();
# ...DELETE
my $sqla = "DELETE FROM circuit WHERE id = $id; PRAGMA foreign_keys = ON;";
my $stha = $dbha->prepare($sqla);
$stha->execute(); 
$stha->finish();
$dbha->disconnect();

    }   
         if ($request->param('oper') && ($request->param('oper') eq 'edit')) {
        my $id = ($request->param('id'));
        my $name = ($request->param('name'));
        my $pfc = ($request->param('pfc'));    
        my $ze = ($request->param('ze'));
        my $p_t = ($request->param('premise_type'));
        my $phase = ($request->param('phase'));
        my $demand = ($request->param('demand'));
        my $address = ($request->param('address'));
        my $postcode = ($request->param('postcode'));
        my $site_customer = ($request->param('site_customer'));
    
 my $dbh = open_db();
 
 #------------------update site details-------------------------------------------------
         say "UPDATE request with id: $id----------------------------------------------";
my $sql = qq(UPDATE site SET name='$name', pfc='$pfc', ze='$ze', premise_type='$p_t', phase='$phase', demand='$demand', address='$address', postcode='$postcode', site_customer='$site_customer' WHERE id= $id);
my $sth = $dbh->prepare($sql);
$sth->execute();
 
 } 
    
    
    my $dbh = open_db();
# ...
my $sql1 = 'SELECT * FROM site';
my $sth1 = $dbh->prepare($sql1);
$sth1->execute();
my @json1 = ();
while (my $row1 = $sth1->fetchrow_hashref) {
    push (@json1, $row1);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json1 ],
    ];

}


#/////////////////////////////////////////////////Serve the Circuit Grid/////////////////////////////////////////////////
sub serve_circuit {
    my $env = shift;
    my $request = Plack::Request->new($env);

            #--------------------------------------------------------add
            
    if ($request->param('oper') && ($request->param('oper') eq 'add')) {

        my $name = ($request->param('name'));
        my $cable_type = ($request->param('cable_type'));    
        my $i_b = ($request->param('i_b'));
		my $d_type = ($request->param('dev_type'));
        my $rm = ($request->param('rm'));
        my $cable_length = ($request->param('cable_length'));
        my $radial = ($request->param('radial'));
        my $circuit_type = ($request->param('circuit_type'));
        my $distro = ($request->param('distro'));
        my $ca = ($request->param('ca'));
        my $cs = ($request->param('cs'));
        my $cd = ($request->param('cd'));
        my $cg = ($request->param('cg'));
        my $ci = ($request->param('ci'));
        my $cc = ($request->param('cc'));
        my $customer_id = ($request->param('customer_id'));
        my $circuit_site = ($request->param('circuit_site'));
#------------------------------------------------------------------------Get site_customer id        
        
      my $dbh7 = open_db();
# ...
#my $sql7 = "SELECT * FROM site WHERE id = $circuit_site";
my $sql7 = "SELECT * FROM site";
my $sth7 = $dbh7->prepare($sql7);
$sth7->execute();
my @sc = ();
while (my @row = $sth7->fetchrow_array) {
    push (@sc, $row[9]);
}      
say "site_customer_id= ".$sc[0];   
#-------------------------------------\\\-------------------------------------        
 my $dbh = open_db();
 # ...
         say "INSERT request ----------------------------------------------";
         say "Device type ----------------------------------------------".$d_type;
my $sql = qq(INSERT INTO circuit (name, cable_type, i_b, dev_type, rm, cable_length, radial, circuit_type, distro, ca, cs, cd, cg, ci, cc, customer_id, circuit_site)
             VALUES ('$name', '$cable_type', '$i_b', '$d_type', '$rm', '$cable_length', '$radial', '$circuit_type', '$distro', '$ca', '$cs', '$cd', '$cg', '$ci', '$cc', '$sc[0]', '$circuit_site'));
my $sth = $dbh->prepare($sql);
$sth->execute();
      my $rid = $dbh->last_insert_id(undef,undef,undef,undef);

print "last insert id = $rid\n";
$sth->finish();
$dbh->disconnect();
#------------------------------Process the input for insert---------------

my $site = get_site_data($circuit_site);
my @site_return = @{$site};
say "getting back : circuit_site : ".$site_return[0]. "address : ".$site_return[1];
#say "check id:  ".$circuit_id;
#say "check name: ".$name;
process($rid, $name, $cable_type, $i_b, $d_type, $rm, $cable_length, $radial, $circuit_type, $distro, $ca, $cs, $cd, $cg, $ci, $cc, $circuit_site, \@site_return);





#-------------------------------------------------------------- 
 } 
 #---------------------------------------------------edit
         if ($request->param('oper') && ($request->param('oper') eq 'edit')) {
         
         
        my $id = ($request->param('id'));
        my $name = ($request->param('name'));
        my $cable_type = ($request->param('cable_type'));    
        my $i_b = ($request->param('i_b'));
		my $d_type = ($request->param('dev_type'));
        my $rm = ($request->param('rm'));
        my $cable_length = ($request->param('cable_length'));
        my $radial = ($request->param('radial'));
        my $circuit_type = ($request->param('circuit_type'));
        my $distro = ($request->param('distro'));
        my $ca = ($request->param('ca'));
        my $cs = ($request->param('cs'));
        my $cd = ($request->param('cd'));
        my $cg = ($request->param('cg'));
        my $ci = ($request->param('ci'));
        my $cc = ($request->param('cc'));

        my $circuit_site = ($request->param('circuit_site'));
    
    
    
    
 my $dbh = open_db();
 
 #-------------------------------------------------------------------------------update
         say "UPDATE request with id: $id----------------------------------------------";
my $sql = qq(UPDATE circuit SET name='$name', cable_type='$cable_type', i_b='$i_b', dev_type='$d_type', rm='$rm', cable_length='$cable_length', radial='$radial', circuit_type='$circuit_type', distro='$distro', ca='$ca', cs='$cs', cd='$cd', cg='$cg', ci='$ci', cc='$cc', circuit_site='$circuit_site' WHERE id= $id);
my $sth = $dbh->prepare($sql);
$sth->execute();
 #------------------------------Process the input for UPDATE---------------

my $site = get_site_data($circuit_site);
my @site_return = @{$site};
say "getting back : ". $site_return[0]. $site_return[1];
#say "check id:  ".$id;
say "check name: ".$name;
process_edit($id, $name, $cable_type, $i_b, $d_type, $rm, $cable_length, $radial, $circuit_type, $distro, $ca, $cs, $cd, $cg, $ci, $cc, $circuit_site, \@site_return);

 
 }
    #---------------------------------------------------
          if ($request->param('oper') && ($request->param('oper') eq 'del')) {
        say "Delete request ----------------------------------------------";
        say "id = " .($request->param('id'));
        my $id = ($request->param('id'));
my $dbh = open_db();
# ...DELETE
my $sql = "DELETE FROM circuit WHERE id = $id; PRAGMA foreign_keys = ON;";
my $sth = $dbh->prepare($sql);
$sth->execute(); 
$sth->finish();
$dbh->disconnect();
    }  
 #----------------------------------------------------------------------------------------Search the circuit grid / also from site selector button
          if ($request->param('_search') && ($request->param('_search') eq 'true')) {
        my $searchField = ($request->param('searchField'));
        my $string = ($request->param('searchString'));
        my $searchOper = ($request->param('searchOper'));    

        #say "search request ----------------------------------------------";
        #say "SearchField : ".$searchField;
        #say "Searchtring is:  ".$string;
        #say $searchOper;
        my $dbh_state = open_db();
        
        ######Lets get the id of the CURRENT (active) row id in site table#####################################
        
        
        my $sql_state = "SELECT * FROM site WHERE active = 'Y'";
		my $sth_state = $dbh_state->prepare($sql_state);
		$sth_state->execute();
		my @sc = ();
		while (my @row = $sth_state->fetchrow_array) {
    	push (@sc, $row[0]);
		}      
		#say "id of Active state is= ".$sc[0];  
        #sleep 5;
        
        $sth_state->finish();
		$dbh_state->disconnect();

        ######Lets set the id of the that tuple with a (N) in site table#################################
        
        
         my $dbh_n = open_db();
        
        
          #say "Updating into (site) table with (N) for active state id-------------".$sc[0];

		my $sql_n = qq(UPDATE site SET active='N' WHERE id= $sc[0]);
		my $sth_n = $dbh_n->prepare($sql_n);
		$sth_n->execute();
        $sth_n->finish();
		$dbh_n->disconnect();
		
		
        ######Lets set the id of the new (active) row id in site table#################################
        
        
         my $dbh_y = open_db();
        
        
        #say "Updating into site table with Y for new active state id-------------".$string;

		my $sql_y = qq(UPDATE site SET active='Y' WHERE id= $string);
		my $sth_y = $dbh_y->prepare($sql_y);
		$sth_y->execute();
        
        $sth_y->finish();
		$dbh_y->disconnect();
        
        
         my $dbh = open_db();
        
        
          #say "Updating into circuit_selector table--------------------------------------------".$string;

my $sql = qq(UPDATE circuit_selector SET selection=$string WHERE id= '1');
my $sth = $dbh->prepare($sql);
$sth->execute();
    
# ...
my $sql0 = "SELECT * FROM circuit WHERE $searchField == $string";
my $sth0 = $dbh->prepare($sql0);
$sth0->execute();
my @json0 = ();
while (my $row0 = $sth0->fetchrow_hashref) {
    push (@json0, $row0);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json0 ],
    ];


    }
#......................................................................................................................
    #my $dbh = open_db();
# .....................................................................................................................



##################say "Getting selection from circuit_selector on normal load of page--------------------------";


      my $dbh8 = open_db();
# ...
my $sql8 = "SELECT * FROM circuit_selector WHERE id = 1";
#my $sql8 = "SELECT * FROM circuit_selector";
my $sth8 = $dbh8->prepare($sql8);
$sth8->execute();
my @sc = ();
while (my @row = $sth8->fetchrow_array) {
    push (@sc, $row[1]);
}      
########################say "circuit_selector selection= ".$sc[0]; 
my $selection = $sc[0];
#-------------------------------------\\\------------------------------------- 






my $dbh2 = open_db();

#say"";
#say "------------------site selection on page load is :".$selection;
#say"";
my $sql2 = "SELECT * FROM circuit WHERE circuit_site = $selection";
#my $sql2 = "SELECT * FROM circuit";
my $sth2 = $dbh2->prepare($sql2);
$sth2->execute();
my @json2 = ();
while (my $row2 = $sth2->fetchrow_hashref) {
    push (@json2, $row2);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json2 ],
    ];

}
#END/////////////////////////////////////////////////Serve the Circuit Grid/////////////////////////////////////////////////


#/////////////////////////////////////////////////Serve the Customer Grid/////////////////////////////////////////////////
sub serve_customer {
    my $env = shift;
    my $request = Plack::Request->new($env);
    #---------------------------------------------------------delete
    if ($request->param('oper') && ($request->param('oper') eq 'del')) {
        say "Delete request ----------------------------------------------";
        say "id = " .($request->param('id'));
        my $id = ($request->param('id'));
my $dbh = open_db();
# ...DELETE
my $sql = "DELETE FROM customer WHERE id = $id; PRAGMA foreign_keys = ON;";
my $sth = $dbh->prepare($sql);
$sth->execute(); 
$sth->finish();
$dbh->disconnect();


#===========================================delete rows from site table cascaded
my $dbh3 = open_db();
# ...DELETE
my $sql3 = "DELETE FROM site WHERE site_customer = $id";
my $sth3 = $dbh3->prepare($sql3);
$sth3->execute(); 
$sth3->finish();
say "deleted rows from site table: id = ". $id;
#===========================================delete rows from circuit table cascaded


my $dbh4 = open_db();
# ...DELETE
my $sql4 = "DELETE FROM circuit WHERE customer_id = $id";
my $sth4 = $dbh4->prepare($sql4);
$sth4->execute(); 
$sth4->finish();

    } 
    #--------------------------------------------------------add
    if ($request->param('oper') && ($request->param('oper') eq 'add')) {
        my $name = ($request->param('name'));
        my $email = ($request->param('email_address'));    
        my $phone = ($request->param('phone_number'));
        my $mobile = ($request->param('mobile'));
        my $company = ($request->param('company'));
        my $address = ($request->param('address'));
        my $postcode = ($request->param('postcode'));
    
 my $dbh = open_db();
 # ...
         say "INSERT request ----------------------------------------------";
my $sql = qq(INSERT INTO customer (name, email_address, phone_number, mobile, company, address, postcode)
             VALUES ('$name', '$email', '$phone', '$mobile', '$company', '$address', '$postcode'));
my $sth = $dbh->prepare($sql);
$sth->execute();
 
 } 
     if ($request->param('oper') && ($request->param('oper') eq 'edit')) {
        my $id = ($request->param('id'));
        my $name = ($request->param('name'));
        my $email = ($request->param('email_address'));    
        my $phone = ($request->param('phone_number'));
        my $mobile = ($request->param('mobile'));
        my $company = ($request->param('company'));
        my $address = ($request->param('address'));
        my $postcode = ($request->param('postcode'));
    
 my $dbh = open_db();
 
 #-------------------------------------------------------------------------------update
         say "UPDATE request with id: $id----------------------------------------------";
my $sql = qq(UPDATE customer SET name='$name', email_address='$email', phone_number='$phone', mobile='$mobile', company='$company', address='$address', postcode='$postcode' WHERE id= $id);
my $sth = $dbh->prepare($sql);
$sth->execute();
 
 }  
    else {# if no action, just poulate grid
    
    }
    my $dbh = open_db();
# ...
my $sql = 'SELECT * FROM customer';
my $sth = $dbh->prepare($sql);
$sth->execute();
my @json = ();
while (my $row = $sth->fetchrow_hashref) {
    push (@json, $row);
}
    return [
        '200',
        [ 'Content-Type' => 'application/json' ],
        [ to_json \@json ],
    ];
}

#END/////////////////////////////////////////////////Serve the Customer Grid/////////////////////////////////////////////////



#/////////////////////////////////////////////////builder/////////////////////////////////////////////////////////

  builder {
  enable 'CrossOrigin', origins => '*';
    enable "Auth::Basic", authenticator => sub {
        my($username, $password) = @_;
        return $username eq 'admin' && $password eq '';
    };
enable "Plack::Middleware::Static",
                path => qr!^/(myjs|css|js|justgage|media_button_bar|jqm|sidebar|images|jq|font-awesome)/!,
                #root => "/Plack::Circuit/circuit/static";
                root => "/usr/local/www/apache24/cgi-bin/Plack__Circuit/circuit/static";
                $app;
  };
  
#////////////////////////////////////////////////builder//////////////////////////////////////////////////////////

sub get_site_data{
my $data_id = shift;
    my $dbh = open_db();
# ...
say $data_id;

my $sql = "SELECT * FROM site WHERE id= $data_id;";
my $sth = $dbh->prepare($sql);
$sth->execute();
my @data = ();
while (my @row = $sth->fetchrow_array) {
    push @data, ($row[0],$row[1],$row[2],$row[3],$row[4],$row[5],$row[6],$row[7],$row[8]);
   
}
say @data;
return (\@data);
}


###########################################################
#-----------------------------------------------------------------INSERT---------------------------------------------------------------------
#/////////////////////////////////////////////////Process////////////////////////////////////////////////////////////////////////////////////
sub process{
#----------------------site parameters--------------------
my ($rid, $cname, $cable_type, $ib, $d_type, $rm, $cable_length, $radial, $circuit_type, $distro, $ca, $cs, $cd, $cg, $ci, $cc, $circuit_site, $site_in) = @_;
say "device_type is---------".$d_type;
my @s = @{$site_in};
#say "site:".$cid;
say "element 1:".$s[1];
#-----------------------------------------------------------
=head1 Site Parameters
Site parameters are passed in with $site_in
=cut

#Site Parameters-------------------------------------------
#Site name
my $s_name = $s[1];
#prospective fault current
my $pfc = $s[2];
#Ze
my $ze = $s[3];
#3 Phase
my $s_ph = $s[4];
#Cable Parameters---------------------------


#Circuit name
my $c_name = $cname;
#Design Current Ib
my $c_Ib = $ib;
#Reference Method
my $c_rm = $rm;
#Cable Type 1=flat thermoplastic 70, 2=swa
my $c_ct = $cable_type;
#Enter Cable Length
my $c_cl = $cable_length;
#Ring 1=yes, 2=no
my $c_ring = $radial;
#Circuit Type - eg. s/o lighting
#lighting=1,heating=2,cooking=3,motors=4,water-heater(inst)=5,water-heater(thermo)=6,floor-warming=7,thermal-storage-heating=8
#standard-final-circuits=9,socket-outlets=10
my $c_cir = $circuit_type;
#Distribution 1=yes, 2=no Only for SWA
my $c_dist = $distro;
#Ca default = 1
my $c_ca = $ca;
#Cs
my $c_cs = $ca;
#Cd
my $c_cd = $ca;
#Cg
my $c_cg = $ca;
#Ci
my $c_ci = $ca;
#Cc
my $c_cc = $ca;

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

my $cable2 = SWA70->new( name => $c_name,
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
    		case 2 {$cable2use = $cable2; say "Using SWA thermoplastic 70";}

    		else     {say "Problem"}
            }


say "Site name: ".uc $site ->name;
say "PFC: ".$site ->pfc;
say "Device Type: ".$d_type;#$site ->dev_type($pfc);
#my $d_type = $site ->dev_type($pfc);
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
#my $dev_max_zs = $cable2use ->maxzs($cable2use ->ib, $d_type);
my $dev_max_zs = $cable2use ->maxzs($In, $d_type);
say "Got---------------------------------------Device Max Zs:".$dev_max_zs;

#Calling MAIN method in FLAT70
#get initial cable size based on maxZs-------

say "testing ring or radial -".$cable2use ->ring;

my $short_list = $cable2use->main($c_Ib, $c_rm, $cable2use ->ring);#get short list It
my %short_list = %{$short_list};
#get cable size and compare calculated zs with device max zs
my $init_mm = $cable2use->r1r2($c_ring, $ze, $dev_max_zs, $c_cl, \%short_list);say "Initial Cable size:".$init_mm." mm";
#get voltage drop of cable size and upgrade if needed
my ($final_mm, $drop, $perc, $vd_allowed) = $cable2use->vdrop($c_cl, $init_mm , $c_Ib, $c_cir, $cable2use ->ring);#length,size,Ib,lighting or other and ring
say "Final Cable size:".$final_mm." mm";
say "Voltage Drop:".$drop." V";
print "Voltage Drop Percentage:".$perc." %";say " -  Allowed Voltage Drop Percentage:".$vd_allowed." %";
#get final zs for final cable size------
my $finalZs = $cable2use->final_zs($final_mm, $c_cl, $ze, $c_ring); say "Final Zs for cable:".$finalZs." ohms";
#--------------------------------------------------------
#---------------update with calculations-----------------
 my $dbh = open_db();
    my $sql = q(select count(*) from circuit);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $rows = $sth->fetchrow_arrayref->[0];
    $sth->finish;
    my $row = $rows+1;
say "row count " . $rows;
   my $percentage3sf = sprintf("%.2f", $perc);# format to 3 significant figures
   my $dbh1 = open_db();

 #-------------------------------------------------------------------------------update
         say "UPDATE request with calcs for id: $row----------------------------------------------";
my $sql1 = qq(UPDATE circuit SET i_n='$In', dev_type='$d_type', dev_zs='$dev_max_zs', cable_size='$final_mm', v_drop='$drop', v_drop_per='$percentage3sf', final_zs='$finalZs' WHERE id= '$rid');
my $sth1 = $dbh1->prepare($sql1);
$sth1->execute();


}

#---------------------------------------
#/////////////////////////////////////////////////Process EDIT////////////////////////////////////////////////////////////////////////////////////
sub process_edit{

#----------------------site parameters--------------------
my ($id, $cname, $cable_type, $ib, $d_type, $rm, $cable_length, $radial, $circuit_type, $distro, $ca, $cs, $cd, $cg, $ci, $cc, $circuit_site, $site_in) = @_;
my @s = @{$site_in};
say "site:".$id;
say "element 1:".$s[1];
say "Inside Process edit and device_type is---------".$d_type;
#-----------------------------------------------------------
#Site Parameters-------------------------------------------
#Site name
my $s_name = $s[1];
#prospective fault current
my $pfc = $s[2];
#Ze
my $ze = $s[3];
#3 Phase
my $s_ph = $s[4];
#Cable Parameters---------------------------


#Circuit name
my $c_name = $cname;
#Design Current Ib
my $c_Ib = $ib;
#Reference Method
my $c_rm = $rm;
#Cable Type 1=flat thermoplastic 70, 2=swa
my $c_ct = $cable_type;
#Enter Cable Length
my $c_cl = $cable_length;
#Ring 1=yes, 2=no
my $c_ring = $radial;
#Circuit Type - eg. s/o lighting
#lighting=1,heating=2,cooking=3,motors=4,water-heater(inst)=5,water-heater(thermo)=6,floor-warming=7,thermal-storage-heating=8
#standard-final-circuits=9,socket-outlets=10
my $c_cir = $circuit_type;
#Distribution 1=yes, 2=no Only for SWA
my $c_dist = $distro;
#Ca default = 1
my $c_ca = $ca;
#Cs
my $c_cs = $ca;
#Cd
my $c_cd = $ca;
#Cg
my $c_cg = $ca;
#Ci
my $c_ci = $ca;
#Cc
my $c_cc = $ca;

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
say "Device Type: ".$d_type;
#my $d_type = $site ->dev_type($pfc);
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
#my $dev_max_zs = $cable2use ->maxzs($cable2use ->ib, $d_type);
my $dev_max_zs = sprintf("%.3f",$cable2use ->maxzs($In, $d_type));
say "Got---------------------------------------Device Max Zs:".$dev_max_zs;
#get initial cable size based on maxZs-------
my $short_list = $cable2use->main($c_Ib, $c_rm, $cable2use ->ring);#get short list It
my %short_list = %{$short_list};
#get cable size and compare calculated zs with device max zs
my $init_mm = $cable2use->r1r2($c_ring, $ze, $dev_max_zs, $c_cl, \%short_list);say "Initial Cable size:".$init_mm." mm";
#get voltage drop of cable size and upgrade if needed
my ($final_mm, $drop, $percentage, $vd_allowed) = $cable2use->vdrop($c_cl, $init_mm , $c_Ib, $c_cir, $cable2use ->ring);#length,size,Ib,lighting or other
say "Final Cable size:".$final_mm." mm";
say "Voltage Drop:".$drop." V";
print "Voltage Drop Percentage:".$percentage." %";say " -  Allowed Voltage Drop Percentage:".$vd_allowed." %";
#get final zs for final cable size------
my $finalZs = sprintf("%.3f", $cable2use->final_zs($final_mm, $c_cl, $ze, $c_ring)); say "Final Zs for cable:".$finalZs." ohms";
#--------------------------------------------------------
#---------------update with calculations-----------------
 my $dbh = open_db();
    my $sql = q(select count(*) from circuit);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $rows = $sth->fetchrow_arrayref->[0];
    $sth->finish;
    my $row = $rows+1;
say "row count " . $rows;
   my $percentage3sf = sprintf("%.2f", $percentage);# format to 3 significant figures
   my $dbh1 = open_db();
 #-------------------------------------------------------------------------------update
         say "UPDATE request with calcs for id: $row----------------------------------------------";
my $sql1 = qq(UPDATE circuit SET i_n='$In', dev_type='$d_type', dev_zs='$dev_max_zs', cable_size='$final_mm', v_drop='$drop', v_drop_per='$percentage3sf', final_zs='$finalZs' WHERE id= '$id');
my $sth1 = $dbh1->prepare($sql1);
$sth1->execute();

}


#--------------------------------------HTML starts here------------------------------------------#
sub get_html {
    return q{
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<title>Zenertek</title>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.min.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.mobile.js"></script>


	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/jquery.mobile.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/quickcalc.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/ui.jqgrid-mobile.css" />
	<link rel="icon" href="https://zenertek.com/cd_static/rstatic/images/favicon.ico?v=2" type="image/x-icon" />
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
	

	
	<script src="https://zenertek.com/cd_static/rstatic/js/quickcalc.js"></script>

<!-- jqgrid edit header works with this -->
	<link rel="stylesheet" type="text/css" href="https://rawgit.com/rzajac/angularjs-slider/master/dist/rzslider.css">

<style>
.ui-input-text {
    width: 100px !important
}

.ui-field-contain_voltage{
float: right;
width: 58px;
margin: 10px 10px 10px 10px;
}
.ui-field-contain_vol{
//float: right;
width: 100%;
margin: 0px 7% 0px auto;

}
.right{
float: right;
margin: -2px 0 0px 0;
}
#label{font-weight: 900;}
.skinny{
height: 6px;
font-size: 8px;
float: right;
}
legend { 
font-size: 0.9em;
border: medium dotted #60A4C1;
}

#ri  {
  float: right;
}
</style>

	<script language="javascript">
	/**
	 * 
 	 *
     * 
     *
    **/
   </script>

</head>
<body onload="fillddl();">



<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.3/angular.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.13.4/ui-bootstrap-tpls.min.js"></script>
<script src="https://rawgit.com/angular-slider/angularjs-slider/master/dist/rzslider.js"></script>




	<script src="https://hammerjs.github.io/dist/hammer.js"></script>
	<div data-role="page" id="main">
		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" data-ajax="false" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
		<div role="main" class="ui-content">

		
		
		
		
		
		<script type='text/javascript'>
// <![CDATA[
jQuery(document).ready(function(){
document.getElementById("voltage").value ="230";
$('input:radio[name="radio-choice-h-1"]').change(function(){
    if (this.checked && this.value == 'on') {

       document.getElementById("voltage").value ="230";
       
    }
        if (this.checked && this.value == 'off') {

       document.getElementById("voltage").value ="415";
       
    }
});

});

// ]]>
</script>
		
		
		
		
		
<!--#####################################################################################################################################-->		
<div ng-app="rzSliderDemo">

    <div ng-controller="MainCtrl" class="wrapper">
    

        <article>
             <h2>R1+R2 Calculation from R2 Measurement</h2>
 


<div class="ui-grid-a">
  <div class="ui-block-a">
     <label for="text-r2">R2 Input Value:</label>
     <input ng-model="r2input" type="text" placeholder="Enter R2">
     <p>R2 &Omega; : <strong>{{ r2resistance | number :4}}</strong> &Omega;</p>
     <p>R2 csa: <strong>{{ r2mm | number :1 }} mm</strong></p>
     <p>m&Omega;/m for R2 :<strong>{{ r2ohm | number :2 }} &Omega;</strong></p>
     <p>Length in Metres : <strong>{{ r2length | number :2}} m</strong></p>


</div>
  <div class="ui-block-b"><strong>
     <label for="text-ze">Ze</label>
     <input ng-model="ze" type="text" placeholder="Enter Ze" id="">
     <p>R1 &Omega; : <strong>{{ r1resistance | number :4}}</strong> &Omega;</p>
     <p>R1 csa: <strong>{{ r1mm | number :1 }} mm</strong></p>
     <p>m&Omega;/m for R1 :<strong>{{ r1ohm | number :2 }} &Omega;</strong></p>
     <p>R1 + R2 :<strong>{{ r12 | number :4 }} &Omega;</strong></p>
     <p>Zs :<strong>{{ zs | number :4 }} &Omega;</strong></p>


</div>
</div><!-- /grid-a -->


	<rzslider rz-slider-model="slider_callbacks_r2.value" rz-slider-options="slider_callbacks_r2.options"></rzslider>

<br /><br />
	    <h3>R1 Size</h3>

        <rzslider rz-slider-model="slider_callbacks_r1.value" rz-slider-options="slider_callbacks_r1.options"></rzslider>

<br /><br />
<!--#####################################################################################################################################-->
        </article>
<br />
	<hr>
            <article>
            <p id="label" class="right">Phase Angle: {{phase_angle | number :1}}&#176;</p>
    <div class="ui-field-contain_vol">
    <fieldset data-role="controlgroup" data-type="horizontal">
        <input type="radio" name="radio-choice-h-1" id="radio-choice-h-1a" value="on" checked="checked">
        <label for="radio-choice-h-1a">230</label>
        <input type="radio" name="radio-choice-h-1" id="radio-choice-h-1b" value="off">
        <label for="radio-choice-h-1b">415</label>
    </fieldset>
</div>
            <p id="label" class="right">PF: {{power_factor | number :2}}</p>
			
	            <div class="ui-field-contain_voltage">
	            
    <label for="textinput-voltage"></label>
    <input type="hidden" name="voltage" id="voltage" placeholder="V" value="" data-mini="true" ng-model="voltage">

	</div>
	    
       
        <p>Current: {{ Power.change_amps | number :1 }} Amps</p>

         <fieldset class="right">
		<legend>Capacitance</legend>    
        <p id="label" class="right">&mu;F: {{farads | number :1}}</p>
        </fieldset>

		<p>Impedence Z: {{ Power.change_power_Z | number :1}} Ohms</p>
		<p id="label" class="right">Q: {{reactive_power | number :2}}</p>
		<label id="label">Real-Power</label>
              
            <rzslider rz-slider-model="slider_callbacks_power_KW.value" rz-slider-options="slider_callbacks_power_KW.options"></rzslider>
             
         <label id="label">Apparent-Power</label>    
			<rzslider rz-slider-model="slider_callbacks_power_VA.value" rz-slider-options="slider_callbacks_power_VA.options"></rzslider>
        </article>
    
    
    
    
    
    
    
    
    
    
    
        <article>
             <h2>Required Heat output KW</h2>

 
	    <h3>Electric Radiators or Panel Heaters</h3>
            <p>Modern Insulation: {{ otherData.change | number :2 }} Watts</p>
	    <p>Poor Insulation: {{ otherData.change1 | number :2}} Watts</p>
	    <h3>Storage Heaters</h3>
	    <p>Modern Insulation: {{ otherData.change2 | number :2}} Watts</p>
	    <p>Poor Insulation: {{ otherData.change3 | number :2}} Watts</p>

            <rzslider rz-slider-model="slider_callbacks.value" rz-slider-options="slider_callbacks.options"></rzslider>
        </article>


        <article>
             <h2>Adiabatic Equation</h2>
	    <h4>0.2sec</h4>
            <p>230V: {{ otherData_adiabatic.change | number :2 }} Amps</p>
	    <p></p>
	    <p>Protective conductor / Earthing </p>
	    <p>minimum csa: {{ otherData_adiabatic.change3 | number :2}} mm</p>


            <rzslider rz-slider-model="slider_callbacks_adiabatic.value" rz-slider-options="slider_callbacks_adiabatic.options"></rzslider>
        </article>
        </div>
        </div>

<!---End-------------------->
				<!--- <div class="content-primary"> -->
		<ul data-role="listview" data-inset="true">
			<li>
				<a href="/paging">
					<h2>Circuit Designer</h2>
					<p>Calculates circuit ZS value and Max Demand</p>
				</a>
			</li>
			<li>
				<a href="#sites">
					<h2>QuickCALC </h2>
					<p>Adiabatic, Power Resistance etc, more...</p>
				</a>
			</li>
		</ul>
		
		
		<!--------------rows------->
		
		<!--/ </div> content-primary -->	
	</div><!-- /content -->
	<div data-role="footer" data-position="fixed" data-theme="b">
	<p class="center">&copy; 2012-2018 Witts&Co Ltd</p>
	</div>
	</div><!-- /page -->
	</div>
	
	
	<!--############################################--------customers------###########################################################-->

	<div data-role="page" id="customers">

		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="#main" class="item_menu">Home</a>
		<a href="#customers" class="item_menu">customers</a>
		<a href="#sites" class="item_menu">sites</a>
		<a href="#circuits" class="item_menu">circuits</a>
		<a href="#equations" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>
		  <p>&nbsp;&nbsp;Customers Table</p>
		  </div>
<!--here-->

	

<!--here-->
</div><!-- /page -->

	<!-- /page -->

	<!--############################################--------Equations------###########################################################-->
<!-- Start of equations page -->
    <div data-role="page" id="equations">
		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" data-ajax="false" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>
		  <p>&nbsp;&nbsp;Equations</p>
		  </div>
<!-- /page -->

		<div role="main" class="ui-content">
		<!--- <div class="content-primary"> -->
		<ul data-role="listview" data-inset="true">
			<li>
				<a href="/paging">
					<h2>Adiabatic</h2>
					<p>Calculates circuit ZS value and Max Demand</p>
				</a>
			</li>
			<li>
				<a href="#sites">
					<h2>Zs</h2>
					<p>Adiabatic, Power Resistance etc, more...</p>
				</a>
			</li>
		</ul>
		<!--/ </div> content-primary -->	

	</div>

</div>



	





<script type='text/javascript'>//<![CDATA[


var app = angular.module('rzSliderDemo', ['rzSlider', 'ui.bootstrap']);

app.controller('MainCtrl', function ($scope, $timeout) {



    //Minimal slider config
    $scope.minSlider = {
        value: 10,
    options: {
        showSelectionBar: true,
        getSelectionBarColor: function(value) {
            if (value <= 3)
                return 'red';
            if (value <= 6)
                return 'orange';
            if (value <= 9)
                return 'yellow';
            return '#2AE02A';
        }
    }
    };


    //Slider with selection bar
    $scope.slider_visible_bar = {
        value: 10,
        options: {
            showSelectionBar: true,


        }
    };

    //Range slider config
    $scope.minRangeSlider = {
        minValue: 10,
        maxValue: 90,
        options: {
            floor: 0,
            ceil: 100,
            step: 1
        }
    };
    
    //Slider with selection bar
    $scope.color_slider_bar = {
      value: 12,
      options: {
        showSelectionBar: true,
        getSelectionBarColor: function(value) {
          if (value <= 3)
            return 'red';
          if (value <= 6)
            return 'orange';
          if (value <= 9)
            return 'yellow';
          return '#2AE02A';
        }
      }
    };

    //Slider config with floor, ceil and step
    $scope.slider_floor_ceil = {
        value: 12,
        options: {
            floor: 10,
            ceil: 100,
            step: 5
        }
    };

    //Slider config for Heat Output
    $scope.slider_callbacks = {

  value: 0,
  options: {
    floor: 0,
    ceil: 50,
    step: 0.1,
    precision: 1,
    showSelectionBar: true,
            translate: function (value) {
                return value + "m&sup2;";
            },
            onStart: function () {
                //$scope.otherData.start = $scope.slider_callbacks.value * 70;
            },

            onChange: function () {
        $scope.otherData.change = $scope.slider_callbacks.value * 85;
		$scope.otherData.change1 = $scope.slider_callbacks.value * 100;
		$scope.otherData.change2 = $scope.slider_callbacks.value * 219;
		$scope.otherData.change3 = $scope.slider_callbacks.value * 257;
            },
            onEnd: function () {
                //$scope.otherData.end = $scope.slider_callbacks.value * 10;
            }

        }
    };
    ///////////////////////////////////////////////////




//////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------R2 Measurement----------------------------------//
    $scope.r2 = {
        start: 0,
        change: 0,
        end: 0
    };

	$scope.r2ohm = 18.10;
	$scope.r2mm = 1;
	$scope.r2length = 0;
	//$scope.r2input = 0;
//------------------------------------------------------------------//

    //Slider config for R2+R1 calculation
    $scope.slider_callbacks_r2 = {
    value: 1,
    options: {
    floor: 0,
    ceil: 5000,
    step: 0.1,
    precision: 1,
    showSelectionBar: true,
    showTicksValues: true,
    stepsArray: [
      {value: 1, legend: 'mm'},
      {value: 1.5},
      {value: 2.5, legend: ''},
      {value: 4},
      {value: 6, legend: ''},
      {value: 10},
      {value: 16, legend: ''},
      {value: 25},
    ],
            translate: function (value) {
                return value + "";
            },
            onStart: function () {


            },

            onChange: function () {
        	$scope.r2mm = $scope.slider_callbacks_r2.value;
		$scope.r2resistance = $scope.r2input;


	    if ($scope.slider_callbacks_r2.value == 1){
		$scope.r2mm = 1;
		$scope.r2length = ($scope.r2resistance / 18.10) *1000;
		$scope.r2ohm = 18.10;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 1.5){
		$scope.r2mm = 1.5;
		$scope.r2length = ($scope.r2resistance / 12.10) *1000;
	        $scope.r2ohm = 12.10;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 2.5){
		$scope.r2mm = 2.5
		$scope.r2length = ($scope.r2resistance / 7.41) *1000;
		$scope.r2ohm = 7.41;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 4){
		$scope.r2mm = 4;
		$scope.r2length = ($scope.r2resistance / 4.61) *1000;
		$scope.r2ohm = 4.61;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 6){
		$scope.r2mm = 6;
		$scope.r2length = ($scope.r2resistance / 3.08) *1000;
		$scope.r2ohm = 3.08;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 10){
		$scope.r2mm = 10;
		$scope.r2length = ($scope.r2resistance / 1.83) *1000;
		$scope.r2ohm = 1.83;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 16){
		$scope.r2mm = 16;
		$scope.r2length = ($scope.r2resistance / 1.15) *1000;
		$scope.r2ohm = 1.15;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r2.value == 25){
		$scope.r2mm = 25;
		$scope.r2length = ($scope.r2resistance / 0.727) *1000;
		$scope.r2ohm = 0.727;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}



            },
            onEnd: function () {
                //$scope.r2Data.change = $scope.slider_callbacks_r2.value;
            }

        }
    };

//-------------------------------- Slider config for R1 calculation----------------------------------//
	//$scope.r2input = 0.1;
	$scope.r1ohm = 18.10;
	$scope.r1mm = 1;
	$scope.r12 = 0;
    //Slider config for R1 calculation
    $scope.slider_callbacks_r1 = {

  value: 1,
  options: {
    floor: 0,
    ceil: 50,
    step: 0.1,
    precision: 1,
    showSelectionBar: true,
    showTicksValues: true,
    stepsArray: [
      {value: 1, legend: 'mm'},
      {value: 1.5},
      {value: 2.5, legend: ''},
      {value: 4},
      {value: 6, legend: ''},
      {value: 10},
      {value: 16, legend: ''},
      {value: 25},
    ],
            translate: function (value) {
                return value + "";
            },

            onStart: function () {

            },

            onChange: function () {
        	$scope.r1mm = $scope.slider_callbacks_r1.value;
		$scope.r2resistance = $scope.r2input;
            	//$scope.r12 = $scope.r1resistance;

	    if ($scope.slider_callbacks_r1.value == 1){
		$scope.r1mm = 1;
		$scope.r1ohm = 18.10;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 1.5){
		$scope.r1mm = 1.5;
		$scope.r1ohm = 12.10;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 2.5){
		$scope.r1mm = 2.5;
		$scope.r1ohm = 7.41;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 4){
		$scope.r1mm = 4;
		$scope.r1ohm = 4.61;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 6){
		$scope.r1mm = 6;
		$scope.r1ohm = 3.08;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 10){
		$scope.r1mm = 10;
		$scope.r1ohm = 1.83;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 16){
		$scope.r1mm = 16;
		$scope.r1ohm = 1.15;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}
	    if ($scope.slider_callbacks_r1.value == 25){
		$scope.r1mm = 25;
		$scope.r1ohm = 0.727;
		$scope.r1resistance = ($scope.r2length * $scope.r1ohm) / 1000;
		$scope.r12 = parseFloat($scope.r2resistance) + parseFloat($scope.r1resistance);
		$scope.zs = parseFloat($scope.ze) + parseFloat($scope.r12);
		}


            },
            onEnd: function () {
                //$scope.otherData.end = $scope.slider_callbacks.value * 10;
            }

	}

    };









    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





    $scope.otherData = {
        start: 0,
        change: 0,
        end: 0
    };
    //Slider config with callbacks
    $scope.slider_callbacks_adiabatic = {

  value: 0,
  options: {
    floor: 0,
    ceil: 60,
    step: 0.01,
    precision: 2,
    showSelectionBar: true,
            translate: function (value) {
                return value + ' &Omega;';
            },
            onStart: function () {
                //$scope.otherData.start = $scope.slider_callbacks_adiabatic.value * 70;
            },

            onChange: function () {

		
        $scope.otherData_adiabatic.change = vol /$scope.slider_callbacks_adiabatic.value;//amps
		$scope.otherData_adiabatic.change1 = ($scope.otherData_adiabatic.change * $scope.otherData_adiabatic.change)*0.2;
		$scope.otherData_adiabatic.change2 = Math.sqrt(parseFloat($scope.otherData_adiabatic.change1)).toString();
	        $scope.otherData_adiabatic.change3 = ($scope.otherData_adiabatic.change2)/143;
            },
            onEnd: function () {
                //$scope.otherData_adiabatic.end = $scope.slider_callbacks_adiabatic.value * 10;
            }

        }
    };
    /////////////////////////////////////////////////////////////////////
        $scope.Power = {
        start: 0,
        change: 0,
        end: 0
    };
    //Slider config with callbacks
    $scope.slider_callbacks_power_KW = {

  value: 0,
  options: {
    floor: 0,
    ceil: 15000,
    step: 0,
    precision: 0,
    showSelectionBar: true,
            translate: function (value) {
                return value + ' W';
            },
            onStart: function () {
                $scope.Power.start = $scope.voltage = document.getElementById("voltage").value;
            },

            onChange: function () {
				$scope.power_factor = ($scope.slider_callbacks_power_KW.value / $scope.slider_callbacks_power_VA.value);//power
				$scope.phase_angle = Math.acos($scope.power_factor) * (180 / Math.PI);
				
				$scope.reactive_power = Math.sqrt(parseFloat($scope.slider_callbacks_power_VA.value * $scope.slider_callbacks_power_VA.value) - ($scope.slider_callbacks_power_KW.value * 					$scope.slider_callbacks_power_KW.value)).toString();
				$scope.v = 240;
				$scope.x = ($scope.v * $scope.v) / ($scope.reactive_power*1000000);
				$scope.c = ((2 * Math.PI) * (60) * ($scope.x));
				$scope.farads = (1/$scope.c).toString();

            },
            onEnd: function () {
                //$scope.Power.change_power_IMP = $scope.voltage / $scope.slider_callbacks_power.value;//power
            }

        }
    };
    //////////////////////////////////////////////////////////////////////
       //Slider config with callbacks
    $scope.slider_callbacks_power_VA = {

  value: 0,
  options: {
    floor: 0,
    ceil: 15000,
    step: 0,
    precision: 0,
    showSelectionBar: true,
            translate: function (value) {
                return value + ' VA';
            },
            onStart: function () {
                //$scope.Power.start = $scope.voltage = document.getElementById("voltage").value;
            },

            onChange: function () {

               $scope.Power.change_amps = ($scope.slider_callbacks_power_VA.value / $scope.voltage);//power
               $scope.Power.change_power_Z = ($scope.voltage * $scope.voltage / $scope.slider_callbacks_power_VA.value);//power
                
                
                $scope.reactive_power = Math.sqrt(parseFloat($scope.slider_callbacks_power_VA.value * $scope.slider_callbacks_power_VA.value) - ($scope.slider_callbacks_power_KW.value * $scope.slider_callbacks_power_KW.value)).toString();
				$scope.v = 240;
				$scope.x = ($scope.v * $scope.v) / ($scope.reactive_power*1000000);
				$scope.c = ((2 * Math.PI) * (60) * ($scope.x));
				$scope.farads = (1/$scope.c).toString();
                
                
                $scope.power_factor = ($scope.slider_callbacks_power_KW.value / $scope.slider_callbacks_power_VA.value);//power
				$scope.phase_angle = Math.acos($scope.power_factor) * (180 / Math.PI);
            },
            onEnd: function () {
                //$scope.Power.change_power_IMP = $scope.voltage / $scope.slider_callbacks_power.value;//power
            }

        }
    };
    
    /////////////////////////////////////////////////////////
    $scope.otherData_adiabatic = {
        start: 0,
        change: 0,
        end: 0
    };
    //Slider config with custom display function
    $scope.slider_translate = {
        minValue: 100,
        maxValue: 400,
        options: {
            ceil: 500,
            floor: 0,
            translate: function (value) {
                return '$' + value;
            }
        }
    };

    //Slider config with steps array of letters
    $scope.slider_alphabet = {
        value: 0,
        options: {
            stepsArray: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
        }
    };

    //Slider with ticks
    $scope.slider_ticks = {
        value: 5,
        options: {
            ceil: 10,
            floor: 0,
            showTicks: true
        }
    };

    //Slider with ticks and values
    $scope.slider_ticks_values = {
        value: 5,
        options: {
            ceil: 10,
            floor: 0,
            showTicksValues: true
        }
    };

    //Slider with ticks and values and tooltip
    $scope.slider_ticks_values_tooltip = {
        value: 5,
        options: {
            ceil: 10,
            floor: 0,
            showTicksValues: true,
            ticksValuesTooltip: function (v) {
                return 'Tooltip for ' + v;
            }
        }
    };

    //Range slider with ticks and values
    $scope.range_slider_ticks_values = {
        minValue: 1,
        maxValue: 8,
        options: {
            ceil: 10,
            floor: 0,
            showTicksValues: true
        }
    };

    //Slider with draggable range
    $scope.slider_draggable_range = {
        minValue: 1,
        maxValue: 8,
        options: {
            ceil: 10,
            floor: 0,
            draggableRange: true
        }
    };
    
    //Slider with draggable range only
    $scope.slider_draggable_range_only = {
      minValue: 4,
      maxValue: 6,
      options: {
        ceil: 10,
        floor: 0,
        draggableRangeOnly: true
      }
    };

    //Vertical sliders
    $scope.verticalSlider1 = {
        value: 0,
        options: {
            floor: 0,
            ceil: 10,
            vertical: true
        }
    };
    $scope.verticalSlider2 = {
        minValue: 20,
        maxValue: 80,
        options: {
            floor: 0,
            ceil: 100,
            vertical: true
        }
    };
    $scope.verticalSlider3 = {
        value: 5,
        options: {
            floor: 0,
            ceil: 10,
            vertical: true,
            showTicks: true
        }
    };
    $scope.verticalSlider4 = {
        minValue: 1,
        maxValue: 5,
        options: {
            floor: 0,
            ceil: 6,
            vertical: true,
            showTicksValues: true
        }
    };
    $scope.verticalSlider5 = {
        value: 50,
        options: {
            floor: 0,
            ceil: 100,
            vertical: true,
            showSelectionBar: true
        }
    };
    $scope.verticalSlider6 = {
        value: 6,
        options: {
            floor: 0,
            ceil: 6,
            vertical: true,
            showSelectionBar: true,
            showTicksValues: true,
            ticksValuesTooltip: function (v) {
                return 'Tooltip for ' + v;
            }
        }
    };

    //Read-only slider
    $scope.read_only_slider = {
        value: 50,
        options: {
            ceil: 100,
            floor: 0,
            readOnly: true
        }
    };

    //Disabled slider
    $scope.disabled_slider = {
        value: 50,
        options: {
            ceil: 100,
            floor: 0,
            disabled: true
        }
    };

    // Slider inside ng-show
    $scope.visible = false;
    $scope.slider_toggle = {
        value: 5,
        options: {
            ceil: 10,
            floor: 0
        }
    };
    $scope.toggle = function () {
        $scope.visible = !$scope.visible;
        $timeout(function () {
            $scope.$broadcast('rzSliderForceRender');
        });
    };

    //Slider inside modal
    $scope.percentages = {
        normal: {
            low: 15
        },
        range: {
            low: 10,
            high: 50
        }
    };
    $scope.openModal = function () {
        var modalInstance = $uibModal.open({
            templateUrl: 'sliderModal.html',
            controller: function ($scope, $uibModalInstance, values) {
                $scope.percentages = JSON.parse(JSON.stringify(values)); //Copy of the object in order to keep original values in $scope.percentages in parent controller.


                var formatToPercentage = function (value) {
                    return value + '%';
                };

                $scope.percentages.normal.options = {
                    floor: 0,
                    ceil: 100,
                    translate: formatToPercentage,
                    showSelectionBar: true
                };
                $scope.percentages.range.options = {
                    floor: 0,
                    ceil: 100,
                    translate: formatToPercentage
                };
                $scope.ok = function () {
                    $uibModalInstance.close($scope.percentages);
                };
                $scope.cancel = function () {
                    $uibModalInstance.dismiss();
                };
            },
            resolve: {
                values: function () {
                    return $scope.percentages;
                }
            }
        });
        modalInstance.result.then(function (percentages) {
            $scope.percentages = percentages;
        });
        modalInstance.rendered.then(function () {
            $rootScope.$broadcast('rzSliderForceRender'); //Force refresh sliders on render. Otherwise bullets are aligned at left side.
        });
    };


    //Slider inside tabs
    $scope.tabSliders = {
        slider1: {
            value: 100
        },
        slider2: {
            value: 200
        }
    };
    $scope.refreshSlider = function () {
        $timeout(function () {
            $scope.$broadcast('rzSliderForceRender');
        });
    };


    //Slider with draggable range
    $scope.slider_all_options = {
        minValue: 2,
        options: {
            floor: 0,
            ceil: 10,
            step: 1,
            precision: 0,
            draggableRange: false,
            showSelectionBar: false,
            hideLimitLabels: false,
            readOnly: false,
            disabled: false,
            showTicks: false,
            showTicksValues: false
        }
    };
    $scope.toggleHighValue = function () {
        if ($scope.slider_all_options.maxValue != null) {
            $scope.slider_all_options.maxValue = undefined;
        } else {
            $scope.slider_all_options.maxValue = 8;
        }
    }
});
//]]> 
</script>









	</body>
</html>
			
    }
}

#############################################################################################################################

sub get_circuits {
    return q{
<!DOCTYPE html>
<html>
<head>

	<meta charset="utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<title>Zenertek</title>
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/jquery.mobile.css" />
<!--<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/jquerymobile.jqGrid.min.js"></script>-->

	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/quickcalc.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/ui.jqgrid-mobile.css" />
	<link rel="icon" href="https://zenertek.com/cd_static/rstatic/images/favicon.ico?v=2" type="image/x-icon" />
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <script src="https://zenertek.com/cd_static/rstatic/js/jquery.min.js"></script>
	<script language="javascript" src="https://www.guriddo.net/demo/mobile/js/jquerymobile.jqGrid.min.js"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/grid.locale-en.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.mobile.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/quickcalc.js"></script>

<script language="javascript">
/**

*/
</script>

</head>
<body onload="fillddl();"> 

	<script src="https://hammerjs.github.io/dist/hammer.js"></script>

		<!--############################################Circuits###########################################################-->	
		<div id="circuits" data-role="page" data-theme="a">
		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" data-ajax="false" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>
		  <p>&nbsp;&nbsp;Circuits Table</p>
		  </div>
<!--here-->
<p id="droptest"></p>
<p id="id"></p>	  
    <div class="center_select"><p id="leftTitle">&nbsp;&nbsp;Circuit Table</p>
    <div id="right"><select name="ddlselect_site" id="ddlselect_site" onchange="circuitFilter();">
    <option value="0">- Select -</option>     
    </select></div>
    </div>

		<table id='circuit'></table>
		<div id='pcircuit'></div>
	
		<script type='text/javascript'>
			jQuery('#circuit').jqGrid({
				"hoverrows":false,
				"viewrecords":true,
				"jsonReader":{"repeatitems":false,"subgrid":{"repeatitems":false}},
				"gridview":true,
				"loadonce":false,
				"url":"/cd-mobile/circuit",
				"scrollPaging":true,
				"autowidth":true,
				"rowNum":20,
				"rowList" : [20,40,60],
				"sortname":"id",
				"height":500,
				"datatype":"json",
    colNames:['Id', 'name', 'cable_type', 'In', 'Ib', 'Type', 'Ref M','Length(m)','Radial', 'circuit_type', 'Distro', 'ca', 'cs','cd','cg', 'ci', 'cc', 'dev_Zs', 'CSA(mm)', 'VD', 'VD%', 'final_zs', 'c_id', 'circuit_site'],
    colModel :[ 
      {name:'id', index:'id', width:20,  align:'center', editable:false, key:true}, 
      {name:'name', index:'name', width:90,  align:'center', editable:true, editoptions:{size:10}},
      {name:'cable_type', index:'cable_type', width:30, editable: true, hidden:true, editrules: { edithidden: true}, edittype: "select", align:'center', editable:true, editoptions:{ value: "1:Flat70;2:swa70"}},
      {name:'i_n', index:'i_n', width:20, align:'center', editable:false, editoptions:{size:10}}, 
      {name:'i_b', index:'i_b', width:20,  align:'center', sortable:false, editable: true, editoptions:{size:10}},
	  {name:'dev_type', index:'dev_type', width:30,  align:'center', editable: true, edittype: "select", editable:true, editoptions:{value: "b:B;c:C;d:D"}}, 
      {name:'rm', index:'rm', width:30,  align:'center', editable: true, edittype: "select", editable:true, editoptions:{value: "c:Clipped;100:#100;101:#101;102:#102;103:#103;a:#a"}}, 
      {name:'cable_length', index:'cable_length', width:30, align:'center', editable: true, editable:true, formoptions: {
                            //colpos: 1, // the position of the column
                            //rowpos: 1, // the position of the row
                            //label: "End - End if Ring:", // the label to show for each input control                    
                            elmsuffix: "(End - End if Ring" // the suffix to show after that
                        },editoptions:{size:10}}, 
      
      {name:'radial', index:'radial', width:30, align:'center', hidden:true, editrules: { edithidden: true}, editable: true, edittype: "select", editable:true, editoptions:{ value: "1:Radial;2:Ring"}},                 
      {name:'circuit_type', index:'circuit_type', width:80, align:'center', editable: true, hidden:true, editrules: { edithidden: true}, edittype: "select", editable:true, editoptions:{ value: "1:Lighting;2:Heating;3:Cooking;4:Motors;5:water-heater(inst);6:water-heater(thermo);7:floor-warming;8:thermal-storage-heating;9:Final Circuit;10:10 - Socket Outlets"}},  
      {name:'distro', index:'distro', width:30,  align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editrules: { edithidden: true}, edittype: "select", editoptions:{ value: "2:No;1:Yes"}}, 
      {name:'ca', index:'ca', width:20,  align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editoptions:{size:10, defaultValue: '1'}},
      {name:'cs', index:'cs', width:20, align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editoptions:{size:10, defaultValue: '1'}}, 
      {name:'cd', index:'cd', width:20, align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editoptions:{size:10, defaultValue: '1'}}, 
      {name:'cg', index:'cg', width:20,  align:'center', sortable:false, hidden:true, editrules: { edithidden: true}, editable: true, editoptions:{size:10, defaultValue: '1'}},
      {name:'ci', index:'ci', width:20,  align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editoptions:{size:10, defaultValue: '1'}},
      {name:'cc', index:'cc', width:20, align:'center', editable:true, hidden:true, editrules: { edithidden: true}, editoptions:{size:10, defaultValue: '1'}},
      {name:'dev_zs', index:'dev_zs', width:50, align:'center', editable:false, editoptions:{size:10}}, 
      {name:'cable_size', index:'cable_size', width:40, align:'center', editable:false, editoptions:{size:10}}, 
      {name:'v_drop', index:'v_drop', width:30,  align:'center', sortable:false, editable: false, editoptions:{size:10}},
      {name:'v_drop_per', index:'v_drop_per', width:30,  align:'center', editable:false, editoptions:{size:10}},
      {name:'final_zs', index:'final_zs', width:30, align:'center', editable:false, editoptions:{size:10}}, 
      {name:'customer_id', index:'customer_id', width:30, align:'center', hidden:true, editable:false, editoptions:{size:10}}, 
      {name:'circuit_site', index:'circuit_site', width:30, align:'center', hidden:true, editrules: { edithidden: true}, editable:true, edittype: "select", 
      editoptions:{dataUrl: "/cd-mobile/site_id", 
	  reloadGridOptions: { fromServer: true },
      buildSelect: function(data)
{
 var response = jQuery.parseJSON(data);
 var s = '<select>';
 jQuery.each(response, function(i, item, item1) {
 s += '<option value="'+response[i].id+'">'+response[i].id+' : '+response[i].name+'</option>';
 });
 return s + "</select>";
 }
}}
    ], 
					"loadError":function(xhr,status, err){ 
						try {
							jQuery.jgrid.info_dialog(jQuery.jgrid.errors.errcap,'<div class="ui-state-error">'+ xhr.responseText +'</div>', jQuery.jgrid.edit.bClose,
							{buttonalign:'right'});
						} catch(e) { 
							alert(xhr.responseText);} 
					},
					"pager":"#pcircuit",
					"editurl":"/cd-mobile/circuit",
					reloadGridOptions: { fromServer: true },
					
		gridComplete: function(){
  		var ids = jQuery("#circuit").jqGrid('getDataIDs');
  		for(var i=0;i < ids.length;i++){
  			var cl = ids[i];
			//document.getElementById("id").innerHTML = ids[i]; 
  			


  		}
  	},
	
	
				});
				jQuery('#circuit').jqGrid('navGrid','#pcircuit',{add:true, edit:true, del:true},{afterComplete: function () {
    			circuitFilter();
				}, closeAfterSubmit:true, closeAfterEdit: true},{reloadAfterSubmit:true, closeAfterAdd:true},{reloadAfterSubmit:true},{multipleSearch:true});


		$("#circuit").jqGrid('setGridParam', {onSelectRow: function(rowid,iRow,iCol,e){
		document.getElementById("id").innerHTML = rowid;
		//alert('row clicked ' +rowid );
		}});
			function selectRow(id) {
			jQuery('#circuit').jqGrid('setSelection',id);
		}
		</script>
	</div>
</div>
		<!--############################################Circuits###########################################################-->

	</body>
</html>
			
    }
}


##############################################################################################################################

sub get_customers {
    return q{
<!DOCTYPE html>
<html>
<head>

	<meta charset="utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<title>Zenertek</title>
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/jquery.mobile.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/quickcalc.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/ui.jqgrid-mobile.css" />
	<link rel="icon" href="https://zenertek.com/cd_static/rstatic/images/favicon.ico?v=2" type="image/x-icon" />
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <script src="https://zenertek.com/cd_static/rstatic/js/jquery.min.js"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/jquerymobile.jqGrid.min.js" id="s1"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/grid.locale-en.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.mobile.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/quickcalc.js"></script>

<script language="javascript">
/**

*/
</script>

</head>
<body onload="fillddl();"> 

	<script src="https://hammerjs.github.io/dist/hammer.js"></script>

		<!--############################################Circuits###########################################################-->	
		<div id="circuits" data-role="page" data-theme="a">
		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" data-ajax="false" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>
		  <p>&nbsp;&nbsp;Customers Table</p>
		  </div>
<!--here-->
<table id='customer'></table>
		<div id='pgrid'></div>

		
		<script type='text/javascript'>
			jQuery('#customer').jqGrid({
				"hoverrows":false,
				"viewrecords":true,
				"jsonReader":{"repeatitems":false,"subgrid":{"repeatitems":false}},
				"gridview":true,
				"loadonce":false,
				"url":"/cd-mobile/customer",
				"scrollPaging":true,
				"autowidth":true,
				"rowNum":20,
				"rowList" : [20,40,60],
				"sortname":"id",
				"height":200,
				"datatype":"json",
    colNames:['Id', 'name', 'email', 'phone', 'Mobile', 'Company','Address','Postcode'],
    colModel :[ 
      {name:'id', index:'id', width:25,  align:'center', editable:false, key:true}, 

      {name:'name', index:'firstname', width:80,  align:'center', editable:true, editoptions:{size:10}},

      {name:'email_address', index:'email_address', width:120, align:'center', editable:true, editoptions:{size:10}}, 
      {name:'phone_number', index:'phone_number', width:100, align:'center', hidden:true, editable:true, editoptions:{size:10}}, 
      {name:'mobile', index:'mobile', width:100,  align:'center', sortable:false, editable: true, editoptions:{size:10}},
      {name:'company', index:'company', width:100,  align:'center', editable:true, editoptions:{size:10}},
      {name:'address', index:'address', width:120, align:'center', editable:true, editoptions:{size:10}}, 
      {name:'postcode', index:'postcode', width:60, align:'center', editable:true, editoptions:{size:10}}, 

      
    ], 
					"loadError":function(xhr,status, err){ 
						try {
							jQuery.jgrid.info_dialog(jQuery.jgrid.errors.errcap,'<div class="ui-state-error">'+ xhr.responseText +'</div>', jQuery.jgrid.edit.bClose,
							{buttonalign:'right'});
						} catch(e) { 
							alert(xhr.responseText);} 
					},
					"pager":"#pgrid",
					"editurl":"/cd-mobile/customer",
					reloadGridOptions: { fromServer: true },
				});
				jQuery('#customer').jqGrid('navGrid','#pgrid',{add:true, edit:true, del:true},{closeAfterSubmit:true, closeAfterEdit: true},{reloadAfterSubmit:true, closeAfterAdd:true},{reloadAfterSubmit:true},{multipleSearch:true});

		$("#customer").jqGrid('setGridParam', {onSelectRow: function(rowid,iRow,iCol,e){
		document.getElementById("id").innerHTML = rowid;
		//alert('row clicked ' +rowid );
		}});
			function selectRow(id) {
			jQuery('#customer').jqGrid('setSelection',id);
		}
		
		
		</script>

	</div>
</div>
		<!--############################################Circuits###########################################################-->
	</body>
</html>
			
    }
}

sub get_sites {
    return q{
<!DOCTYPE html>
<html>
<head>

	<meta charset="utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<title>Zenertek</title>
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/jquery.mobile.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/quickcalc.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/ui.jqgrid-mobile.css" />
	<link rel="icon" href="https://zenertek.com/cd_static/rstatic/images/favicon.ico?v=2" type="image/x-icon" />
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <script src="https://zenertek.com/cd_static/rstatic/js/jquery.min.js"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/jquerymobile.jqGrid.min.js" id="s1"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/grid.locale-en.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.mobile.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/quickcalc.js"></script>

<script language="javascript">
/**

*/
</script>

</head>
<body onload="fillddl();"> 

	<script src="https://hammerjs.github.io/dist/hammer.js"></script>

		<!--############################################Circuits###########################################################-->	
		<div id="circuits" data-role="page" data-theme="a">
		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>

<!--here-->
		  <p>&nbsp;&nbsp;Sites Table</p>
		  </div>
			<table id='site'></table>
			<div id='something'></div>
			<script type='text/javascript'>
				jQuery('#site').jqGrid({
					"hoverrows":false,
					"viewrecords":true,
					"jsonReader":{"repeatitems":false,"subgrid":{"repeatitems":false}},
					"gridview":true,
					"loadonce":false,
					"url":"/cd-mobile/site",
					"scrollPaging":true,
					"autowidth":true,
					"rowNum":20,
					"rowList" : [20,40,60],
					"sortname":"id",
					"height":200,
					"datatype":"json",
    colNames:['Id', 'name', 'Pfc', 'Ze', 'premise_type', 'Phase', 'Max Demand','Address','Postcode', 'active', 'site_customer'],
    colModel :[ 
      {name:'id', index:'id', width:25,  align:'center', editable:false, key:true}, 
      {name:'name', index:'name', width:120,  align:'center', editable:true, editoptions:{size:10}},
      {name:'pfc', index:'pfc', width:60, align:'center', editable:true, editoptions:{size:10}}, 
      {name:'ze', index:'ze', width:60, align:'center', editable:true, editoptions:{size:10}},
      {name:'premise_type', index:'premise_type', width:100,  align:'center', sortable:false, hidden:true, editable:true, edittype: "select", editoptions:{ value: "1:Domestic;2:Office/Shop;3:Hotels/Guest House"}},        
      {name:'phase', index:'phase', width:100,  align:'center', sortable:false, editable:true, hidden:true, edittype: "select", editoptions:{ value: "1:Single;2:3 Phase"}}, 
      {name:'demand', index:'demand', width:100,  align:'center', editable:true, editoptions:{size:10}},
      {name:'address', index:'address', width:160, align:'center', editable:true, editoptions:{size:10}}, 
      {name:'postcode', index:'postcode', width:60, align:'center', editable:true, editoptions:{size:10}}, 
      {name:'active', index:'active', width:60, align:'center', editable:false, hidden:true, editoptions:{size:10}},
      {name:'site_customer', index:'site_customer', width:60, align:'center', hidden:true, editable:true, edittype: "select", 
      editoptions:{dataUrl: "/cd-mobile/cus_id", 
	  reloadGridOptions: { fromServer: true },
      buildSelect: function(data)
		{
 		var response = jQuery.parseJSON(data);
 		var s = '<select>';
 		jQuery.each(response, function(i, item, item1) {
 		s += '<option value="'+response[i].id+'">'+response[i].id+' : '+response[i].name+'</option>';
 		});
 		return s + "</select>";
		}
	}
} 
    	],
					"loadError":function(xhr,status, err){ 
						try {
							jQuery.jgrid.info_dialog(jQuery.jgrid.errors.errcap,'<div class="ui-state-error">'+ xhr.responseText +'</div>', jQuery.jgrid.edit.bClose,
							{buttonalign:'right'});
						} catch(e) { 
							alert(xhr.responseText);} 
					},
					"pager":"#something",
					"editurl":"/cd-mobile/site",
					reloadGridOptions: { fromServer: true },
				});
				jQuery('#site').jqGrid('navGrid','#something', {add:true, edit:true, del:true},{closeAfterSubmit:true, closeAfterEdit: true},{reloadAfterSubmit:true, closeAfterAdd:true},{reloadAfterSubmit:true},{multipleSearch:true});

		$("#site").jqGrid('setGridParam', {onSelectRow: function(rowid,iRow,iCol,e){
		document.getElementById("id").innerHTML = rowid;
		//alert('row clicked ' +rowid );
		}});
			function selectRow(id) {
			jQuery('#site').jqGrid('setSelection',id);
		}
		//$("#site").jqGrid('setGridParam', {gridComplete: function(rowid,iRow,iCol,e){setTimeout(function(){ selectRow(1); }, 3000); }});
		//$("#site").jqGrid('setGridParam', {ondblClickRow: function(rowid,iRow,iCol,e){alert('double clicked');}});
		//--------------------------------------------max demand---------------------------------------------
		function maxdemand(id) {
  		var xhttp = new XMLHttpRequest();
  		xhttp.onreadystatechange = function() {
    	if (xhttp.readyState == 4 && xhttp.status == 200) {
     	//document.getElementById("demo").innerHTML = xhttp.responseText;
	 	//setTimeout(function(){ selectRow(id); }, 3000);
    	}
  		};
		xhttp.open("GET", "/cd-mobile/getMax?id=" + id, true);
  		xhttp.send();
  		$('#site').trigger( 'reloadGrid' );
		}
		//--------------------------------------------max demand---------------------------------------------
		</script>
	</div>
</div>
		<!--############################################Sites###########################################################-->
			<script>
	var myElement = document.getElementById('site');
	// We create a manager object, which is the same as Hammer(), but without the presetted recognizers. 
	var mc = new Hammer.Manager(myElement);
	// Tap recognizer with minimal 2 taps
	mc.add( new Hammer.Tap({ event: 'doubletap', taps: 2 }) );
	// Single tap recognizer
	mc.add( new Hammer.Tap({ event: 'singletap' }) );
	// we want to recognize this simulatenous, so a quadrupletap will be detected even while a tap has been recognized.
	mc.get('doubletap').recognizeWith('singletap');
	// we only want to trigger a tap, when we don't have detected a doubletap
	mc.get('singletap').requireFailure('doubletap');
	mc.on("doubletap", function(ev) {
    var id = document.getElementById("id").innerHTML;
	//alert(document.getElementById("id").innerHTML);
	maxdemand(id);
	//myElement.textContent += ev.type +" ";
	});
	</script>
	</body>
</html>
			
    }
}

sub get_equations {
    return q{
<!DOCTYPE html>
<html>
<head>

	<meta charset="utf-8"/>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="0" />
	<title>Zenertek</title>
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/jquery.mobile.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/quickcalc.css" />
	<link rel="stylesheet"  href="https://zenertek.com/cd_static/rstatic/css/ui.jqgrid-mobile.css" />
	<link rel="icon" href="https://zenertek.com/cd_static/rstatic/images/favicon.ico?v=2" type="image/x-icon" />
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <script src="https://zenertek.com/cd_static/rstatic/js/jquery.min.js"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/jquerymobile.jqGrid.min.js" id="s1"></script>
	<script language="javascript" src="https://zenertek.com/cd_static/rstatic/js/grid.locale-en.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/jquery.mobile.js"></script>
	<script src="https://zenertek.com/cd_static/rstatic/js/quickcalc.js"></script>

<script language="javascript">
/**

*/
</script>

</head>
<body onload="fillddl();"> 

	<script src="https://hammerjs.github.io/dist/hammer.js"></script>


		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>

<!--here-->
		  <p>&nbsp;&nbsp;equations</p>
		  </div>
	<!--############################################--------Equations------###########################################################-->
<!-- Start of equations page -->

		<header>
		<h1>QuickCALC</h1>
		<div class="top">
		<a href="#" class="menu_icon"><i class="material-icons">dehaze</i></a>	
		</div>
		<a class="navbar-brand" href="#"><img id="logo_img" src="https://zenertek.com/cd_static/rstatic/images/zenertek_logo_.png" alt="zenertek logo"></a>
		</header>
		<nav class="menu">
		<a href="/cd-mobile/" data-ajax="false" class="item_menu">Home</a>
		<a href="/cd-mobile/customers" data-ajax="false" class="item_menu">customers</a>
		<a href="/cd-mobile/sites" data-ajax="false" class="item_menu">sites</a>
		<a href="/cd-mobile/circuits" data-ajax="false" class="item_menu">circuits</a>
		<a href="/cd-mobile/equations" data-ajax="false" class="item_menu">Equations</a>
		</nav>
	<!-- /header -->
		  <div data-role="footer" data-position="fixed" data-theme="b"><p id="id"></p>
		  <p>&nbsp;&nbsp;Equations</p>
		  </div>
<!-- /page -->

		<div role="main" class="ui-content">
		<!--- <div class="content-primary"> -->
		<ul data-role="listview" data-inset="true">
			<li>
				<a href="/paging">
					<h2>Adiabatic</h2>
					<p>Calculates circuit ZS value and Max Demand</p>
				</a>
			</li>
			<li>
				<a href="#sites">
					<h2>Zs</h2>
					<p>Adiabatic, Power Resistance etc, more...</p>
				</a>
			</li>
		</ul>
		<!--/ </div> content-primary -->	



</div>
	</body>
</html>
			
    }
}




