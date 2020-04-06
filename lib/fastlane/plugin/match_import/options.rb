
require 'fastlane_core'
require 'match'

module Fastlane
  module MatchImport
    class Options
      def self.exclude_match_options
        # [:output_path, :additional_cert_types, :readonly, :generate_apple_certs, :skip_provisioning_profiles, :force, :force_for_new_devices, :skip_confirmation, :template_name]
        # Don't know how to exclude unused options and don't get error like:
        # Could not find option 'type' in the list of available options
        []
      end

      def self.available_options
        all = Match::Options.available_options

        exclude_match_options.each do |key|
          (i = all.find_index { |item| item.key == key }) && all.delete_at(i)
        end

        return all
      end
    end
  end
end
