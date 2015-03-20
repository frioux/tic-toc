package TTT::Schema::Result::Game;

use TTT::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

has_many moves => '::Move', 'game_id';

1;
