
### Class GateAOS4: Create a AmigaOS gatestub file ############################

BEGIN {
    package GateAOS4;
    use vars qw(@ISA);
    @ISA = qw( Gate );

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
      
      $self->SUPER::header (@_);

      print "#undef __USE_INLINE__\n";
      print "#define _NO_INLINE\n";
      print "#define __NOLIBBASE__\n";
      print "#define __NOGLOBALIFACE__\n";
      print "#include <proto/$sfd->{basename}.h>\n";
      print "#undef _NO_INLINE\n";
      print "#undef __NOLIBBASE__\n";
      print "#undef __NOGLOBALIFACE__\n";
      print "#include <stdarg.h>\n";
      print "#include <interfaces/exec.h>\n";
      print "#include <exec/emulation.h>\n";
      print "\n";
    }

    sub function {
      my $self     = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($prototype->{type} eq 'function' ||
          $prototype->{type} eq 'varargs' ) {
          $self->function_proto (prototype => $prototype);
          $self->function_start (prototype => $prototype);
          for my $i (0 .. $$prototype{'numargs'} - 1 ) {
            $self->function_arg (prototype => $prototype,
                             argtype   => $$prototype{'argtypes'}[$i],
                             argname   => $$prototype{'___argnames'}[$i],
                             argreg    => $$prototype{'regs'}[$i],
                             argnum    => $i );
          }
          $self->function_end (prototype => $prototype);
          
          print "\n";

          if ($prototype->{type} eq 'function' && $prototype->{bias} != 0) {
            if (!$self->{PROTO}) {
                $self->emu_function_start (prototype => $prototype);
                for my $i (0 .. $$prototype{'numargs'} - 1 ) {
                  $self->emu_function_arg (prototype => $prototype,
                                     argtype   => $$prototype{'argtypes'}[$i],
                                     argname   => $$prototype{'___argnames'}[$i],
                                     argreg    => $$prototype{'regs'}[$i],
                                     argnum    => $i );
                }
                $self->emu_function_end (prototype => $prototype);
            }

            $self->emu_trap (prototype => $prototype);
          }
      }
    }
    
    sub function_start {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      print "$prototype->{return}";
      if ($prototype->{type} eq 'varargs') {
          print " VARARGS68K";
      }
      print "\n";
      print "$gateprefix$prototype->{funcname}(";
      if ($prototype->{type} eq 'function' &&
          $prototype->{subtype} =~ /^(library|device|boopsi)$/) {
          # Special function prototype

          if ($prototype->{bias} == 0) {
            # Do nothing
          }
          elsif ($prototype->{subtype} eq 'library' ||
               $prototype->{subtype} eq 'boopsi') {
            print "struct LibraryManagerInterface* _iface";
          }
          elsif( $prototype->{subtype} eq 'device') {
            print "struct DeviceManagerInterface* _iface";
          }
      }
      else {
          print "struct $sfd->{BaseName}IFace* _iface";
      }
    }

    sub function_arg {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $argtype   = $params{'argtype'};
      my $argname   = $params{'argname'};
      my $argreg    = $params{'argreg'};
      my $argnum    = $params{'argnum'};
      my $sfd       = $self->{SFD};

      if ($prototype->{subtype} ne 'tagcall' ||
          $argnum ne $prototype->{numargs} - 2) {

          if ($argnum != 0 || $prototype->{bias} != 0) {
            print ",\n";
          }

          if ($prototype->{subtype} =~ /^(library|device|boopsi)$/ &&
            $prototype->{bias} == 0 &&
            $argnum == $prototype->{numargs} - 1 ) {
            print "     struct ExecIFace* _iface";
          }
          else {
            print "     $prototype->{___args}[$argnum]";
          }
      }
    }
    
    sub function_end {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($self->{PROTO}) {
          print ");\n";
      }
      else {
          print ")\n";
          print "{\n";
          
          if ($prototype->{subtype} =~ /^(library|device|boopsi)$/ &&
            $prototype->{bias} == 0) {
            print "  $prototype->{___args}[$prototype->{numargs} - 1] = ".
                "($prototype->{argtypes}[$prototype->{numargs} - 1]) " .
                "_iface->Data.LibBase;\n";
          }
          
          if ($prototype->{type} ne 'varargs') {
            print "  return $libprefix$prototype->{funcname}(";

            if ($libarg eq 'first' && !$prototype->{nb}) {
                print "($sfd->{basetype}) _iface->Data.LibBase";
                print $prototype->{numargs} > 0 ? ", " : "";
            }

            print join (', ', @{$prototype->{___argnames}});

            if ($libarg eq 'last' && !$prototype->{nb}) {
                print $prototype->{numargs} > 0 ? ", " : "";
                print "($sfd->{basetype}) _iface->Data.LibBase";
            }
          }
          else {
            my $na;

            if ($prototype->{subtype} eq 'tagcall') {
                $na = $prototype->{numargs} - 3;
            }
            elsif ($prototype->{subtype} eq 'printfcall') {
                $na = $prototype->{numargs} - 2;
            }
            else {
                # methodcall: first vararg is removed
                $na = $prototype->{numargs} - 3;
            }
            
            print "  va_list _va;\n";
            print "  va_startlinear (_va, ";
            if ($na >= 0) {
                print "$prototype->{___argnames}[$na]);\n";
            }
            else {
                print "_iface);\n"
            }

            print "  return $libprefix$prototype->{real_funcname}(";

            if ($libarg eq 'first' && !$prototype->{nb}) {
                print "($sfd->{basetype}) _iface->Data.LibBase";
                print $prototype->{numargs} > 0 ? ", " : "";
            }

            for (my $i = 0; $i <= $na; ++$i) {
                print "@{$prototype->{___argnames}}[$i], ";
            }

            print "va_getlinearva (_va, " .
                "$prototype->{argtypes}[$prototype->{numargs}-1])";
            
            if ($libarg eq 'last' && !$prototype->{nb}) {
                print $prototype->{numargs} > 0 ? ", " : "";
                print "($sfd->{basetype}) _iface->Data.LibBase";
            }
          }
      
          print ");\n";
          print "}\n";
      }
    }


    sub emu_function_start {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      print "STATIC $prototype->{return} \n";
      print "$gateprefix$prototype->{funcname}PPC(ULONG *regarray)\n";
      print "{\n";
      print "  struct Library * _base = (struct Library *) regarray[REG68K_A6/4];\n";
      print "  struct ExtendedLibrary * ExtLib = (struct ExtendedLibrary *) ((ULONG) _base + _base->lib_PosSize);\n";
      
      if ($prototype->{subtype} =~ /^(library|device|boopsi)$/) {
          # Special function prototype

          if ($prototype->{bias} == 0) {
            # Do nothing
          }
          elsif ($prototype->{subtype} eq 'library' ||
               $prototype->{subtype} eq 'boopsi') {
            print "  struct LibraryManagerInterface* _iface = ";
            print "ExtLib->ILibrary;\n";
          }
          elsif( $prototype->{subtype} eq 'device') {
            print "  struct DeviceManagerInterface* _iface = ";
            print "ExtLib->IDevice;\n";
          }
      }
      else {
          print "  struct $sfd->{BaseName}IFace* _iface = ";
          print "(struct $sfd->{BaseName}IFace*) ExtLib->MainIFace;\n";
      }
    }

    sub emu_function_arg {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $argtype   = $params{'argtype'};
      my $argname   = $params{'argname'};
      my $argreg    = $params{'argreg'};
      my $argnum    = $params{'argnum'};
      my $sfd       = $self->{SFD};

      print "  $prototype->{___args}[$argnum] = ($argtype) regarray[REG68K_" .
          (uc $argreg) . "/4];\n";
    }
    
    sub emu_function_end {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      print "\n";

      my $funcname = $prototype->{funcname};
      
      if ($prototype->{subtype} eq 'library' ||
          $prototype->{subtype} eq 'device' ||
          $prototype->{subtype} eq 'boopsi') {

          if ($prototype->{bias} == 6) {
            $funcname = "Open";
          }
          elsif ($prototype->{bias} == 12) {
            $funcname = "Close";
          }
          elsif ($prototype->{bias} == 18 ||
               $prototype->{bias} == 24) {
            print "  return 0;\n";
            print "}\n";
            print "\n";
            return;
          }

          if ($prototype->{subtype} eq 'device') {
            if ($prototype->{bias} == 30) {
                $funcname = "BeginIO";
            }
            elsif ($prototype->{bias} == 36) {
                $funcname = "AbortIO";
            }
          }
      }
      
      print "  return _iface->$funcname(";
      print join (', ', @{$prototype->{___argnames}});

      if ($prototype->{subtype} eq 'device' && ($prototype->{bias} == 36)) {
          print "), 0;  /* Return type changed to VOID in OS4?! */\n";
      }
      else {
          print ");\n";
      }
      print "}\n";
      print "\n";
    }
    
    sub emu_trap {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($self->{PROTO}) {
          print "extern ";
      }

      print "CONST struct EmuTrap m68k$gateprefix$prototype->{funcname}";

      if (!$self->{PROTO}) {
          print " = { TRAPINST, TRAPTYPE, (ULONG (*)(ULONG *)) $gateprefix$prototype->{funcname}PPC }";
      }
      
      print ";\n";
      print "\n";
    }
}
