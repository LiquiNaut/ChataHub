require "rails_helper"

# Session and encrypted cookies are read this way, see #96
RSpec.describe ActiveSupport::MessageEncryptor do
  it "reads back a JSON message with metadata" do
    encryptor = described_class.new(SecureRandom.bytes(32), serializer: :json)
    message = encryptor.encrypt_and_sign({ "user" => 1 }, purpose: :cookie)

    expect(encryptor.decrypt_and_verify(message, purpose: :cookie)).to eq("user" => 1)
  end
end
