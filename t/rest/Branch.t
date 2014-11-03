#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 5;
use Test::MockModule;
use Test::WWW::Mechanize::CGIApp;

use Koha::REST::Branch;
use DateTime::Format::DateParse;
use JSON;
use Data::Dumper;

use Carp ();
$SIG{__WARN__} = \&Carp::cluck;
$SIG{__DIE__} = \&Carp::confess;

my $c4_branch_module = new Test::MockModule('C4::Branch');

$c4_branch_module->mock('GetBranches', \&mock_c4_branch_GetBranches);
$c4_branch_module->mock('GetBranchDetail', \&mock_c4_branch_GetBranchDetail); 

my (%branches, %branch_by_branchcode);


# Tests

my $mech = Test::WWW::Mechanize::CGIApp->new;
$mech->app('Koha::REST::Dispatch');

## POST /branch
#my $path = "/branch";

## GET /branch
#my $path = "/branch";
#$mech->get_ok('/branch');
#my $output = from_json($mech->response->content);
#is(ref $output, 'ARRAY', "$path response is an array");
#is(scalar @$output, 1, "$path response contains the good number of holds");
#foreach my $key (qw(code name))
#{
#    ok(exists $output->[0]->{$key}, "$path first hold contain key '$key'");
#    ok(exists $output->[1]->{$key}, "$path second hold contain key '$key'");
#}

## GET /branch/:branchCode
my $path = "/branch/:branchCode";
$mech->get_ok('/branch/B1');
my $output = from_json($mech->response->content);
is(ref $output, 'ARRAY', "$path response is a array");
is(scalar @$output, 1, "$path response contains the good number of branches");
is($output->[0]->{code},"B1", "$path response contains the correct code");
is($output->[0]->{name},"Branch 1", "$path response contains the correct name");

# Mocked subroutines


#BEGIN {
#    %branches = (
#        B1 => 'Branch 1',
#        B2 => 'Branch 2',
#        B3 => 'Branch 3',
#    );
#}

#sub mock_c4_branch_GetBranches {
#
#    return $branches;
#}


BEGIN {
    %branch_by_branchcode = (
        B1 => {branchcode => 'B1', branchname => 'Branch 1'},
        B2 => {branchcode => 'B2', branchname => 'Branch 2'},
        B3 => {branchcode => 'B3', branchname => 'Branch 3'},
    );
}

sub mock_c4_branch_GetBranchDetail {
    my ($branchcode) = @_;

    return $branch_by_branchcode{$branchcode};
}