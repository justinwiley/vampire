require 'spec_helper'

# test classes

class Item
  attr_accessor :name
  attr_accessor :children
  include Vampire
  def initialize(name); self.name = name; end
end

class Company < Item
end

class Category < Item
end

class Product < Item
end

# visitors

class ReturnName < Vampire::Visitor
  def visit obj, *args
    obj.name
  end
end

class SteveJobsifier < Vampire::Visitor
  def visit obj, *args
    "#{obj.name} - the most #{args.join(', ')} thing you've ever seen"
  end
end

class DisplayHierarchy < Vampire::Visitor
  def visit obj, *args
    "#{"  " * self.depth}#{obj.name} - id #{self.depth}:#{self.node}"
  end
end

class SetToReferenceName < Vampire::Visitor
  def visit_with_reference obj, ref_obj, *args
    obj.name = ref_obj.name
  end
end


describe Vampire do
  let(:company) { Company.new 'Pancakes Inc.' }
  let(:cat) { Category.new 'Traditional' }
  let(:cat2) { Category.new 'Old Timey' }
  let(:cat3) { Category.new 'Healthy' }
  let(:prod) { Product.new 'Buttermilk Pancake' }
  let(:prod2) { Product.new 'Hand-rolled Artesianal Bread Disk' }
  let(:prod3) { Product.new 'Ancient Grains' }
  let(:expected_company_hierarchy) { [company, [cat, [prod]], [cat2, [prod2]], [cat3, [prod3]]] }
  let(:expected_hierarchy_comparison) { [false, [true, [true]], [false, [false]]] }

  let(:company2) { Company.new 'McButters Pancakes Inc.' }
  let(:cat4) { Category.new 'Extra Delicious' }
  let(:prod4) { Product.new("McButters Fluffy Pancake")}

  before do
    cat.children = [prod]
    cat2.children = [prod2]
    cat3.children = [prod3]
    company.children = [cat,cat2,cat3]

    company2.children = [cat, cat4]
    cat4.children = [prod4]
  end

  describe Vampire::Visitor do
    let(:visitor) { Vampire::Visitor.new }

    it 'should define accessors for current node in tree, and current depth, initialized to zero by default' do
      visitor.node.should be_zero
      visitor.depth.should be_zero
    end

    it '#visit should define a default visit method returning the current object' do
      company.accept(visitor).should == expected_company_hierarchy
    end

    it '#visit_with_reference should define a default visit method comparing ' do
      company.accept_with_reference(visitor, company2).should == expected_hierarchy_comparison
    end
  end

  it '#hierarchy should alias default visitor method to return current object' do
    company.hierarchy.should == expected_company_hierarchy
  end

  it '#compare_hierarchy should alias default visitor visit_with_reference' do
    company.compare_hierarchy(company2).should == expected_hierarchy_comparison
  end

  describe '#accept' do
    it 'should execute given visitor against host model, each child in the defined hierarchy' do
      cat.children = [prod]
      cat2.children = [prod2]
      company.children = [cat,cat2]
      company.accept(ReturnName.new).should == ["Pancakes Inc.", 
        ["Traditional", ["Buttermilk Pancake"]],
        ["Old Timey", ["Hand-rolled Artesianal Bread Disk"]]
      ]
    end

    it 'should accept multiple, optional arguments, apply them along with host object' do
      require 'pp'
      pp company.accept(SteveJobsifier.new, 'Amazing', 'Exceptional')
      company.accept(SteveJobsifier.new, 'Amazing', 'Exceptional').should == [
        "Pancakes Inc. - the most Amazing, Exceptional thing you've ever seen"
      ]
    end

    it 'should expose depth and number' do
      company.accept(DisplayHierarchy.new).should == ["Pancakes Inc. - id 0:0", 
        ["  Traditional - id 1:1", 
          ["    Buttermilk Pancake - id 2:2"]], 
          ["  Old Timey - id 1:3", ["    Hand-rolled Artesianal Bread Disk - id 2:4"]], 
          ["  Healthy - id 1:5", ["    Ancient Grains - id 2:6"]
        ]
      ]
    end
  end

  describe '#accept_with_reference' do
    it 'should execute given visitor against host model, using another model with similar hierarchy as reference' do
      company.accept_with_reference(SetToReferenceName.new,company2)
      company.hierarchy.should == expected_company_hierarchy
      company.name.should == company2.name
      company.children.map(&:name).should ==  ["Traditional", "Extra Delicious", "Healthy"]
      company.children.map(&:children).flatten.map(&:name).should == ["Buttermilk Pancake", "McButters Fluffy Pancake", "Ancient Grains"]
    end
  end
end