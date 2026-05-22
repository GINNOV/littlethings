
        NGDis v0.32 - a disassembler for TLCS900H and NeoGeo Pocket
                  (c) 2001 Jouni 'Mr.Spiv' Korhonen


What?
        NGDis is a simple command line based disassembler for the
        TLCS900H CPU, which is used for example in NeoGeo Pocket (NGP)
        handheld gaming machine. NGDis has some limited knowledge
        about NGP's internals such as the structure of the NGP cart
        rom header.

Why?
        So far I have not found any decent free crossplatform
        disassembler for NGP or TLCS900H -> write your own.

        I needed to do something :)

How?
        If you are familiar with Rossi Monitor which was a popular
        monitor for Amiga then you will find NGDis very similar in
        spirit and usage.

        NGDis has a couple of command line options:

        <!-- begin example --!>

        korhojo3:~/src/c/ngdis>./ngd
        Usage: ./ngd [-<options>] rom-file
        Options:
          -l n        List n lines
          -b address  ROM base address in hex
          -s n        Add n bytes of empty space
          -S address  Start address for dump disassembly
          -E address  End address for dump disassembly

        <!-- end example --!>

        -l will define the number of lines that are displayed during
           disassembly or memory dump. Default is 20 lines.

        -b sets the base address for loaded rom-file. If NGDis detects
           that the rom is actually a valid NGP cart rom then the
           base address will become 0x200000. You can override system
           default with this option though. If NGDis does not
           recognise the rom then the default base address is
           0x000000.

        -s defines how much extra space is added at the end of loaded
           rom-file. This is useful when, for example, patching
           existing roms and you need to write your own code at the
           end of rom. NGDis does not allow accessing memory areas
           autside the loaded rom-file. The default is 0.

        -S and -E are used in so called dump mode. The dump mode
           allows you to disassemble the entire rom at once. For
           example if you want to disassemle 4KB of NGP's bios
           starting from 0xff1000 then use options like:
           ./ngd -b ff0000 -S ff1000 -E ff2000 bios.ngp > bios.asm

           -S defaults to the start of the rom-file (i.e. base address)
           and -E defaults to the end of  the rom-file.


        At the moment NGDis has few usable command during the
        interactive usage. An example:

        <!-- begin example --!>

        korhojo3:~/src/c/ngdis>./ngd.exe -b ff0000 bios.ngp

        NEOGEO Pocket aware TLCS900H Disassembler v0.32
             (c) 2001 Jouni 'Mr.Spiv' Korhonen

        Loaded 65536 (10000H) bytes. Extra space is 0 bytes.

        -> h

        Quick Command Reference

        <CRLF>             -> repeat some previous commands without parameters
        : address bytes .. -> poke bytes into memory
        D                  -> disasseble starting from previous address
        d [address]        -> disasseble starting from address
        h                  -> print short command manual
        help               -> print short command manual
        m [address]        -> dump memory starting from address
        rom                -> print NGP rom info
        w name start end   -> save rom between start and end
        x                  -> exit
        ->

        <!-- end example --!>

        : pokes bytes/shorts/longs into the rom. like:
           -> : ff0010 22 _22 1af 123d5 

          would write following bytes starting from 0xff0010:
          0x22 0x16 0x01 0xaf 0x00 0x01 0x23 0xd5

          Note if the number starts with an underscore then NGDis
          handles it as a decimal. This rule applies to all numbers
          and addresses.

        d disassembles nn lines of code starting from address. If you
          leave the address out the disassembly continues from where the
          disassembly stopped last time.

        D re-disassembles the previous disassembly.

        m dumps nn lines of memory in hexadecimals and in ascii
          formats. If you leave the address out the the dump continues
          from where the dump stopped last time.

        <CRLF> if you press enter/return after 'd' and 'm' commands
          it is handled as 'd' and 'm' commands without the address
          field.

        h and help displays a short help page.

        rom displays the rom-file information. If the rom-file is a
          NGP cart rom then the header structure information get
          displayed.

        x exits the NGDis.

        w writes rom data between start and end addresses to a file
          named 'name'.

Contact:
        jouni.korhonen@sonera.inet.fi

ToDo:
        Search command.

Copyright & Distribution:
        NGDis is freeware! You go and do what ever you want with these
        sources. If you use them for your own projects, please, give
        me a credit.

        If you happen to e.g. add new commands, please, support the
        NGP scene and send them to me and other developers.

History:
        v0.32 - First public beta.
















