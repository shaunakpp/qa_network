require_relative 'validator'
require_relative 'block'
require_relative 'resolver'
GENESIS_BLOCK = Block.new(0, '', Time.now.to_i, 'Genesis block', 0)

GENERATION_INTERVAL = 10
DIFFICULTY_ADJUSTMENT_INTERVAL = 10

module Blockchain
  def self.block_chain
    @chain
  end

  def self.block_chain=(chain)
    @chain = chain
  end

  def self.generate_new_block(data)
    previous_block = get_latest_block
    difficulty = get_difficulty
    block = find_block(previous_block.number + 1, previous_block.current_hash, Time.now.to_i, data, difficulty)
    block_chain.push(block) if Validator.valid_block?(block, previous_block)
  end

  def self.find_block(number, previous_hash, timestamp, data, difficulty)
    block = Block.new(number, previous_hash, timestamp, data, difficulty)
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

Blockchain.block_chain = [GENESIS_BLOCK]
