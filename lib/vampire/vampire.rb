module Vampire
  # recursively apply visitor to single object hierarchy
  class Visitor
    attr_accessor :num, :depth

    def initialize *args
      self.num ||= 0
      self.depth ||= 0
    end
  end

  def accept visitor, *args
    child_vals = []

    parent_val = [visitor.visit(self, *args)]
    if respond_to?(:children) && children
      visitor.depth += 1
      children.each do |child|
        visitor.num += 1
        child_vals << child.accept(visitor, *args)
      end
      visitor.depth -= 1
    end
    child_vals.any? ? parent_val + child_vals : parent_val
  end

  # recursively apply visitor, using another object with a similar hierarchy as an input
  def accept_with_reference visitor, reference_obj, *args
    child_vals = []
    if respond_to?(:children) && reference_obj.respond_to?(:children) && reference_obj.children && reference_obj.children.any?
      visitor.depth += 1
      reference_obj.children.each_with_index do |ref_child, i|
        if child = children[i]
          visitor.num += 1
          child_vals << child.accept_with_reference(visitor, ref_child, *args)
        end
      end
      visitor.depth -= 1
    end
    parent_val = [visitor.visit(self, reference_obj, *args)]
    child_vals.any? ? parent_val + child_vals : parent_val    
  end

end