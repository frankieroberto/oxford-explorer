require 'active_support'

module EadNameParser

  class NameField

    DATE_REGEX =
      /\A
      (?:
        (fl\.?\s)?        # fl.
        (?:c\.?\s?)?        # Circa
        (?:(?:b\.?\s?)?\??(\d{4})\.?\??)?       # Year followed by optional full stop and or question mark
        \-?                 # Hyphen
        (?:(?:d\.?\s)?(\d{1,4})\.?\??)?       # Year followed by optional full stop and or question mark
        \z                  # End of string
      )/x

    BRACKET_FORMAT =
      /\A
        ((?:Mc)?[\p{Lu}\-\s\']+)
        \s+
        \(
          ([\p{L}\s\-\.]+)
        \)
        \s*
          ([^\d]*)
          (?:(?:b\.?\s?)?(\d{4})\.?\??)?       # Year followed by optional full stop and or question mark
          \-?                 # Hyphen
          (?:(?:d\.?\s)?(\d{4})\.?\??)?       # Year followed by optional full stop and or question mark
      /x

    COMMA_FORMAT =
      /\A
        ([\p{Lu}\-\s]+)
        \,
        \s+
        ([\p{L}\s\-\.]+)
        \s*
        \(?
          (?:(?:b\.?\s?)?(\d{4})\.?\??)?       # Year followed by optional full stop and or question mark
          \-?                 # Hyphen
          (?:(?:d\.?\s)?(\d{4})\.?\??)?       # Year followed by optional full stop and or question mark
        \)?
        (?:\,([^\,]+))?

      /x


    def initialize(field)
      @field = field.gsub(/\n/, ' ').squeeze(' ')
    end

    def name_in_natural_order

      if nca_name?

        if name_parts.size == 1
          name = name_parts[0]
        elsif name_parts.size == 2
          name = name_parts[1] + " " + name_parts[0]
        elsif name_parts.size == 3
          name = name_parts[1] + " " + name_parts[2] + " "+ name_parts[0]
        end

        name&.strip

      elsif match = bracket_match || match = comma_match

        surname = match[1].gsub(/\p{Lu}+/) {|match| ActiveSupport::Multibyte::Chars.new(match).capitalize.to_s}

        "#{match[2]} #{surname}".squeeze(' ')

      else
        @field

      end

    end

    def born_in

      if (date_match && date_is_real? && date_match[2])
        date_match[2].to_i
      elsif bracket_match && bracket_match[4].to_s.strip != ''
        bracket_match[4].to_i
      elsif comma_match && comma_match[3].to_s.strip != ''
        comma_match[3].to_i
      else
        nil
      end
    end

    def died_in
      if (date_match && date_is_real? && date_match[3])
        date_match[3].to_i
      elsif bracket_match && bracket_match[5].to_s.strip != ''
        bracket_match[5].to_i
      elsif comma_match && comma_match[4].to_s.strip != ''
        comma_match[4].to_i
      else
        nil
      end
    end

    def other

      other = []

      if !date_is_real?
        other << date_match[0]
      end

      if nca_name?

        if nca_parts.size >= 4 && nca_parts[2] =~ DATE_REGEX
          other << nca_parts[3]

          if nca_parts[4]
            other << nca_parts[4].gsub(/\Ax\s/, '')
          end

        elsif nca_parts.size >= 5 && nca_parts[3] =~ DATE_REGEX
          other << nca_parts[4]

        elsif nca_parts.size >= 3 && nca_parts[1] != '-' && nca_parts[1] =~ DATE_REGEX
          other << nca_parts[2]
        elsif nca_parts.size >= 3 && !(nca_parts[2] =~ /\Afl\.?/)
          other << nca_parts[2]
        end


      elsif bracket_match

        if bracket_match[3].to_s.strip != ''
          other << bracket_match[3].to_s.strip.gsub(/[\,]\Z/, '').gsub(/\A\,\s*/, '')
        end

      elsif comma_match

        if comma_match[5].to_s.strip != ''
          other << comma_match[5].to_s.strip
        end

      end

      other
    end

    private

    def name_parts
      @name_parts ||= begin
        if nca_name?

          if nca_parts.size >= 3 && nca_parts[2] =~ DATE_REGEX
            name_parts = [nca_parts[0], nca_parts[1]]
          elsif nca_parts.size >= 4 && nca_parts[3] =~ DATE_REGEX
            name_parts = [nca_parts[0], nca_parts[1], nca_parts[2]]

          elsif nca_parts.size >= 2 && nca_parts[1] =~ DATE_REGEX
            name_parts = [nca_parts[0]]
          elsif nca_parts.size >= 2
            name_parts = name_parts = [nca_parts[0], nca_parts[1]]
          end

          name_parts.collect {|part| part == '-' ? '' : part}


        else
          @field
        end
      end
    end

    def date_is_real?
      date_match.nil? || date_match[1] == nil  # No 'fl' indicating 'flourished'
    end

    def date_match
      if nca_name?

        if nca_parts.size >= 3 && date_match = nca_parts[2].match(DATE_REGEX)
          date_match
        elsif nca_parts.size >= 4 &&date_match = nca_parts[3].match(DATE_REGEX)
          date_match
        elsif nca_parts.size >= 2 && date_match = nca_parts[1].match(DATE_REGEX)
          date_match
        else
          nil
        end
      end
    end

    def nca_name?
      @field =~ /\|/
    end

    def comma_match
      @field.match(COMMA_FORMAT)
    end

    def bracket_match
      @field.match(BRACKET_FORMAT)
    end

    def bracket_format?
      @field.match(BRACKET_FORMAT)
    end

    def nca_parts
      @nca_parts ||= @field.split('|').collect(&:strip)
    end

  end


end
