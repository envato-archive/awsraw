require 'finer_struct'

class Credentials < FinerStruct::Immutable(:access_key_id, :secret_access_key)
end

