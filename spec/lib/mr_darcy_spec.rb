require 'spec_helper'

describe MrDarcy do
  it { should be }
  it { should respond_to :driver }
  it { should respond_to :driver= }

  describe '#promise' do
    When 'no driver is specified' do
      subject { MrDarcy.promise {} }

      it 'uses whichever driver is the default' do
        expect(MrDarcy).to receive(:driver).and_return(:thread)
        subject
      end
    end
  end
end
