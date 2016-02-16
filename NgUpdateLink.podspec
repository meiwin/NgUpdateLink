Pod::Spec.new do |spec|
spec.name         = 'NgUpdateLink'
spec.version      = '1.0.1'
spec.summary      = 'An iOS library for regulating/scheduling UI updates.'
spec.homepage     = 'https://github.com/meiwin/NgUpdateLink'
spec.author       = { 'Meiwin Fu' => 'meiwin@blockthirty.com' }
spec.source       = { :git => 'https://github.com/meiwin/ngupdatelink.git', :tag => "v#{spec.version}" }
spec.source_files = 'NgUpdateLink/**/*.{h,m}'
spec.requires_arc = true
spec.license      = { :type => 'MIT', :file => 'LICENSE' }
spec.frameworks   = 'UIKit'
spec.ios.deployment_target = "8.0"
end