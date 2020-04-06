require 'fastlane_core/print_table'

module Fastlane
  module MatchImport
    class Runner
      attr_accessor :files_to_commit
      attr_accessor :storage

      def run(params)
        self.files_to_commit = []

        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Get and verify custom file path
        file_path = MatchImport::Utils.ensure_valid_file_path(params[:file_name], params[:source_path], "File to import")
        # Verify destination path is one level dir. Othervise encrypt/decript won't work
        destination_path = MatchImport::Utils.ensure_valid_one_level_path(params[:destination_path])

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, false)

        # Init the encryption only after the `storage.download` was called to have the right working directory
        encryption = MatchImport::Utils.encryption(params, storage)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        output_dir = File.join(storage_workspace, "customImport/customImport/customImport", "custom")
        output_dir = File.join(output_dir, destination_path) if destination_path

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir)
        # dest_path = File.join(output_dir, params[:file_name])
        dest_path = output_dir

        # Copy file
        # IO.copy_stream(file_path, dest_path)

        Dir[file_path].each do |file|
          dest_file = File.join(dest_path, File.basename(file))
          if File.file?(dest_file) && FileUtils.compare_file(file, dest_file)
            UI.success("File '#{file}' already exist at destination and is unchanged")
          else
            self.files_to_commit << dest_path

            FileUtils.cp(file, dest_path)
            UI.success("Finish copying '#{file}' to '#{dest_path}'") if FastlaneCore::Globals.verbose?
          end
        end

        if self.files_to_commit.count > 0
          encryption.encrypt_files if encryption
          storage.save_changes!(files_to_commit: self.files_to_commit)
        end
      end

      def run_export(params)
        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Verify source path is one level dir. Othervise encrypt/decript won't work
        source_path = MatchImport::Utils.ensure_valid_one_level_path(params[:source_path])

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, true)

        # Init the encryption only after the `storage.download` was called to have the right working directory
        MatchImport::Utils.encryption(params, storage)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        input_dir = File.join(storage_workspace, "customImport/customImport/customImport", "custom")
        source_path = source_path.nil? ? input_dir : File.join(input_dir, source_path)

        # Get and verify custom file path
        file_path =  MatchImport::Utils.ensure_valid_file_path(params[:file_name], source_path, "File to export")

        output_dir = params[:destination_path].nil? ? '.' : params[:destination_path]

        # Make dir if doesn't exist
        FileUtils.mkdir_p(output_dir)
        # dest_path = File.join(output_dir, params[:file_name])
        dest_path = output_dir

        # Copy file
        # IO.copy_stream(file_path, dest_path)

        Dir[file_path].each do |file|
          dest_file = File.join(dest_path, File.basename(file))
          if File.file?(dest_file) && FileUtils.compare_file(file, dest_file)
            UI.success("File '#{file}' already exist at destination and is unchanged")
          else
            FileUtils.cp(file, dest_path)
            UI.success("Finish copying '#{file}' to '#{dest_path}'") if FastlaneCore::Globals.verbose?
          end
        end
      end

      def run_remove(params)
        self.files_to_commit = []

        FastlaneCore::PrintTable.print_values(config: params,
                                              hide_keys: [],
                                              title: "Summary for match_import #{Fastlane::MatchImport::VERSION}")

        MatchImport::Utils.update_optional_values_depending_on_storage_type(params)

        # Verify source path is one level dir. Othervise encrypt/decript won't work
        source_path = MatchImport::Utils.ensure_valid_one_level_path(params[:source_path])

        # Choose the right storage and encryption implementations
        storage = MatchImport::Utils.storage(params, false)

        storage_workspace = storage.prefixed_working_directory

        # Hack to avoid conflicts with "fastlane match" encryption.
        # It uses pattern: [File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")]
        # To avoid conflicts we use three level deep folder.
        input_dir = File.join(storage_workspace, "customImport/customImport/customImport", "custom")
        source_path = source_path.nil? ? input_dir : File.join(input_dir, source_path)

        # Get and verify custom file path
        file_path = MatchImport::Utils.ensure_valid_file_path(params[:file_name], source_path, "File to remove")

        # Copy file
        # IO.copy_stream(file_path, dest_path)

        Dir[file_path].each do |file|
          self.files_to_commit << file

          FileUtils.rm(file)
          UI.success("Finish removing '#{file}'") if FastlaneCore::Globals.verbose?
        end

        if self.files_to_commit.count > 0
          storage.save_changes!(files_to_commit: self.files_to_commit)
        end
      end
    end
  end
end
