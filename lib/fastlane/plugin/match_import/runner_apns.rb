require 'fastlane_core/print_table'
require 'spaceship'

module Fastlane
  module MatchImport
    class RunnerAPNS
      attr_accessor :files_to_commit
      attr_accessor :storage

      def run(params)
        self.files_to_commit = []

        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Verify correct type
        cert_type = params[:type]

        UI.user_error!("Cert type '#{cert_type}' is not supported. Use 'development' for development push or 'appstore', 'adhoc', 'enterprise' for production push") unless ['development', 'appstore', 'adhoc', 'enterprise'].include?(cert_type)

        # Get and verify apns cert path
        cert_path = MatchImport::Utils.ensure_valid_file_path(params[:cert_file_name], params[:source_path], "Certificate to import", one_file_only: true)
        p12_path = MatchImport::Utils.ensure_valid_file_path(params[:p12_file_name], params[:source_path], "Private key to import", one_file_only: true)

        # Check validity of certificate
        if Utils.is_cert_valid?(cert_path)
          UI.verbose("Your certificate '#{File.basename(cert_path)}' is valid")
        else
          UI.user_error!("Your certificate '#{File.basename(cert_path)}' is not valid, please check end date and renew it if necessary")
        end

        Spaceship::Portal.login(params[:username])
        Spaceship::Portal.select_team(team_id: params[:team_id], team_name: params[:team_name])

        certs = []
        cert_type_s = ""
        case cert_type
        when "development"
          cert_type_s = "development"
          certs = Spaceship::Portal.certificate.development_push.all
        when "appstore", "adhoc", "enterprise"
          cert_type_s = "production"
          certs = Spaceship::Portal.certificate.production_push.all
        else
          UI.user_error!("Cert type '#{cert_type}' is not supported")
        end

        # Base64 encode contents to find match from API to find a cert ID
        cert_contents_base_64 = Base64.strict_encode64(File.binread(cert_path))
        matching_cert = certs.find do |cert|
          content_cert = Base64.strict_encode64(cert.download_raw)
          is_same_cert = content_cert == cert_contents_base_64

          cert_type = Spaceship::Portal::Certificate::CERTIFICATE_TYPE_IDS[cert.type_display_id].to_s.split("::")[-1]
          if is_same_cert
            UI.success("(Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime('%Y-%m-%d')}, type: #{cert_type}) - match") if FastlaneCore::Globals.verbose?
          else
            UI.verbose("(Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime('%Y-%m-%d')}, type: #{cert_type}) - don't match") if FastlaneCore::Globals.verbose?
          end

          is_same_cert
        end

        UI.user_error!("This certificate cannot be imported - the certificate contents did not match with any available on the Developer Portal") if matching_cert.nil?

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, false)

        # Init the encryption only after the `storage.download` was called to have the right working directory
        encryption = MatchImport::Utils.encryption(params, storage)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        output_dir = File.join(storage_workspace, "customImport/customImport/customImport", "apns")
        output_dir = File.join(output_dir, cert_type_s)

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir)
        # dest_path = File.join(output_dir, params[:file_name])
        dest_path = output_dir

        dest_cert_path = File.join(dest_path, "#{matching_cert.id}.cer")
        dest_p12_path = File.join(dest_path, "#{matching_cert.id}.p12")

        self.files_to_commit = [dest_cert_path, dest_p12_path]

        # Copy file
        IO.copy_stream(cert_path, dest_cert_path)
        IO.copy_stream(p12_path, dest_p12_path)
        UI.success("Finish copying '#{cert_path}' and '#{p12_path}'") if FastlaneCore::Globals.verbose?

        encryption.encrypt_files if encryption
        storage.save_changes!(files_to_commit: self.files_to_commit)
      end

      def run_export(params)
        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Verify correct type
        cert_type = params[:type]

        UI.user_error!("Cert type '#{cert_type}' is not supported. Use 'development' for development push or 'appstore', 'adhoc', 'enterprise' for production push") unless ['development', 'appstore', 'adhoc', 'enterprise'].include?(cert_type)

        cert_type_s = ""
        case cert_type
        when "development"
          cert_type_s = "development"
        when "appstore", "adhoc", "enterprise"
          cert_type_s = "production"
        else
          UI.user_error!("Cert type '#{cert_type}' is not supported")
        end

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, true)

        # Init the encryption only after the `storage.download` was called to have the right working directory
        MatchImport::Utils.encryption(params, storage)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        source_path = File.join(storage_workspace, "customImport/customImport/customImport", "apns")
        source_path = File.join(source_path, cert_type_s)

        output_dir = params[:destination_path]

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir) if output_dir
        # dest_path = File.join(output_dir, params[:file_name])
        dest_path = output_dir

        if Dir.exist?(source_path) && !Dir.empty?(source_path)
          file_path = File.join(source_path, '*.cer')
          Dir[file_path].each do |file|
            p12_file = File.basename(file, ".cer") + ".p12"
            p12_file = File.join(source_path, p12_file)

            # Check validity of certificate
            if Utils.is_cert_valid?(file)
              UI.verbose("Your certificate '#{File.basename(file)}' is valid")
            else
              UI.user_error!("Your certificate '#{File.basename(file)}' is not valid, please check end date and renew it if necessary")
            end

            if Helper.mac?
              UI.message("Installing certificate...")

              # Only looking for cert in "custom" (non login.keychain) keychain
              # Doing this for backwards compatibility
              keychain_name = params[:keychain_name] == "login.keychain" ? nil : params[:keychain_name]

              if FastlaneCore::CertChecker.installed?(file, in_keychain: keychain_name)
                UI.verbose("Certificate '#{File.basename(cert_path)}' is already installed on this machine")
              else
                Utils.import(file, params[:keychain_name], password: params[:keychain_password])
              end

              # Import the private key
              # there seems to be no good way to check if it's already installed - so just install it
              # Key will only be added to the partition list if it isn't already installed
              Utils.import(p12_file, params[:keychain_name], password: params[:keychain_password])
            else
              UI.message("Skipping installation of certificate as it would not work on this operating system.")
            end

            next unless dest_path

            FileUtils.cp(file, dest_path)
            UI.success("Finish copying '#{file}' to '#{dest_path}'") if FastlaneCore::Globals.verbose?

            FileUtils.cp(p12_file, dest_path)
            UI.success("Finish copying '#{p12_file}' to '#{dest_path}'") if FastlaneCore::Globals.verbose?
          end
        else
          UI.important("#{source_path} is empty. Nothing to export")
        end
      end

      def run_remove_invalid(params)
        self.files_to_commit = []

        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Verify correct type
        cert_type = params[:type]

        UI.user_error!("Cert type '#{cert_type}' is not supported. Use 'development' for development push or 'appstore', 'adhoc', 'enterprise' for production push") unless ['development', 'appstore', 'adhoc', 'enterprise'].include?(cert_type)

        Spaceship::Portal.login(params[:username])
        Spaceship::Portal.select_team(team_id: params[:team_id], team_name: params[:team_name])

        certs = []
        cert_type_s = ""
        case cert_type
        when "development"
          cert_type_s = "development"
          certs = Spaceship::Portal.certificate.development_push.all
        when "appstore", "adhoc", "enterprise"
          cert_type_s = "production"
          certs = Spaceship::Portal.certificate.production_push.all
        else
          UI.user_error!("Cert type '#{cert_type}' is not supported")
        end

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, true)

        # Init the encryption only after the `storage.download` was called to have the right working directory
        MatchImport::Utils.encryption(params, storage)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        source_path = File.join(storage_workspace, "customImport/customImport/customImport", "apns")
        source_path = File.join(source_path, cert_type_s)

        if Dir.exist?(source_path) && !Dir.empty?(source_path)
          file_path = File.join(source_path, '*.cer')
          Dir[file_path].each do |file|
            p12_file = File.basename(file, ".cer") + ".p12"
            p12_file = File.join(source_path, p12_file)

            # Check validity of certificate
            is_valid = Utils.is_cert_valid?(file)
            if is_valid
              UI.verbose("Your certificate '#{File.basename(file)}' is not expired.")
            else
              UI.verbose("Your certificate '#{File.basename(file)}' is not valid, please check end date. Will remove it together with '#{File.basename(p12_file)}'")
              files_to_commit << file
              files_to_commit << p12_file
            end

            next unless is_valid

            UI.verbose("Checking if '#{File.basename(file)}' is present on Developer Portal")

            # Base64 encode contents to find match from API to find a cert ID
            cert_contents_base_64 = Base64.strict_encode64(File.binread(file))
            matching_cert = certs.find do |cert|
              content_cert = Base64.strict_encode64(cert.download_raw)
              is_same_cert = content_cert == cert_contents_base_64

              cert_type = Spaceship::Portal::Certificate::CERTIFICATE_TYPE_IDS[cert.type_display_id].to_s.split("::")[-1]
              if is_same_cert
                UI.success("(Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime('%Y-%m-%d')}, type: #{cert_type}) - match") if FastlaneCore::Globals.verbose?
              else
                UI.verbose("(Cert id: #{cert.id}, name: #{cert.name}, expires: #{cert.expires.strftime('%Y-%m-%d')}, type: #{cert_type}) - don't match") if FastlaneCore::Globals.verbose?
              end

              is_same_cert
            end

            if matching_cert.nil?
              UI.verbose("This certificate '#{File.basename(file)}' will be removed together with '#{File.basename(p12_file)}' - the certificate contents did not match with any available on the Developer Portal")
              files_to_commit << file
              files_to_commit << p12_file
            else
              UI.verbose("Your certificate '#{File.basename(file)}' is valid. Skip it")
            end
          end
        else
          UI.important("#{source_path} is empty. Nothing to check")
        end

        if self.files_to_commit.count > 0
          self.files_to_commit.each do |file|
            FileUtils.rm(file)
            UI.success("Finish removing '#{file}'") if FastlaneCore::Globals.verbose?
          end

          storage.save_changes!(files_to_commit: self.files_to_commit)
        end
      end
    end
  end
end
