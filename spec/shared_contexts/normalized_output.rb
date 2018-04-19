RSpec.shared_context "normalized output" do
  let(:normalized_output) do
    File.read(File.expand_path(File.join(
      __dir__, '..', 'fixtures', 'normalized_output.yml'
    )))
  end
end
