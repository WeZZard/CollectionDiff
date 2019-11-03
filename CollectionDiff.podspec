Pod::Spec.new do |spec|
  spec.name             	= "CollectionDiff"
  spec.version          	= "0.0.2"
  spec.license          	= { :type => "MIT", :file => "LICENSE" }
  spec.homepage         	= 'https://github.com/WeZZard/CollectionDiff'
  spec.author           	= { "WeZZard" => "https://wezzard.com" }
  spec.summary          	= "A framework makes use of advanced Core Animation features without leaving UIKit."
  spec.source           	= { :git => "https://github.com/WeZZard/CollectionDiff.git", :tag => '0.0.2'}
  spec.source_files     	= 'CollectionDiff/**/*.swift'
  spec.module_name		= 'CollectionDiff'
  spec.ios.deployment_target	= '8.0'
  spec.osx.deployment_target	= '10.9'
  spec.watchos.deployment_target	= '2.0'
  spec.tvos.deployment_target	= '9.0'
  spec.swift_versions		= ['5.1', '5.0', '4.2']
end
