require 'rotp'
module OtpAuthenticator

  def self.authentication_times
    @authentication_times ||= {}
  end

  def self.authenticator_for(user_id)
    ROTP::TOTP.new PASSWD[user_id]
  end

  def self.valid?(user_id, password)
    verification = authenticator_for(user_id).verify_with_drift_and_prior(password, 0, authentication_times[user_id])
    if verification
      authentication_times[user_id] = verification
      true
    end
  end

end
