require 'tempfile'
require 'ssm_utils/put_params_command'
require 'shared_contexts/ssm_params'
require 'shared_contexts/put_params'
require 'shared_contexts/sample_config'

RSpec.describe SsmUtils::PutParamsCommand do
  include_context 'sample config'
  include_context 'ssm params'
  include_context 'put params'

  let(:temp_file_path) do
    file = Tempfile.new('test') 
    path = file.path
    file.close
    file.unlink
    path
  end

  before(:each) do
    File.write(temp_file_path, sample_config_string)
  end

  after(:each) do
    File.delete(temp_file_path)
  end

  subject { SsmUtils::PutParamsCommand.new(in_file: temp_file_path) }

  describe '#execute' do
    it 'calls AWS with the expected calls' do
      aggregate_failures do 
        expected_aws_calls.each do |call|
          expect(ssm_client_double).to receive(:put_parameter).with(call).once
        end
      end

      subject.execute
    end
  end
end
