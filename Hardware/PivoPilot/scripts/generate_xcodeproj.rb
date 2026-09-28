#!/usr/bin/env ruby

require "pathname"
require "xcodeproj"

ROOT = Pathname(__dir__).parent
PROJECT_PATH = ROOT.join("PivoPilot.xcodeproj")

project = Xcodeproj::Project.new(PROJECT_PATH.to_s)
project.root_object.attributes["LastSwiftUpdateCheck"] = "2600"
project.root_object.attributes["LastUpgradeCheck"] = "2600"

app_target = project.new_target(:application, "PivoPilot", :ios, "17.0")
app_target.product_name = "PivoPilot"
resources_phase = app_target.resources_build_phase

project.build_configurations.each do |config|
    config.build_settings["SWIFT_VERSION"] = "6.0"
end

app_target.build_configurations.each do |config|
    config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.metools.PivoPilot"
    config.build_settings["INFOPLIST_FILE"] = "Config/PivoPilot-Info.plist"
    config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
    config.build_settings["SWIFT_VERSION"] = "6.0"
    config.build_settings["TARGETED_DEVICE_FAMILY"] = "1,2"
    config.build_settings["MARKETING_VERSION"] = "1.0"
    config.build_settings["CURRENT_PROJECT_VERSION"] = "1"
    config.build_settings["CODE_SIGN_STYLE"] = "Automatic"
    config.build_settings["DEVELOPMENT_TEAM"] = ""
    config.build_settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = ""
    config.build_settings["LD_RUNPATH_SEARCH_PATHS"] = ["$(inherited)", "@executable_path/Frameworks"]
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "x86_64"
end

main_group = project.main_group

["Sources", "Config", "Resources"].each do |folder|
    next unless Dir.exist?(ROOT.join(folder))
    group = main_group.new_group(folder, folder)
    Dir.glob(ROOT.join(folder, "**", "*")).sort.each do |path|
        next if File.directory?(path)
        relative_path = Pathname(path).relative_path_from(ROOT.join(folder)).to_s
        file_ref = group.new_file(relative_path)
        case File.extname(path)
        when ".swift"
            app_target.source_build_phase.add_file_reference(file_ref)
        when ".plist"
            next
        else
            resources_phase.add_file_reference(file_ref)
        end
    end
end

["CoreMotion", "CoreBluetooth", "WatchConnectivity"].each do |framework|
    app_target.add_system_framework(framework)
end

project.save
