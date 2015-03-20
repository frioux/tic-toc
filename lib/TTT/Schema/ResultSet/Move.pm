package TTT::Schema::ResultSet::Move;

use 5.20.1;
use warnings;

use base 'TTT::Schema::ResultSet';

use experimental 'signatures';

sub xs ($self) { $self->search({ $self->me . 'player' => 1 }) }
sub os ($self) { $self->search({ $self->me . 'player' => 0 }) }

# None of the following make sense outside of the context of a game

sub vertical ($self) {
   $self->search(undef, {
      group_by => [$self->me . 'x'],
      columns => [
         'x',
         { count => '*' },
      ],
      having => \'COUNT(*) = 3',
   })->count
}

sub horizontal ($self) {
   $self->search(undef, {
      group_by => [$self->me . 'y'],
      columns => [
         'y',
         { count => '*' },
      ],
      having => \'COUNT(*) = 3',
   })->count
}

sub diagonal_descending ($self) {
   $self->search({
      $self->me . x => { -ident => $self->me . 'y' }
   })->count == 3
}

sub diagonal_ascending ($self) {
   # the following SHOULD work, but I think SQLite is confused?
   # $self->search({
   #    $self->me . y => \'-x + 2'
   # })->count == 3

   $self->search([{
      x => 0,
      y => 2,
   }, {
      x => 1,
      y => 1,
   }, {
      x => 2,
      y => 0,
   }])->count == 3;
}

sub winner ($self) {
   $self->horizontal          ||
   $self->vertical            ||
   $self->diagonal_descending ||
   $self->diagonal_ascending
}

1;
