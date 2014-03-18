# File actionpack/lib/action_controller/assertions/selector_assertions.rb, line 201
      def assert_select(*args, &block)
        # Start with optional element followed by mandatory selector.
        arg = args.shift

        if arg.is_a?(HTML::Node)
          # First argument is a node (tag or text, but also HTML root),
          # so we know what we're selecting from.
          root = arg
          arg = args.shift
        elsif arg == nil
          # This usually happens when passing a node/element that
          # happens to be nil.
          raise ArgumentError, "First argument is either selector or element to select, but nil found. Perhaps you called assert_select with an element that does not exist?"
        elsif @selected
          root = HTML::Node.new(nil)
          root.children.concat @selected
        else
          # Otherwise just operate on the response document.
          root = response_from_page_or_rjs
        end

        # First or second argument is the selector: string and we pass
        # all remaining arguments. Array and we pass the argument. Also
        # accepts selector itself.
        case arg
          when String
            selector = HTML::Selector.new(arg, args)
          when Array
            selector = HTML::Selector.new(*arg)
          when HTML::Selector
            selector = arg
          else raise ArgumentError, "Expecting a selector as the first argument"
        end

        # Next argument is used for equality tests.
        equals = {}
        case arg = args.shift
          when Hash
            equals = arg
          when String, Regexp
            equals[:text] = arg
          when Integer
            equals[:count] = arg
          when Range
            equals[:minimum] = arg.begin
            equals[:maximum] = arg.end
          when FalseClass
            equals[:count] = 0
          when NilClass, TrueClass
            equals[:minimum] = 1
          else raise ArgumentError, "I don't understand what you're trying to match"
        end

        # By default we're looking for at least one match.
        if equals[:count]
          equals[:minimum] = equals[:maximum] = equals[:count]
        else
          equals[:minimum] = 1 unless equals[:minimum]
        end

        # Last argument is the message we use if the assertion fails.
        message = args.shift
        #- message = "No match made with selector #{selector.inspect}" unless message
        if args.shift
          raise ArgumentError, "Not expecting that last argument, you either have too many arguments, or they're the wrong type"
        end

        matches = selector.select(root)
        # If text/html, narrow down to those elements that match it.
        content_mismatch = nil
        if match_with = equals[:text]
          matches.delete_if do |match|
            text = ""
            text.force_encoding(match_with.encoding) if text.respond_to?(:force_encoding)
            stack = match.children.reverse
            while node = stack.pop
              if node.tag?
                stack.concat node.children.reverse
              else
                content = node.content
                content.force_encoding(match_with.encoding) if content.respond_to?(:force_encoding)
                text << content
              end
            end
            text.strip! unless NO_STRIP.include?(match.name)
            unless match_with.is_a?(Regexp) ? (text =~ match_with) : (text == match_with.to_s)
              content_mismatch ||= build_message(message, "<?> expected but was\n<?>.", match_with, text)
              true
            end
          end
        elsif match_with = equals[:html]
          matches.delete_if do |match|
            html = match.children.map(&:to_s).join
            html.strip! unless NO_STRIP.include?(match.name)
            unless match_with.is_a?(Regexp) ? (html =~ match_with) : (html == match_with.to_s)
              content_mismatch ||= build_message(message, "<?> expected but was\n<?>.", match_with, html)
              true
            end
          end
        end
        # Expecting foo found bar element only if found zero, not if
        # found one but expecting two.
        message ||= content_mismatch if matches.empty?
        # Test minimum/maximum occurrence.
        min, max = equals[:minimum], equals[:maximum]
        message = message || %(Expected #{count_description(min, max)} matching "#{selector.to_s}", found #{matches.size}.)
        assert matches.size >= min, message if min
        assert matches.size <= max, message if max

        # If a block is given call that block. Set @selected to allow
        # nested assert_select, which can be nested several levels deep.
        if block_given? && !matches.empty?
          begin
            in_scope, @selected = @selected, matches
            yield matches
          ensure
            @selected = in_scope
          end
        end

        # Returns all matches elements.
        matches
      end