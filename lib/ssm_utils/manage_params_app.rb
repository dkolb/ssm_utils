require 'commander'
require 'ssm_utils/hash_walker'
require 'ssm_utils/version'
require 'ssm_utils/get_params_command'
require 'ssm_utils/put_params_command'

module SsmUtils
  class ManageParamsApp
    include Commander::Methods

    def run
      program :name, 'Manage SSM Params'
      program :version, SsmUtils::VERSION
      program :description, 'Manages SSM parameters!'
      program :help, 'Author', 'David Kolb <david.kolb@coxautoinc.com>'

      command :get do |c|
        c.syntax = 'manage_ssm_params get [OPTIONS]'
        c.description = <<~EOF
          Retrieves an entire tree of your SSM parameter store as a well
          structured YAML document.
        EOF
        c.option '--file FILE', String, 'File to retrieve account to.'
        c.option '--[no-]decrypt', 'Decrypt SecureStrings, default true'
        c.option '--ssm_root PATH_ROOT', String,
          "A path root to retrieve from, default is '/'"
        c.when_called do |args, options|
          options.default(decrypt: true, ssm_root: '/')
          GetParamsCommand.new(
            file_out: options.file,
            decrypt: options.decrypt,
            ssm_root: options.ssm_root
          ).execute
        end
      end

      command :put do |c|
        c.syntax = 'manage_ssm_params put [OPTIONS]'
        c.description = <<~EOF
          Writes the supplied YAML structure into SSM parameter store using
          the reverse of the mappings used by get.
        EOF
        c.option '--file FILE', String, 'File to retrieve account to.'
        c.option '--retry-limit INTEGER', Integer, 'increase retry limit, default 3'
        c.option '--[no-]overwrite', 'Overwrite exitings strings, default true'
        c.when_called do |args, options|
          options.default(overwrite: true, retry_limit: 3)
          PutParamsCommand.new(
            in_file: options.file,
            overwrite: options.overwrite,
            retry_limit: options.retry_limit
          ).execute
        end
      end

      run!
    end
  end
end
