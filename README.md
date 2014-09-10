# Associates

Associate multiple models together and make them behave as one. Quacks like a single Model for the Views (validations, errors, form endpoints) and for the Controller (restful actions). Also a [great alternative](#an-alternative-to-the-current-nested-forms-solution) to `#accepts_nested_attributes_for`.

Currently only compatible with ActiveRecord, support for other ORMs is on the list. Also, you might want to check out [apotonick/reform](https://github.com/apotonick/reform) to handle more complex situations.

[![Gem Version](https://badge.fury.io/rb/associates.png)](http://badge.fury.io/rb/associates)
[![Code Climate](https://codeclimate.com/github/phildionne/associates.png)](https://codeclimate.com/github/phildionne/associates)
[![Coverage Status](https://coveralls.io/repos/phildionne/associates/badge.png)](https://coveralls.io/r/phildionne/associates)
[![Dependency Status](https://gemnasium.com/phildionne/associates.png)](https://gemnasium.com/phildionne/associates)
[![Build Status](https://travis-ci.org/phildionne/associates.png)](https://travis-ci.org/phildionne/associates)
[![associates API Documentation](https://www.omniref.com/ruby/gems/associates.png)](https://www.omniref.com/ruby/gems/associates)

# Usage

```ruby
# app/forms/guest_order
class GuestOrder
  include Associates

  associate :user
  associate :order, only: :product, depends_on: :user
  associate :payment, depends_on: :order
end
```

```ruby
# app/models/user
class User < ActiveRecord::Base
  validates :username, :password, presence: true
end

# app/models/order
class Order < ActiveRecord::Base
  attr_accessor :product

  belongs_to :user
  validates :user, :product, presence: true
end

# app/models/payment
class Payment < ActiveRecord::Base
  attr_accessor :amount

  belongs_to :order
  validates :order, presence: true
end
```

```ruby
# config/routes
resource :guest_orders, only: [:new, :create]
```

```ruby
# app/controllers/guest_orders_controller
class GuestOrdersController < ApplicationController

  def new
    @guest_order = GuestOrder.new
  end

  def create
    @guest_order = GuestOrder.new(permitted_params)

    if @guest_order.save
      sign_in @guest_order.user

      redirect_to root_path
    else
      render action: :new
    end
  end


  private

  def permitted_params
    params.require(:guest_order).permit(:username, :password, :product, :amount)
  end
end
```

```erb
# views/guest_orders/_form.html.erb
<%= form_for @guest_order do |f| %>
  <%= f.text_field :username %>
  <%= f.text_field :password %>
  <%= f.text_field :product %>
  <%= f.text_field :amount %>

  <%= f.submit %>
<% end %>
```


## Validations

For the object to be valid, every associated model must be valid too. Associated models' errors are traversed and added to the form object's error hash.

```ruby
o = GuestOrder.new(username: nil, password: '12345', product: 'surfboard', amount: 20)
o.valid?
# => false

o.errors.messages
# => { username: [ "can't be blank" ] }
```

When an attribute is invalid and isn't defined on the object including Associates, the corresponding error is added to the `:base` key.

```ruby
o = GuestOrder.new(username: 'phildionne', password: '12345', product: 'surfboard')
o.valid?
# => false

o.errors[:base]
# => "Amount can't be blank"
```

## Persistence

Calling `#save` will persist every associated model. By default associated models are persisted inside a database transaction: if any associated model can't be persisted, none will be. Read more on [ActiveRecord transactions](http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html). You can also override the `#save` method and implement a different persistence logic.

```ruby
o = GuestOrder.new(username: 'phildionne', password: '12345', product: 'surfboard', amount: 20)
o.save

[o.user, o.order, o.payment].all?(&:persisted?)
# => true
```

## Associations

`belongs_to` associations between associated models can be handled using the `depends_on` option:

```ruby
class GuestOrder
  include Associates

  associate :user
  associate :order, depends_on: :user
end

o = GuestOrder.new
o.user = User.find(1)
o.save

o.order.user
# => #<User id: 1 ... >
```

or by declaring an attribute which will define a method with the same signature as the foreign key setter:

```ruby
class GuestOrder
  include Associates

  associate :order, only: :user_id
end
```


## Delegation

Associates works by delegating the right method calls to the right models. By default, delegation is enabled and will define the following methods:

```ruby
class GuestOrder
  include Associates

  associate :user
end
```

- `#user`
- `#user=`
- `#username`
- `#username=`
- `#password`
- `#password=`

You might want to disable delegation to avoid attribute name clashes between associated models:

```ruby
class GuestOrder
  include Associates

  associate :user
  associate :referring_user, class_name: User, delegate: false
end
```

- `#user`
- `#user=`
- `#username`
- `#username=`
- `#password`
- `#password=`
- `#referring_user`
- `#referring_user=`

or granularly select each attribute:

```ruby
class GuestOrder
  include Associates

  associate :user, only: [:username]
  associate :order, except: [:product]
end
```

- `#user`
- `#user=`
- `#username`
- `#username=`
- `#order`
- `#order=`

## An alternative to the current nested forms solution

I'm not a fan of Rails' current solution for handling multi-model forms using `#accepts_nested_attributes_for`. I feel like it breaks the Single Responsibility Principle by handling the logic on one of the models. Add just a bit of custom behavior and it usually leads to spaghetti logic in the controller and the tests. Using Associates to refactor nested forms logic into a multi-model object is a great fit.

# TODO
- [ ] Add a "#{model}_attributes" method to return an array of attributes included by the form object
- [ ] Support other ORMs

# Contributing

1. Fork it
2. [Create a topic branch](http://learn.github.com/p/branching.html)
3. Add specs for your unimplemented modifications
4. Run `bundle exec rspec`. If specs pass, return to step 3.
5. Implement your modifications
6. Run `bundle exec rspec`. If specs fail, return to step 5.
7. Commit your changes and push
8. [Submit a pull request](http://help.github.com/send-pull-requests/)
9. Thank you!

# Inspiration

- [rafBM's](https://github.com/rafBM) [presentation](https://github.com/rafBM/opencode12-rails) at [OpenCode XII](http://opencode.ca/)
- [Thoughtbot's](http://thoughtbot.com) [Harlow Ward](https://github.com/harlow) [ActiveModel Form Objects](http://robots.thoughtbot.com/post/33296680513/activemodel-form-objects) post
- [Ryan Bates](https://github.com/ryanb) [Form objects](http://railscasts.com/episodes/416-form-objects)' railscast

# Author

[Philippe Dionne](http://phildionne.com)

# License

See [LICENSE](https://github.com/phildionne/associates/blob/master/LICENSE)
