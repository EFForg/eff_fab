require 'commands'

RSpec.describe Commands do
  describe "#run" do
    it "creates a new object from the command arg" do
      expect(Commands.run(command: "/where")).to be_a(Commands::Where)
    end
  end
end
