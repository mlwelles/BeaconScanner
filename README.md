BeaconScanner
=============

iBeacon Scanning Utility for OSX

![Alt text](ScreenShot.png)

A notible absense when apple added iBeacon support to iOS was a lack of an API and client utilities for OSX.  This application attempts to remedy this, allowing beacon scanning on the desktop, and the source framework provides a means to add iBeacon support any other OSX project.

###Installing

To install without building from source, first [download the prebuilt archive](Builds/BeaconScanner.zip).  Double click the zip to extract, and then double click again to run. 

Once you start the app it'll automatically begin scanning for bluetooth devices.  Any beacons within range will automatically appear and it will continuously update as long as it remains scanning.

###Building

Building the app requires [cocoapods](http://cocoapods.org).  Once installed, launch Terminal.app and in the project directory, run "pod install".  When it completes, open the *BeaconScanner.xcworkspace* file that it create in Xcode.  The app should then build and run successfully. 

###Adding beacon support to your own project

To add iBeacon support to your own desktop application (at least until the a proper cocoapod is made available), just copy the following four files into your project:  

- *HGBeaconManager.h*
- *HGBeaconManager.m*
- *HGBeacon.h*
- *HGBeacon.m*

The beacon manager announces the beacons it detects to the subscribers of the [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) signal that it provides for this.  

All that's needed for a client to detect beacons is to subscribe to this signal:

	[[[HGBeaconManager] sharedBeaconManager] startScanning];
	
	RACSignal *beaconSignal = [[HGBeaconManager sharedBeaconManager] beaconSignal];
	[beaconSignal subscribeNext:^(HGBeacon *detectedBeacon) {
		NSLog(@"iBeacon Detected: %@", detectedBeacon);
	}];


To limit this subscription to just those beacons that are relevant to your application, a filtered signal can be composed from the raw feed, like so:


	NSUUID *applicationUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

	RACSignal *filteredSignal = [[[HGBeaconManager sharedBeaconManager] beaconSignal] filter:^(HGBeacon *beacon) {
		return [beaconSignal.proximityUUID isEqual:applicationUUID];
	}];
	

Note that as long as any given beacon is in range, it will be announced periodically via the subscription.  

It's best to use these updates to maintain a seperate list of nearby active beacons, and then periodically purge from this list those that have not been heard from in a while in order to ensure that only active beacons are tracked.   

In the application source, the class *HGBeaconViewController* provides a good example of how to do this. 


### See Also

In order to turn your OSX Mavericks box into an iBeacon emitter, see Matthew Robinsons' [BeaconOX](https://github.com/mttrb/BeaconOSX). It's also the reason this project exists. 


### The Icon

The "Radar" image in the icon was created by [ricaodomaia](http://openclipart.org/user-detail/ricardomaia) and downloaded from [openclipart.org](http://openclipart.org/detail/122719/radar-by-ricardomaia) 