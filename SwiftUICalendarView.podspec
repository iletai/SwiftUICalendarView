Pod::Spec.new do |s|
  s.name                  = 'SwiftUICalendarView'
  s.summary               = 'Create fully customizable calendar in no time. Keep your code clean'
  s.description           = <<-DESC
    SwiftUICalendarView is a zero-dependency, high-performance declarative calendar library for SwiftUI with 120Hz ProMotion fluidity, multi-mode rendering, and fluid gestures.
                               DESC

  s.version               = '3.1.0'
  s.platform              = :ios
  s.ios.deployment_target = '17.0'
  s.swift_version         = '5.9'

  s.source_files          = 'Sources/CalendarView/**/*.{swift}'
  s.frameworks            = 'SwiftUI', 'Foundation'

  s.homepage              = 'https://github.com/iletai/SwiftUICalendarView.git'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Le Quang Trong Tai' => 'iletai@hotmail.com' }
  s.source                = { :git => 'https://github.com/iletai/SwiftUICalendarView.git', :tag => 'v' + s.version.to_s }
end
