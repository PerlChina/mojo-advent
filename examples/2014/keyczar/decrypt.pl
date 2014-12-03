#!/usr/bin/perl

use strict;
use warnings;
use v5.10;
use FindBin qw/$Bin/;
use Crypt::Keyczar::Crypter;

my $msg = shift @ARGV or die "message is required.\n";

my $c = Crypt::Keyczar::Crypter->new("$Bin/crypt-rsa");
say $c->decrypt(Crypt::Keyczar::Util::decode($msg));