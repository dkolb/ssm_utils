require 'ssm_utils/ssm_writer_driver'
require 'shared_contexts/sample_config'
require 'shared_contexts/ssm_params'
require 'shared_contexts/put_params'

RSpec.describe SsmUtils::SsmWriterDriver do
  include_context 'sample config'
  include_context 'ssm params'
  include_context 'put params'

  subject { SsmUtils::SsmWriterDriver.new(parameters: sample_config) }

  describe '#write_requests' do
    it 'writes the parameters into AWS' do
      aggregate_failures do 
        expected_aws_calls.each do |call|
          expect(ssm_client_double).to receive(:put_parameter).with(call).once
        end
      end

      subject.write_parameters
    end
  end

  describe '#ssm_requests' do
    it 'reconfigures the parameter hash into the approprate set of calls' do
      expect(subject.ssm_requests).to match_array(expected_aws_calls)
    end
  end
end
