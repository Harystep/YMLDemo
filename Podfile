# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
#      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] ="arm64"
#    end
#  end
#end

target 'GTDemo' do
  # Comment the next line if you don't want to use dynamic frameworks  
  use_frameworks!
  pod 'GTSDK'
  pod 'GTCommonSDK'
  pod 'AFNetworking', '~> 4.0'
  # Pods for GTDemo

  target 'GTDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GTDemoUITests' do
    # Pods for testing
  end

end

target 'SZNotificationSevice' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'GTExtensionSDK'
  # Pods for SZNotificationSevice

end

#def update_xcconfig(xcconfig_path, key, value)
#  # read from xcconfig to build_settings dictionary
#  build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.delete!("\n").split(/\s*=\s*/, 2)}.flatten]
#  
#  # modify key
#  if build_settings.has_key?(key)
#    if build_settings[key].index(value) == nil
#      build_settings[key] << value
#    end
#  else
#    build_settings[key] = value
#  end
#  
#  # write build_settings dictionary to xcconfig
#  File.open(xcconfig_path, "w+") {|file|
#    build_settings.each do |k, v|
#      file.puts "#{k} = #{v}"
#    end
#  }
#end
#
## post_install hook
#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      xcconfig_path = config.base_configuration_reference.real_path
#      update_xcconfig(xcconfig_path, 'OTHER_LDFLAGS', ' -Wl,-weak-lswiftCoreGraphics')
#    end
#  end
#end


#post_install do |installer|
#  installer.aggregate_targets.each do |target|
#    target.xcconfigs.each do |variant, xcconfig|
#      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
#      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
#    end
#  end
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
#        xcconfig_path = config.base_configuration_reference.real_path
#        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
#      end
#    end
#  end
#end
