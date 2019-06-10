# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'



    use_frameworks!

target 'pholio01' do


source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

  # Pods for pholio01

	pod 'Firebase/Core'

	pod 'Firebase/Database'

	pod 'Firebase/Auth'

	pod 'Firebase/Storage'

	pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :tag => '4.2.0'


	pod 'FacebookShare'

	pod 'FacebookCore'

	pod 'FacebookLogin'

	pod 'LBTAComponents', :git => 'https://github.com/bhlvoong/LBTAComponents.git'

	pod 'JGProgressHUD'
	
	pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

	pod 'Firebase/Firestore'

	pod 'Haneke'
	
	pod 'Alamofire'
	
	pod 'FirebaseUI'

	pod 'SDWebImage'
	
   	pod 'SwiftyJSON'

	pod "CTSlidingUpPanel"

	pod 'TextFieldEffects'

	pod "Pastel"

	pod 'Cosmos'

	pod 'Firebase/Messaging'

	pod "BSImagePicker"
	
	pod 'Fusuma'

	pod 'FirebaseInstanceID'

	pod 'UICircularProgressRing'

	pod 'InstagramLogin'

	pod 'YPImagePicker'
 
	pod 'Kingfisher'

	pod 'FAPanels'

	pod 'CircleMenu'

	pod 'LBTATools'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(FRAMEWORK_SEARCH_PATHS)'
    ]
  end
end