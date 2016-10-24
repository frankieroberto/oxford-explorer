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
     "gfs_subject.raw" => "Subjects",
     "gfs_item_type" => "Types of thing",
     "gfs_item_type.raw" => "Types of thing",
     "gfs_institution_id" => "Institutions",
     "gfs_author.raw" => "People",
     "gfs_author" => "People",
     "gfs_pubyear" => "Dates"}

    lookup[superfield]
  end

  def gfs_field_to_superfield(gfs_field)
    lookup = {"gfs_subject" => "subjects",
     "gfs_subject.raw" => "subjects",
     "gfs_item_type" => "types_of_things",
     "gfs_item_type.raw" => "types_of_things"}

    lookup[gfs_field]
  end


  def superfield_path_to_superfield(superfield_path)
    lookup = {"item_types" => "type_of_things",
              "subjects" => "subjects"}
    lookup[superfield_path]
  end

  def superfield_index_path(superfield)

    case superfield
    when 'gfs_item_type', 'gfs_item_type.raw'
      item_types_path
    when 'gfs_author', 'gfs_author.raw'
      people_path
    when 'gfs_subject', 'gfs_subject.raw'
      subjects_path
    when 'gfs_institution_id',
      institutions_path
    else
      "#"
    end

  end

  def polar_to_cartesian(x, y, radius, degrees)
    radians = (degrees) * Math::PI / 180.0;

    {
      x: x + (radius * Math.cos(radians)),
      y: y + (radius * Math.sin(radians))
    }
  end

  def describe_pie_slice(x,y,radius,start_angle,end_angle, close = true)
    if end_angle > 360
      end_angle = 360
    end

    end_point = polar_to_cartesian(x, y, radius, end_angle);

    large_arc_flag = end_angle - start_angle <= 180 ? "0" : "1";

    if close
      path = [
        "M", x,y ,
        "L", x+radius,y ,
        "A", radius, radius, 0, large_arc_flag, 1, end_point[:x], end_point[:y], "z"
      ].join(" ");
    else
      path = [
        "M", x+radius,y ,
        "A", radius, radius, 0, large_arc_flag, 1, end_point[:x], end_point[:y]
      ].join(" ");
    end

  end


end
