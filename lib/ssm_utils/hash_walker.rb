module SsmUtils
  module HashWalker

    class Walker
      def initialize(hash, path_delim, block)
        @hash = hash
        @path_delim = path_delim
        @block = block
      end

      def walk
        walker(nil, @hash)
      end


      private

      def walker(path, node)
        if valid_value_hash? node
          @block.yield(path, node)
        elsif node.is_a? Hash
          node.each do |key, value|
            #nil path = "" + "" + {key}
            #non-nill path = {path} + {path_delim} + {key}
            walker("#{path}#{path.nil? ? "" : @path_delim}#{key}", value)
          end
        else
          @block.yield(path, node)
        end
      end

      def valid_value_hash?(node)
        return false unless node.is_a?(Hash) && node.has_key?('_value') 
        if node.has_key?('_type') && node['_type'] == 'SecureString'
          return false unless node.has_key? '_key'
        end
        true
      end
    end

    # For a hash { 'a' => { 'b' => { 'c' => 'd' } } } this function will
    # yield to the provided block ('a/b/c', 'd'). Furthermore, hashs containing
    # the keys '_value' and '_type' will be interpreted as leaves and will not
    # be walked into and instead yielded to the block.
    def walk_hash(hash, path_delim, &block)
      raise ArgumentError.new("Block required") unless block_given?

      if !hash.is_a? Hash
        raise ArgumentError.new("Cannot walk things that aren't hashes")
      end

      Walker.new(hash, path_delim.to_s, block).walk
      hash
    end

    #Recursive safe-setting of keys
    def dig_set(hash, key_list, value)
      if !key_list.is_a? Array || key_list.length < 1
        raise ArgumentError.new("Key list cannot be empty or a non-array")
      elsif key_list.length == 1
        hash[key_list[0]] = value
      else
        if hash[key_list[0]].nil?
          hash[key_list[0]] = {}
        end
        dig_set(hash[key_list[0]], key_list[1..-1], value)
        hash
      end
    end
  end
end
