
### Class MacroMOS: Implements MorphOS-only features for macro files ##########

BEGIN {
    package MacroMOS;
    use vars qw(@ISA);
    @ISA = qw (Macro68k);

    sub new {
      my $proto  = shift;
      my $class  = ref($proto) || $proto;
      my $self   = $class->SUPER::new( @_ );
      bless ($self, $class);
      return $self;
    }

    sub header {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "/* Automatically generated header (sfdc SFDC_VERSION)! Do not edit! */\n";
      print "\n";
      print "#ifndef _PPCINLINE_$$sfd{'BASENAME'}_H\n";
      print "#define _PPCINLINE_$$sfd{'BASENAME'}_H\n";
      print "\n";
      print "#ifndef _SFDC_VARARG_DEFINED\n";
      print "#define _SFDC_VARARG_DEFINED\n";
      print "#ifdef __HAVE_IPTR_ATTR__\n";
      print "typedef APTR _sfdc_vararg __attribute__((iptr));\n";
      print "#else\n";
      print "typedef ULONG _sfdc_vararg;\n";
      print "#endif /* __HAVE_IPTR_ATTR__ */\n";
      print "#endif /* _SFDC_VARARG_DEFINED */\n";
      print "\n";
 
      print "#ifndef __PPCINLINE_MACROS_H\n";
      print "#include <ppcinline/macros.h>\n";
      print "#endif /* !__PPCINLINE_MACROS_H */\n";
      print "\n";

      if ($$sfd{'base'} ne '') {
          print "#ifndef $self->{BASE}\n";
          print "#define $self->{BASE} $$sfd{'base'}\n";
          print "#endif /* !$self->{BASE} */\n";
          print "\n";
      }
    }

    sub footer {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "#endif /* !_PPCINLINE_$$sfd{'BASENAME'}_H */\n";
    }

    sub function_start {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($$prototype{'type'} eq 'function') {

          my $regs      = join(',', @{$$prototype{'regs'}});
          my $argtypes  = join(',', @{$$prototype{'argtypes'}});
          my $fp        = $argtypes =~ /\(\*+\)/;
      my $return    = $$prototype{'return'};
      my $numfp     = 0;

      @{$self->{FUNCARGTYPE}} = ();
          for my $argtype (@{$$prototype{'argtypes'}}) {
            if ($argtype =~ /\(\*+\)/) {
                @{$self->{FUNCARGTYPE}}[$numfp] = $argtype;
        $numfp++;
            }
          }

      $self->{FUNCRETTYPE} = '';
      if($return =~ /\(\*+\)/)
      {
        $self->{FUNCRETTYPE} = $return;
      }
          
          printf "      LP%d%s%s%s%s%s(0x%x, ", $$prototype{'numargs'},
          $prototype->{nr} ? "NR" : "",
          $prototype->{nb} ? "NB" : "",
          scalar @{$self->{FUNCARGTYPE}} > 0 ? "FP" : "",
          scalar @{$self->{FUNCARGTYPE}} > 1 ? scalar @{$self->{FUNCARGTYPE}} : "",
      $self->{FUNCRETTYPE} ne '' ? "FR" : "",
          $$prototype{'bias'};

      if ($self->{FUNCRETTYPE})
      {
        print "__fpr, "; 
      }
          elsif (!$prototype->{nr}) {
            print "$$prototype{'return'}, ";
          }

          print "$$prototype{'funcname'} ";
      }
      else {
          $self->SUPER::function_start (@_);
      }
    }

    sub function_arg {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};

      if ($$prototype{'type'} eq 'function') {
          my $argtype   = $params{'argtype'};
          my $argname   = $params{'argname'};
          my $argreg    = $params{'argreg'};
      my $fpidx     = 0;
      my $fpfound   = 0;
          
          if ($argreg eq 'a4' || $argreg eq 'a5') {
            $argreg = 'd7';
          }
          
      for my $atype (@{$self->{FUNCARGTYPE}}) {
        $fpidx++;
        if ($atype eq $argtype) {
          printf ", __fpt%s, %s, %s",
            scalar @{$self->{FUNCARGTYPE}} > 1 ? $fpidx : "",
            $argname, $argreg;
          $fpfound = 1;
          last;
                }
      }

          if($fpfound eq 0) {
        if($argtype eq "va_list") {
          print ", long *, $argname, $argreg";
        } else {
          print ", $argtype, $argname, $argreg";
        }
          }
      }
        else {
          $self->SUPER::function_arg (@_);
      }
    }


    sub function_end {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};
  my $fpidx     = 0;

      if ($$prototype{'type'} eq 'function') {
          if (!$prototype->{nb}) {
            print ",\\\n      , $self->{BASE}";
          }

      for my $fa (@{$self->{FUNCARGTYPE}}) {
        $fpidx++;
        if(scalar @{$self->{FUNCARGTYPE}} gt 1) {
                  $fa =~ s/\((\*+)\)/($1__fpt$fpidx)/;
        }
        else {
                  $fa =~ s/\((\*+)\)/($1__fpt)/;
        }
                print ", $fa";
      }

      if ($self->{FUNCRETTYPE} ne '')
      {
        my $fr = $self->{FUNCRETTYPE};

        $fr =~ s/\((\*+)\)/($1__fpr)/;

        print ", $fr";
      }
          
          print ", 0, 0, 0, 0, 0, 0)\n";
      }
      else {
          $self->SUPER::function_end (@_);
      }
    }
}
