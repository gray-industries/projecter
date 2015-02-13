require 'commands/create'

shared_examples_for 'a project' do
  let(:project) { 'test_project' }

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
  end
end

RSpec.describe ProjecterCLI do
  describe '#create_project_dirs' do
    let(:project) { 'test_project' }
    let(:options) do
      {
        library: library
      }
    end

    subject do
      described_class.class_options(
        quiet: true,
        pretend: true
      )
      described_class.new([], library: library)
    end

    before do
      allow(subject).to receive(:empty_directory).and_return(true)
    end

    after do
      subject.create(project)
    end

    context 'when in library mode' do
      let(:library) { true }
      it_behaves_like 'a project'

      it 'does not create lib/commands' do
        expect(subject).not_to receive(:empty_directory).with(File.join(project, 'lib/commands'))
        subject.create(project)
      end

      it 'does not create a main app' do
        expect(subject).not_to receive(:chmod).with(File.join(project, 'bin', project), 0755)
        subject.create(project)
      end
    end

    context 'when not in library mode' do
      let(:library) { false }
      let(:main_app) { File.join(project, 'bin', project) }
      it_behaves_like 'a project'

      before do
        allow(File).to receive(:stat).with(main_app) { double('dirent', mode: 0644) }
        allow(subject).to receive(:chmod).with(main_app, 0755).and_return(true)
      end

      it 'makes the main app executable' do
        expect(File).to receive(:stat).with(main_app) { double('dirent', mode: 0644) }
        expect(subject).to receive(:chmod).with(main_app, 0755).and_return(true)
      end

      %w(unit integration acceptance).each do |dir|
        it "creates spec/#{dir}/lib/commands" do
          expect(subject).to receive(:empty_directory).with(File.join(project, 'spec', dir, 'lib/commands'))
        end
      end
    end
  end
end
