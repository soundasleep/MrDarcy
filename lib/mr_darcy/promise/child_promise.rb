module MrDarcy
  module Promise
    class ChildPromise < MrDarcy::Deferred

      attr_accessor :resolve_block, :reject_block

      def initialize opts={}
        @driver = opts[:driver] if opts.has_key? :driver
        super
      end

      def parent_resolved value
        begin
          return resolve_with value unless handles_resolve?
          new_value = result_for :resolve, value
          if thenable? new_value
            defer_resolution_via new_value
          else
            resolve_with new_value
          end
        rescue Exception => e
          reject_with e
        end
      end

      def parent_rejected value
        begin
          return reject_with value unless handles_reject?
          new_value = result_for :reject, value
          if thenable? new_value
            defer_resolution_via new_value
          else
            resolve_with new_value
          end
        rescue Exception => e
          reject_with e
        end
      end

      private

      def result_for which, value
        block = public_send("#{which}_block")
        if block
          block.call value
        else
          value
        end
      end

      def handles_reject?
        !!reject_block
      end

      def handles_resolve?
        !!resolve_block
      end

      def thenable? object
        object.respond_to?(:then) && object.respond_to?(:fail)
      end

      def defer_resolution_via child_promise
        child_promise.then do |value|
          resolve_with value
          value
        end
        child_promise.fail do |exception|
          reject_with exception
          exception
        end
      end

      def resolve_with value
        promise.resolve value
      end

      def reject_with exception
        promise.reject exception
      end
    end
  end
end
