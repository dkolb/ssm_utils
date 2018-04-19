require 'aws-sdk-ssm'
require 'ssm_utils/hash_walker'

module SsmUtils
  class SsmReaderDriver
    include HashWalker

    def initialize(options={})
      options = {
        decrypt: true,
        ssm_root: '/'
      }.merge(options)
      @ssm = Aws::SSM::Client.new()
      @decrypt_flag = options[:decrypt]
      @ssm_root = options[:ssm_root]
    end

    def raw_account_params
      return @raw_params if @raw_params
      
      params = []

      @ssm.get_parameters_by_path(
        path: @ssm_root, 
        recursive: 'true',
        with_decryption: @decrypt_flag
      ).each do |r|
        params += r.to_h[:parameters]
      end

      @raw_params = params
    end

    def account_params
      params = {}
      raw_account_params.each do |r|
        if r[:type] == 'String'
          value = r[:value]
        elsif r[:type] == 'SecureString'
          value = {
            '_value' => r[:value],
            '_type'  => r[:type],
            '_key'   => encryption_key(r)
          }
        else
          value = {
            '_value' => r[:value],
            '_type'  => r[:type]
          }
        end
        dig_set(params, key_list(r[:name]), value)
      end
      params
    end

    def encryption_key(param)
      response = @ssm.get_parameter_history(name: param[:name])
      matched_version = nil

      # Apparently this is the idiomatic way to do/while. :-/
      loop do
        matched_version = response.parameters.find do |p| 
          p.version == param[:version]
        end
        response = response.next_page if response.next_page?
        break unless matched_version.nil? && response.next_page?
      end
      matched_version.nil? ? nil : matched_version.key_id
    end

    def key_list(param_name)
      param_name[0] == '/' ? param_name[1..-1].split('/') : param_name.split('/')
    end
  end
end
