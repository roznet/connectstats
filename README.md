## Description [![Actions Status](https://github.com/roznet/connectstats/workflows/CI/badge.svg)](https://github.com/roznet/connectstats/actions)

This project contains several related applications to analyse fitness data:

### ![Icon](https://raw.githubusercontent.com/roznet/connectstats/master/ConnectStats/Media.xcassets/ConnectStatsNewAppIcon.appiconset/icon-76.png) ConnectStats

[ConnectStats](https://itunes.apple.com/app/apple-store/id581697248?mt=8) is an application for iOS (iPhone or iPad) that allows display, statistics and graphs on sports activities recorded with a garmin device or strava. This application is quite mature and available on the [app store](https://itunes.apple.com/app/apple-store/id581697248?mt=8) and has a [home page](https://ro-z.net/blog/connectstats/)

ConnectStats relies on a server with the implementation [here](https://github.com/roznet/connectstats_server)


### ![Icon](https://github.com/roznet/connectstats/raw/master/FitFileExplorer/Assets.xcassets/FitExplorerIcon76.imageset/FITFileExplorerIcons76.png)  FitFileExplorer

In addition to ConnectStats this project contains the companion app [FitFileExplorer](https://itunes.apple.com/us/app/fit-file-explorer/id1244431640?ls=1&mt=12).

[FitFileExplorer](https://itunes.apple.com/us/app/fit-file-explorer/id1244431640?ls=1&mt=12) is a [mac os utility](https://ro-z.net/blog/fitfileexplorer/) to view Fit File content. 


### Additional component

A few component of ConnectStats have been made available as open source packages:

- [FitFileParser](https://github.com/roznet/FitFileParser) is the implementation of the generic [Fit File](https://developer.garmin.com/fit) parsing library in swift.
- [RZUtils](https://github.com/roznet/rzutils) contains the implementation of the statistics and graphs used by the app.

### To build and run the app locally

- run `pod install`
- copy and edit with your own keys the file `credentials.sample.json` as `credentials.json`. Note that if you do not provide any keys you will only be able to use the Garmin Service from the web site and not Strava or ConnectStats server.
- open `ConnectStats.xcworkspace`




