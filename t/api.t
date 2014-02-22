#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use_ok( 'Net::BitTorrentSync');

my $config = set_config('C:\dev\btconfig.txt');

ok (ref $config->{'webui'}, 'HASH');
like ($config->{'webui'}->{'listen'}, qr/^[0-9]{1,3}(?:\.[0-9]{1,3}){3}:[0-9]+$/);

my $response = add_folder('C:\\dev\\Net-BitTorrentSync\\t\\data');

is_deeply($response, { result => 0 });

$response = get_folders();

is_deeply( remove_folder($response->[0]->{secret}), {error => 0} );

if ($^O eq 'MSWin32') {
    is_deeply (get_os(), { os => "win32" })
}

=begin

    start_btsync
    
    set_listened_path
    remove_folder
    get_files
    set_file_prefs
    get_folder_peers
    get_secrets
    get_folder_prefs
    set_folder_prefs
    get_folder_hosts
    set_folder_hosts
    get_prefs
    set_prefs
    get_os
    get_version
    get_speed
    shutdown

=cut

done_testing;
