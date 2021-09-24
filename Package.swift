// swift-tools-version:5.4
//
//  Package.swift
//  NumberKit
//
//  Created by Matthias Zenger on 01/05/2017.
//  Copyright © 2015-2020 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let package = Package(
  name: "NumberKit",
  
  // Platforms define the operating systems for which this library can be compiled for.
  platforms: [
    .macOS(.v10_12),
    .iOS(.v12),
  ],
  
  // Products define the executables and libraries produced by a package, and make them visible
  // to other packages.
  products: [
    .library(name: "NumberKit", targets: ["NumberKit"]),
  ],
  
  // Dependencies declare other packages that this package depends on.
  // e.g. `.package(url: /* package url */, from: "1.0.0"),`
  dependencies: [
  ],
  
  // Targets are the basic building blocks of a package. A target can define a module or
  // a test suite. Targets can depend on other targets in this package, and on products
  // in packages which this package depends on.
  targets: [
    .target(name: "NumberKit",
            dependencies: [],
            exclude: ["Info.plist"]),
    .testTarget(name: "NumberKitTests",
                dependencies: ["NumberKit"],
                exclude: ["Info.plist"]),
  ],
  
  // Required Swift language version.
  swiftLanguageVersions: [.v5]
)
