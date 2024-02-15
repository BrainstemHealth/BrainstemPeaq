# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example

end

target 'peaq-iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'TweetNacl'
  pod 'secp256k1.swift'
  pod 'IrohaCrypto'
  pod 'keccak.c'
  # Pods for peaq-iOS

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
  
end
