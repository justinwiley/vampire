require 'spec_helper'

# test classes

class TestItem
  attr_accessor :name
  include Vampire
  def initialize(name); self.name = name; end
end

class TestCompany < TestItem
  attr_accessor :children
end

class TestCategory < TestItem
  attr_accessor :children
end

class TestProduct < TestItem
end

# visitors

class ReturnName
  def visit obj, *args
    obj.name
  end
end

class Barlow
  def visit obj, *args
    obj.name
  end
end

class SteveJobsifier
  def visit obj, *args
    "#{obj.name} - the most #{args.join(', ')} thing you've ever seen"
  end
end

class SetToReferenceName
  def visit obj, ref_obj, *args
    obj.name = ref_obj.name
  end
end

describe Vampire do
  let(:company) { TestCompany.new 'Pancakes Inc.' }
  let(:cat) { TestCategory.new 'Traditional' }
  let(:cat2) { TestCategory.new 'Portland' }
  let(:prod) { TestProduct.new 'Buttermilk Pancake' }
  let(:prod2) { TestProduct.new 'Hand-rolled Artesianal Bread Disk' }

  let(:company2) { TestCompany.new 'another company.' }
  let(:cat3) { TestCategory.new 'Misc' }

  before do
    cat.children = [prod]
    cat2.children = [prod2]
    company.children = [cat,cat2]
    company2.children = [cat3]
  end

  describe '#accept' do
    it 'should execute given visitor against host model, each child in the defined hierarchy' do
      cat.children = [prod]
      cat2.children = [prod2]
      company.children = [cat,cat2]
      company.accept(ReturnName.new).should == ["Pancakes Inc.", 
        ["Traditional", ["Buttermilk Pancake"]],
        ["Portland", ["Hand-rolled Artesianal Bread Disk"]]
      ]
    end

    it 'should accept multiple, optional arguments, apply them along with host object' do
      company.children = []
      company.accept(SteveJobsifier.new, 'Amazing', 'Exceptional').should == [
        "Pancakes Inc. - the most Amazing, Exceptional thing you've ever seen"
      ]
    end
  end

  describe '#accept_with_reference' do
    it 'should execute given visitor against host model, using another model with similar hierarchy as reference' do
      company.accept_with_reference(SetToReferenceName.new,company2)
      company.name.should == company2.name
      company.children.map(&:name).should ==  ['Misc','Portland']
    end
  end
end