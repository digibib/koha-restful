package Koha::REST::Branch;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean format_error);
use C4::Context;
use C4::Branch;
use JSON;
use Data::Dumper;

sub setup {
    my $self = shift;
    $self->run_modes(
        get_branches => 'rm_get_branches',
        create_branch => 'rm_create_branch',
    );
}

sub rm_get_branches {
    my $self = shift;
    my $response = [];
    my $branches = C4::Branch::GetBranches();
    if ($branches) {
        foreach my $branch (values %$branches) {
            push @$response, {
                code => $branch->{branchcode},
                name => $branch->{branchname},
            };
        }
    }
    return format_response($self, $response);
}

# POST /branch
sub rm_create_branch {
    my $self = shift;
    my $q = $self->query;
    my $jsondata = $q->param('POSTDATA');

    my $data = from_json($jsondata);

    # ModBranch add => true inserts new branch if not present
    $data->{add} = "true";

    my $error = C4::Branch::ModBranch($data);
    if ($error) {
        return format_response($self, { error => "Not created" });
    }
}

1;
