module Vampire
  # recursively apply visitor to single object hierarchy
  def accept visitor, *args
    child_vals = []
    if respond_to?(:children)
      children.each do |child|
        child_vals << child.accept(visitor)
      end
    end
    parent_val = [visitor.visit(self, *args)]
    child_vals.any? ? parent_val + child_vals : parent_val
  end

  # recursively apply visitor, using another object with a similar hierarchy as an input
  def accept_with_reference visitor, reference_obj, *args
    child_vals = []
    if respond_to?(:children) && reference_obj.respond_to?(:children) && reference_obj.children && reference_obj.children.any?
      reference_obj.children.each_with_index do |ref_child, i|
        if child = children[i]
          child_vals << child.accept_with_reference(visitor, ref_child, *args)
        end
      end
    end
    parent_val = [visitor.visit(self, reference_obj, *args)]
    child_vals.any? ? parent_val + child_vals : parent_val    
  end

end