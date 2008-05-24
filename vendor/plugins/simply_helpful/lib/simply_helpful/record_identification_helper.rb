module SimplyHelpful
  module RecordIdentificationHelper
    protected
      def partial_path(*args, &block)
        RecordIdentifier.partial_path(*args, &block)
      end

      def dom_class(*args, &block)
        RecordIdentifier.dom_class(*args, &block)
      end

      def dom_id(*args, &block)
        RecordIdentifier.dom_id(*args, &block)
      end
  end
end
