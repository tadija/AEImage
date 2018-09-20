Pod::Spec.new do |s|

s.name = 'AEImage'
s.version = '2.2.1'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Adaptive image viewer for iOS (with support for zoom, gyro motion and infinite scroll)'

s.source = { :git => 'https://github.com/tadija/AEImage.git', :tag => s.version }
s.source_files = 'Sources/AEImage/*.swift'

s.swift_version = '4.2'

s.ios.deployment_target = '9.0'

s.homepage = 'https://github.com/tadija/AEImage'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

end
