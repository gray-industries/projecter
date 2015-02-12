require 'commands/create'

shared_examples_for 'a library' do
  let(:project) { 'test_project' }

  subject do
    described_class.class_options(
      quiet: true,
      pretend: true
    )
    described_class.new(['--library'])
  end

  after do
    subject.create(project)
  end

  it 'creates project lib dir' do
    expect(subject).to receive(:empty_directory).with(File.join(project, 'lib', project))
  end

  %w(unit integration acceptance).each do |dir|
    it "creates spec/#{dir}/lib/project" do
      expect(subject).to receive(:empty_directory).with(File.join(project, 'spec', dir, 'lib', project))
    end

    it "creates spec/#{dir}/lib/commands" do
      expect(subject).to receive(:empty_directory).with(File.join(project, 'spec', dir, 'lib/commands'))
    end
  end
end

RSpec.describe ProjecterCLI do
  describe '#create_project_dirs' do
    let(:project) { 'test_project' }

    before do
      allow(subject).to receive(:empty_directory).and_return(true)
    end

    context 'when in library mode' do
      it_behaves_like 'a library'
    end

    context 'when not in library mode' do
      it_behaves_like 'a library'
    end

  end
end
