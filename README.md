BeaconScanner
=============

iBeacon Scanning Utility for OSX

![Alt text](ScreenShot.png)

When apple released iBeacon support in iOS 7, there was a deserved amount of exitement.   One oversight, however, was the lack of client API support for OSX.  Developing and testing iBeacons has required using an iOS device.  This utility was authored to allow scanning for nearby beacons on the desktop.   



##Using the Utility

Usage is simple.  Start the app, and it'll be scanning for bluetooth devices.  Any iBeacons that are detected while will appear.  Columns can be sorted by whatever attribute is most important. 


##Building the Source

Building the app requires [cocoapods](http://cocoapods.org).  Once installed, launch Terminal.app and in the project directory, run "pod install".  When it completes, open the *BeaconScanner.xcworkspace* file that it create in Xcode.  The app should then build and run successfully. 

##Reusing the Source

To add iBeacon support to your own desktop applications, at least until the a proper cocoapod is made available, just copy the following four files into your project:  

- BCBeaconManager.h
- BCBeaconManager.m
- BCBeacon.h
- BCBeacon.m

The beacon manager announces the detection of beacons to the subscribers of a [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) signal that it makes available.  All that's needed to detect beacons is to first tell the manager to start scanning, and then to setup a subscription to this beacon signal:

	[[[HGBeaconManager] sharedBeaconManager] startScanning];
	
	RACSignal *beaconSignal = [[HGBeaconManager sharedBeaconManager] beaconSignal];
	[beaconSignal subscribeNext:^(HGBeacon *detectedBeacon) {
		NSLog(@"iBeacon Detected: %@", )
	}];


To limit this subscription to just those beacons that are relevant to your application, a filtered signal can be composed from the raw feed, like so:


	NSUUID *applicationUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

	RACSignal *filteredSignal = [[[HGBeaconManager sharedBeaconManager] beaconSignal] filter:^(HGBeacon *beacon) {
		return [beaconSignal.proximityUUID isEqual:applicationUUID];
	}];
	

Note that as long as any given beacon is in range, it will be announced periodically via the subscription.  

It's best to use these updates to maintain a seperate list of nearby active beacons, and then periodically purge from this list those that have not been heard from in a while in order to ensure that only active beacons are tracked.   

In the application source, the class *HGBeaconViewController* provides a good example of how to do this. 



## The Icon

The "Radar" image in the icon was created by [ricaodomaia](http://openclipart.org/user-detail/ricardomaia) and downloaded from [openclipart.org](http://openclipart.org/detail/122719/radar-by-ricardomaia) 