module Steep
  module AST
    module Ignore
      class IgnoreStart
        attr_reader :comment, :location

        def initialize(comment, location)
          @comment = comment
          @location = location
        end

        def line
          location.start_line
        end
      end

      class IgnoreEnd
        attr_reader :comment, :location

        def initialize(comment, location)
          @comment = comment
          @location = location
        end

        def line
          location.start_line
        end
      end

      class IgnoreLine
        attr_reader :comment, :location, :raw_diagnostics

        def initialize(comment, diagnostics, location)
          @comment = comment
          @raw_diagnostics = diagnostics
          @location = location
        end

        def line
          location.start_line
        end

        def ignored_diagnostics
          if raw_diagnostics.empty?
            return :all
          end

          if raw_diagnostics.size == 1 && raw_diagnostics[0].source == "all"
            return :all
          end

          raw_diagnostics.map do |diagnostic|
            name = diagnostic[:name].source
            name.gsub(/\ARuby::/, "")
          end
        end
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
          matched = scanner.matched or raise
          loc = RBS::Location.new(
            buffer,
            begin_pos + scanner.charpos - matched.size,
            begin_pos + scanner.charpos
          )

          scanner.skip(/\s*/)
          return unless scanner.eos?

          IgnoreStart.new(comment, loc)
        when scanner.scan(/steep:ignore:end\b/)
          matched = scanner.matched or raise
          loc = RBS::Location.new(
            buffer,
            begin_pos + scanner.charpos - matched.size,
            begin_pos + scanner.charpos
          )

          scanner.skip(/\s*/)
          return unless scanner.eos?

          IgnoreEnd.new(comment, loc)
        when scanner.scan(/steep:ignore\b/)
          # @type var diagnostics: IgnoreLine::diagnostics
          diagnostics = []

          keyword_match = scanner.matched or raise
          loc = RBS::Location.new(
            buffer,
            begin_pos + scanner.charpos - keyword_match.size,
            begin_pos + scanner.charpos
          )

          until (scanner.skip(/\s*/); scanner.eos?)
            if scanner.scan(/[A-Z][\w]*/)
              name = scanner.matched or raise
              name_begin = begin_pos + scanner.charpos - name.size
              name_end = begin_pos + scanner.charpos
            else
              break
            end

            scanner.skip(/\s*/)
            if scanner.scan(/,/)
              comma_begin = begin_pos + scanner.charpos - 1
              comma_end = begin_pos + scanner.charpos
            end

            if comma_begin && comma_end
              loc = RBS::Location.new(buffer, name_begin, comma_end)

            else
              break
            end
          end

          IgnoreLine.new(comment, diagnostics, loc)

        #   until (scanner.skip(/\s*/); scanner.eos?)
        #     if scanner.scan(/all\b/)

        #     end
        #   end

          # if list = $3
          #   list.strip!

          #   if list == "all"
          #     diagnostics = :all
          #   else

          #   end
          # end

          # IgnoreLine.new(comment, diagnostics, loc)
        end
      end
    end
  end
end
