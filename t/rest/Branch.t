#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 26;
use Test::MockModule;
use Test::WWW::Mechanize::CGIApp;
use HTTP::Status qw(:constants :is status_message);

use Koha::REST::Branch;
use DateTime::Format::DateParse;
use JSON;
use Data::Dumper;

# use Carp ();
# $SIG{__WARN__} = \&Carp::cluck;
# $SIG{__DIE__} = \&Carp::confess;

my $c4_branch_module = new Test::MockModule('C4::Branch');
$c4_branch_module->mock('GetBranches', \&mock_c4_branch_GetBranches);
$c4_branch_module->mock('ModBranch', \&mock_c4_branch_ModBranch);

my (%branches, %newBranch, %modifiedBranch);

# Tests

my $mech = Test::WWW::Mechanize::CGIApp->new;
$mech->requests_redirectable([]);
$mech->app('Koha::REST::Dispatch');

## GET /branch
my $path = "/branch";
$mech->get_ok('/branch');
is($mech->status, HTTP_OK, "$path should return correct status code");
my $output = from_json($mech->response->content);
is(ref $output, 'ARRAY', "$path response is an array");
is(scalar @$output, 3, "$path response contains the good number of branches");
foreach my $key (qw(code name))
{
   ok(exists $output->[0]->{$key}, "$path first hold contain key '$key'");
   ok(exists $output->[1]->{$key}, "$path second hold contain key '$key'");
}

## GET /branch/:branchCode
### Scenario: good case, branch exists
$path = "/branch/:branchCode";
$c4_branch_module->mock('GetBranchDetail', \&mock_c4_branch_GetBranchDetail);
$mech->get_ok('/branch/B1');
is($mech->status, HTTP_OK, "$path should return correct status code");
$output = from_json($mech->response->content);
is(ref $output, 'ARRAY', "$path response is a array");
is(scalar @$output, 1, "$path response contains the good number of branches");
is($output->[0]->{code},"B1", "$path response contains the correct code");
is($output->[0]->{name},"Branch 1", "$path response contains the correct name");

### Scenario: bad case, branch does not exists
$mech->get('/branch/BRANCH_CODE_THAT_DOES_NOT_EXIST');
is($mech->status, HTTP_NOT_FOUND, "$path should return correct status code");

## POST /branch
$path = "/branch";
$c4_branch_module->mock('GetBranchDetail', \&mock_c4_branch_GetBranchDetail_newBranch); 
my $newBranch = to_json(\%newBranch);
$mech->post( $path, [ POSTDATA => $newBranch, 'content-type' => 'application/json' ], "create branch");
is($mech->status, HTTP_CREATED, "$path should return correct status code");
my $location = $mech->response->headers->{location};
is($location, "http://localhost/branch/" . $newBranch{branchcode}, "$path returns location to created resource");

## PUT /branch
$path = "/branch/:branchCode";
$c4_branch_module->mock('GetBranchDetail', \&mock_c4_branch_GetBranchDetail_modifiedBranch); 
my $modifiedBranch = to_json(\%modifiedBranch);
$mech->put_ok( '/branch/B1', { content => $modifiedBranch, 'content-type' => 'application/json' }, "modify branch");
is($mech->status, HTTP_OK, "$path should return correct status code");
$output = from_json($mech->response->content);
is($output->{branchcode},"B1", "$path response contains the correct code");
is($output->{branchname},"Modified Branch 1", "$path response contains the correct modified name");

## DELETE /branch/:branchCode
$path = "/branch/:branchCode";
$c4_branch_module->mock('DelBranch', \&mock_c4_branch_DelBranch_success);
$mech->delete( '/branch/B1', "delete branch");
is($mech->status, HTTP_NO_CONTENT, "$path should return correct status code");
$output = from_json($mech->response->content);
is($output->{deleted}, JSON::true, "$path response contains the correct response");

$c4_branch_module->mock('DelBranch', \&mock_c4_branch_DelBranch_nonexisting);
$mech->delete( '/branch/B1', "delete non-existing branch");
is($mech->status, HTTP_NOT_FOUND, "$path should return correct status code");
$output = from_json($mech->response->content);
is($output->{deleted}, JSON::false, "$path response contains the correct response");
is($output->{error}, "0E0", "$path response contains the correct response");

# Mocked subroutines

BEGIN {
    %branches = (
        B1 => {branchcode => 'B1', branchname => 'Branch 1'},
        B2 => {branchcode => 'B2', branchname => 'Branch 2'},
        B3 => {branchcode => 'B3', branchname => 'Branch 3'},
    );
}

BEGIN {
    %newBranch = (
        branchcode => 'B1',
        branchname => 'Branch 1',
        branchaddress1 => 'Branch 1 Adress 1',
        branchaddress2 => 'Branch 1 Adress 2',
        branchaddress3 => 'Branch 1 Adress 3',
        branchzip => '012345',
        branchcity => 'City of Branch 1',
        branchstate => 'State of Branch 1',
        branchcountry => 'Contry of Branch 1',
        branchphone => 'B1',
        branchfax => 'B1',
        branchemail => 'B1',
        branchurl => 'B1',
        branchip => 'B1',
        branchprinter => 'B1',
        branchnotes => 'B1',
        opac_info => 'B1',
        branchreplyto => 'B1',
        branchreturnpath => 'B1'
    );
}

BEGIN {
    %modifiedBranch = (
        branchcode => 'B1',
        branchname => 'Modified Branch 1',
    );
}

sub mock_c4_branch_ModBranch {
    return 0;
}

sub mock_c4_branch_GetBranches {
    return ( \%branches );
}

sub mock_c4_branch_GetBranchDetail {
    my ($branchcode) = @_;

    return $branches{$branchcode};
}

sub mock_c4_branch_GetBranchDetail_newBranch {
    return ( \%newBranch );
}

sub mock_c4_branch_GetBranchDetail_modifiedBranch {
    return ( \%modifiedBranch );
}

sub mock_c4_branch_DelBranch_success {
    return 1;
}

sub mock_c4_branch_DelBranch_nonexisting {
    return "0E0";
}