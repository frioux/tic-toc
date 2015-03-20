package TTT::Schema;

use 5.20.1;

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
   default_resultset_class => '+TTT::Schema::ResultSet',
);

1;
