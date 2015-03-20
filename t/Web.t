#!/usr/bin/env perl

use Test::More;
use Plack::Test;
use HTTP::Request;

use TTT::Web;

my $app = TTT::Web->new->to_psgi_app;

#   0  1  2
# 0  |  |
#  ----------
# 1  |  |
#  ----------
# 2  |  |

test_psgi
    app => $app,
    client => sub {
        my $cb  = shift;

        my $game_url;

        subtest 'new game' => sub {
           my $req = HTTP::Request->new(POST => '/');
           my $res = $cb->($req);
           ok($res->is_success, 'new game started') or die('something is very wrong');

           $game_url = $res->header('location');
        };

        subtest 'moves' => sub {
           my $req = HTTP::Request->new(
              PUT => $game_url,
              [ content_type => 'application/x-www-form-urlencoded' ],
              'x=0&y=0',
           );

           my $res = $cb->($req);
           ok($res->is_success, 'move made');
           my $fail = $cb->($req);
           is($fail->code, 403, 'duplicate move blocked');
        };

    };

done_testing;
