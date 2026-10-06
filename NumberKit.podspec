Pod::Spec.new do |s|
  s.name                   = 'NumberKit'
  s.module_name            = 'NumberKit'
  s.version                = '2.6.1'
  s.summary                = 'Advanced numeric data types for Swift 5, including BigInt, Rational, and Complex numbers.'
  s.homepage               = 'https://github.com/objecthub/swift-numberkit'
  s.license                = 'Apache License 2.0'
  s.author                 = { 'Matthias Zenger' => 'matthias@objecthub.com' }
  s.source                 = { :git => 'https://github.com/objecthub/swift-numberkit.git', :tag => s.version }
  s.ios.deployment_target = '16.4'
  s.tvos.deployment_target = '16.4'
  s.osx.deployment_target = '13.3'
  s.watchos.deployment_target = '9.4'
  s.swift_version = '5.8'
  s.source_files = 'Sources/NumberKit/**/*.{swift}'
end