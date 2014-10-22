package AnyEvent::ZeroMQ::Reply;
BEGIN {
  $AnyEvent::ZeroMQ::Reply::VERSION = '0.01';
}
# ABSTRACT: Non-blocking OO abstraction over ZMQ_REP request/reply sockets
use Moose;
use true;
use namespace::autoclean;
use Scalar::Util qw(weaken);
use ZeroMQ::Raw::Constants qw(ZMQ_REP);

with 'AnyEvent::ZeroMQ::Role::WithHandle' =>
    { socket_type => ZMQ_REP, socket_direction => '' };

has 'on_request' => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

after 'BUILD' => sub {
    my $self = shift;
    my $h = $self->handle;

    weaken $self;
    $h->on_read(sub {
        my ($h, $msg) = @_;
        my $res = $self->on_request->($self, $msg);
        $h->push_write($res);
    });
};

with 'AnyEvent::ZeroMQ::Handle::Role::Generic';

__PACKAGE__->meta->make_immutable;

__END__
=pod

=head1 NAME

AnyEvent::ZeroMQ::Reply - Non-blocking OO abstraction over ZMQ_REP request/reply sockets

=head1 VERSION

version 0.01

=head1 AUTHOR

Jonathan Rockway <jrockway@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jonathan Rockway.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

