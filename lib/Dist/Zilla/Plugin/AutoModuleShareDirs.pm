package Dist::Zilla::Plugin::AutoModuleShareDirs;
BEGIN {
  $Dist::Zilla::Plugin::AutoModuleShareDirs::AUTHORITY = 'cpan:GETTY';
}
{
  $Dist::Zilla::Plugin::AutoModuleShareDirs::VERSION = '0.001';
}
# ABSTRACT: Automatically install sharedirs for modules by scheme

use Moose;

extends 'Dist::Zilla::Plugin::ModuleShareDirs';

use Module::Metadata;
use Class::Load ':all';

### SHOULD BE ONLY LOADED ON SHAERDIR_MEHOD USAGE ACTUALLY....
use File::Spec;
my $lib;
BEGIN { $lib = File::Spec->catdir( File::Spec->curdir(), 'lib' ); }
use Carp qw( croak );
use lib "$lib";
#Carp::carp("[Bootstrap::lib] $lib added to \@INC");
##################################################################

around BUILDARGS => sub {
	my $orig = shift;
	my ( $class, @arg ) = @_;

	my %copy = ref $arg[0] ? %{$arg[0]} : @arg;

	my $scan_namespaces = delete $copy{scan_namespaces};
	my $sharedir_method = delete $copy{sharedir_method};

	my $modules = Module::Metadata->provides(
		dir => $copy{zilla}->root->subdir('lib'),
		version => '1.4',
	);

	my %sharedirs;

	for my $mod (keys %{$modules}) {
		if ($scan_namespaces) {
			next unless grep { $mod =~ /^${_}::.*/ } split(/,/,$scan_namespaces);
		}
		if ($sharedir_method) {
			try_load_class($mod);
			next unless $mod->can($sharedir_method);
			$sharedirs{$mod} = $mod->$sharedir_method;
		} else {
			# TODO set a default handling
			croak __PACKAGE__." has no default behaviour defined so far, please use sharedir_method";
		}
	}

	for (keys %sharedirs) {
		$copy{$_} = $sharedirs{$_} if -d $copy{zilla}->root->subdir($sharedirs{$_});
	}

	return $class->$orig(%copy);
};

1;


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::AutoModuleShareDirs - Automatically install sharedirs for modules by scheme

=head1 VERSION

version 0.001

=head1 SYNOPSIS

In dist.ini:

  [AutoModuleShareDirs]
  scan_namespaces = MyApp::Plugin
  sharedir_method = function_on_the_package

=head1 DESCRIPTION

More information to come, but this module actually automatize the setting for defining the 
sharedirs for module inside your distribution (see L<Dist::Zilla::Plugin::ModuleShareDirs>).

So far there is no default behaviour defined, soon to come.

The usage of B<scan_namespaces> is optional.

It only includes modules that have a sharedir after the specification given.

=encoding utf8

=head1 SEE ALSO

L<Dist::Zilla::Plugin::ModuleShareDirs>

=head1 SPONSOR

This module is sponsored by L<DuckDuckGo Inc.|http://duckduckgo.com/>.

=head1 SUPPORT

IRC

  Join #distzilla on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/Getty/p5-dist-zilla-plugin-automodulesharedirs
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/Getty/p5-dist-zilla-plugin-automodulesharedirs/issues

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Torsten Raudssus L<http://raudss.us/>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

