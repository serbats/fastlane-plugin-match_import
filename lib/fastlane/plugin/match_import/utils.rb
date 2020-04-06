require 'match'

module Fastlane
  module MatchImport
    class Utils
      # Be smart about optional values here
      # Depending on the storage mode, different values are required
      def self.update_optional_values_depending_on_storage_type(params)
        if params[:storage_mode] != "git"
          params.option_for_key(:git_url).optional = true
        end
      end

      def self.ensure_valid_file_path(file_path, source_path, file_description, one_file_only: false)
        file_path = File.join(source_path, file_path) if source_path
        file_path = File.absolute_path(file_path) unless file_path == ""
        path_to_file = file_path
        if one_file_only
          file_path = File.exist?(file_path) ? file_path : nil
        else
          file_path = nil if Dir.glob(file_path).empty?
        end

        UI.user_error!("#{file_description} does not exist at path: #{path_to_file}") if file_path.nil?
        file_path
      end

      def self.ensure_valid_one_level_path(destination_path)
        destination_path_components = []
        destination_path_components = destination_path.split("/") if destination_path
        UI.user_error!("#{destination_path} should be one level dir(Correct encrypt/decript requires one level). It has more levels: #{destination_path_components}.") if destination_path_components.count > 1
        destination_path
      end

      def self.storage(params, readonly)
        storage =  Match::Storage.for_mode(params[:storage_mode], {
          git_url: params[:git_url],
          shallow_clone: params[:shallow_clone],
          skip_docs: params[:skip_docs],
          git_branch: params[:git_branch],
          git_full_name: params[:git_full_name],
          git_user_email: params[:git_user_email],
          clone_branch_directly: params[:clone_branch_directly],
          type: params[:type].to_s,
          platform: params[:platform].to_s,
          google_cloud_bucket_name: params[:google_cloud_bucket_name].to_s,
          google_cloud_keys_file: params[:google_cloud_keys_file].to_s,
          google_cloud_project_id: params[:google_cloud_project_id].to_s,
          readonly: readonly,
          username: readonly ? nil : params[:username],
          team_id: params[:team_id],
          team_name: params[:team_name]
        })
        storage.download

        storage
      end

      def self.encryption(params, storage)
        encryption = Match::Encryption.for_storage_mode(params[:storage_mode], {
          git_url: params[:git_url],
          working_directory: storage.working_directory
        })
        encryption.decrypt_files if encryption

        encryption
      end

      def self.import(item_path, keychain, password: "")
        keychain_path = FastlaneCore::Helper.keychain_path(keychain)
        FastlaneCore::KeychainImporter.import_file(item_path, keychain_path, keychain_password: password, output: FastlaneCore::Globals.verbose?)
      end

      def self.is_cert_valid?(cer_certificate_path)
        cert = OpenSSL::X509::Certificate.new(File.binread(cer_certificate_path))
        now = Time.now.utc
        return (now <=> cert.not_after) == -1
      end
    end
  end
end
