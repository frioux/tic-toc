#!/usr/bin/env perl

use 5.20.1;
use warnings;

use experimental 'signatures';

use Test::More;
use Plack::Test;
use HTTP::Request;

use TTT::Web;

my $inner = TTT::Web->new;
my $app = $inner->to_psgi_app;

#   0  1  2
# 0  |  |
#  ----------
# 1  |  |
#  ----------
# 2  |  |

test_psgi
  app    => $app,
  client => sub {
   my $cb = shift;

   subtest 'vertical win' => sub {
      my $game_url;

      subtest 'new game' => sub {
         my $req = HTTP::Request->new(POST => '/');
         my $res = $cb->($req);
         ok($res->is_success, 'new game started')
           or die('something is very wrong');

         $game_url = $res->header('location');
      };

      subtest 'moves' => sub {
         {
            my $req = _xy($game_url, 0, 0);

            my $res = $cb->($req);
            ok($res->is_success, 'move made');
            my $fail = $cb->($req);
            is($fail->code, 403, 'duplicate move blocked');
            is(
               $fail->decoded_content,
               'that move is already taken',
               '... with the right message'
            );
         }

         _expect_win(
            [
                       [1, 0],
               [0, 1], [2, 1],
               [0, 2]
            ],
            'X', $cb, $game_url,
         );
      };
      my $r = $cb->(HTTP::Request->new(GET => $game_url));
      is(
         $r->decoded_content,
         "X|O| \n".
         "-----\n".
         "X| |O\n".
         "-----\n".
         "X| | \n",
         'renders correctly',
      );
   };

   subtest 'horizontal win' => sub {
      my $game_url;

      subtest 'new game' => sub {
         my $req = HTTP::Request->new(POST => '/');
         my $res = $cb->($req);
         ok($res->is_success, 'new game started')
           or die('something is very wrong');

         $game_url = $res->header('location');
      };

      subtest 'moves' => sub {
         _expect_win(
            [
               [0, 0], [0, 1],
               [1, 0], [1, 2],
               [2, 0]
            ],
            'X', $cb, $game_url,
         );
      };
      my $r = $cb->(HTTP::Request->new(GET => $game_url));
      is(
         $r->decoded_content,
         "X|X|X\n".
         "-----\n".
         "O| | \n".
         "-----\n".
         " |O| \n",
         'renders correctly',
      );
   };

   subtest 'diagonal descending win' => sub {
      my $game_url;

      subtest 'new game' => sub {
         my $req = HTTP::Request->new(POST => '/');
         my $res = $cb->($req);
         ok($res->is_success, 'new game started')
           or die('something is very wrong');

         $game_url = $res->header('location');
      };

      subtest 'moves' => sub {
         _expect_win(
            [
               [1, 0], [0, 0],
               [1, 2], [1, 1],
               [2, 1], [2, 2],
            ],
            'O', $cb, $game_url,
         );
      };
      my $r = $cb->(HTTP::Request->new(GET => $game_url));
      is(
         $r->decoded_content,
         "O|X| \n".
         "-----\n".
         " |O|X\n".
         "-----\n".
         " |X|O\n",
         'renders correctly',
      );
   };

   subtest 'diagonal_descending win' => sub {
      my $game_url;

      subtest 'new game' => sub {
         my $req = HTTP::Request->new(POST => '/');
         my $res = $cb->($req);
         ok($res->is_success, 'new game started')
           or die('something is very wrong');

         $game_url = $res->header('location');
      };

      subtest 'moves' => sub {
         _expect_win(
            [
               [1, 0], [2, 0],
               [1, 2], [1, 1],
               [2, 1], [0, 2],
            ],
            'O', $cb, $game_url,
         );
      };
   };
  };

sub _xy ($game, $x, $y) {
   my $req = HTTP::Request->new(
      PUT => $game,
      [content_type => 'application/x-www-form-urlencoded'],
      "x=$x&y=$y",
   );
}

sub _expect_win ($moves, $player, $cb, $game_url) {
   my @moves = @$moves;

   my $final = pop @moves;

   for (@moves) {
      my $req = _xy($game_url, @$_);

      my $res = $cb->($req);
      ok($res->is_success, 'move made');
   }

   my $req = _xy($game_url, @$final);

   my $res = $cb->($req);
   ok($res->is_success, 'move made');
   is($res->decoded_content, "$player won!", 'game won');
}

done_testing;
