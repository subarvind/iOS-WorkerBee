## Couchbase Mobile Workflow Test App

This iOS app is a shell for long-running workflow tests of the [Couchbase Mobile][1] framework.

## Getting Started

These instructions assume you are familiar with how to make an iOS app. Please follow them fully and in order the first time you build.

If you have questions or get stuck or just want to say hi, please visit the [Mobile Couchbase group][4] on Google Groups.

Prerequisite: Xcode 4.0.2 or later with the SDK for iOS 4 or later. (It's possible the project might still work with Xcode 3, but we're not testing or supporting this anymore.)

## Building The App

### Download or clone the repository

You can [download a Zip archive of the current source code][8].

Or you can clone the repo with git:

    git clone git://github.com/couchbaselabs/WorkerBee.git

### Get the frameworks (Couchbase and CouchCocoa)

This project isn't quite standalone; it links against the Couchbase Mobile and CouchCocoa, which it expects to find in the "Frameworks" subfolder. If you've already got those, you can just copy or symlink them in. If not, here's how to get them:

1. Go to the [Couchbase Mobile for iOS home page][1] and download the release (see the Download button in the right column.) This will get you "Couchbase.framework".
2. Either [download and unzip the latest][5] compiled CouchCocoa.framework, or [check out the source code][6] and build it yourself. (Build the "iOS Framework" scheme, then find CouchCocoa.framework in the build output directory.)
3. Copy both Couchbase.framework and CouchCocoa.framework into the Frameworks directory of this project. (You don't need to drag them into Xcode; the project already has references to them.)

### Open the Xcode project

    open 'Worker Bee.xcodeproj'

### Build and run the app

1. Select the appropriate destination (an iOS device or simulator) from the pop-up menu in the Xcode toolbar.
2. Click the Run button.

Once in the app, you'll see a list of available tests. Tap the on/off switch next to a test to start or stop it. (Some tests stop automatically, some run forever till you stop them.)

To see more info about a test, tap its name to navigate to its page. This will show the test's log output. You can also start and stop the test from this page. The test will keep running whether you're on its page or not.

Test output is saved to the app's Documents directory. If you're running on a real device, you can access this directory by tethering the device, selecting it in iTunes, going to the Apps tab, scrolling down to the File Sharing list, then selecting "Worker Bee" in the list. In the simulator, you can look in the Xcode console output for lines starting with "** OPENING" to see the paths to the log files.

## Adding Your Own Tests

Just create a new subclass of BeeCouchTest. Read API docs for that class and its parent BeeTest to see what you can do, and look at the existing tests for inspiration. 

Generally you'll override -setUp, set a heartbeatInterval, and override -heartbeat to perform periodic activity. The framework takes care of creating a fresh database for you to work with.

## License

Portions under Apache, Erlang, and other licenses.

Background pattern images are from [subtlepatterns.com][9], released under a Creative Commons Attribution 3.0 Unported License.

The overall package is released under the Apache license, 2.0.

Copyright 2011, Couchbase, Inc.


[1]: http://www.couchbase.org/get/couchbase-mobile-for-ios/current
[4]: https://groups.google.com/group/mobile-couchbase
[5]: https://github.com/couchbaselabs/CouchCocoa/downloads
[6]: https://github.com/couchbaselabs/CouchCocoa/
[8]: https://github.com/couchbaselabs/WorkerBee/zipball/master
[9]: http://subtlepatterns.com/
