require 'spec_helper'

# test classes

class Item
  attr_accessor :name
  include Vampire
  def initialize(name); self.name = name; end
end

class Company < Item
  attr_accessor :children
end

class Category < Item
  attr_accessor :children
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
    "#{"  " * self.depth}#{obj.name} - id #{self.depth}:#{self.num}"
  end
end

class SetToReferenceName < Vampire::Visitor
  def visit obj, ref_obj, *args
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

  let(:company2) { Company.new 'another company.' }
  let(:cat4) { Category.new 'Misc' }

  before do
    cat.children = [prod]
    cat2.children = [prod2]
    cat3.children = [prod3]
    company.children = [cat,cat2,cat3]
    company2.children = [cat4]
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
      company.children = []
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
      company.name.should == company2.name
      company.children.map(&:name).should ==  ['Misc','Old Timey', 'Healthy']
    end
  end
end