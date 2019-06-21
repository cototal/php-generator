# frozen_string_literal: true

RSpec.describe Pgen::Generate do
  subject { Pgen::Generate.new(File.join("sample"), File.join("output")) }
  it "can be initialized with a yaml directory" do
    expect(subject.yaml_dir).to eq "sample"
  end

  it "can list files" do
    expect(subject.files.count).to eq 1
  end

  it "parses the files as YAML" do
    subject.collect
    content = subject.data.values[0]
    expect(content).to be_a Hash
  end

  it "outputs a file based on the YAML" do
    subject.run
    expect(File.exist?(File.join("output", "sample", "a1.php"))).to be true
  end
end
