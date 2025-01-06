#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint freshchat_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'freshchat_sdk'
  s.version          = '0.10.23'
  s.summary          = 'Freshchat Flutter SDK - iOS'
  s.description      = <<-DESC
  Freshchat Flutter SDK - iOS.
                       DESC
  s.homepage         = 'http://freshworks.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Freshworks' => 'support@freshchat.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios
  s.dependency "FreshchatSDK", '6.3.1'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.static_framework = true
end
