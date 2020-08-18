module Lab42
  class Rgxargs
    module Checker

      private

      def _check_kwd(kwd)
        return if allowed.nil?
        return if allowed.member? kwd
        return if required.member? kwd
        errors << [:unauthorized_kwd, kwd]
      end

      def _check_required_kwds
        missing = required - options.to_h.keys
        @errors += missing.map(&_mk_pair(:required_kwd_missing))
      end
      

      def _mk_pair(prefix)
        -> element do
          [prefix, element]
        end
      end

      def _check_switch(_)
        
      end


    end
  end
end
