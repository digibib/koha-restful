#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 14;
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
$c4_branch_module->mock('GetBranchDetail', \&mock_c4_branch_GetBranchDetail); 

my (%branches);

# Tests

my $mech = Test::WWW::Mechanize::CGIApp->new;
$mech->app('Koha::REST::Dispatch');

## POST /branch
#my $path = "/branch";

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
$path = "/branch/:branchCode";
$mech->get_ok('/branch/B1');
is($mech->status, HTTP_OK, "$path should return correct status code");
$output = from_json($mech->response->content);
is(ref $output, 'ARRAY', "$path response is a array");
is(scalar @$output, 1, "$path response contains the good number of branches");
is($output->[0]->{code},"B1", "$path response contains the correct code");
is($output->[0]->{name},"Branch 1", "$path response contains the correct name");

# Mocked subroutines

BEGIN {
   %branches = (
        B1 => {branchcode => 'B1', branchname => 'Branch 1'},
        B2 => {branchcode => 'B2', branchname => 'Branch 2'},
        B3 => {branchcode => 'B3', branchname => 'Branch 3'},
   );
}

sub mock_c4_branch_GetBranches {
   return ( \%branches );
}

sub mock_c4_branch_GetBranchDetail {
    my ($branchcode) = @_;

    return $branches{$branchcode};
}