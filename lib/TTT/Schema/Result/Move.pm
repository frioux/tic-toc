package TTT::Schema::Result::Move;

use TTT::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column game_id => { data_type => 'int' };

column x       => { data_type => 'int' };

column y       => { data_type => 'int' };

column player  => { data_type => 'boolean' };

column timestamp => {
   data_type => 'timestamp',
   set_on_create => 1,
};

belongs_to game => '::Game', 'game_id';

unique_constraint [qw( game_id x y )];

1;
