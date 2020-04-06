# match_import plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-match_import)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-match_import`, add it to your project by running:

```bash
fastlane add_plugin match_import
```

## About match_import

Match repository custom import

 * all kinds of files - with "match_import import --file_name='*.txt'"
 * APNS certs and p12 - with "match_import import_apns"
 * easy export to keychain APNS certs with p12 - with "match_import export_apns --type='adhoc'"
 * easy export of custom files to some directory - with "match_export export --file_name='*.txt' --destination_path='myTestDir'"
 * `ENV` variables

## Example

```ruby

lane :test_apns_import do
  # Import APNS development certificate into match repo if certificate exist on Dev Portal and is not expired. Takes './test/DevPush.cer' and check if it is not expired and present on Dev Portal under Development Push Certificates and if present and not expired copies both './test/DevPush.cer' and './test/DevPush.p12' into match repo 'customImport/customImport/customImport/apns/development/' and encrypts
  match_import_apns(type: "development", cert_file_name: 'DevPush.cer', p12_file_name: 'DevPush.p12', source_path: 'test', verbose: true)
end

lane :test_apns_import2 do
   # Import APNS production certificate into match repo if certificate exist on Dev Portal and is not expired. Takes './test/ProdPush.cer' and check if it is not expired and present on Dev Portal under Production Push Certificates and if present and not expired copies both './test/ProdPush.cer' and './test/ProdPush.p12' into match repo 'customImport/customImport/customImport/apns/production/' and encrypts
  match_import_apns(type: "adhoc", cert_file_name: 'ProdPush.cer', p12_file_name: 'ProdPush.p12', source_path: 'test', verbose: true)
end

lane :test_apns_export do
  # Export APNS production certs from match repo into keychain. Takes from repo 'customImport/customImport/customImport/apns/production/*' and install them into 'login' keychain
  match_export_apns(type: "adhoc", verbose: true)
end

lane :test_apns_export2 do
  # Export APNS development certs from match repo into keychain. Takes from repo 'customImport/customImport/customImport/apns/development/*' and install them into 'login' keychain
  match_export_apns(type: "development", verbose: true)
end

lane :test_apns_export3 do
  # Export APNS production certs from match repo into keychain. Takes from repo 'customImport/customImport/customImport/apns/production/*' and install them into 'Fastlane' keychain
  match_export_apns(type: "adhoc", keychain_name: "Fastlane", keychain_password: "qwerty", verbose: true)
end

lane :test_apns_export4 do
  # Export APNS production certs from match repo into keychain. Takes from repo 'customImport/customImport/customImport/apns/production/*' and install them into 'login' keychain. Also copy it together with p12 into './testDir/'
  match_export_apns(type: "adhoc", destination_path: "testDir", verbose: true)
end

lane :test_apns_remove_invalid do
  # Remove expired or revoked certs from match repo. Takes from repo 'customImport/customImport/customImport/apns/production/*' and remove all expired or revoked from Dev Portal
  match_remove_invalid_apns(type: "adhoc", verbose: true)
end

lane :test_apns_remove_invalid2 do
  # Remove expired or revoked certs from match repo. Takes from repo 'customImport/customImport/customImport/apns/development/*' and remove all expired or revoked from Dev Portal
  match_remove_invalid_apns(type: "development", verbose: true)
end

lane :test_import do
  # Import custom files into encrypted match repo. Takes 'myDirWithFiles/*.txt' and copy them to repo with path 'customImport/customImport/customImport/custom/testPath/' and encrypts
  match_import(file_name: '*.txt', destination_path: "testPath", source_path: 'myDirWithFiles', verbose: true)
end

lane :test_import2 do
  # Import custom file into encrypted match repo. Takes './Gemfile' and copy it to repo with path 'customImport/customImport/customImport/custom/' and encrypts
  match_import(file_name: 'Gemfile',  verbose: true)
end

lane :test_export do
  # Decrypts and export files from match repo. Decrypts match repo and takes all files from repo 'customImport/customImport/customImport/custom/testPath/*.txt' into './testDir/'
  match_export(file_name: '*.txt', destination_path: "testDir/", source_path: 'testPath', verbose: true)
end

lane :test_export2 do
  # Decrypts and export file from match repo. Decrypts match repo and take file from repo 'customImport/customImport/customImport/custom/Gemfile' into './'
  match_export(file_name: 'Gemfile',  verbose: true)
end

lane :test_remove do
  # Removes files from match repo. Removes files from repo 'customImport/customImport/customImport/custom/testPath/*.txt' 
  match_remove(file_name: '*.txt', source_path: 'testPath/', verbose: true)
end

lane :test_remove2 do
  # Removes file from match repo. Removes 'customImport/customImport/customImport/custom/Gemfile' from repo
  match_remove(file_name: 'Gemfile',  verbose: true)
end

```

## Commandline Examples:

```bash
# Import custom files
match_import import --file_name='*.txt' --source_path='testDir' --destination_path='repoDir'

# Export custom files
match_import export --file_name='*.txt' --source_path='repoDir' --destination_path='testDir'

# Remove custom files
match_import remove --file_name='*.txt' --source_path='repoDir'

# Import APNS file
match_import import_apns --type='development' --cert_file_name='PushDev.cer' --p12_file_name='PushDev.p12'

# Export APNS file into keychain and directory
match_import export_apns --type='development' --keychain_name='FastlaneKeychain' --keychain_password='password' --destination_path='testDir'

# Remove invalid APNS development certs
match_import remove_invalid_apns --type='development'

```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
