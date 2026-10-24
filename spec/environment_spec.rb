require "rails_helper"

RSpec.describe "Test environment" do
  it "runs specs in the test environment" do
    expect(Rails.env).to eq("test")
  end

  it "uses the test database" do
    expect(ActiveRecord::Base.connection_db_config.database).to eq("chata_hub_test")
  end
end
