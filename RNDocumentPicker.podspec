require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNDocumentPicker"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :osx => "11.0" }
  s.source       = { :git => "https://github.com/victorhenrion/react-native-document-picker-macos.git", :tag => "#{s.version}" }

  s.source_files = "macos/**/*.{h,m,mm,cpp}"
  s.private_header_files = "macos/**/*.h"

  install_modules_dependencies(s)
end
