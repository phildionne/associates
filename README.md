# Associates

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

resource :guest_order, only: [:new, :create]
```

```ruby
# app/controllers/guest_order_controller

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

For the object to be valid, every associated models must be valid too. Associated models errors are traversed and added to the form object's error hash. When an attribute is invalid and isn't defined on the object, the corresponding error is added to the `:base` key.

For example:

```ruby
o = GuestOrder.new(username: 'pdionne', password: '12345', product: 'surfboard')
o.valid?
# => false

o.errors[:base]
# => "Amount can't be blank"
```

## Persitence

By default associated models are persisted inside a database transaction. Read more on [ActiveRecord transactions](http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html). You can also override the `#save` method and implement a different persistence logic.

## Associations

`ActiveRecord` associations between associated models can be handled using the `depends_on` option:

```ruby
class GuestOrder
  associate :user
  associate :order, depends_on: :user
end
```

or by declaring an attribute which will define a method with the same signature than the foreign key setter:

```ruby
class GuestOrder
  associate :order, only: :user_id
end
```


## Delegation

By default delegation is enabled and will define the following methods:

```ruby
class GuestOrder
  associate :user
end
```

- `#user`
- `#user=`
- `#username`
- `#username=`
- `#password`
- `#password=`

You might want to disable delegation to avoid attributes name clash between associated models:

```ruby
class GuestOrder
  associate :user, delegate: false
end
```

- `#user`
- `#user=`

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

Inspired by [rafBM's](https://github.com/rafBM) [presentation](https://github.com/rafBM/opencode12-rails) at [OpenCode XII](http://opencode.ca/), [Thoughtbot's](http://thoughtbot.com) [Harlow Ward](https://github.com/harlow) [ActiveModel Form Objects](http://robots.thoughtbot.com/post/33296680513/activemodel-form-objects) post and [Ryan Bates](https://github.com/ryanb) [Form objects](http://railscasts.com/episodes/416-form-objects)' railscast.

# Author

[Philippe Dionne](http://phildionne.com)

# License

See [LICENSE](https://github.com/phildionne/associates/blob/master/LICENSE)
