# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
use_modular_headers!

target 'Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example

end

target 'peaq-iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'TweetNacl'
  pod 'secp256k1.c'
  pod 'IrohaCrypto'
  pod 'keccak.c'
  pod 'SwiftProtobuf'
  pod 'Alamofire'

  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end
  
end
