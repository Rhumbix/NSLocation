Pod::Spec.new do |s|
  s.name         = "NSLocation"
  s.module_name  = "NSLocation"
  s.version      = "0.1.0"
  s.summary      = "No-Sweat/No-Shit Location Service for iOS"

  s.description  = <<-DESC
                    No-Sweat/No-Shit Location Service for iOS
                   DESC

  s.homepage     = "https://github.com/Rhumbix/NSLocation.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Rhumbix" => "dev@rhumbix.com" }
  s.social_media_url   = "https://www.facebook.com/Rhumbix"

  s.platform     = :ios, "8.0"
  s.ios.deployment_target     = '8.0'
  s.source       = { :git => "https://github.com/Rhumbix/NSLocation.git", :tag => s.version.to_s }
  s.source_files = "NSLocation/**/*.{h,swift}"
  s.requires_arc = true
end
