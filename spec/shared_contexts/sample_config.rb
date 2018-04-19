require 'yaml'

RSpec.shared_context "sample config" do
  let(:sample_config_string) do
    File.read(File.expand_path(File.join(
      __dir__, '..', 'fixtures', 'sample_config.yml'
    )))
  end

  let(:sample_config) do
    YAML.load(sample_config_string)
  end
end
