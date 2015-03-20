package TTT::Schema::Candy;

use parent 'DBIx::Class::Candy';

sub base { 'TTT::Schema::Result' }
sub perl_version { 20 }
sub autotable { 1 }

1;

