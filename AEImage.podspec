Pod::Spec.new do |s|
s.name = 'AEImage'
s.version = '0.1.0'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Simple & lightweight adaptive image viewer with zoom and gyro motion support written in Swift'

s.homepage = 'https://github.com/tadija/AEImage'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

s.source = { :git => 'https://github.com/tadija/AEImage.git', :tag => s.version }
s.source_files = 'Sources/*.swift'

s.ios.deployment_target = '8.0'
end
