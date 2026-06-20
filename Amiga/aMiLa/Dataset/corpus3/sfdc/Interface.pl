
### Class Interface: Create a struct with function pointers ###################

BEGIN {
    package Interface;

    sub new {
      my $proto  = shift;
      my %params = @_;
      my $class  = ref($proto) || $proto;
      my $self   = {};
      $self->{SFD} = $params{'sfd'};
      $self->{BIAS} = -1;
      $self->{PADCNT} = 1;
      bless ($self, $class);
      return $self;
    }

    sub header {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "/* Automatically generated function table (sfdc SFDC_VERSION)! Do not edit! */\n";
      print "\n";
      print "#ifndef $sfd->{'BASENAME'}_INTERFACE_DEF_H\n";
      print "#define $sfd->{'BASENAME'}_INTERFACE_DEF_H\n";
      print "\n";

      foreach my $inc (@{$$sfd{'includes'}}) {
          print "#include $inc\n";
      }

      foreach my $td (@{$$sfd{'typedefs'}}) {
          print "typedef $td;\n";
      }

      print "\n";
      $self->define_interface_data();
      print "\n";

      print "struct $sfd->{BaseName}IFace\n";
      print "{\n";

      $self->output_prelude();
    }

    sub function {
      my $self      = shift;
      my $sfd       = $self->{SFD};
      my %params    = @_;
      my $prototype = $params{'prototype'};

      if ($self->{BIAS} == -1) {
          $self->{BIAS} = $prototype->{bias} - 6;
      }

      while ($self->{BIAS} < ($prototype->{bias} - 6)) {
          print "  APTR Pad$self->{PADCNT};\n";
          $self->{BIAS} += 6;
          ++$self->{PADCNT};
      }

      $self->{BIAS} = $prototype->{bias};

      $self->output_function(@_);
    }
    
    sub footer {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "};\n";
      print "\n";
      print "#endif /* $sfd->{'BASENAME'}_INTERFACE_DEF_H */\n";
    }


    # Helper functions
    
    sub define_interface_data {
      my $self     = shift;
      my $sfd      = $self->{SFD};

      print "struct $sfd->{BaseName}InterfaceData {\n";
      print "  $sfd->{basetype} LibBase;\n";
      print "};\n";
    }


    sub output_prelude {
      my $self     = shift;
      my $sfd      = $self->{SFD};

      print "  struct $sfd->{BaseName}InterfaceData Data;\n";
      print "\n";
      print "  static struct $sfd->{BaseName}IFace* CreateIFace($sfd->{basetype} _$sfd->{base}) {\n";
      print "    struct $sfd->{BaseName}IFace* _iface = new struct $sfd->{BaseName}IFace();\n";
      print "    _iface->Data.LibBase = _$sfd->{base};\n";
      print "    return _iface;\n";
      print "  }\n";
      print "\n";
      print "  static void DestroyIFace(struct $sfd->{BaseName}IFace* _iface) {\n";
      print "    delete _iface;\n";
      print "  }\n";
      print "\n";
    }

    sub output_function {
      my $self     = shift;
      my $sfd      = $self->{SFD};
      my %params    = @_;
      my $prototype = $params{'prototype'};

      print "  $prototype->{return} ";
      print "$prototype->{funcname}(";
      print join (', ', @{$prototype->{args}});
      print ");\n";
    }
}
