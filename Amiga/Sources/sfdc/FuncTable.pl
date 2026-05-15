
### Class FuncTable: Create a function table fragment #########################

BEGIN {
    package FuncTable;

    sub new {
      my $proto  = shift;
      my %params = @_;
      my $class  = ref($proto) || $proto;
      my $self   = {};
      $self->{SFD} = $params{'sfd'};
      bless ($self, $class);
      return $self;
    }

    sub header {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "/* Automatically generated function table (sfdc SFDC_VERSION)! Do not edit! */\n";
      print "\n";
      print "#ifdef __SFDC_FUNCTABLE_M68K__\n";
      print "# define _sfdc_func(f) &m68k ## f\n";
      print "#else\n";
      print "# define _sfdc_func(f) f\n";
      print "#endif\n";
    }

    sub function {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};

      if ($prototype->{bias} == 0) {
          return;
      }

      if ($prototype->{type} eq 'function' ||
          $prototype->{type} eq 'cfunction') {
          print "  (CONST_APTR) _sfdc_func($gateprefix$prototype->{funcname}),\n";
      }
    }
    
    sub footer {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "#undef _sfdc_func\n";
      print "\n";
    }
}
