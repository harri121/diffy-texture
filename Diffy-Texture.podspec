#
# Be sure to run `pod lib lint Diffy-Texture.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Diffy-Texture'
  s.version          = '0.1.0'
  s.summary          = 'Diffable Datasource for Texture'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Diffable Datasource for Textures ASCollectionNode.
                       DESC

  s.homepage         = 'https://github.com/harri121/Diffy-Texture'
  s.authors       = { 'Daniel Hariri' => 'daniel.hariri@gmail.com' }
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.swift_version = '5.1'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Daniel Hariri' => 'daniel.hariri@gmail.com' }
  s.source           = { :git => 'https://github.com/harri121/Diffy-Texture.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Diffy-Texture/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Diffy-Texture' => ['Diffy-Texture/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Texture', '~> 3.0'
end
