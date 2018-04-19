RSpec.shared_context 'put params' do
  let(:ssm_client_double) { double(Aws::SSM::Client) }

  let(:expected_aws_calls) do
    account_params.map do |param|
      c = param.clone
      c.delete(:version)
      c[:overwrite] = false
      if c[:name] == '/TestApplication/e2e/DBPassword'
        c[:key_id] = 'alias/myAppKey'
      end
      c
    end
  end

  let(:expected_calls_with_no_overwrite) do
    expected_calls.map do |x|
      x[:overwrite] = true
    end
  end

  
  before(:each) {
    expect(Aws::SSM::Client).to receive(:new).and_return(ssm_client_double)
  }
end
