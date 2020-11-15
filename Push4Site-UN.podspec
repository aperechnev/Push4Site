#
# Be sure to run `pod lib lint Push4Site-UN.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Push4Site-UN'
  s.version          = '0.2.0'
  s.summary          = 'The official iOS SDK for Push4Site.com.'

  s.description      = <<-DESC
  The official framework for Push4Site.com service.
                       DESC

  s.homepage         = 'https://github.com/aperechnev/Push4Site'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Perechnev' => 'alexander@perechnev.com' }
  s.source           = { :git => 'https://github.com/aperechnev/Push4Site.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'Push4Site-UN/Classes/**/*'
  s.dependency 'Alamofire'
end
