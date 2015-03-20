package TTT::Schema::Result::Game;

use TTT::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

has_many moves => '::Move', 'game_id';

sub last_player {
   shift->moves->search(undef, {
      # assumes that the id always increments
      order_by => { -desc => 'id' },
      rows => 1,
   })->get_column('player')->single
}

1;
