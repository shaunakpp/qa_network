class Validator
  def self.valid_block?(new_block, previous_block)
    return true if new_block.genesis_block?
    rules = [
      (new_block.number != previous_block.number + 1),
      (new_block.previous_hash != previous_block.current_hash),
      (new_block.calculate_hash != new_block.current_hash),
      !valid_timestamp?(new_block, previous_block)
    ]
    rules.any? { |rule| rule == true } ? false : true
  end

  def self.valid_chain?(chain)
    chain.map.with_index { |block, index| valid_block?(block, chain[index - 1]) }.none? { |x| x == false }
  end

  def self.difficulty_match?(hash, difficulty)
    hex_to_binary(hash).start_with?('0' * difficulty)
  end

  def self.valid_timestamp?(block, previous_block)
    (previous_block.timestamp - 60 < block.timestamp) && (block.timestamp - 60 < Time.now.to_i)
  end

  def self.hex_to_binary(hex)
    dictionary = { '0' => '0000', '1' => '0001', '2' => '0010', '3' => '0011', '4' => '0100', '5' => '0101', '6' => '0110', '7' => '0111', '8' => '1000', '9' => '1001', 'a' => '1010', 'b' => '1011', 'c' => '1100', 'd' => '1101', 'e' => '1110', 'f' => '1111' }
    hex.each_char.collect { |c| dictionary[c] }.join
  end
end

