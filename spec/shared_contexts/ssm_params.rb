RSpec.shared_context "ssm params" do
  let(:db_password_param) do
    {
      name: '/TestApplication/e2e/DBPassword',
      value: 'super-secret-password',
      type: 'SecureString',
      version: 2
    }
  end

  let(:account_params) do
    [
      { 
        name: '/TestApplication/e2e/DBHosts',
        value: 'somedb.example.com,somedb2.example.com',
        type: 'StringList',
        version: 4,
      }, {
        name: '/TestApplication/e2e/DBUser',
        value: 'app_user',
        type: 'String',
        version: 5,
      }, {
        name: '/TestApplication/e2e/FeatureFlag',
        value: 'true',
        type: 'String',
        version: 1
      }, {
        name: '/TestApplication/uat/FeatureFlag',
        value: 'true',
        type: 'String',
        version: 1
      }, db_password_param
    ]
  end

  let(:db_password_history) do
    default = {
      name: '/TestApplication/e2e/DBPassword',
      type: 'SecureString',
      key_id: 'alias/myAppKey',
      version: 2,
      value: 'AQICAHgjsA2ZGcSGqxgvWL2jWnyL6y0TbyeWODcc7l==',
    }

    prior = default.clone
    prior[:version] = 1
    prior[:value] = 'AIBADBzBgkqhkiG9w0BBwEwHgYJY=='

    [ default, prior ]
  end

  before(:each, :stub_aws) do
    Aws.config[:ssm] ||= {}
    Aws.config[:ssm][:stub_responses] = {
      get_parameters_by_path: {
        parameters: account_params
      },
      get_parameter_history: {
        parameters: db_password_history
      }
    }
  end

  after(:each, :stub_aws) do
    Aws.config[:ssm].delete(:stub_responses)
  end
end
