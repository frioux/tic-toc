package TTT::Schema::Result::Game;

use TTT::Schema::Candy;

use experimental 'signatures';

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

sub has_winner ($self) {
   $self->moves->xs->winner || $self->moves->os->winner
}
sub cat ($self) { $self->moves->count == 9 }

sub winner ($self) {
   return 1 if $self->moves->xs->winner;
   return 0 if $self->moves->os->winner;
   die "no winner!"
}

1;
