require_relative 'validator'
require_relative 'block'
require_relative 'resolver'
require 'pry'
unless Block.find(number: 0).first
  GENESIS_BLOCK = Block.new(number: 0, previous_hash: '', timestamp: Time.now.to_i, data: 'Genesis block', difficulty: 0, nonce: 0)
  GENESIS_BLOCK.calculate_hash
  GENESIS_BLOCK.save
end

GENERATION_INTERVAL = 10
DIFFICULTY_ADJUSTMENT_INTERVAL = 10

module Blockchain
  def self.block_chain
    Block.all.sort(&:number)
  end

  def self.generate_new_block(data)
    previous_block = get_latest_block
    difficulty = get_difficulty
    block = find_block(previous_block.number + 1, previous_block.current_hash, Time.now.to_i, data, difficulty)
    block.save if Validator.valid_block?(block, previous_block)
  end

  def self.find_block(number, previous_hash, timestamp, data, difficulty)
    block = Block.new(number: number, previous_hash: previous_hash, timestamp: timestamp, data: data, difficulty: difficulty, nonce: 0)
    loop do
      block.current_hash = block.calculate_hash
      if Validator.difficulty_match?(block.current_hash, difficulty)
        return block
      end

      block.nonce += 1
    end
  end

  def self.get_latest_block
    block_chain.last
  end

  def self.get_difficulty
    block = get_latest_block
    if (block.number % DIFFICULTY_ADJUSTMENT_INTERVAL).zero? && !block.genesis_block?
      get_adjusted_difficulty
    else
      block.difficulty
    end
  end

  def self.get_adjusted_difficulty
    previous_adjustment_block = block_chain[block_chain.length - DIFFICULTY_ADJUSTMENT_INTERVAL]
    expected_time = DIFFICULTY_ADJUSTMENT_INTERVAL * GENERATION_INTERVAL
    time_taken = get_latest_block.timestamp - previous_adjustment_block.timestamp
    if time_taken < (expected_time / 2)
      previous_adjustment_block.difficulty + 1
    elsif time_taken > (expected_time * 2)
      previous_adjustment_block.difficulty - 1
    else
      previous_adjustment_block.difficulty
    end
  end
end
