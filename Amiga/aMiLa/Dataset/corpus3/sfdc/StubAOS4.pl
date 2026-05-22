
### Class StubAOS4: Create an AOS4 stub file ####################################

BEGIN {
    package StubAOS4;
    use vars qw(@ISA);
    @ISA = qw( Stub );

    sub new {
      my $proto  = shift;
      my $class  = ref($proto) || $proto;
      my $self   = $class->SUPER::new( @_ );
      bless ($self, $class);
      return $self;
    }

    sub header {
      my $self = shift;
      my $sfd       = $self->{SFD};

      # Ugly, but it works

      print "/* Interface base override */\n";
      print "\n";
      print "#ifndef BASE_EXT_DECL\n";
      print "#define BASE_EXT_DECL\n";
      print "#define BASE_EXT_DECL0 extern struct $sfd->{BaseName}IFace * I$sfd->{BaseName};\n";
      print "#endif /* !BASE_EXT_DECL */\n";
      print "#ifndef BASE_NAME\n";
      print "#define BASE_NAME I$sfd->{BaseName}\n";
      print "#endif /* !BASE_NAME */\n";
      print "\n";
      
      $self->SUPER::header (@_);

      print "#include <interfaces/$sfd->{basename}.h>\n";
      print "#include <stdarg.h>\n";
      print "\n";
    }

    sub function_proto {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};

      if ($prototype->{type} eq 'varargs') {

          if ($prototype->{subtype} ne 'tagcall') {
            # We have to add the attribute to ourself first
          
            $self->special_function_proto (@_);
            print " __attribute__((linearvarargs));\n";
            print "\n";
            $self->special_function_proto (@_);
          }
      }
      else {
          $self->SUPER::function_proto (@_);
      }
    }

    sub function_start {
      my $self      = shift;
      my %params    = @_;
      my $prototype = $params{'prototype'};
      my $sfd       = $self->{SFD};

      if ($prototype->{type} eq 'function') {
          print "\n";
          print "{\n";

          if (!$prototype->{nb}) {
            print "  BASE_EXT_DECL\n";
          }

          if (!$prototype->{nr}) {
            print "  $prototype->{return} _res = ($prototype->{return}) ";
          }
          else {
            print "  ";
          }

          printf "BASE_NAME->$prototype->{funcname}(";
      }
      elsif ($prototype->{type} eq 'varargs') {
          if ($prototype->{subtype} ne 'tagcall') {
            my $na;

            if ($prototype->{subtype} eq 'printfcall') {
                $na = $prototype->{numargs} - 2;
            }
            else {
                # methodcall: first vararg is removed
                $na = $prototype->{numargs} - 3;
            }
            
            print "\n";
            print "{\n";
            print "  va_list _va;\n";
            print "  va_startlinear (_va, $prototype->{___argnames}[$na]);\n";
            print "  return $$prototype{'real_funcname'}(BASE_PAR_NAME ";
          }
          else {
            # Shamelessly stolen from fd2inline ...
            
            # number of regs that contain varargs
            my $n = 9 - $prototype->{numregs};

            # add 4 bytes if that's an odd number, to avoid splitting a tag
            my $d = $n & 1 ? 4 : 0;

            # offset of the start of the taglist
            my $taglist = 8;

            # size of the stack frame
            my $local = ($taglist + $n * 4 + $d + 8 + 15) & ~15;

            #  Stack frame:
            #
            #   0 -  3: next frame ptr
            #   4 -  7: save lr
            #   8 -  8+n*4+d+8-1: tag list start
            #   ? - local-1: padding

            print  "__asm(\"\\n\\\n";
            print  "    .align      2\\n\\\n";
            print  "    .globl      $prototype->{funcname}\\n\\\n";
            print  "    .type $prototype->{funcname},\@function\\n\\\n";
            print  "$prototype->{funcname}:\\n\\\n";
            print  "    stwu  1,-$local(1)\\n\\\n";
            print  "    mflr  0\\n\\\n";
            printf "    stw   0,%d(1)\\n\\\n", $local + 4;

            # If n is odd, one tag is split between regs and stack.
            # Copy its ti_Data together with the ti_Tag.
          
            if ($d != 0) {
                # read ti_Data
                printf "      lwz   0,%d(1)\\n\\\n", $local + 8;
            }

            # Save the registers
          
            for my $count ($prototype->{numregs} .. 8) {
                printf "      stw   %d,%d(1)\\n\\\n",
                $count + 2,
                ($count - $prototype->{numregs}) * 4 + $taglist;
            }

            if ($d != 0) {
                # write ti_Data
                printf "      stw   0,%d(1)\\n\\\n", $taglist + $n * 4;
            }

            # Add TAG_MORE

            print  "    li    11,2\\n\\\n";
            printf "    addi  0,1,%d\\n\\\n", $local + 8 + $d;
            printf "    stw   11,%d(1)\\n\\\n", $taglist + $n * 4 + $d;
            printf "    stw   0,%d(1)\\n\\\n", $taglist + $n * 4 + $d + 4;

            # vararg_reg = &saved regs
          
            printf "    addi  %d,1,%d\\n\\\n",
            $prototype->{numregs} + 2, $taglist;
            print "     bl    $prototype->{real_funcname}\\n\\\n";
          }
      }
      else {
          $self->SUPER::function_start (@_);
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

      if ($$prototype{'type'} eq 'function') {
          print "$argname";
          print ", " unless $argnum == $prototype->{numargs} - 1;
      }
      elsif ($prototype->{type} eq 'varargs') {
          if ($prototype->{subtype} eq 'tagcall') {
          }
          elsif ($prototype->{subtype} eq 'methodcall' &&
               $argnum == $prototype->{numargs} - 2) {
            # Nuke it!
          }
          elsif ($argnum == $prototype->{numargs} - 1) {
            my $vt  = $$prototype{'argtypes'}[$$prototype{'numargs'} - 1];
            print ", va_getlinearva(_va, $vt)";
          }
          else {
            $self->SUPER::function_arg (@_);
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
      
      if ($$prototype{'type'} eq 'function') {
          print ");\n";
          
          if (!$prototype->{nr}) {
            print "  return _res;\n";
          }
    
          print "};\n";
      }
      elsif ($prototype->{type} eq 'varargs') {
          if ($prototype->{subtype} eq 'tagcall') {
            # number of regs that contain varargs
            my $n = 9 - $prototype->{numregs};

            # add 4 bytes if that's an odd number, to avoid splitting a tag
            my $d = $n & 1 ? 4 : 0;

            # offset of the start of the taglist
            my $taglist = 8;

            # size of the stack frame
            my $local = ($taglist + $n * 4 + $d + 8 + 15) & ~15;

            # clear stack frame & return
            printf "    lwz   0,%d(1)\\n\\\n", $local + 4;
            print  "    mtlr  0\\n\\\n";
            printf "    addi  1,1,%d\\n\\\n", $local;
            print  "    blr\\n\\\n";
            print  ".L$prototype->{funcname}e1:\\n\\\n";
            print  "    .size $prototype->{funcname}," .
                ".L$prototype->{funcname}e1-$prototype->{funcname}\\n\\\n";

            print "\");\n";
          }
          else {
            print ");\n";
            print "}\n";
          }
      }
      else {
          $self->SUPER::function_end (@_);
      }
    }


    sub special_function_proto {
      my $self     = shift;
      my %params   = @_;
      my $prototype    = $params{'prototype'};
      my $decl_regular = $params{'decl_regular'};
      my $sfd      = $self->{SFD};

      if ($prototype->{type} eq 'varargs' && $decl_regular) {
          my $rproto = $prototype->{real_prototype};

          print "$$rproto{'return'} $$rproto{'funcname'}(";
          if (!$prototype->{nb}) {
            if ($$rproto{'numargs'} == 0) {
                print "BASE_PAR_DECL0";
            }
            else {
                print "BASE_PAR_DECL ";
            }
          }
          print join (', ', @{$$rproto{'___args'}});

          print ");\n";
          print "\n";
      }
      
      print "$$prototype{'return'}\n";
      print "$$prototype{'funcname'}(";
      if (!$prototype->{nb}) {
          if ($$prototype{'numargs'} == 0) {
            print "BASE_PAR_DECL0";
          }
          else {
            print "BASE_PAR_DECL ";
          }
      }

      my @newargs;

      for my $i (0 .. $#{$prototype->{___args}}) {
          if ($prototype->{subtype} ne 'methodcall' ||
            $i != $prototype->{numargs} - 2 ) {
            push @newargs, $prototype->{___args}[$i];
          }
      }

      print join (', ', @newargs);
      print ")";
      
    }
}
