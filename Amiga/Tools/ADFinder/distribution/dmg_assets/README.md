# Installing ADFinder

ADFinder is not notarized with Apple, so macOS may identify it as being from an
unidentified developer after download.

For a free graphical option, install
[Sentinel](https://github.com/alienator88/Sentinel), drag ADFinder onto it, and
choose **Unquarantine**. Do not use Sentinel's self-sign action.

Alternatively, copy ADFinder to Applications and run:

```bash
xattr -rc "/Applications/ADFinder.app"
```

ADFinder requires macOS 15 or later and currently supports Apple silicon Macs.
After the first installation, signed updates are available from
**ADFinder → Check for Updates…**.
