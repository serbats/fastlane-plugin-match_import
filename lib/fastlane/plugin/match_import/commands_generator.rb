require 'commander'
require 'fastlane_core/configuration/configuration'

require_relative '../match_import'

HighLine.track_eof = false
module Fastlane
  module MatchImport
    class CommandsGenerator
      include Commander::Methods

      def self.start
        self.new.run
      end

      def run
        program :name, 'match_import'
        program :version, Fastlane::MatchImport::VERSION
        program :description, Fastlane::MatchImport::DESCRIPTION
        program :help, 'Author', 'Sergii Batsevych <serbats@ukr.net>'
        program :help, 'Website', 'https://fastlane.tools'
        program :help, 'GitHub', 'https://github.com/serbats/fastlane-plugin-match_import'
        program :help_formatter, :compact

        global_option('--verbose') { FastlaneCore::Globals.verbose = true }

        command :import do |c|
          c.syntax = 'match_import import'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::CustomFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import import --file_name='*.txt' --source_path='testDir' --destination_path='repoDir'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::CustomFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::Runner.new.run(params)
          end
        end

        command :export do |c|
          c.syntax = 'match_import export'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::CustomFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import export --file_name='*.txt' --source_path='repoDir' --destination_path='testDir'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::CustomFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::Runner.new.run_export(params)
          end
        end

        command :remove do |c|
          c.syntax = 'match_import remove'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::CustomFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import remove --file_name='*.txt' --source_path='repoDir'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::CustomFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::Runner.new.run_remove(params)
          end
        end

        command :import_apns do |c|
          c.syntax = 'match_import import_apns'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::APNSFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import import_apns --type='development' --cert_file_name='PushDev.cer' --p12_file_name='PushDev.p12'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::APNSFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::RunnerAPNS.new.run(params)
          end
        end

        command :export_apns do |c|
          c.syntax = 'match_import export_apns'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::APNSExportFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import export_apns --type='development' --keychain_name='FastlaneKeychain' --keychain_password='password' --destination_path='testDir'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::APNSExportFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::RunnerAPNS.new.run_export(params)
          end
        end

        command :remove_invalid_apns do |c|
          c.syntax = 'match_import remove_invalid_apns'
          c.description = Fastlane::MatchImport::DESCRIPTION

          FastlaneCore::CommanderGenerator.new.generate(Fastlane::MatchImport::APNSRemoveInvalidFileOptions.available_options, command: c)

          c.action do |args, options|
            if args.count > 0
              FastlaneCore::UI.user_error!("Please run `match_import remove_invalid_apns --type='development'`")
            end

            params = FastlaneCore::Configuration.create(Fastlane::MatchImport::APNSRemoveInvalidFileOptions.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")

            Match::Encryption.register_backend(type: "git", encryption_class: MatchImport::Encryption::OpenSSL)
            Match::Encryption.register_backend(type: "s3", encryption_class: MatchImport::Encryption::OpenSSL)

            Fastlane::MatchImport::RunnerAPNS.new.run_remove_invalid(params)
          end
        end

        default_command(:import)

        run!
      end
    end
  end
end
