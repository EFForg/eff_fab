require 'commands/add_fab_back'

RSpec.describe Commands::AddFabBack do
  let(:user) { FactoryGirl.create(:user) }
  let(:body) { "This week I wrote a Mattermost command for updating FABs" }
  let(:username) { user.username }
  let(:extra_args) { {} }
  let(:args) { { user_name: username, text: body }.merge(extra_args) }

  before { ENV['MATTERMOST_TOKEN_ADDFABBACK'] = 'valid_token' }

  describe ".response" do
    subject(:response_body) { described_class.new(args).response }

    it "responds with failure" do
      expect(response_body.keys).to eq([:failure])
    end

    context "with valid token" do
      let(:extra_args) { { token: 'valid_token' } }

      it "creates a Fab note for the user" do
        expect { response_body }.to change(user.fabs, :count).by(1)
        expect(user.fabs.last.backward.pluck(:body)).to include(body)
      end

      it "responds with the necessary keys" do
        expect(response_body.keys).to match_array(
          [:response_type, :text, :username]
        )
      end

      it "sets the response_type" do
        expect(response_body[:response_type]).to eq("ephemeral")
      end

      it "sets the text" do
        expect(response_body[:text]).to eq(
          "You've added \"#{body}\" to this week's FAB."
        )
      end

      context "when the user already has a fab" do
        let!(:fab) { user.fabs.create(period: Fab.get_start_of_current_fab_period) }

        it "doesn't create a new fab" do
          expect { response_body }.to change(user.fabs, :count).by(0)
        end

        it "edits a note for the existing fab" do
          expect { response_body }.to change(
            user.fabs.last.backward.where(body: nil), :count
          ).by(-1)
          expect(user.fabs.last.backward.pluck(:body)).to include(body)
        end

        context "and there are no blank notes" do
          before do
            fab.notes.each { |n| n.update(body: Faker::ChuckNorris.fact) }
          end

          it "idk, what does it do?" do
            expect { response_body }.to change(fab.backward, :count).by(1)
            expect(fab.backward.pluck(:body)).to include(body)
          end
        end
      end

      context "when username contains an @" do
        let(:username) { "@#{user.username}" }

        it "finds the correct user" do
          expect { response_body }.to change(user.fabs, :count).by(1)
        end
      end

      context "when user is not found" do
        let(:username) { "nope" }

        it "returns a friendly message" do
          expect(response_body[:text]).to match(/I couldn't save your FAB/)
        end
      end

      context "failure" do
        before { allow_any_instance_of(Note).to receive(:save).and_return(false) }

        it "responds with the necessary keys" do
          expect(response_body.keys).to match_array(
            [:response_type, :text, :username]
          )
        end

        it "sets the response_type" do
          expect(response_body[:response_type]).to eq("ephemeral")
        end

        it "sets the text" do
          expect(response_body[:text]).to eq(
            "I couldn't save your FAB. Better set it at https://fab.eff.org/ :sweat_smile:"
          )
        end
      end
    end
  end
end
