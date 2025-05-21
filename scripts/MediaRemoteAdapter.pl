use strict;
use warnings;
use DynaLoader;
use File::Spec;

die "Framework path not provided" unless @ARGV >= 1 && @ARGV <= 2;

my $framework_path = $ARGV[0];
my $framework = File::Spec->catfile($framework_path, 'MediaRemoteAdapter');
die "Framework not found at $framework\n" unless -e $framework;

my $handle = DynaLoader::dl_load_file($framework, 0)
  or die "Failed to load framework: $framework\n";
my $function_name = $ARGV[1] // 'loop';
die "Invalid function name: '$function_name'. Must be 'loop' or 'test'.\n"
  unless $function_name eq 'loop' || $function_name eq 'test';

my $symbol = DynaLoader::dl_find_symbol($handle, $function_name)
  or die "Symbol '$function_name' not found in $framework\n";
DynaLoader::dl_install_xsub("main::$function_name", $symbol);

eval {
    no strict 'refs';
    &{"main::$function_name"}();
};
if ($@) {
    die "Error executing $function_name: $@\n";
}
