Pod::Spec.new do |spec|
	spec.name                 = 'EmarsysNotificationService'
	spec.version              = '1.99.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Emarsys NotificationService'
	spec.platform             = :ios, '11.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-emarsys-sdk.git', :tag => spec.version }
	spec.source_files         = [
        'MobileEngage/RichNotificationExtension/**/*.{h,m}',
        'Core/Categories/NSError*.{h,m}',
        'Core/Validators/EMSDictionaryValidator*.{h,m}'
    ]
	spec.public_header_files  = [
        'MobileEngage/RichNotificationExtension/EMSNotificationService.h'
	]
	spec.libraries = 'z', 'c++'
end
