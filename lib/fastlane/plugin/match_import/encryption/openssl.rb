require 'match'

module Fastlane
  module MatchImport
    module Encryption
      class OpenSSL < Match::Encryption::OpenSSL
        def iterate(source_path)
          super
          # apns *.cer and *.p12 are encrypted/decrypted by 'super' call
          Dir[File.join(source_path, "customImport/customImport/customImport", "custom", "**", "*")].each do |path|
            next if File.directory?(path)
            yield(path)
          end
        end
      end
    end
  end
end
