RSpec.describe Moirai::Data do
  let(:instance) { Moirai::Data.new }

  describe "#parents" do
    it "returns a list of parents" do
      expect(instance.parents).to eq(%w[Zeus Themis])
    end
  end
end
