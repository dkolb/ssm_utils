require 'aws-sdk-ssm'
require 'ssm_utils/hash_walker'

module SsmUtils
  class SsmWriterDriver
    include HashWalker

    def initialize(options)
      options = {
        overwrite: false
      }.merge(options)

      raise ArgumentError('Missing parameters') unless options.key? :parameters

      @parameters = options[:parameters]
      @ssm = Aws::SSM::Client.new
      @overwrite = options[:overwrite]
    end

    def write_parameters
      ssm_requests.each do |request|
        @ssm.put_parameter(request)
      end
    end

    def ssm_requests
      return @calls if @calls

      @calls = []

      walk_hash(@parameters, '/') { |path, value|
        path = "/#{path}"
        if value.is_a? Hash
          @calls.push process_hash_value(path, value)
        else
          @calls.push process_literal_value(path,value)
        end
      }

      @calls
    end

    private

    def process_literal_value(path, value)
      {
        name: path,
        value: value.to_s,
        type: "String",
        overwrite: @overwrite
      }
    end

    def process_hash_value(path, value)
      call = {
        name: path,
        value: value['_value'].to_s,
        type: value['_type'],
        overwrite: @overwrite
      }

      if value['_type'] == 'SecureString'
        call[:key_id] = value['_key']
      end

      call
    end
  end
end
