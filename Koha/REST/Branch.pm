package Koha::REST::Branch;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean format_error);
use C4::Context;
use C4::Branch;
use JSON;
use HTTP::Status qw(:constants :is status_message);
use Data::Dumper;

sub setup {
    my $self = shift;
    $self->run_modes(
        get_branch_by_code => 'rm_get_branch_by_code',
        get_branches => 'rm_get_branches',
        create_branch => 'rm_create_branch',
        edit_branch => 'rm_edit_branch',
    );
}

# GET /branch
# Returns a list of branches
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

# GET /branch/:branchcode
# Returns the branch with given branchcode
sub rm_get_branch_by_code {
    my $self = shift;
    my $branchcode = $self->param('branchcode');
    my $response = [];
    my $branch = C4::Branch::GetBranchDetail($branchcode);
    if ($branch) {
        push @$response, {
            code => $branch->{branchcode},
            name => $branch->{branchname},
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
        return format_error($self, HTTP_BAD_REQUEST, {
            error => "Not created",
        });
    } else {
        my $branch = C4::Branch::GetBranchDetail($data->{branchcode});
        return format_response($self, $branch, HTTP_CREATED);
    }
}

# PUT /branch/:branchCode
sub rm_edit_branch {
    my $self = shift;
    my $branchcode = $self->param('branchcode');
    my $q = $self->query;
    my $jsondata = $q->param('PUTDATA');

    my $data = from_json($jsondata);

    my $error = C4::Branch::ModBranch($data);
    if ($error) {
        return format_error($self, HTTP_BAD_REQUEST, {
            error => "Not modified",
        });
    } else {
        my $branch = C4::Branch::GetBranchDetail($data->{branchcode});
        return format_response($self, $branch, HTTP_OK);
    }
}

1;
