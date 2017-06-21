Pod::Spec.new do |s|

s.name = 'AEImage'
s.version = '2.1.0'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Adaptive image viewer for iOS (with support for zoom, gyro motion and infinite scroll)'

s.homepage = 'https://github.com/tadija/AEImage'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

s.source = { :git => 'https://github.com/tadija/AEImage.git', :tag => s.version }
s.source_files = 'Sources/*.swift'

s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

s.ios.deployment_target = '9.0'

end
