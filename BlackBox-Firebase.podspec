Pod::Spec.new do |s|
    s.name = "BlackBox-Firebase"
    s.version = "0.1.0"
    s.summary = "Firebase Plugin for BlackBox"

    s.source = { :git => "https://github.com/dodopizza/BlackBox-ios-Firebase.git", :tag => s.version }
    s.homepage = "https://github.com/dodopizza/BlackBox-ios-Firebase.git"

    s.license = 'Apache License, Version 2.0'
    s.author = { "Aleksey Berezka" => "a.berezka@dodopizza.com" }

    s.ios.deployment_target = "10.0"
    s.swift_version = '5.0'

    s.source_files = 'Sources/**/*.swift'

    s.frameworks = 'Foundation'

    s.dependency 'BlackBox', '~> 0.2.1'
    s.dependency 'Firebase/Crashlytics', '~> 7.0'
end
