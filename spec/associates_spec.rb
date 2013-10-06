require 'spec_helper'

describe Associates do

  include_context "associates_setup"

  let(:guest_order) { GuestOrder.new }

  describe :ClassMethods do

    describe :associate do

      context "with valid arguments" do

        describe "undefined model name", :skip do
          # @TODO Think wether it is a feature or not
          # Could be metadefined later
          it { expect { GuestOrder.send(:associate, :undefined) }.not_to raise_error }
        end

        describe "undefined attribute name", :skip do
          # @TODO Think wether it is a feature or not
          # Could be metadefined later
          it { expect { GuestOrder.send(:associate, :order, only: :undefined) }.not_to raise_error }
        end
      end

      context "with invalid arguments" do

        describe "already defined model name" do
          it { expect { GuestOrder.send(:associate, :user) }.to raise_error }
        end

        describe "already defined attribute name" do
          it { expect { GuestOrder.send(:associate, :user, only: :product) }.to raise_error }
        end

        describe "inexisting depend_on name" do
          it { expect { GuestOrder.send(:associate, :user, only: :username, depends_on: :inexisting) }.to raise_error }
        end
      end
    end
  end

  describe :InstanceMethods do

    it "defines an instance setter for the specified model" do
      expect(guest_order).to respond_to(:user=)
      expect(guest_order).to respond_to(:order=)
      expect(guest_order).to respond_to(:payment=)
    end

    it "defines an instance getter for the specified model" do
      expect(guest_order).to respond_to(:user)
      expect(guest_order).to respond_to(:order)
      expect(guest_order).to respond_to(:payment)
    end

    context "with delegation" do
      before do
        GuestOrder.reset_associate!(:user)
        GuestOrder.associate(:user, delegate: true)
      end

      it "defines attributes setters for the specified model" do
        expect(guest_order).to respond_to(:username=)
        expect(guest_order).to respond_to(:password=)
        expect(guest_order).to respond_to(:product=)
        expect(guest_order).to respond_to(:amount=)
      end

      it "defines attributes getters for the specified model" do
        expect(guest_order).to respond_to(:username)
        expect(guest_order).to respond_to(:password)
        expect(guest_order).to respond_to(:product)
        expect(guest_order).to respond_to(:amount)
      end
    end

    context "without delegation" do
      before do
        GuestOrder.reset_associate!(:user)
        GuestOrder.associate(:user, delegate: false)
      end

      it "doesn't define attributes setters for the specified model" do
        expect(guest_order).not_to respond_to(:username=)
        expect(guest_order).not_to respond_to(:password=)
      end

      it "doesn't define attributes getters for the specified model" do
        expect(guest_order).not_to respond_to(:username)
        expect(guest_order).not_to respond_to(:password)
      end
    end

    describe :delegation do
      it "delegates attributes setters to the specified model" do
        expect(guest_order.user).to receive(:username=).with('pdionne')
        guest_order.username = 'pdionne'
      end

      it "delegates attributes getters to the specified model" do
        expect(guest_order.user).to receive(:username)
        guest_order.username
      end
    end
  end
end
