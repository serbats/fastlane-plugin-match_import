
require 'fastlane_core'

module Fastlane
  module MatchImport
    class APNSExportFileOptions
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
        destination_path_index = Fastlane::MatchImport::CustomFileOptions.available_options.find_index { |item| item.key == :destination_path }
        destination_path = Fastlane::MatchImport::CustomFileOptions.available_options[destination_path_index] if destination_path_index
        destination_path_array = destination_path.nil? ? [] : [destination_path]

        [
        ] + destination_path_array
      end
    end
  end
end
