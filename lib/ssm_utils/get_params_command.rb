require 'ssm_utils/ssm_reader_driver'
require 'yaml'

module SsmUtils
  class GetParamsCommand
    def initialize(options)
      opt = {
        decrypt: true,
        ssm_root: '/',
      }.merge(options)

      raise ArgumentError.new("No file path specified") if !opt.key?(:file_out)
      @file_out = opt[:file_out]
      @decrypt = opt[:decrypt]
      @ssm_root = opt[:ssm_root]
    end

    def execute
      ssm = SsmUtils::SsmReaderDriver.new(decrypt: @decrypt, ssm_root: @ssm_root)
      params = ssm.account_params

      File.open(@file_out, 'w') do |f|
        YAML.dump(params, f, line_width: -1)
      end
    end
  end
end
