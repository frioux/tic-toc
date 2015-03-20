use Moops;
use TTT::Schema;
use Try::Tiny;

class TTT::Web extends Web::Simple::Application {

   has schema => (
      is => 'ro',
      lazy => 1,
      builder => sub {
         my $s = TTT::Schema->connect('dbi:SQLite::memory:');
         $s->deploy;
         $s
      },
   );

   method dispatch_request ($env) {
      'POST + /' => 'create_game',
      '/*' => method ($game_id, $env) {

         my $game = $self->schema->resultset('Game')->find($game_id);

         'PUT + %x=&y=' => method ($x, $y, $env) {
            $self->make_move($game, $x, $y)
         },
         GET => method { $self->render_game($game) }
      },
   }

   method create_game {
      my $game = $self->schema->resultset('Game')->create({});

      return [ 200, [
         content_type => 'text/plain',
         location => '/' . $game->id,
      ], ['have fun!']];
   }

   method make_move($game, $x, $y) {
      # check for unique constraint violation
      try {
         $self->schema->txn_do(sub {

            # this will be undef the first time, which is fine
            my $last_player = $game->last_player;

            $game->add_to_moves({
               x => $x,
               y => $y,
               player => 0+!$last_player,
            });
         });

         return [ 200, [ content_type => 'text/plain' ], ['good move!']];
      } catch {
         return [ 403, [ content_type => 'text/plain' ], ['that move is already taken']]
            if m/UNIQUE constraint failed: moves\.game_id, moves\.x, moves\.y/;
         die $_
      };
   }

   method render_game($game) {

   }

};

1;
