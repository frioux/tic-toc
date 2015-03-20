package TTT::Schema::Result;

use 5.20.1;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw(
   TimeStamp
   Helper::Row::RelationshipDWIM
));

sub default_result_namespace { 'TTT::Schema::Result' }

1;
