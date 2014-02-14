module Vampire
  # Visitor contains the algorithm you want to run on the hierarchy, defined as visit or visit_with_reference
  # It has default methods for both, subclass and override them with your custom logic, see vampire_spec.rb
  class Visitor
    attr_accessor :node, :depth

    def initialize *args
      self.node ||= 0
      self.depth ||= 0
    end

    # return all objects in hierarchy
    def visit(obj); obj; end

    # compare two hierarchies
    def visit_with_reference(obj, reference_obj); obj == reference_obj; end
  end

  def default_visitor; Visitor.new(self); end

  # calls default visit method defined in Visitor above
  def hierarchy; accept(default_visitor); end

  # calls default visit_with_reference method defined in Visitor
  def compare_hierarchy(reference_obj); accept_with_reference(default_visitor, reference_obj);  end

  # accepts a visitor object, recursively applys to object and all children in the hierarchy
  def accept visitor, *args
    child_vals = []

    parent_val = [visitor.visit(self, *args)]
    if respond_to?(:children)
      visitor.depth += 1
      children.each do |child|
        visitor.node += 1
        child_vals << child.accept(visitor, *args)
      end
      visitor.depth -= 1
    end
    child_vals.any? ? parent_val + child_vals : parent_val
  end

  # recursively apply visitor, using another object with a similar hierarchy as a reference
  # typically this would be used to check for equality
  # (checkout the "compare" method above for a way to do this without having to create a custom visitor)
  def accept_with_reference visitor, reference_obj, *args
    child_vals = []

    parent_val = [visitor.visit_with_reference(self, reference_obj, *args)]
    if respond_to?(:children) && reference_obj.respond_to?(:children) && reference_obj.children && reference_obj.children.any?
      visitor.depth += 1
      reference_obj.children.each_with_index do |ref_child, i|
        if child = children[i]
          visitor.node += 1
          child_vals << child.accept_with_reference(visitor, ref_child, *args)
        end
      end
      visitor.depth -= 1
    end
    child_vals.any? ? parent_val + child_vals : parent_val    
  end

end