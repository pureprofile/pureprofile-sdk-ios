Pod::Spec.new do |s|  
    s.name              = 'Pureprofile'
    s.version           = '1.3.1'
    s.summary           = 'Pureprofile survey monetization SDK' 
    s.homepage          = 'https://www.pureprofile.com'
    s.documentation_url = 'https://github.com/pureprofile/pureprofile-sdk-ios/'
    s.author            = { 'Pureprofile Pty Ltd' => 'product@pureprofile.com' }
    s.license           = { :type => 'Commercial', :file => 'LICENSE' }
    s.platform          = :ios
    s.source            = { :http => 'https://devtools.pureprofile.com/surveys/ios/latest/PureprofileSDK.zip' }
    s.description       = <<-DESC
Pureprofile is a survey platform that delivers surveys through the web and mobile apps. The Pureprofile iOS SDK is an easy to use library for developers who want to integrate Purerprofile's surveying platform into their iOS apps.
DESC
    s.swift_version     = '5.1'
    s.ios.deployment_target = '10.0'
    s.vendored_frameworks = 'PureprofileSDK.framework'
end 
