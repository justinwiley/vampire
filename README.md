# Vampire

Vampire is a simple implementation of the visitor pattern in Ruby.

<img src="http://upload.wikimedia.org/wikipedia/commons/1/19/Bela_lugosi_dracula.jpg"
 alt="Vampire" title="Vampire" height=240 width=315 />

## Installation

Add this line to your application's Gemfile:

    gem 'vampire'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vampire

## Usage

The [visitor pattern](http://butunclebob.com/ArticleS.UncleBob.IuseVisitor) "separates the algorithm from object hierarchy".  What this means in practice is it allows you to focus on what you want to change in a hierarchy of objects, instead of writing boilerplate to recursively walk it.

This is essentially a way to work around Ruby's lack of support for [double-dispatch](http://lostechies.com/derekgreer/2010/04/19/double-dispatch-is-a-code-smell/).

For example, imagine you have a hierarchical set of objects that describe a company, categories of products, and the products themselves.  Each object has a "children" accessor that contains pointers to objects underneath it in the hierarchy.


```ruby
class Item
  attr_accessor :name, :children
  def initialize(name); self.name = name; end
end

class Company < Item; end

class Category < Item; end

class Product < Item; end

company = Company.new 'Pancakes Inc.'
cat = Category.new 'Traditional'
cat2 = Category.new 'Old Timey'
cat3 = Category.new 'Healthy'
prod = Product.new 'Buttermilk Pancake'
prod2 = Product.new 'Hand-rolled Artisanal Bread Disk'
prod3 = Product.new 'Ancient Grains'

cat.children = [prod]
cat2.children = [prod2]
cat3.children = [prod3]
company.children = [cat,cat2,cat3]
```

Here we used [PORO](http://blog.jayfields.com/2007/10/ruby-poro.html)s, but this could also apply to an ActiveRecord hierarchy (see caveats below).

This gives you a hierarchy that looks like:

```
Pancakes Inc.
  Traditional
    Buttermilk Pancake
  Old Timey
    Hand-rolled Artisanal Bread Disk
  Healthy
    Ancient Grains
```

Imagine marketing asks you to spice up the name of each item by throwing a set of adjectives on the front of each description.  You whip up a recursive function that walks the hierarchy and updates the description as appopriate.

```
Awesome Pancakes Inc.
  Traditional
    Awesome Buttermilk Pancake
  Old Timey
    Awesome Hand-rolled Artesianal Bread Disk
  Healthy
    Awesome Ancient Grains
```

Months go by, and a new marketing visionary joins and asks you to update these descriptions, but with totally different rules.

Your dust-off your recursive function,  but it's now getting a little unweildy, and difficult to test.  Enter this charming gem.  It's perfectly willing to help, all you have to do is invite it into your object hierarchy.

#### Traversing an object hierarchy

```ruby
class Item
  include Vampire  # so happy to make your acquaintance
  ...
end
```

You look at your old recursive method, and create a separate class with a single method "visit", that inherits from Vampire::Visitor and describes the action to take on each object in the heirarchy.

```ruby
class SteveJobsifier < Vampire::Visitor
  def visit obj, *args
    obj.name = "#{obj.name} - the most #{args.join(', ')} thing you've ever seen"
  end
end
```

Visit is called by the corresponding method that was injected when you included Vampire in your object hierarcy "accept".  An instance of the SteveJobsifier will be passed down the hierarchy, working its magic:

```ruby

company = Company.first

company.accept(SteveJobsifier.new, "Amazing", "Exceptional")
=>
["Pancakes Inc. - the most Amazing, Exceptional thing you've ever seen",
 ["Traditional - the most Amazing, Exceptional thing you've ever seen",
  ["Buttermilk Pancake - the most Amazing, Exceptional thing you've ever seen"]],
 ["Old Timey - the most Amazing, Exceptional thing you've ever seen",
  ["Hand-rolled Artesianal Bread Disk - the most Amazing, Exceptional thing you've ever seen"]],
 ["Healthy - the most Amazing, Exceptional thing you've ever seen",
  ["Ancient Grains - the most Amazing, Exceptional thing you've ever seen"]]]
```

So you can chuck all the old recursive code and just keep this simple class.  Note the structure returned: a hierarchical array of arrays.

"But wait," the marketing director says.  "I don't want to update the first element, the name of the company itself."

```ruby
class SteveJobsifier < Vampire::Visitor
  def visit obj, *args
    if depth > 0
      obj.name = "#{obj.name} - the most #{args.join(', ')} thing you've ever seen"
    end
  end
end
```

Vampire::Visitor sets up 2 accessors: depth and node.

- depth: an integer containing the current depth in the hierarchy
- node: an integer containing the current node

As accept walks the hierarchy, it updates these two accessors appropriately.

### Comparing two similar object hierarchies

Now you look at your other function, which compares your company's products with another:

This time you'll be using another method, visit_with_reference, that takes an object, and compares it with another reference object and returns the results.

```ruby
class Comparator < Vampire::Visitor
  def visit_with_reference obj, ref_obj, *args
    obj.name == ref_obj.name
  end
end
```

You setup the company:

```ruby
company2 = Company.new 'McButters Pancakes Inc.'
cat4 = Category.new 'Extra Delicious'
prod4 = Product.new "McButters Fluffy Pancake"
```

...and you execute the comparison, which returns the results.

```ruby
company.accept_with_reference(Comparator.new, company2)
=>
[false, [true, [true]], [false, [false]]]
```

Note depth and node are available to you as well, however they refer to the host object hierarchy, not necessarily the reference.

#### Helpers

The Vampire module brings in 2 helpers:

 - hierarchy
 - compare_hierarchy

Hierarchy simple returns the object hierarchy in array format whereever its called.

```ruby
company.hierarchy
=>
# a nested array of true or false comparison results
```

compare_hierarchy performs the same task as above, without the need for a seperate class.  Nodes are compared via == method.

```ruby
company.compare_hierarchy(company2)
=>
# a nested array of true or false comparison results
```

## Caveats

 - Objects in your hierachy must respond to a method called "children" which produces an array-like list of children
 - The entire object graph will be loaded into memory
 - No tail-recursion, so quite possible to have a stack overflow for super-deep hierarchies
 - "It sure would be nice to apply an arbitrary block to a hierarchy, instead of having to create a method and pass it around."  I agree.

## Thanks to:

 - George Entenman

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
