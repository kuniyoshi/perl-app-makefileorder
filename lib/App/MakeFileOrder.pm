package App::MakeFileOrder;

use strict;
use warnings;
use Carp qw( croak );
use base "Class::Accessor";
use Path::Class ( );
use Readonly;
use List::MoreUtils qw( first_index );
use Scalar::Util qw( blessed );
use File::Basename qw( fileparse );

our $VERSION = "0.03";

Readonly my @FIELDS        => qw( mode  verbose  dry_run  dir  index );
Readonly my %DEFAULT       => (
    dir     => ".",
    mode    => "plain",
    verbose => 0,
    dry_run => 0,
);
Readonly my $SUFFIX        => ".t";
Readonly my %MOVE_COMMANDS => (
    plain => [ qw( mv ) ],
    git   => [ qw( git mv ) ],
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

    croak "Could not understand the mode[", $self->mode, "]."
        unless exists $MOVE_COMMANDS{ $self->mode };

    if ( ! blessed $self->dir ) {
        $self->dir( Path::Class::dir( $self->dir ) );
    }
    else {
        croak "Dir should is a Path::Class."
            unless $self->dir->isa( "Path::Class" );
    }

    croak sprintf "No dir[%s] exists.", $self->dir->absolute
        unless -d $self->dir->absolute;

    return $self;
}

sub move {
    my $self  = shift;
    my %param = @_;

    return
        if $param{to} eq $param{from};

    if ( $self->verbose ) {
        printf "Rename from %s to %s.\n",
            $param{from}->relative,
            $param{to}->relative;
    }

    unless ( $self->dry_run ) {
        system(
            @{ $MOVE_COMMANDS{ $self->mode } },
            $param{from}->relative,
            $param{to}->relative,
        ) == 0
            or die "Could not ", join( q{ }, @{ $MOVE_COMMANDS{ $self->mode } } ), ".[$!]";
    }

    return $self;
}

sub is_test_file {
    my $self = shift;
    my $file = shift
        or croak "File required.";

    return
        if $file->is_dir;

    my( $name, $path, $suffix ) = fileparse $file->absolute, $SUFFIX;

    return $suffix && $suffix eq $SUFFIX;
}

sub order {
    my $self = shift;

    foreach my $file ( grep { $self->is_test_file( $_ ) } $self->dir->children ) {
        my $name = $file->basename;
        $name =~ s{\A \d{2,3} [-] }{}msx;

        my $index = first_index { $_ eq $name } @{ $self->index };
        $index++;

        $name = $self->dir->file( sprintf "%02d-%s", $index, $name );

        $self->move( from => $file, to => $name );
    }

    return $self;
}

sub unorder {
    my $self = shift;

    foreach my $file ( grep { $self->is_test_file( $_ ) } $self->dir->children ) {
        my $name = $file->basename;
        $name =~ s{\A \d{2,3} [-] }{}msx;

        $name = $self->dir->file( $name );

        $self->move( from => $file, to => $name );
    }

    return $self;
}

1;

__END__
=encoding utf-8

=head1 NAME

App::MakeFileOrder - Perl extension for making test files order

=head1 SYNOPSIS

  use App::MakeFileOrder;

  my @index_list = qw(
      prereq.t  use.t  can.t  new.t
  );

  App::MakeFileOrder->new(
      index => \@index_list,
      mode  => "git",
  )->order;

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

