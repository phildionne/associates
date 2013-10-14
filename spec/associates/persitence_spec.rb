require 'spec_helper'

describe Associates::Persistence do

  include_context "associates_setup"

  describe :InstanceMethods do

    describe :save do

      context "with a valid associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order.save).to be_true }

        it "persists the associated user" do
          expect { guest_order.save }.to change(User, :count).by(1)
        end

        it "persists the associated order" do
          expect { guest_order.save }.to change(Order, :count).by(1)
        end

        it "persists the associated payment" do
          expect { guest_order.save }.to change(Payment, :count).by(1)
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

        it { expect(guest_order.save).to be_false }

        it "doesn't persists the associated user" do
          expect { guest_order.save }.not_to change(User, :count).by(1)
        end

        it "doesn't persists the associated order" do
          expect { guest_order.save }.not_to change(Order, :count).by(1)
        end

        it "doesn't persists the associated payment" do
          expect { guest_order.save }.not_to change(Payment, :count).by(1)
        end
      end
    end

    describe :save! do

      context "with a valid associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order.save!).to be_true }
      end

      context "with an invalid associate" do
        let(:guest_order) { Factory.build(:invalid_guest_order) }

        it { expect { guest_order.save! }.to raise_error }
      end
    end
  end
end
