
Pod::Spec.new do |s|
  s.name             = 'SBSpeechRecognizer'
  s.version          = '0.2.0'
  s.summary          = 'A Swift wrapper for SFSpeechRecognizer'

  s.description      = <<-DESC
A Swift wrapper for Apple's SFSpeechRecognizer that handles set up and timing
                       DESC

  s.homepage         = 'https://github.com/simonbromberg/SBSpeechRecognizer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'simonbromberg' => 'me@sbromberg.com' }
  s.source           = { :git => 'https://github.com/simonbromberg/SBSpeechRecognizer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/shimmb'

  s.ios.deployment_target = '10.0'

  s.source_files = 'SBSpeechRecognizer/Classes/**/*'

end
