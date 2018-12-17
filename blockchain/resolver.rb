class Resolver
  def self.replace_chain(new_chain)
    if Validator.valid_chain?(new_chain) && get_accumulated_difficulty(new_chain) > get_accumulated_difficulty(Blockchain.block_chain)
      Blockchain.block_chain = new_chain
    else
      puts 'invalid blockchain'
    end
  end

  def self.get_accumulated_difficulty(chain)
    chain.map{ |x| 2**x.difficulty }.reduce(:+)
  end
end

