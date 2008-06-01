use strict;
use warnings;
package Dist::Zilla::App::Command::test;
use Dist::Zilla::App -command;

sub abstract { 'test your dist' }

sub run {
  my ($self, $opt, $arg) = @_;

  require Dist::Zilla;
  require File::Temp;
  require Path::Class;
  require IPC::Run3;
  my $run = \&IPC::Run3::run3;

  my $target = Path::Class::dir( File::Temp::tempdir() );
  print "> building test distribution under $target\n";

  my $dist = Dist::Zilla->from_dir('.');
  $dist->build_dist($target);

  chdir($target);
  eval {
    system($^X => 'Makefile.PL') and die "> error with Makefile.PL\n";
    system('make') and die "> error running make\n";
    system('make test') and die "> error running make test\n";
  }

  if ($@) {
    print $@;
    print "> left dist in place\n";
  } else {
    $target->rmtree;
  }
}

1;