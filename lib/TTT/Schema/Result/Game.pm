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

my %move_map = (
   '00' => 0,
   '01' => 2,
   '02' => 4,

   '10' => 12,
   '11' => 14,
   '12' => 16,

   '20' => 24,
   '21' => 28,
   '22' => 30,
);

sub as_string ($self) {
   my $template =
      " | | \n" .
      "-----\n" .
      " | | \n" .
      "-----\n" .
      " | | \n";

   for ($self->moves->all) {
      substr $template, $move_map{$_->x . $_->y}, 1, $_->player ? 'O' : 'X'
   }

   return $template
}

1;
