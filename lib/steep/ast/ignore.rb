module Steep
  module AST
    module Ignore
      class IgnoreStart

      end

      class IgnoreEnd

      end

      class IgnoreLine

      end

      def self.parse(comment, buffer)
        return unless comment.inline?

        scanner = StringScanner.new(comment.text)

        scanner.scan(/#/)
        scanner.skip(/\s*/)

        begin_pos = comment.location.expression.begin_pos
        end_pos = comment.location.expression.end_pos

        case
        when scanner.scan(/steep:ignore:start\b/)
          loc = RBS::Location.new(
            buffer,
            begin_pos + scanner.charpos - scanner.size,
            begin_pos + scanner.charpos
          )

          scanner.skip(/\s*/)
          return unless scanner.eos?

          IgnoreStart.new(comment, loc)
        when scanner.scan(/steep:ignore:end\b/)
          loc = RBS::Location.new(
            buffer,
            begin_pos + scanner.charpos - scanner.size,
            begin_pos + scanner.charpos
          )

          scanner.skip(/\s*/)
          return unless scanner.eos?

          IgnoreEnd.new(comment, loc)
        when scanner.scan(/steep:ignore\b/)
          # @type var diagnostics: IgnoreLine::diagnostics
          diagnostics = []

          keyword_begin = begin_pos + scanner.charpos - scanner.size
          keyword_end = begin_pos + scanner.charpos

          until (scanner.skip(/\s*/); scanner.eos?)
            if scanner.scan(/all\b/)

            end
          end

          # if list = $3
          #   list.strip!

          #   if list == "all"
          #     diagnostics = :all
          #   else

          #   end
          # end

          IgnoreLine.new(comment, diagnostics, loc)
        end
      end
    end
  end
end
