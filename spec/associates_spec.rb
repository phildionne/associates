require 'spec_helper'

describe Associates do

  include_context "associates_setup"

  let(:guest_order) { GuestOrder.new }

  describe :ClassMethods do

    describe :associate do

      context "with valid arguments" do

        describe "with options" do

          describe :only do
            before do
              GuestOrder.reset_associate!(:user)
              GuestOrder.associate(:user, only: :username)
            end

            it "defines setters and getters only for the specified attribute" do
              expect(guest_order).to respond_to(:username)
              expect(guest_order).to respond_to(:username=)
              expect(guest_order).not_to respond_to(:password)
              expect(guest_order).not_to respond_to(:password=)
            end
          end

          describe :except do
            before do
              GuestOrder.reset_associate!(:user)
              GuestOrder.associate(:user, except: :username)
            end

            it "defines setters and getters for all attributes except for the specified attribute" do
              expect(guest_order).not_to respond_to(:username)
              expect(guest_order).not_to respond_to(:username=)
              expect(guest_order).to respond_to(:password)
              expect(guest_order).to respond_to(:password=)
            end
          end

          describe :class_name do

            describe "when specified" do
              before { GuestOrder.reset_associate!(:user) }

              it "uses the given class" do
                AdminUser = Class.new(User)
                GuestOrder.associate(:user, class_name: AdminUser)

                expect(guest_order.user).to be_an_instance_of(AdminUser)
              end

              it "accepts a String" do
                GuestOrder.associate(:user, class_name: 'User')

                expect(guest_order.user).to be_an_instance_of(User)
              end
            end

            describe "when unspecified" do

              it "infers the class from the associate name" do
                expect(guest_order.user).to be_an_instance_of(User)
              end
            end
          end

          describe :delegate do

            describe "enabled" do
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

            describe "disabled" do
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
          end
        end

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

    describe :new do
      let(:guest_order) { GuestOrder.new(username: 'phildionne', password: '123456789', product: 'surfboard') }

      it "works with ActiveModel::Model #new" do
        expect(guest_order.username).to eq('phildionne')
        expect(guest_order.password).to eq('123456789')
        expect(guest_order.product).to  eq('surfboard')
      end
    end

    describe :instance_setter do

      it "sets its dependent associate relation" do
        user = guest_order.user
        expect(guest_order.order.user).to be(user)
      end
    end

    describe :instance_getter do

      it "sets its dependent associate relation" do
        user = User.new
        guest_order.user = user

        expect(guest_order.order.user).to be(user)
      end

      it "doesn't sets its dependent associate relation when existing" do
        guest_order.order.user = User.new
        user = guest_order.user

        expect(guest_order.order.user).not_to be(user)
      end
    end

    describe :delegation do
      before do
        GuestOrder.reset_associate!(:user)
        GuestOrder.associate(:user, delegate: true)
      end

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
