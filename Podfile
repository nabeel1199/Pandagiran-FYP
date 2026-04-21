# Uncomment the next line to define a global platform for your project
platform :ios, '10.1'

target 'Pandagiran' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pandagiran
	pod 'Firebase/Core', '~> 6.0'
	pod 'Firebase/Database'
	pod 'Alamofire', '~> 4.5'
  	pod 'GoogleSignIn', '~> 5.0.2'
	pod 'SwiftyJSON'
	pod 'Kingfisher', '~> 4.0'
	pod 'GooglePlaces'
  	pod 'GooglePlacePicker'
  	pod 'GoogleMaps'
	pod 'Charts' , '~> 3.2.2'
	pod 'Firebase/Messaging'
	pod "TTGSnackbar"
	#pod 'Fabric', '~> 1.7.6'
	pod 'FirebaseCrashlytics'
	#pod 'Firebase/Analytics'
	#pod 'Crashlytics', '~> 3.10.1'
	pod 'Firebase/Performance'
	#pod 'Firebase/Invites'
	pod 'Firebase/DynamicLinks'
	pod 'FBSDKLoginKit'
	pod 'FacebookCore'
	pod 'FBSDKCoreKit'
	pod 'FSCalendar'
	pod 'PinCodeTextField'
	pod 'WSTagsField', '~> 4.0.0'
	pod 'Firebase/InAppMessagingDisplay'
	pod 'FSPagerView'
	pod 'XLPagerTabStrip', '~> 9.0'
	pod 'Socket.IO-Client-Swift', '~> 14.0.0'
	pod 'Cosmos', '~> 18.0'
	pod 'ImageViewer'
	pod 'RangeSeekSlider', '~> 1.7.0'
	pod 'Lightbox'
	pod 'Instructions'
	pod 'SkeletonView'
	pod 'DropDown'
	pod 'CryptoSwift'#, '~> 0.15.0'
	#pod 'AES256CBC'
	pod 'SwiftyBeaver'
	pod 'SideMenu', '~> 5.0'
        pod 'SDWebImage'
    pod 'Mixpanel-swift'

  target 'PandagiranTests' do
    inherit! :search_paths
    # Pods for testing
	
  end

  target 'PandagiranUITests' do
    inherit! :search_paths
    # Pods for testing
  end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

    end
end

end


