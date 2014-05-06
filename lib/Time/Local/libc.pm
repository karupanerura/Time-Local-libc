package Time::Local::libc;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use parent qw/Exporter/;
our %EXPORT_TAGS = (
    default => [qw/timelocal timegm/],
    nocheck => [qw/timelocal_nocheck timegm_nocheck/],
);
our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;
$EXPORT_TAGS{all} = \@EXPORT_OK;

use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=encoding utf-8

=head1 NAME

Time::Local::libc - It's new $module

=head1 SYNOPSIS

    use Time::Local::libc;

=head1 DESCRIPTION

Time::Local::libc is ...

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

