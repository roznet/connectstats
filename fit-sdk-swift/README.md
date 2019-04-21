# Fit File Parsing for swift

This code provide basic parsing of Fit Files in swift

It uses the official [Fit SDK](https://www.thisisant.com/resources/fit)

This project provides a framework that you can integrate into your own iOS or macOS app.

It contains a few examples

- a small command line example to parse a file. A command line utilities can't use the framework, so you need to compile and like the files.
- a small iOS app that will link and embed the framework
- a small macOS app

To integrade into an external app you will need to:

- add the framework project to your app project.
- create and xcconfig file with the relevant `SWIFT_INCLUDE_PATHS` defined. If you use cocoapods your xcconfig file will need to include the cocoapods xcconfig file.
- import into your swift file both RZFitFile and RZFitFileTypes (if you need the fit constants like `FIT_MESG_XXX`)
 
You can see an example of integration into the MacOS and iOS apps [FitFileExplorer and ConnectStats](https://github.com/roznet/connectstats).

Specifically and you can find here an [example of xcconfig file](https://github.com/roznet/connectstats/blob/master/ConnectStats/ConnectStats.debug.xcconfig)

## Approach

It takes the example c code from the official SDK and integrate it into swift to generate a native object with an array of messages made of native swift dictionaries.

All the keys and fields are generated from the c structure that are parsed in `fit_convert.c` from the example SDK. The file `fit_example.h` contains all the definition and a script fitconv.py parses that and automatically generate the swift code to build the native swift structures.

When a new SDK is available, after download, the c example should be copied into the sdk directory, and running the `fitconv.py` script will regenerate the swift code.

## Why?

This goal of this code is to replace the original cpp code from the SDK used in FitFileExplorer. The cpp parsing ended up very slow, and it made fit file parsing on [ConnectStats or FitFileExplorer](https://github.com/roznet/connecstats) quite slow. This approach in c/swift is much faster.

