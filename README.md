# Vampire

Vampire is a simple implementation of the visitor pattern in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'vampire'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vampire

## Usage

The visitor pattern "seperates the algorithm from object hierarchy".  What this means in practice is it allows you to focus on what you want to change in a hierarchy of objects, instead of writing boilerplate to recursively walk it.

For example, imagine you have a hierarchical set of objects that describe a company, categories of products, and the products themselves.  Each object has a name attribute.

```ruby
class Item
  attr_accessor :name
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

company = Company.new 'Pancakes Inc.'
cat = Category.new 'Traditional'
cat2 = Category.new 'Old Timey'
cat3 = Category.new 'Healthy'
prod = Product.new 'Buttermilk Pancake'
prod2 = Product.new 'Hand-rolled Artesianal Bread Disk'
prod3 = Product.new 'Ancient Grains'
```

Imagine marketing asks you to spice up the name of each item by throwing a set of adjectives on each.  So you whip up a recursive function, problem solved.

At some point down the road, it turns out you need to .  Once again, you write a recursive function similar to the first.  You notice there's a chance to dry all of this up.  But how?

You stumble across this charming, innocent looking gem.  It's perfectly willing to help, all you have to do is invite it in.

```ruby
class Item
  include Vampire
  attr_accessor :name
  def initialize(name); self.name = name; end
end
```

You pull out the name change code, and create a seperate class with a single method "visit", that describes the action to take on each object in the heirarchy.

```ruby
class SteveJobsifier < Vampire::Visitor
  def visit obj, *args
    obj.name = "#{obj.name} - the most #{args.join(', ')} thing you've ever seen"
  end
end
```

It shouldn't inclu

```ruby
company.accept(SteveJobsifier.new, "Amazing", "Exceptional")
 => ["Oats Inc - the most Amazing, Exceptional thing you've ever seen", ["Whole Grain - the most  thing you've ever seen", ["Modern - the most  thing you've ever seen"], ["Pappy's Old Fashioned - the most  thing you've ever seen"]]]
```
Great.  But it shouldn't update the name of the company itself.

class SteveJobsifier
  def visit obj, *args
    depth ||= 0
    obj.name = "#{obj.name} - the most #{args.join(', ')} thing you've ever seen" if depth > 0
    depth += 1
  end
end
company.accept(SteveJobsifier.new, "Amazing", "Exceptional")


Pancakes Inc. - id 0:0
  Traditional - id 1:1
    Buttermilk Pancake - id 2:2
  Old Timey - id 1:3
    Hand-rolled Artesianal Bread Disk - id 2:4
  Healthy - id 1:5
    Ancient Grains - id 2:6


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
