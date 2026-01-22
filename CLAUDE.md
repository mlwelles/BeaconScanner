# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BeaconScanner is a macOS desktop application written in Objective-C for scanning and detecting iBeacon devices via Bluetooth Low Energy (BLE). It fills a gap in Apple's macOS ecosystem by providing iBeacon client support that was only available on iOS.

## Build Commands

```bash
# Install dependencies (requires CocoaPods)
pod install

# Open in Xcode (always use workspace, not project)
open BeaconScanner.xcworkspace

# Build: Cmd+B in Xcode
# Run: Cmd+R in Xcode
# Test: Cmd+U in Xcode
```

## Dependencies (CocoaPods)

- **ReactiveCocoa** - Reactive programming framework for signal-based communication
- **BlocksKit** - Block-based API extensions
- **libextobjc** - Objective-C extensions (@weakify/@strongify macros)

## Architecture

### Core Components

**HGBeaconScanner** (Singleton)
- Central manager for all Bluetooth scanning operations
- Instantiates `CBCentralManager` on a dedicated dispatch queue
- Exposes `beaconSignal` (RACSignal) for detected beacons
- Exposes `bluetoothStateSignal` for Bluetooth state changes
- Implements `CBCentralManagerDelegate` protocol

**HGBeacon** (Model)
- Represents a single iBeacon with UUID, major, minor, measuredPower, RSSI
- Parses 25-byte iBeacon manufacturer data from BLE advertisements
- Static factory methods: `beaconWithAdvertisementDataDictionary:` and `beaconWithManufacturerAdvertisementData:`

**HGBeaconViewController** (UI Controller)
- Manages NSTableView displaying detected beacons
- Subscribes to beacon signals and updates UI reactively
- Implements housekeeping to remove stale beacons (15-second timeout)
- Supports beacon recording feature via HGBeaconHistory

### Data Flow

1. `HGBeaconScanner` receives BLE advertisements via `CBCentralManagerDelegate`
2. `HGBeacon` parses manufacturer data to extract iBeacon payload
3. Valid beacons are emitted via `beaconSignal` (RACSubject)
4. Subscribers (like `HGBeaconViewController`) receive and process beacon events

### iBeacon Protocol

The 25-byte payload format:
- Bytes 0-1: Company ID (0x4C = Apple)
- Byte 2: Data type (0x02)
- Byte 3: Data length (0x15 = 21 bytes)
- Bytes 4-19: Proximity UUID (128-bit)
- Bytes 20-21: Major (16-bit, big-endian)
- Bytes 22-23: Minor (16-bit, big-endian)
- Byte 24: Measured Power (calibrated RSSI at 1m)

## Key Patterns

- **Reactive subscriptions**: Use RACSignal subscriptions for beacon events, not delegate callbacks
- **Signal filtering**: Filter `beaconSignal` by UUID to listen for specific beacons
- **Stale beacon cleanup**: Periodically purge beacons not heard from recently (see HGBeaconViewController for implementation)
