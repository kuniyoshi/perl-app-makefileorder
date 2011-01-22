package App::MakeFileOrder;

use strict;
use warnings;
use Carp qw( croak );
use base "Class::Accessor";
use Path::Class ( );
use Readonly;
use List::MoreUtils qw( first_index );

our $VERSION = "0.01";

Readonly my @FIELDS  => qw( mode  verbose  dry_run  dir  order );
Readonly my %DEFAULT => (
    mode    => "plain",
    verbose => 0,
    dry_run => 0,
);

__PACKAGE__->mk_accessors( @FIELDS );

sub new {
    my $class = shift;
    my %param = @_;

    foreach my $need ( @FIELDS ) {
        $param{ $need } = $DEFAULT{ $need }
            unless exists $param{ $need };

        croak sprintf "%s required.", ucfirst $param{ $need }
            unless exists $param{ $need };
    }

    my $self = $class->SUPER::new( \%param );

    $self->dir( Path::Class::dir( $self->dir ) );

    croak sprintf "No dir[%s] exists.", $self->dir->absolute
        unless -d $self->dir->absolute;

    return $self;
}

sub move {
    my $self  = shift;
    my %param = @_;

    return
        if $param{to} eq $param{from};

    my @commands = $self->mode eq "plain" ? qw( mv )
                                          : $self->mode eq "git" ? qw( git mv )
                                                                 : ( );

    if ( $self->verbose ) {
        printf "Rename from %s to %s.\n",
            $param{from}->relative,
            $param{to}->relative;
    }

    unless ( $self->dry_run ) {
        system( @commands, $param{from}->relative, $param{to}->relative ) == 0
            or die "Could not @commands.[$!]";
    }

    return $self;
}

sub rename {
    my $self = shift;

    foreach my $file ( grep { ! $_->is_dir } $self->dir->children ) {
        my $name = $file->basename;
        $name =~ s{\A \d{2} [-] }{}msx;

        my $index = first_index { $_ eq $name } @{ $self->order };
        $index++;

        $name = $self->dir->file( sprintf "%02d-%s", $index, $name );

        $self->move( from => $file, to => $name );
    }

    return $self;
}

1;
__END__
=encoding utf-8

=head1 NAME

App::MakeFileOrder - Perl extension for test files make order.

=head1 SYNOPSIS

  use App::MakeFileOrder;

  my @order_list = qw(
      prereq.t  use.t  can.t  new.t
  );

  App::MakeFileOrder->new(
      dir   => "t",
      order => \@order_list,
      mode  => "git",
  )->renmae;

=head1 DESCRIPTION

Allows you to make order the test files.

The perl command of prove depends depends filename order.
To control the order, add a number prefix to test files.
This do it.

=head1 SEE ALSO

=head1 AUTHOR

kuniyoshi kouji, E<lt>kuniyoshi@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by kuniyoshi kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.1 or,
at your option, any later version of Perl 5 you may have available.


=cut

