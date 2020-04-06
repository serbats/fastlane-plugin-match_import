require 'fastlane/action'
require_relative '../helper/match_import_helper'

module Fastlane
  module Actions
    class MatchRemoveInvalidApnsAction < Action
      def self.run(params)
        UI.message("The match_remove_invalid_apns plugin is working!")
        params.load_configuration_file("Matchfile")

        Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
        Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

        Fastlane::MatchImport::RunnerAPNS.new.run_remove_invalid(params)
      end

      def self.description
        "Match repository apns certs remove invalid"
      end

      def self.authors
        ["Serhii Batsevych"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Remove expired or revoked apns certs from match encrypted repository"
      end

      def self.available_options
        Fastlane::MatchImport::APNSRemoveInvalidFileOptions.available_options
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
