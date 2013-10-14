module Associates
  module Validations
    extend ActiveSupport::Concern

    included do
      alias_method_chain :valid?, :associates
    end

    module ClassMethods
    end

    # Runs the model validations plus the associated models validations and
    # merges each messages in the errors hash
    #
    # @return [Boolean]
    def valid_with_associates?(context = nil)
      # Model validations
      valid_without_associates?(context)

      # Associated models validations
      self.class.associates.each do |associate|
        model = send(associate.name)
        model.valid?(context)

        model.errors.each_entry do |attribute, message|
          # Do not include association presence validation errors
          if associate.dependent_names.include?(attribute.to_s)
            next
          elsif respond_to?(attribute)
            errors.add(attribute, message)
          else
            errors.add(:base, model.errors.full_messages_for(attribute))
          end
        end
      end

      errors.messages.values.each(&:uniq!)
      errors.none?
    end
  end
end
