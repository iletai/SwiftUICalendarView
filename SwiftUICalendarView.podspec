Pod::Spec.new do |s|
    s.name                  = 'CalendarView'
    s.summary               = 'Create fully customisable calendar in no time. Keep your code clean'
    s.description           = <<-DESC
      SwiftUICalendarView is a free and open-source library in SwiftUI to make calendar.
                                 DESC
    
    s.version               = '1.4.1'
    s.ios.deployment_target = '16.0'
    s.swift_version         = '5.9'
    s.dependency 'SwiftDate', '~> 7.0.0'

    s.source_files          = 'Sources/**/*'
    s.frameworks            = 'SwiftUI', 'Foundation', 'Combine'
    
    s.homepage              = 'https://github.com/iletai/SwiftUICalendarView'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Le Quang Trong Tai' => 'iletai@hotmail.com' }
    s.source                = { :git => 'https://github.com/iletai/SwiftUICalendarView', :tag => s.version.to_s }
  end
