/* test.rexx */

if ~Show('L','arexx_asl.library')

then do
        say 'adding arexx_asl.library' 
        call AddLib('arexx_asl.library',0,-30,0)
     end

filename$=SelectFile()
say filename$


