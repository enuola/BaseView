Pod::Spec.new do |spec|
	spec.name		= 'BaseLibrarySDK'
	spec.version	= "1.0"
	spec.summary	= 'base library function in enuola's iOS project'
	spec.homepage   = 'https://github.com/enuola/BaseView.git'
	spec.license	= { :type => 'MIT' }
	spec.authors	= { 'MIT' => 'mit@mogujie.com' }
	spec.platform   = :ios, "7.0"
	spec.ios.deployment_target = "7.0"
	spec.source       = { :git => 'http://gitlab.mogujie.org/ios-team/pay-app.git',:tag => "2.3.14"}
	spec.source_files = 'MoguPay/MoguPay/**/*.{h,m,mm}'
	spec.resources 	  = 'MoguPay/MoguPay/RsaCertResource/*.der','MoguPay/MoguPay/mgjpay.bundle','MoguPay/MoguPay/viewControllers/**/*.xib','MoguPay/MoguPay/Localizations/**'
	spec.frameworks   =	'Security', 'CoreGraphics', 'UIKit', 'Foundation'
	spec.requires_arc = true
	spec.libraries    = 'z', 'System'
	spec.requires_arc = true
	spec.prefix_header_file = "MoguPay/MoguPay/MoguPay-Prefix.pch"
	spec.dependency 'MGJiPhoneSDK', '~> 0.6.0'
	spec.dependency 'MGJH5WebContainer', '~> 0.7.0'
	spec.dependency 'TPKeyboardAvoiding', '~> 1.2.4'
	spec.dependency 'MGJVendors', '~> 0.1.2'
	spec.dependency 'MogujiePaySDK', '~> 0.4.0'
	spec.dependency 'Financial', '~> 0.2.0'
end
