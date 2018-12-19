require 'ohm'
require 'ohm/contrib'
require 'digest'
Ohm.redis = Redic.new('redis://127.0.0.1:6379')
class Block < Ohm::Model
  include Ohm::DataTypes

  attribute :number, Type::Integer
  attribute :current_hash
  attribute :previous_hash
  attribute :timestamp, Type::Integer
  attribute :type
  attribute :data
  attribute :difficulty, Type::Integer
  attribute :nonce, Type::Integer

  index :number
  index :current_hash
  index :previous_hash
  index :data
  index :type

  def calculate_hash
    self.current_hash = Digest::SHA256.hexdigest "#{number}#{previous_hash}#{data}#{nonce}"
  end

  def genesis_block?
    number.zero?
  end

  def ui_json
    attributes.merge(to_hash)
  end
end

