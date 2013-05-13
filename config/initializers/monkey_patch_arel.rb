# From https://github.com/rails/arel/issues/149
# Also fixes https://github.com/rails/rails/issues/9263

module Arel
  module Nodes
    class SqlLiteral < String
      def encode_with(coder)
        coder['string'] = to_s
      end
      def init_with(coder)
        clear << coder['string']
      end
    end
  end
end