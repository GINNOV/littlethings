
### Class Macro68k: Implements m68k-only features for macro files #############

BEGIN {
    package Macro68k;
    use vars qw(@ISA);
    @ISA = qw( MacroLP );

    sub new {
      my $proto  = shift;
      my $class  = ref($proto) || $proto;
      my $self   = $class->SUPER::new( @_ );
      bless ($self, $class);
      return $self;
    }

    sub function_start {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($$prototype{'type'} eq 'function') {

          my $regs      = join(',', @{$$prototype{'regs'}});
          my $argtypes  = join(',', @{$$prototype{'argtypes'}});
          my $a4        = $regs =~ /a4/;
          my $a5        = $regs =~ /a5/;
          my $fp        = $argtypes =~ /\(\*+\)/;
      my $return    = $$prototype{'return'};
      my $numfp     = 0;

          if ($a4 && $a5 && !$quiet) {
            print STDERR "$$prototype{'funcname'} uses both a4 and a5 " .
                "for arguments. This is not going to work.\n";
          }
      
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
          
          printf "      LP%d%s%s%s%s%s%s%s(0x%x, ", $$prototype{'numargs'},
          $prototype->{nr} ? "NR" : "",
          $prototype->{nb} ? "NB" : "",
          $a4 ? "A4" : "", $a5 ? "A5" : "",
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
        print ", $argtype, $argname, $argreg";
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
          
          print ")\n";
      }
      else {
          $self->SUPER::function_end (@_);
      }
    }
}
