module ApplicationHelper

  # Same as pluralize helper but with the number formatted using
  # a delimiter.
  def pluralize_with_delimiter(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || singular.pluralize
    end

    "#{number_with_delimiter(count) || 0}&nbsp;#{word}".html_safe
  end

  def percentage_with_varying_accuracy(decimal)

    percentage = decimal * 100

    decimal_places = percentage < 0.01 ? 5 : 2

    number_to_percentage(percentage, precision: decimal_places, strip_insignificant_zeros: true)
  end

  def human_superfield_name(superfield)
    lookup = {"gfs_subject" => "Subjects",
     "gfs_subject.raw" => "Types of thing",
     "gfs_item_type" => "Types of thing",
     "gfs_item_type.raw" => "Types of thing",
     "gfs_pubyear" => "Dates"}

    lookup[superfield]
  end

  def polar_to_cartesian(x, y, radius, degrees)
    radians = (degrees) * Math::PI / 180.0;

    {
      x: x + (radius * Math.cos(radians)),
      y: y + (radius * Math.sin(radians))
    }
  end

  def describe_pie_slice(x,y,radius,start_angle,end_angle)
    if end_angle > 360
      end_angle = 360 
    end

    end_point = polar_to_cartesian(x, y, radius, end_angle);

    large_arc_flag = end_angle - start_angle <= 180 ? "0" : "1";

    path = [
      "M", x,y ,
      "L", x+radius,y ,
      "A", radius, radius, 0, large_arc_flag, 1, end_point[:x], end_point[:y], "z"
    ].join(" ");
  end


end
