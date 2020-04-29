#
# Be sure to run `pod lib lint TheQKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TheQKit'
  s.version          = '1.1.1'
  s.summary          = 'TheQKit SDK allows your own app to run game from The Q Trivia Network'
  
  s.swift_version = '4.2'
  # s.static_framework = true

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/streamwithadot/TheQKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
   s.license          = { :type => 'proprietary', :file => 'LICENSE' }
  s.author           = { 'Spohn' => 'spohn@stre.am' }
  s.source           = { :git => 'https://github.com/streamwithadot/TheQKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'TheQKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TheQKit' => ['TheQKit/Assets/*.png']
  # }
  
  s.resource_bundles = {
      'TheQKit' => ['TheQKit/Assets/*.{storyboard,xib,png,jpeg,jpg,xcassets,json,wav}']
  }
  #xcassets,json,imageset,png,jpeg,jpg
  #s.resources = 'TheQKit/Assets/Images.xcassets/*.imageset/*.png'


  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'VideoToolbox', 'QuartzCore', 'OpenGLES', 'MobileCoreServices', 'MediaPlayer', 'CoreVideo', 'CoreMedia', 'CoreGraphics', 'AVFoundation', 'AudioToolbox'
  
  s.libraries = 'z', 'bz2', 'stdc++'
  
  s.dependency 'Alamofire', '~> 4.9.1'
  s.dependency 'lottie-ios', '~> 3.1.6'
  s.dependency 'SwiftyJSON', '~> 5.0.0'
  s.dependency 'ObjectMapper', '~> 3.5.2'
  s.dependency 'Toast-Swift', '~> 5.0.1'
  s.dependency 'SwiftyAttributes', '~> 5.1.1'
  s.dependency 'Kingfisher', '~> 5.13.2'
  s.dependency 'Mixpanel-swift', '~> 2.7.0'
  s.dependency 'ijkplayer', '1.1.2'
  
end
