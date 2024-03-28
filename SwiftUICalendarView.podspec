Pod::Spec.new do |s|
    s.name                  = 'SwiftUICalendarView'
    s.summary               = 'Create fully customisable calendar in no time. Keep your code clean'
    s.description           = <<-DESC
      SwiftUICalendarView is a free and open-source library in SwiftUI to make calendar.
                                 DESC
    
    s.version               = '1.4.2'
    s.platform     = :ios
    s.ios.deployment_target = '16.0' # Updated deployment target to a valid iOS version
    s.swift_version         = '5.9'
    s.dependency 'SwiftDate', '~> 7.0.0'

    s.source_files = 'Sources/CalendarView/**/*.{swift}' # Updated source_files pattern to match the correct file path
    s.frameworks            = 'SwiftUI', 'Foundation'
    
    s.homepage              = 'https://github.com/iletai/SwiftUICalendarView.git'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Le Quang Trong Tai' => 'iletai@hotmail.com' }
    s.source                = { :git => 'https://github.com/iletai/SwiftUICalendarView.git', :tag => 'v' + s.version.to_s  }
  end
