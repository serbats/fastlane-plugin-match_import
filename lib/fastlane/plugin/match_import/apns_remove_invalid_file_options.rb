
require 'fastlane_core'

module Fastlane
  module MatchImport
    class APNSRemoveInvalidFileOptions
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
        [
        ]
      end
    end
  end
end
