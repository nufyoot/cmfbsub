require "helper"

set :environment, :test

describe "The Campaign Monitor Subscribe Form app" do
  let(:app) { Sinatra::Application }
  let(:client_id) { ENV["GITHUB_CLIENT_ID"] }
  let(:client_secret) { ENV["GITHUB_CLIENT_SECRET"] }

  describe "GET /" do
    context "when there's no session for the user" do
      it "redirects to request authorisation" do
        get "/"

        expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
        expect(last_request.env["rack.session"]["fb_token"]).to be_nil
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq("http://example.org/auth/facebook")
      end
    end

    context "when there's a session for the user but it doesn't match the current fb user" do
      it "clears the session and redirects to request authorisation" do
        get "/",
          { "facebook" => { "user_id" => 7654321 } },
          { "rack.session" => { "fb_auth" => { "uid" => 1234567 } } }

        expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
        expect(last_request.env["rack.session"]["fb_token"]).to be_nil
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq("http://example.org/auth/facebook")
      end
    end
  end

  describe 'GET /auth/failure' do
    it "clears the session and redirects to /" do
      get "/auth/failure"

      expect(last_request.env["rack.session"]["fb_auth"]).to be_nil
      expect(last_request.env["rack.session"]["fb_token"]).to be_nil
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/")
    end
  end

  describe "GET /privacy" do
    it "shows the privacy page" do
      get "/privacy"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to \
        include("The Campaign Monitor Subscribe Form app respect's the privacy of people who use it")
    end
  end

end
