
  Pod::Spec.new do |s|
    s.name = 'CapacitorGeofenceBoxTracker'
    s.version = '0.0.1'
    s.summary = 'Capacitor Geofence Tracker'
    s.license = 'MIT'
    s.homepage = 'https://github.com/jaimbox/capacitor-geofence-box-tracker.git'
    s.author = 'Jaimbox'
    s.source = { :git => 'https://github.com/jaimbox/capacitor-geofence-box-tracker.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end