
### Class Interface: Create a struct with function pointers ###################

BEGIN {
    package InterfaceAOS4;
    use vars qw(@ISA);
    @ISA = qw( Interface );

    sub new {
      my $proto  = shift;
      my $class  = ref($proto) || $proto;
      my $self   = $class->SUPER::new( @_ );
      bless ($self, $class);
      return $self;
    }

    # Helper functions
    
    sub define_interface_data {
      my $self     = shift;
      my $sfd      = $self->{SFD};

      print "#include <exec/interfaces.h>\n";
    }


    sub output_prelude {
      my $self     = shift;
      my $sfd      = $self->{SFD};

      print "  struct InterfaceData Data;\n";
      print "\n";
      print "#ifdef __cplusplus\n";
      print "  static struct $sfd->{BaseName}IFace* CreateIFace($sfd->{basetype} _$sfd->{base}) {\n";
      print "    return (struct $sfd->{BaseName}IFace*) GetInterface((struct Library*) _$sfd->{base}, \"main\", 1, NULL);\n";
      print "  }\n";
      print "\n";
      print "  static void DestroyIFace(struct $sfd->{BaseName}IFace* _iface) {\n";
      print "      DropInterface((struct Interface*) _iface);\n";
      print "  }\n";
      print "#endif\n";
      print "\n";
      print "  ULONG APICALL (*Obtain)(struct $sfd->{BaseName}IFace *Self);\n";
      print "  ULONG APICALL (*Release)(struct $sfd->{BaseName}IFace *Self);\n";
      print "  void APICALL (*Expunge)(struct $sfd->{BaseName}IFace *Self);\n";
      print "  struct Interface * APICALL (*Clone)(struct $sfd->{BaseName}IFace *Self);\n";
    }

    sub output_function {
      my $self     = shift;
      my $sfd      = $self->{SFD};
      my %params    = @_;
      my $prototype = $params{'prototype'};

      print "  $prototype->{return} APICALL ";
      print "(*$prototype->{funcname})(struct $sfd->{BaseName}IFace* Self";

      if ($prototype->{type} eq 'varargs' &&
          ($prototype->{subtype} eq 'tagcall' ||
           $prototype->{subtype} eq 'methodcall')) {
          # Nuke second last argument (=first varargs argument) 
          # or it will be placed in a register!
          for my $i (0 .. $#{@{$prototype->{args}}}) {
            if ($i != $prototype->{numargs} - 2 ) {
                print ", $prototype->{args}[$i]";
          }
      }
          
      }
      else {
          if ($prototype->{numargs} != 0) {
            print ", ";
          }
          print join (', ', @{$prototype->{args}});
      }
      print ");\n";
    }
}
