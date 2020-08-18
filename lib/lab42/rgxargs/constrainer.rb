module Lab42
  class Rgxargs
    module Constrainer

      def allow_kwds(*kwds)
        @allowed = (allowed||Set.new).union(Set.new(kwds.flatten))
      end

      def require_kwds(*kwds)
        @required = (required||Set.new).union(Set.new(kwds.flatten))
      end

    end
  end
end
