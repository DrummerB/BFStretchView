Pod::Spec.new do |spec|
  spec.name = 'BFStretchView'
  spec.version = '0.1.0'
  spec.authors = {'Balázs Faludi' => 'balazsfaludi@gmail.com'}
  spec.homepage = 'https://github.com/DrummerB/BFStretchView'
  
  spec.platform = :ios
  spec.requires_arc = true

  spec.source = {:git => 'https://github.com/DrummerB/BFStretchView.git', :tag => spec.version.to_s}
  spec.source_files = 'BFStretchView/**/*.{h,m}'
end
