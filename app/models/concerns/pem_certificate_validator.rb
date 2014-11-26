require 'openssl'

# Validates that an attribute contains a valid PEM-encoded certificate.
class PemCertificateValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    begin
      OpenSSL::X509::Certificate.new value
    rescue OpenSSL::X509::CertificateError => e
      record.errors.add attr, e.message
    end
  end
end

