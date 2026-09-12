module AST
  Literal  = Struct.new(:value)
  Grouping = Struct.new(:expression)
  Unary    = Struct.new(:operator, :right)
  Binary   = Struct.new(:left, :operator, :right)
end
