require 'finer_struct'

module AWSRaw
  class Credentials < FinerStruct::Immutable(:access_key_id, :secret_access_key)
  end
end

