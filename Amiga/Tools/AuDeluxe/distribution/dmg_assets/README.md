# Quarantine Flag
Some apps are not signed (Apple needs more money for that...) and by default they are marked as "no trusted developer", you need to remove the default quarantine flag. To do that you have three **free** options. Pick the one easiest for you.

**Terminal**:
just run this command `xattr -rc ~/Downloads/AuDeluxe.app`

**GUI**: Sentil is a great app for managing the quarantine and signing. Free to use. It's [here](https://github.com/alienator88/Sentinel).

**Prerefences**: If you know what this means I don't have to explain how to use it. :-) 

**Note**: Apple restricts certain features from running (in the name of security and privacy) like QuickLook and Shortcuts. Unless they are either signed by an approved Apple's account (app store) or signed locally by the developer.

Enjoy.