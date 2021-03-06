#
# Be sure to run `pod lib lint PR2StudioSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PR2StudioSwift"
  s.version          = "0.3.11"
  s.summary          = "Swift base library used for PR2Studio projects"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
PR2StudioSwift is the base library for developing Swift projects. Most of the projects from PR2Studio uses it.
                       DESC

  s.homepage         = "https://github.com/pabloroca/PR2StudioSwift"
  s.license          = 'MIT'
  s.author           = { "Pablo Roca Rozas" => "pablorocar@gmail.com" }
  s.source           = { :git => "https://github.com/pabloroca/PR2StudioSwift.git", :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Source/*.swift'

  # s.resource_bundles = {
  #   'PR2StudioSwift' => ['PR2StudioSwift/Assets/*.png']
  # }

  s.dependency 'Alamofire', '~> 4.6'
  
end
