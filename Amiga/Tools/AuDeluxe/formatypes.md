# Module formats supported by AuDeluxe

AuDeluxe discovers files by extension, then uses libopenmpt to validate, read, and play the module data. A matching extension does not guarantee that a damaged or unrelated file will load.

| Extension | Format | Example of use | Technical brief |
| --- | --- | --- | --- |
| `.mod` | ProTracker MOD and compatible variants | Music written in ProTracker for Amiga games and demos. | A sample-based pattern format descended from Ultimate SoundTracker. Classic files use four channels and 31 samples. Later variants add more channels and effects. |
| `.s3m` | Scream Tracker 3 Module | DOS demoscene music written in Scream Tracker 3. | A channel-based format with digital samples, optional AdLib instruments, channel panning, order lists, patterns, and S3M effect commands. |
| `.xm` | FastTracker 2 Extended Module | PC demo and game music written in FastTracker 2. | Extends the tracker model with instruments, sample maps, volume and panning envelopes, 16-bit samples, and linear or Amiga-style frequency slides. |
| `.it` | Impulse Tracker Module | DOS and Windows tracker music written in Impulse Tracker. | Supports up to 64 pattern channels, instruments, envelopes, compressed samples, filters, and New Note Actions for overlapping notes. |
| `.med` | OctaMED Module | Eight-channel and MIDI-assisted compositions made with OctaMED on the Amiga. | Covers the MMD family used by MED and OctaMED. Files can contain sampled instruments, synth definitions, multiple songs, and tracker-specific commands. |
| `.okt` | Oktalyzer Module | Amiga music written in Oktalyzer when more than four logical voices were needed. | An IFF-style chunked format. Oktalyzer combines Amiga hardware voices to provide as many as eight logical channels, with 8-bit samples and format-specific effects. |
| `.mtm` | MultiTracker Module | Multichannel DOS music written in MultiTracker. | Stores reusable tracks separately from the pattern order, with as many as 32 channels and 8-bit sample instruments. |
| `.669` | Composer 669 or UNIS 669 Module | Early DOS tracker music written with Composer 669 or UNIS 669. | Uses eight channels, 64-row patterns, embedded 8-bit samples, and per-pattern tempo and break positions. The `if` or `JN` signature identifies the main variants. |
| `.dsm` | DSIK or Dynamic Studio Module | Music shipped through the Digital Sound Interface Kit or authored in Dynamic Studio. | The extension covers related but distinct RIFF-like module layouts. They store orders, patterns, samples, and channel data in tagged chunks. libopenmpt identifies the variant from the file structure. |
| `.far` | Farandole Composer Module | DOS compositions made with Farandole Composer. | A 16-channel sample module with variable pattern breaks, per-channel panning, song text, and format-specific effects. |
| `.ptm` | PolyTracker Module | DOS tracker music made with PolyTracker. | A 32-channel sample format influenced by S3M. It has its own headers, pattern packing, effects, and sample metadata. |
| `.ult` | UltraTracker Module | Multichannel DOS music authored in UltraTracker. | Stores as many as 32 channels, sample instruments, pan positions, and run-length encoded pattern events. Several file revisions extend the instrument metadata. |
| `.amf` | DSMI Advanced Music Format or ASYLUM Music Format | AMF music used by DOS titles built with DSMI, including games distributed by Webfoot, or authored for ASYLUM. | The extension names more than one legacy format. DSMI AMF stores sparse pattern events and sample tables. ASYLUM AMF has a separate layout. libopenmpt probes the content to select a loader. |
| `.ams` | Extreme Tracker or Velvet Studio Module | Tracker music authored in Extreme Tracker and its successor, Velvet Studio. | A sample and instrument format with envelopes and packed musical data. AMS revisions differ in headers and compression details. |
| `.dbm` | DigiBooster Pro Module | Amiga and MorphOS music written in DigiBooster Pro. | An IFF-style module with chunked song data, instruments, envelopes, patterns, and samples. It supports more channels and richer instruments than classic MOD. |
| `.dmf` | X-Tracker or DSMI-derived Module | DOS music authored in X-Tracker, plus DMF variants found in some Webfoot games. | The extension is ambiguous. X-Tracker DMF is a chunked module format, while some DSMI and ASYLUM variants also use `.dmf`. libopenmpt distinguishes them by their signatures and structure. |
| `.imf` | Imago Orpheus Module | DOS tracker music composed in Imago Orpheus. | A multichannel instrument format with patterns, samples, envelopes, and effect commands. Its instrument model is more detailed than MOD or STM. |
| `.j2b` | Jazz Jackrabbit 2 Music | The in-game soundtrack of Jazz Jackrabbit 2. | A game-specific tracked-music format. libopenmpt decodes its patterns, instruments, samples, and playback commands into the same internal model used for other modules. |
| `.mdl` | DigiTrakker Module | DOS modules authored in DigiTrakker. | A packed multichannel format with instruments, envelopes, pattern tracks, and compressed sample data. Later revisions add more instrument and envelope fields. |
| `.mo3` | MO3 compressed module | Tracker music distributed through XMPlay or BASS-based software when a small download was important. | A compressed container for IT, MOD, MPTM, MTM, S3M, or XM data. It can store samples with MP3, Ogg Vorbis, or lossless compression and compresses the module structure too. |
| `.psm` | Epic MegaGames MASI Module | Music from Epic MegaGames-era titles such as Jazz Jackrabbit. | A game-oriented sample module with orders, patterns, channel events, and embedded samples. Multiple PSM variants exist, so the loader uses content signatures rather than the extension alone. |
| `.stm` | Scream Tracker 2 Module | Four-channel DOS music written in Scream Tracker 2. | A compact sample module derived from the early PC tracker model. It uses four channels, fixed-size patterns, instrument headers, and tempo and effect commands. |
| `.stx` | Scream Tracker Music Interface Kit Module | Music prepared for software that used the Scream Tracker Music Interface Kit. | Combines an STM-like song model with S3M-style storage. The format contains orders, packed patterns, samples, and channel settings. |
| `.umx` | Unreal Music Package | Music packages from Unreal, Unreal Tournament, Deus Ex, and Jazz Jackrabbit 3D. | An Unreal Engine package container that embeds module data, commonly IT, S3M, XM, or MOD. libopenmpt extracts the embedded object before decoding the module. |

## Scope

AuDeluxe intentionally exposes a smaller set than the complete libopenmpt decoder list. The app scans only the extensions in [`ModuleFormat.supportedExtensions`](AuDeluxe/Structures/ModuleFormat.swift). It does not currently discover MPTM, archive containers, or extensionless modules even when the bundled libopenmpt version could decode them.

## References

- [OpenMPT module format reference](https://wiki.openmpt.org/Manual:_Module_formats)
- [OpenMPT supported features and import formats](https://openmpt.org/features)
- [libopenmpt supported file types](https://lib.openmpt.org/libopenmpt/faq/)
- [libopenmpt module metadata](https://lib.openmpt.org/doc/classopenmpt_1_1module.html)
- [MOD FAQ format summary](https://resources.openmpt.org/modfaq/2.html)
