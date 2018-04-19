require 'ssm_utils/hash_walker'
require 'shared_contexts/sample_config'

RSpec.describe SsmUtils::HashWalker, :stub_aws do
  include_context 'sample config'

  subject { Class.new { include SsmUtils::HashWalker }.new }
  # sample_config is from spec_helper
  let(:the_hash) { sample_config }
  let(:path_delim) { '/' }
  let(:expected_calls) do
    {
      'TestApplication/e2e/DBHosts' =>
        {
          '_value' => 'somedb.example.com,somedb2.example.com',
          '_type'  => 'StringList'
        },
      'TestApplication/e2e/DBUser' => 'app_user',
      'TestApplication/e2e/DBPassword' =>
        {
          '_value' => 'super-secret-password',
          '_type'  => 'SecureString',
          '_key'   => 'alias/myAppKey'
        },
      'TestApplication/e2e/FeatureFlag' =>
        {
          '_value' => true,
          '_type'  => 'String'
        },
      'TestApplication/uat/FeatureFlag' => true
    }
  end

  describe '#walk_hash' do
    it 'calls the provided block with each value and path to it' do
      calls = expected_calls
      subject.walk_hash(the_hash, path_delim) do |path, value|
        expect(value).to eq(calls.delete(path)), 
          "Expected: #{expected_calls[path]}\nValue:#{value}\n"\
          "Path: path=`#{path}`"
      end
      expect(calls).to be_empty, "The following calls were not made: "\
        "#{calls.inspect}"
    end

    it 'returns the hash passed in' do
      r = subject.walk_hash(the_hash, path_delim) { |p, v| nil }
      expect(r).to eq(the_hash)
    end

    it 'raises an error when no block is passed in' do
      expect {subject.walk_hash(the_hash, path_delim)}
        .to raise_error(ArgumentError)
    end

    it 'rasies an error when the hash argument is not a hash' do
      expect {subject.walk_hash(nil, path_delim)}
        .to raise_error(ArgumentError)
    end
  end

  describe '#dig_set' do
    let(:key_list) { ['TestApp','e2e','db_host'] }
    let(:value) { 'db_a,db_b' }
    let(:hash) { Hash.new }

    it 'generates a nested hash for a set of keys' do
      expect(subject.dig_set(hash, key_list, value))
        .to eq({'TestApp' => { 'e2e' => {'db_host' => 'db_a,db_b' } } })
    end

    it 'raises and ArgumentError when the key list is not a list' do
      expect{subject.dig_set(hash, 'db_host', value)}
        .to raise_error(ArgumentError)
    end
  end
end
