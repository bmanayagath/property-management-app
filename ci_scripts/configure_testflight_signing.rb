require 'fileutils'
require 'xcodeproj'

runner_temp = ENV.fetch('RUNNER_TEMP')
profile = Xcodeproj::Plist.read_from_path(File.join(runner_temp, 'profile.plist'))
entitlements = profile.fetch('Entitlements')
uuid = profile.fetch('UUID')
unless uuid.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
  abort 'Invalid provisioning profile UUID.'
end
if profile.key?('ProvisionedDevices') || profile['ProvisionsAllDevices'] || entitlements['get-task-allow'] != false
  abort 'Use an App Store Connect distribution profile, not a development, ad hoc, or enterprise profile.'
end
abort 'The provisioning profile has expired.' if profile.fetch('ExpirationDate') <= Time.now

team_id = profile.fetch('TeamIdentifier').first
bundle_id = entitlements.fetch('application-identifier').split('.', 2).last
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')
runner = project.targets.find { |target| target.name == 'Runner' }
abort 'Runner target was not found.' unless runner
unless runner.build_configurations.all? { |config| config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] == bundle_id }
  abort "Profile bundle ID #{bundle_id} does not match Runner. Update Runner and its Firebase iOS configuration before uploading."
end

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
  config.build_settings['DEVELOPMENT_TEAM'] = team_id
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = uuid
end
project.save

# Support both the legacy and current Xcode provisioning profile locations.
['Library/MobileDevice/Provisioning Profiles',
 'Library/Developer/Xcode/UserData/Provisioning Profiles'].each do |relative_path|
  directory = File.join(Dir.home, relative_path)
  FileUtils.mkdir_p(directory)
  FileUtils.cp(File.join(runner_temp, 'app.mobileprovision'), File.join(directory, "#{uuid}.mobileprovision"))
end

Xcodeproj::Plist.write_to_path({
  'method' => 'app-store-connect',
  'destination' => 'export',
  'teamID' => team_id,
  'signingStyle' => 'manual',
  'signingCertificate' => 'Apple Distribution',
  'provisioningProfiles' => { bundle_id => uuid },
  'manageAppVersionAndBuildNumber' => false,
  'uploadSymbols' => true
}, File.join(runner_temp, 'ExportOptions.plist'))
File.open(ENV.fetch('GITHUB_ENV'), 'a') { |file| file.puts "PROFILE_UUID=#{uuid}" }
puts "Configured App Store signing for #{bundle_id}."
