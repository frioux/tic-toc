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
         my $last_player = $game->last_player // 1;
         my $current_player = 0+!$last_player;

         $self->schema->txn_do(sub {

            return $self->_forbidden('game already won')
               if $game->has_winner;

            return $self->_forbidden('game already over')
               if $game->cat;

            $game->add_to_moves({
               x => $x,
               y => $y,
               player => $current_player,
            });

         });

         return $self->_basic($self->_render_player($current_player) . ' won!')
            if $game->has_winner;

         return $self->_basic('good move!')
      } catch {
         return $self->_forbidden('that move is already taken')
            if m/UNIQUE constraint failed: moves\.game_id, moves\.x, moves\.y/;
         die $_
      };
   }

   method render_game($game) {

   }

   method _render_player($player) { $player ? 'X' : 'O' }

   method _forbidden($msg) { [ 403, [ content_type => 'text/plain' ], [$msg]] }

   method _basic($msg) { [ 200, [ content_type => 'text/plain' ], [$msg]] }

};

1;
