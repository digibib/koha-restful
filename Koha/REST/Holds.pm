package Koha::REST::Holds;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean);
use C4::Reserves;
use C4::HoldsQueue qw(GetHoldsQueueItems);
use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Koha;   # GetItemTypes
use C4::Branch; # GetBranches
use C4::Members;
use YAML;
use File::Basename;
use JSON;

sub setup {
    my $self = shift;
    $self->run_modes(
        get_all_holds        => 'rm_get_all_holds',
        put_found_book       => 'rm_put_found_book',
        get_pending_holds    => 'rm_get_pending_holds',
        get_holds_for_branch => 'rm_get_holds_for_branch',
    );
}

# return all holds in queue
sub rm_get_all_holds {
    my $self = shift;
    C4::HoldsQueue::CreateQueue();  # rebuild holds queue
    my $response = [];
    my $pending_holds = GetHoldsQueueItems();
    foreach my $pending_hold (@$pending_holds) {
        push @$response, {
            hold => $pending_hold
        };
    };
    return format_response($self, [@$pending_holds] );
}

sub rm_put_found_book {
    my $self = shift;
    my $biblionumber = $self->param('biblionumber');
    my $itemnumber = $self->param('itemnumber');
    my $borrowernumber = $self->param('borrowernumber');

    my $response;
    
    # Modules no longer working!
    #my $reserve_id = C4::Reserves::GetReserveId({ biblionumber => $biblionumber, borrowernumber => $borrowernumber});
    #my $reserve_info = C4::Reserves::GetReserveInfo($reserve_id);

    # ModReserveAffect fills hold and marks book as Waiting or Transit
    my $modreserve = C4::Reserves::ModReserveAffect($itemnumber, $borrowernumber);
    # my $modreserve = ModReserve({ 
    #     rank => 'del',
    #     reserve_id => $reserve_id,
    #     branchcode => 'hutl',
    #     itemnumber => $itemnumber,
    #     biblionumber => $biblionumber, 
    #     borrowernumber => $borrowernumber,
    # });

    # Rebuild holdsqueue
    C4::HoldsQueue::CreateQueue();  # rebuild holds queue

    push @$response, {
#        reserve_id => $reserve_id,
#        reserve_info => $reserve_info,
        mod_reserve => $modreserve,
    };
    
    return format_response($self, $response );
}

# return array of biblio items with pendings holds
sub rm_get_pending_holds {
    my $self = shift;
    my $response = [];
    my $pending_hold_biblionumbers = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    foreach my $pending_hold_biblionumber (@$pending_hold_biblionumbers) {
        my $requests = C4::HoldsQueue::GetPendingHoldRequestsForBib($pending_hold_biblionumber);
        foreach my $request (@$requests) {
            push @$response, {
                request => $request,
            };
        };
    };

    return format_response($self, $response );
}

# return current holds for a branch
# NOT USED!
sub rm_get_holds_for_branch {
    my $self = shift;
    my $branchcode = $self->param('branchcode');
    return [] unless ($branchcode);

    my $response = [];
    
    #my @holds = C4::Reserves::GetReservesForBranch($branchcode);
    my $pending_hold_biblionumbers = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    my @pending_hold_biblionumbers2 = GetHoldsQueueItems($branchcode);
    foreach my $pending_hold_biblionumber (@$pending_hold_biblionumbers) {
        # my $holds = C4::HoldsQueue::GetPendingHoldRequestsForBib($pending_hold_biblionumber);
        my $reserves = C4::Reserves::GetReservesFromBiblionumber($pending_hold_biblionumber);
        foreach my $reserve (@$reserves) {
            my $biblio = (C4::Biblio::GetBiblio($reserve->{biblionumber}))[-1];
            my $item = (C4::Items::GetItem($reserve->{itemnumber}))[-1];
            push @$response, {
                hold_id => $reserve->{reserve_id},
                priority => $reserve->{priority},
                lowestPriority => $reserve->{lowestPriority},
                reservedate => $reserve->{reservedate},
                reservenotes => $reserve->{reservenotes},
                reservedate => $reserve->{reservedate},
                reservetime => $reserve->{reservetime},
                biblionumber => $reserve->{biblionumber},
                branchcode => $reserve->{branchcode},
                itemnumber => $reserve->{itemnumber},
                title => $biblio ? $biblio->{title} : '',
                barcode => $item ? $item->{barcode} : '',
                itemcallnumber => $item ? $item->{itemcallnumber} : '',
                branchname => C4::Branch::GetBranchName($reserve->{branchcode}),
                expirationdate => $reserve->{expirationdate},
                found => $reserve->{found},
                suspend => $reserve->{suspend},
                suspend_until => $reserve->{suspend_until},
                constrainttype => $reserve->{constrainttype},
            };
        };
    };
    return format_response($self, $response);
}

1;
