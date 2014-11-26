require 'openssl'

# Validates that an attribute contains a valid PEM-encoded key.
class PemKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    begin
      OpenSSL::PKey.read value
    rescue ArgumentError => e
      record.errors.add attr, e.message
    end
  end
end
