#!/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';
use Test::More;

use_ok( 'Net::BitTorrentSync');

# start_btsync

start_btsync();

# set_config
my $config = set_config();

ok (ref $config->{'webui'} eq 'HASH', 'correct structure returned');

like (
    $config->{'webui'}->{'listen'},
    qr/^[0-9]{1,3}(?:\.[0-9]{1,3}){3}:[0-9]+$/,
    'listened address is [ip:port]'
);

# set_listened_address

set_listened_address($config->{'webui'}->{'listen'});

# add_folder
my $response = add_folder(abs_path './t/data/sync_test');

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

# get_files

$response = get_files($secret);

my $compare = [
  {
    have_pieces => 1,
    name => "New Text Document.txt",
    size => 3359,
    state => "created",
    total_pieces => 1,
    type => "file",
  },
  { name => "sub", state => "created", type => "folder" },
];

is_deeply ($response, $compare, 'matching file structures');

$response = get_files($secret, 'sub');

$compare = [
  {
    have_pieces => 1,
    name => "index.html",
    size => 11,
    state => "created",
    total_pieces => 1,
    type => "file",
  },
];

is_deeply ($response, $compare, 'matching file structures');


=begin

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

=cut

# remove_folder
is_deeply(
    remove_folder($secret),
    {error => 0},
    'folder removed ok'
 );

$response = get_folders();

is_deeply ($response, [], 'should now be empty ArrayRef');

# get_os
$response = get_os();

if ($^O eq 'MSWin32') {
        is_deeply ($response, { os => "win32" }, 'OS identified as MSWin32');
} elsif ($^O eq 'linux') {
        is_deeply ($response, { os => "linux" }, 'OS identified as linux');
}

shutdown_btsync();

done_testing;
