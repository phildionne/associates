shared_context "associates_setup" do

  before do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string  :username
        t.string  :password
      end

      create_table(:orders, force: true) do |t|
        t.references :user
        t.string :product
      end

      create_table(:payments, force: true) do |t|
        t.references :order
        t.string :amount
      end
    end

    spawn_class('User', ActiveRecord::Base) do
      validates :username, :password, presence: true
    end

    spawn_class('Order', ActiveRecord::Base) do
      belongs_to :user
      validates :product, presence: true
    end

    spawn_class('Payment', ActiveRecord::Base) do
      belongs_to :order
    end

    spawn_class('GuestOrder', Object) do
      extend Helpers # Usage for specs only
      include Associates

      associate :user
      associate :order, only: :product
      associate :payment, depends_on: :order
    end

  end
end
