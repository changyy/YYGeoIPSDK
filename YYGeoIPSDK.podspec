Pod::Spec.new do |s|
  s.name     = 'YYGeoIPSDK'
  s.version  = '1.0'
  s.license  = { :type => 'BSD'}
  s.summary  = 'Simple GeoIP SDK for iOS.'
  s.homepage = 'https://github.com/changyy/YYGeoIPSDK'
  s.authors  = 'Yuan-Yi Chang', 
  s.source   = { :git => 'https://github.com/changyy/YYGeoIPSDK.git',
                 :tag => "#{s.version}" }
  s.description = ''
  s.source_files = '{YYGeoIPSDK}/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '4.0'
end
