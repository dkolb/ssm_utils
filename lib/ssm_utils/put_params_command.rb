require 'yaml'
require 'aws-sdk-ssm'
require 'ssm_utils/ssm_writer_driver'

module SsmUtils
  class PutParamsCommand
    def initialize(options)
      options = {
        overwrite: false,
        retry_limit: 3
      }.merge(options)

      raise ArgumentError.new("No input file") unless options.key? :in_file

      @overwrite = options[:overwrite]
      @retry_limit = options[:retry_limit]
      @in_file = options[:in_file]
    end

    def execute
      parameters = YAML.load_file(@in_file)
      SsmWriterDriver.new(
        parameters: parameters,
        overwrite:  @overwrite,
        retry_limit:  @retry_limit
      ).write_parameters
    end
  end
end
