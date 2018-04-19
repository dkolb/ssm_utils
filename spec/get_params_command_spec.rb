require 'tempfile'
require 'ssm_utils/get_params_command'
require 'shared_contexts/ssm_params'
require 'shared_contexts/normalized_output'

RSpec.describe SsmUtils::GetParamsCommand, :stub_aws do
  include_context 'ssm params'
  include_context 'normalized output'

  let(:temp_file_path) do
    file = Tempfile.new('test') 
    path = file.path
    file.close
    file.unlink
    path
  end

  after(:each) do
    File.delete(temp_file_path)
  end
  
  subject do 
    SsmUtils::GetParamsCommand.new(
      file_out: temp_file_path
    )
  end

  describe '#execute' do
    it 'writes out to the specified path' do
      subject.execute
      expect(File).to exist(temp_file_path)
    end

    it 'writes the expected contents' do
      subject.execute
      expect(File.read(temp_file_path)).to eq(normalized_output)
    end
  end
end
