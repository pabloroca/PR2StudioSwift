# PR2StudioSwift

[![Build Status](https://travis-ci.org/pabloroca/PR2StudioSwift.svg?branch=master)](https://travis-ci.org/pabloroca/PR2StudioSwift)
[![Cocoapods](https://img.shields.io/cocoapods/v/PR2StudioSwift.svg)](https://cocoapods.org/pods/PR2StudioSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift](https://img.shields.io/badge/swift-4.0-red.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/PR2StudioSwift.svg?style=flat)](http://cocoapods.org/pods/PR2StudioSwift)

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Documentation](#jazzy)
- [Credits](#credits)
- [License](#license)

## Requirements

- iOS 11.0+
- Xcode 9.0+
- Swift 4.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build PR2StudioSwift

To integrate PR2StudioSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'PR2StudioSwift'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PR2StudioSwift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pabloroca/PR2StudioSwift"
```

Run `carthage update` to build the framework and drag the built `PR2StudioSwift.framework` into your Xcode project.

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate PR2StudioSwift into your project manually.

---

## Jazzy 

Doc generation in ,/docs folder. See it here: https://rawgit.com/pabloroca/PR2StudioSwift/master/docs/index.html

https://github.com/realm/jazzy

Script to run

    jazzy \
      --clean \
      --author PabloRoca \
      --author_url https://pr2studio.com \
      --module-version 1.00 \
      --xcodebuild-arguments -scheme,PR2StudioSwift \
      --module PR2StudioSwift \
      --output docs \
      --min-acl internal


## Credits

Pablo Roca Rozas, pablorocar@gmail.com

## License

PR2StudioSwift is available under the MIT license. See the LICENSE file for more info.
