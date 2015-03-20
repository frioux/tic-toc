package TTT::Schema::ResultSet;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
   Helper::ResultSet::Me
));

1;
