
require 'fastlane_core'

module Fastlane
  module MatchImport
    class APNSFileOptions
      def self.exclude_options
        # [:keychain_name, :keychain_password]
        # Don't know how to exclude unused options and don't get error like:
        # Could not find option 'type' in the list of available options
        []
      end

      def self.available_options
        all = Fastlane::MatchImport::Options.available_options

        exclude_options.each do |key|
          (i = all.find_index { |item| item.key == key }) && all.delete_at(i)
        end

        return all + custom_options
      end

      def self.custom_options
        source_path_index = Fastlane::MatchImport::CustomFileOptions.available_options.find_index { |item| item.key == :source_path }
        source_path = Fastlane::MatchImport::CustomFileOptions.available_options[source_path_index] if source_path_index
        source_path_array = source_path.nil? ? [] : [source_path]

        [
          FastlaneCore::ConfigItem.new(key: :cert_file_name,
                                     env_name: "MATCH_IMPORT_CERT_FILENAME",
                                     description: "Certificare .cer to import",
                                     optional: false),
          FastlaneCore::ConfigItem.new(key: :p12_file_name,
                                     env_name: "MATCH_IMPORT_P12_FILENAME",
                                     description: "Private key .p12 to import. Should have empty password for correct export to keychain",
                                     optional: false)
        ] + source_path_array
      end
    end
  end
end
