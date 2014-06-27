require 'spec_helper'

describe Associates::Persistence do

  include_context "associates_setup"

  describe :InstanceMethods do

    describe :save do

      context "with a valid associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order.save).to be_truthy }

        it "persists the associated user" do
          count = User.count
          guest_order.save
          expect(User.count).to eq(count + 1)
        end

        it "persists the associated order" do
          count = Order.count
          guest_order.save
          expect(Order.count).to eq(count + 1)
        end

        it "persists the associated payment" do
          count = Payment.count
          guest_order.save
          expect(Payment.count).to eq(count + 1)
        end

        context "with the depend_on option specified" do

          it "sets the dependent model on the associate" do
            guest_order.save

            expect(guest_order.order.user).to eq(guest_order.user)
            expect(guest_order.payment.order).to eq(guest_order.order)
          end
        end
      end

      context "with an invalid associate" do
        let(:guest_order) { Factory.build(:invalid_guest_order) }

        it { expect(guest_order.save).to be_falsey }

        it "doesn't persists the associated user" do
          count = User.count
          guest_order.save
          expect(User.count).to eq(count)
        end

        it "doesn't persists the associated order" do
          count = Order.count
          guest_order.save
          expect(Order.count).to eq(count)
        end

        it "doesn't persists the associated payment" do
          count = Payment.count
          guest_order.save
          expect(Payment.count).to eq(count)
        end
      end
    end

    describe :save! do

      context "with a valid associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order.save!).to be_truthy }
      end

      context "with an invalid associate" do
        let(:guest_order) { Factory.build(:invalid_guest_order) }

        it { expect { guest_order.save! }.to raise_error }
      end
    end

    describe :persited? do
      context "with a persisted associate" do
        let(:guest_order) { Factory.create(:guest_order) }

        it { expect(guest_order).to be_persisted }
      end

      context "with a unpersisted associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order).not_to be_persisted }
      end
    end
  end
end
