
### Class AutoOpen: Create a proto file #######################################

BEGIN {
    package AutoOpen;

    sub new {
      my $proto    = shift;
      my %params   = @_;
      my $class    = ref($proto) || $proto;
      my $self     = {};
      $self->{SFD} = $params{'sfd'};
      bless ($self, $class);
      return $self;
    }

    sub header {
      my $self = shift;
      my $sfd  = $self->{SFD};

      print "/* Automatically generated header (sfdc SFDC_VERSION)! Do not edit! */\n";
      print "\n";
      if ($sfd->{base} ne '') {
          print "#ifdef __cplusplus\n";
          print "extern \"C\" {\n";
          print "#endif /* __cplusplus */\n";
          print "\n";
          print "#if defined (__libnix__)\n";
          print "\n";
          print "#include <stabs.h>\n";
          print "void* $sfd->{base}" . "[2] = { 0, \"$sfd->{libname}\" };\n";
          print "ADD2LIB($sfd->{base});\n";
          print "\n";
          print "#elif defined (__AMIGAOS4__)\n";
          print "\n";
          print "#undef __USE_INLINE__\n";
          print "#define _NO_INLINE\n";
          foreach my $inc (@{$$sfd{'includes'}}) {
            print "#include $inc\n";
          }
          
          foreach my $td (@{$$sfd{'typedefs'}}) {
            print "typedef $td;\n";
          }

          print "\n";
          print "#include <interfaces/$sfd->{basename}.h>\n";
          print "#include <proto/exec.h>\n";
          print "#include <assert.h>\n";
          print "\n";
          print "__attribute__((weak)) $sfd->{basetype} $sfd->{base} = NULL;\n";
          print "__attribute__((weak)) struct $sfd->{BaseName}IFace* I$sfd->{BaseName} = NULL;\n";
          print "\n";
          print "void __init_$sfd->{BaseName}(void) __attribute__((constructor));\n";
          print "void __exit_$sfd->{BaseName}(void) __attribute__((destructor));\n";
          print "\n";
          print "void __init_$sfd->{BaseName}(void) {\n";
          print "  if ($sfd->{base} == NULL) {\n";
          print "    $sfd->{base} = ($sfd->{basetype}) IExec->OpenLibrary(\"$sfd->{libname}\", 0);\n";
          print "    assert($sfd->{base} != NULL);\n";
          print "  }\n";
          print "  if (I$sfd->{BaseName} == NULL) {\n";
          print "    I$sfd->{BaseName} = (struct $sfd->{BaseName}IFace*) IExec->GetInterface(";
          print "(struct Library*) $sfd->{base}, \"main\", 1, NULL);\n";
          print "    assert(I$sfd->{BaseName} != NULL);\n";
          print "  }\n";
          print "}\n";
          print "\n";
          print "void __exit_$sfd->{BaseName}(void) {\n";
          print "  IExec->DropInterface((struct Interface*) I$sfd->{BaseName});\n";
          print "  IExec->CloseLibrary((struct Library*) $sfd->{base});\n";
          print "}\n";
          print "\n";
          print "\n";
          print "#endif\n";
      }

      
      print "\n";
      print "#ifdef __cplusplus\n";
      print "}\n";
      print "#endif /* __cplusplus */\n";
    }

    sub function {
      # Nothing to do here ...
    }

    sub footer {
      # Nothing to do here ...
    }
}
