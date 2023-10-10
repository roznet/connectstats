source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'
target 'ConnectStats' do
  use_frameworks!
  pod 'GoogleMaps', :inhibit_warnings => true
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'Armchair', '>= 0.3', :inhibit_warnings => true
  target 'ConnectStatsXCTests' do
    pod 'CHCSVParser', :inhibit_warnings => true
  end
end
target 'HealthStats' do
  use_frameworks!
  pod 'GoogleMaps', :inhibit_warnings => true
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'Armchair', '>= 0.3', :inhibit_warnings => true
end
target 'ConnectStatsTestApp' do
  use_frameworks!
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'GoogleMaps', :inhibit_warnings => true
  pod 'CHCSVParser', :inhibit_warnings => true
end
target 'FitFileExplorer' do
  use_frameworks!
  platform :osx, '10.14'
  pod 'Armchair', '>= 0.3', :inhibit_warnings => true
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            # fix warning after update about deployment target
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
            # fix warning after install about overriden architecture
            config.build_settings.delete('ARCHS')
        end
    end
end
