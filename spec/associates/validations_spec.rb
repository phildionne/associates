require 'spec_helper'

describe Associates::Validations do

  include_context "associates_setup"

  describe :InstanceMethods do

    describe :valid? do

      context "with a valid associate" do
        let(:guest_order) { Factory.build(:guest_order) }

        it { expect(guest_order.valid?).to be_truthy }

        it "doesn't populates the errors hash" do
          guest_order.valid?

          expect(guest_order.errors[:username]).to be_empty
          expect(guest_order.errors[:password]).to be_empty
          expect(guest_order.errors[:product]).to  be_empty
          expect(guest_order.errors[:amount]).to   be_empty
        end

        context "with an unspecified associated model attribute" do

          it "doesn't populates the errors hash base" do
            run_migration { add_column(:orders, :merchant, :string) }
            Order.send(:validates, :merchant, presence: true)
            Order.reset_column_information

            guest_order.order.merchant = 'Babylon Surfshop'
            guest_order.valid?

            expect(guest_order.errors[:base]).to be_empty
          end
        end

        it "doesn't populates the errors hash with model association presence validation errors" do
          guest_order.valid?

          expect(guest_order.errors).not_to have_key(:user)
          expect(guest_order.errors).not_to have_key(:order)
        end
      end

      context "with an invalid associate" do
        let(:guest_order) { Factory.build(:invalid_guest_order, username: 'pdionne') }

        it { expect(guest_order.valid?).to be_falsey }

        it "populates the errors hash" do
          guest_order.valid?

          expect(guest_order.errors[:username]).to     be_empty
          expect(guest_order.errors[:password]).not_to be_empty
          expect(guest_order.errors[:product]).not_to  be_empty
          expect(guest_order.errors[:amount]).to       be_empty
        end

        context "with an unspecified associated model attribute" do

          it "populates the errors hash base" do
            run_migration { add_column(:orders, :merchant, :string) }
            Order.send(:validates, :merchant, presence: true)
            Order.reset_column_information

            guest_order.order.merchant = nil
            guest_order.valid?

            expect(guest_order.errors[:base]).not_to be_empty
          end
        end

        it "doesn't duplicate error messages" do
          skip
        end
      end
    end
  end
end
