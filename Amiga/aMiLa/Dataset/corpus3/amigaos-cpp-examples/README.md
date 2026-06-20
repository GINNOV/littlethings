# AmigaOS CPP Examples

C++ examples for AmigaOS/MorphOS (system programming, no hardware code).

## Sections

[dos.library](/dos)

## Compilation:

### Linux cross compilation for AmigaOS3 68k

requirments:
- [bebbo/amiga-gcc](https://github.com/bebbo/amiga-gcc)

each example compilation steps:
```
m68k-amigaos-g++ -std=c++17 -noixemul -c example-file-name.cpp
m68k-amigaos-g++ example-file-name.o -lstdc++ -lamiga -noixemul -o example-file-name.bin
```

### MorphOS compilation

requirments:
- [MorphOS SDK](https://www.morphos-team.net/downloads)

each example compilation steps:
```
g++ -std=c++17 -noixemul -c example-file-name.cpp
g++ -noixemul example-file-name.o -lstdc++ -o example-file-name.bin
```
