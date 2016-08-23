package Dist::Zilla::Plugin::AutoModuleShareDirs;
# ABSTRACT: Automatically install sharedirs for modules by scheme

use Moose;

extends 'Dist::Zilla::Plugin::ModuleShareDirs';

use Module::Metadata;
use Class::Load 'load_class';
use Carp qw( croak );
use List::Util 'first';

around BUILDARGS => sub {
	my $orig = shift;
	my ( $class, @arg ) = @_;

	my %copy = ref $arg[0] ? %{$arg[0]} : @arg;

	my @scan_namespaces = split ',', delete $copy{scan_namespaces};
	my $sharedir_method = delete $copy{sharedir_method};

	my $root = $copy{zilla}->root;

	my $lib = $root->child('lib')->stringify;
	unshift @INC, $lib;

	my $modules = Module::Metadata->provides(
		dir => $lib,
		version => '1.4',
	);

	for my $mod (keys %{$modules}) {
		if (@scan_namespaces) {
			next unless first { $mod =~ /^${_}::.*/ } @scan_namespaces;
		}
		if ($sharedir_method) {
			load_class($mod);
			next unless $mod->can($sharedir_method);
			my $sd = $mod->$sharedir_method;
			$copy{$mod} = $sd if -d $root->child($sd);
		}
		else {
			# TODO set a default handling
			croak __PACKAGE__ . ' has no default behaviour defined so far, please use sharedir_method';
		}
	}

	return $class->$orig(%copy);
};

1;


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::AutoModuleShareDirs - Automatically install sharedirs for modules by scheme

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

=head1 CONTRIBUTING

To browse the repository, submit issues, or bug fixes, please visit
the github repository:

=over 4

L<https://github.com/duckduckgo/p5-dzp-automodulesharedirs>

=back

=head1 AUTHOR

Zach Thompson <zach@duckduckgo.com>
Torsten Raudssus <torsten@raudss.us>

=cut

