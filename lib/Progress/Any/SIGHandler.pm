package Progress::Any::SIGHandler;

use 5.010001;
use strict;
use warnings;

use Progress::Any '$progress';
use Progress::Any::Output ();

# AUTHORITY
# DATE
# DIST
# VERSION

our $Template  = 'Progress: %P/%T (%6.2p%%), %R';
our $Signal    = 'USR1';

sub import {
    my ($package, %args) = @_;

    #if (my $val = delete $args{indicator}) {
    #    $Indicator = $val;
    #}
    if (defined(my $val = delete $args{template})) {
        $Template = $val;
    }

    die "Unknown import argument(s): " . join(", ", sort keys %args)
        if keys %args;

    install_sig_handler();
}

sub install_sig_handler {
    my $filled_message = "";

    Progress::Any::Output->add(
        'Callback',
        callback => sub {
            my ($self, %args) = @_;
            $filled_message = $progress->fill_template($Template);
        },
    );

    $SIG{ $Signal } = sub {
        warn $filled_message, "\n";
    };
}

1;
# ABSTRACT: Add signal handler so your process can report progress when sent signal e.g. USR1

=for Pod::Coverage ^()$

=head1 SYNOPSIS

=head2 Simplest way to use

In F<foo.pl>:

 #!/usr/bin/env perl

 use strict;
 use warnings;

 use Progress::Any '$progress';
 use Progress::Any::SIGHandler;

 # do stuffs while updating progress
 $progress->target(100);
 for (1..100) {
     # do stuffs
     sleep(rand()*3 + 1);
     $progress->update;
 }
 $progress->finish;

When run in bash:

 % ./foo.pl &     ; # run in background

 % kill -USR1 %1
 Progress: 5/100 (  5.00%), 2m38s left

 % kill -USR1 %1
 Progress: 8/100 (  8.00%), 2m27s left


=head2 Customize some aspects

 use Progress::Any::SIGHandler (
     template  => '...',      # default template is: "Progress: %P/%T (%6.2p%%), %R"
     signal    => 'USR2',     # default is USR1
 );


=head1 DESCRIPTION

Importing this module will install a C<%SIG> handler (the default is C<USR1>).
When your process is sent the signal, the handler will print to STDERR the
progress report. You can customize some aspects (see Synopsis). More
customization will be added in the future.


=head1 IMPORT ARGUMENTS

=head2 signal

See L</$Signal>.

=head2 template

See L</$Template>.


=head1 PACKAGE VARIABLES

=head2 $Signal

The Unix signal to use. Set it before call to C<install_sig_handler()>. A
convenient is to pass the `signal` argument during import, which will set this
variable.

=head2 $Template

Template to use (see C<fill_template> in L<Progress::Any> documentation).


=head1 FUNCTIONS

=head2 install_sig_handler

Called automatically by C<import()>, but if you do not import, you can invoke
this explicitly yourself.


=head1 SEE ALSO

L<Progress::Any>

=cut
