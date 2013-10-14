shared_context 'associates_setup' do

  before do
    run_migration do
      create_table(:users, force: true) do |t|
        t.string  :username
        t.string  :password
      end

      create_table(:orders, force: true) do |t|
        t.references :user
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
      attr_accessor :product

      belongs_to :user
      validates :user, :product, presence: true
    end

    spawn_class('Payment', ActiveRecord::Base) do
      belongs_to :order
      validates :order, presence: true
    end

    spawn_class('GuestOrder', Object) do
      extend Helpers # Usage for specs only
      include Associates

      associate :user
      associate :order, only: :product, depends_on: :user
      associate :payment, depends_on: :order
    end

  end
end
