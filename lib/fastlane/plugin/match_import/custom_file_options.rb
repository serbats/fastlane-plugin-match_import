
require 'fastlane_core'
require 'match'

module Fastlane
  module MatchImport
    class CustomFileOptions
      def self.exclude_match_options
        # [:type, :output_path, :keychain_name, :keychain_password]
        # Don't know how to exclude unused options and don't get error like:
        # Could not find option 'type' in the list of available options
        []
      end

      def self.available_options
        all = Fastlane::MatchImport::Options.available_options

        exclude_match_options.each do |key|
          (i = all.find_index { |item| item.key == key }) && all.delete_at(i)
        end

        return all + custom_options
      end

      def self.custom_options
        [
          FastlaneCore::ConfigItem.new(key: :file_name,
                                     env_name: "MATCH_IMPORT_FILENAME",
                                     description: "File to import. Could contain mask like '*.txt'",
                                     optional: false),
          FastlaneCore::ConfigItem.new(key: :destination_path,
                                     env_name: "MATCH_IMPORT_DESTINATION_PATH",
                                     description: "Path to copy imported file to",
                                     optional: true),
          FastlaneCore::ConfigItem.new(key: :source_path,
                                     env_name: "MATCH_IMPORT_SOURCE_PATH",
                                     description: "Path to take importing file from",
                                     optional: true)
        ]
      end
    end
  end
end
