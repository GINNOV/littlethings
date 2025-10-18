# ADFinder

I found myself wanting to work on an ADF image in the same way modern computers allow to manage files. 

macOS spoils users with the easy going user interface and I didn't find any tool out there that would offer the rich experience and being compatible with the need of an amiga engineer. But I did find a [fantastic library](https://github.com/adflib/ADFlib) that would enable me to get the job done.

So I start building it. Details and pre-built app are [here](https://ginnov.github.io/littlethings/)

## Features List

1.	✅ Load ADFs that workbench can read
2.	✅ Show the content of files in a HEX editor
3.	✅ Navigate folder structure back and forth
4.	✅ Delete files and folder
5.	✅ Create an ADF from scratch
6.	✅ Open ADF images by dropping the image over the files’ window
7.	✅ Show disk layout, file usage and other stats
8.	✅ Create new folders
9.	✅ Rename files and folders
10.	✅ Sorting (different kinds)
11.	✅ Preferences
12.	✅ Create blank images for FSO/FFS
13. ✅ Add files to image
14. ✅ Set file permissions and attributes
15. ✅ Get Info of permissions and attributes
16. ✅ Text Editor built in for startup sequence galore!
17. ✅ Compare two ADFs by (Sector map / Block inspector)
18. ✅ Export files to macOS
19. ✅ Generate disk content report (dir and pemissions)
20. ✅ Generate HexDump of a disk
21.	✅ IFF Image viewer
22.	✅ IFF image converter	

## Work in Progress / Thinking about
the items below move up as they get done.

19.	👷🏻 Add files via Drag and Drop (lo pri)
21.	👷🏻 Auto convert audio when adding them to an image



## Users requests
* ✅ Change volume's name [[warpdesign](https://github.com/warpdesign)]


# What it looks like?
I took a bunch of screenshots, I don't always keep them up to date but [here](https://ginnov.github.io/littlethings/adfinder_learnmore.html) you'll find what's up now.

# Engineering tips
To make it easier on less terminal experienced coders I provided with the code the unmodified [ADFLib](https://github.com/adflib/ADFlib) library built only for Apple Silicon and Universal. However, if for some reason, you would like to use the source code, the repo doesn't provide instructions on how to build for macOS, I always write done what I figure out and [here](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/ADFinder/distribution/docs) you find the steps I took to build the library. I hope it helps.

I also put together a general architecture doc for how the app is structured to help others that want to to fork and dork around it. It's here (link to come)
