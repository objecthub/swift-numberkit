// swift-tools-version:5.4
//
//  Package.swift
//  NumberKit
//
//  Created by Matthias Zenger on 01/05/2017.
//  Copyright © 2015-2024 Matthias Zenger. All rights reserved.
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
  platforms: [
    .macOS("13.3"),
    .iOS(.v13),
    .tvOS(.v13)
  ],
  products: [
    .library(name: "NumberKit", targets: ["NumberKit"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "NumberKit",
            dependencies: [],
            exclude: ["Info.plist"]),
    .testTarget(name: "NumberKitTests",
                dependencies: ["NumberKit"],
                exclude: ["Info.plist"]),
  ],
  swiftLanguageVersions: [.v5]
)
