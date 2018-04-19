require 'ssm_utils/ssm_reader_driver'
require 'shared_contexts/ssm_params'
require 'shared_contexts/sample_config'

RSpec.describe SsmUtils::SsmReaderDriver, :stub_aws do
  include_context 'ssm params'
  include_context 'sample config'

  Struct.new("AwsIteratorStub") do
    def each
      yield Aws::SSM::Types::GetParametersByPathResult.new(
          parameters: []
      )
    end
  end

  subject do
    SsmUtils::SsmReaderDriver.new()
  end

  describe "#raw_params" do
    it 'calls AWS SSM and retrieves all paths in the account' do
      expect(subject.raw_account_params).to match_array(account_params)
    end

    it 'caches the result' do
      ssm = double(Aws::SSM::Client)
      expect(ssm).to receive(:get_parameters_by_path)
        .once
        .and_return(Struct::AwsIteratorStub.new)
        
      expect(Aws::SSM::Client).to receive(:new).once.and_return(ssm)

      sbjct = SsmUtils::SsmReaderDriver.new
      sbjct.raw_account_params
      sbjct.raw_account_params
    end

    it 'passes in no decryption when decyrpt flag is false' do
      ssm = double(Aws::SSM::Client)

      expect(ssm).to receive(:get_parameters_by_path)
        .with(hash_including(:with_decryption => false))
        .once
        .and_return(Struct::AwsIteratorStub.new)
      expect(Aws::SSM::Client).to receive(:new).once.and_return(ssm)

      sbjct = SsmUtils::SsmReaderDriver.new(decrypt: false)
      sbjct.raw_account_params
    end
  end

  describe "#account_params" do
    let(:expected_result) do 
      # Just reuse the sample config for posting things to SSM but correct stuff
      # that we are expecting to be normalized.
      result = sample_config 
      result['TestApplication']['e2e']['FeatureFlag'] = 'true'
      result['TestApplication']['uat']['FeatureFlag'] = 'true'
      result
    end 
    it "reconfigures the aboslute paths into a nested hash" do
      expect(subject.account_params).to eq(expected_result)
    end
  end

  describe "#encryption_key" do
    it 'returns the key given a raw account parameter hash' do
      expect(subject.encryption_key(db_password_param))
        .to eq('alias/myAppKey')
    end
  end

  describe "#key_list" do
    it 'breaks the path up by slashes' do
      expect(subject.key_list('/First/Second/Third'))
        .to eq(['First', 'Second', 'Third'])
    end

    it 'handles one element' do
      expect(subject.key_list('/First'))
        .to eq(['First'])
    end

    it 'handles no leading slash' do
      expect(subject.key_list('First/Second'))
        .to eq(['First', 'Second'])
    end
  end
end
