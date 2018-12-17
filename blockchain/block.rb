# require 'ohm'
require 'digest'
class Block # < Ohm::Model
  # attribute :number
  # attribute :hash
  # attribute :previous_hash
  # attribute :timestamp
  # attribute :data
  attr_accessor :number, :current_hash, :previous_hash, :timestamp, :data, :difficulty, :nonce

  def initialize(number, previous_hash, timestamp, data, difficulty, nonce = 0)
    @number = number
    @previous_hash = previous_hash
    @timestamp = timestamp
    @data = data
    @difficulty = difficulty
    @nonce = nonce
    @current_hash = calculate_hash
  end

  def calculate_hash
    Digest::SHA256.hexdigest "#{number}#{previous_hash}#{data}#{nonce}"
  end

  def genesis_block?
    number.zero?
  end
end

