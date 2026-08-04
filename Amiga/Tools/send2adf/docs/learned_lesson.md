# Learned lessons

The early implementation established the lifecycle still used by `send2adf`:
initialize ADFlib, create and format a file-backed floppy device, mount the
device and volume, copy files and directories, then unmount and clean up in
reverse order. The important debugging result was that a newly formatted
device must be mounted before its volume is opened for file I/O.

Several early assumptions are no longer build guidance. ADFlib is not installed
into a system prefix, headers are not copied into the project, and developers do
not select an arbitrary upstream branch. Both consumers build the exact shared
manifest identity as a private static library. Architecture, source tree,
transport, patch, license inventory, and provenance are verified rather than
inferred from a successful link.

The modern runtime also treats output creation as a transaction. It validates
all inputs and boot-block selection, builds a temporary image, verifies it, and
only then replaces the requested destination. Failure leaves the prior output
unchanged.

## Historical boot-block experiment

The repository briefly carried `genboot.cpp`, a standalone macOS port of
Nameless Algorithm's Genboot v1.0 based on Andreas Fredriksson's trackloader
scripts. It was never referenced by the send2adf build or runtime and was
retired instead of becoming a second product. Its implementation and original
attribution links remain available in Git commit
`224515b72fe781a0e04818aa1bfc177af7311554` and its parents.
