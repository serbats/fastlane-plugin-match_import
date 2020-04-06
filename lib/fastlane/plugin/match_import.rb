module Fastlane
  module MatchImport
    # Return all .rb files inside the "actions" and "helper" directory
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

require 'fastlane/plugin/match_import/version'
require 'fastlane/plugin/match_import/options'
require 'fastlane/plugin/match_import/runner'
require 'fastlane/plugin/match_import/runner_apns'
require 'fastlane/plugin/match_import/utils'
require 'fastlane/plugin/match_import/custom_file_options'
require 'fastlane/plugin/match_import/apns_file_options'
require 'fastlane/plugin/match_import/apns_export_file_options'
require 'fastlane/plugin/match_import/apns_remove_invalid_file_options'
require 'fastlane/plugin/match_import/encryption/openssl'
require 'fastlane/plugin/match_import/commands_generator'

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::MatchImport.all_classes.each do |current|
  require current
end
