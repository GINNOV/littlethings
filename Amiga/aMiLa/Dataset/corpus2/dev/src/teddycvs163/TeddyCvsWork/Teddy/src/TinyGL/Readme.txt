
This is quick hack to make TinyGL to work with SDL. I made very little
changes to the sourcecode. I added ZB_Update() which enables TinyGL to
directly render to SDL_Surface. I reformatted some parts of the source,
but if/when new TinyGL version comes, I probably won't do that again.
Some #include <> directives from .h files were moved to related .c
files to fix compilation problems when including .h from .cpp files.

New files are sdlswgl.c and  sdlswgl.h. I have not included the whole
original TinyGL distribution.


Original author of TinyGL:

Fabrice Bellard (bellard@email.enst.fr -
http://www-stud.enst.fr/~bellard).

Original TinyGL Homepage and distribution:

http://www.stud.enst.fr/~bellard/TinyGL.html


The SDL integration is very bad at the moment.
- Check SwapBuffers code
- Add reshaping windows 
- Add support more than one pixel mode 
- Improve code looks
- etc...

  -- Timo K. Suoranta -- tksuoran@cc.helsinki.fi --
