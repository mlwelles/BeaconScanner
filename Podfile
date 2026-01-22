platform :osx, '10.13'

target 'Beacon Scanner' do
  use_frameworks!
  pod 'ReactiveCocoa', '~> 2.5'  # Last Objective-C version (3.0+ is Swift)
  pod 'BlocksKit'
  pod 'libextobjc'

  target 'BeaconScannerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
    end
  end
end

