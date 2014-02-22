#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';
use Test::More;

use_ok( 'Net::BitTorrentSync');

# set_config
my $config = set_config('C:\dev\btconfig.txt');

ok (ref $config->{'webui'} eq 'HASH', 'correct structure returned');

like (
    $config->{'webui'}->{'listen'}, 
    qr/^[0-9]{1,3}(?:\.[0-9]{1,3}){3}:[0-9]+$/,
    'listened address is [ip:port]'
);

# add_folder
my $response = add_folder(abs_path '.\t\data\sync_test');

is_deeply($response, { result => 0 }, 'folder added ok');

# get_folders
$response = get_folders();

ok (ref $response eq 'ARRAY', 'get_folders returns an ArrayRef');

ok (ref $response->[0] eq 'HASH', 'Each element is a HashRef');

is_deeply (
    [sort keys %{$response->[0]}], 
    [(qw/dir error files indexing secret size type/)], 
    'correct items'
);

my $secret = $response->[0]->{secret};

# get_secrets
$response = get_secrets($secret);

ok (ref $response eq 'HASH', 'get_secrets returns a hashref');
ok ($response->{read_write} eq $secret, 
    'the read_write secret is folder secret');
ok ($response->{read_only} ne $secret, 
    'and the read_only secret is different');

=begin get_files

$response = get_files($secret, 'sub');

=cut

# remove_folder
is_deeply( 
    remove_folder($secret), 
    {error => 0}, 
    'folder removed ok'
 );

# get_os
$response = get_os();
if ($^O eq 'MSWin32') {
    is_deeply ($response, { os => "win32" }, 'OS identified as MSWin32');
}

=begin

    start_btsync
    set_listened_path
    set_file_prefs
    get_folder_peers
    get_folder_prefs
    set_folder_prefs
    get_folder_hosts
    set_folder_hosts
    get_prefs
    set_prefs
    get_version
    get_speed
    shutdown

=cut

done_testing;
