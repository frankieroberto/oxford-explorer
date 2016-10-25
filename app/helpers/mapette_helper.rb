module MapetteHelper
  COLUMN_COUNT = 26
  GRID_SPACING = 10
  MARGIN = 5

  def radius_inside_square(radius)
    Math.sqrt((radius ** 2) / 2)
  end

  def xy_for_index(i)
    item_no = i+1

    row_index = ((item_no.to_f / COLUMN_COUNT).ceil - 1).to_i

    col_index = (item_no - (row_index * COLUMN_COUNT)) - 1;

    x = (col_index * GRID_SPACING) + MARGIN
    y = (row_index * GRID_SPACING) + MARGIN

    {x: x, y: y}
  end

  def homepage_link_for_superfield(superfield, id)
    if superfield == 'gfs_subject'
      if Collection.subjects.include?(id.downcase)
        root_path(key: 'subjects', value: id.downcase)
      end
    elsif superfield == 'gfs_item_type'
      if Collection.types_of_things.include?(id.downcase)
        root_path(key: 'types_of_things', value: id.downcase)
      end
    end
  end

  def reason_for_no_homepage_link_for_superfield(superfield,id)
    case superfield
    when 'gfs_subject'
      "<em>#{id}</em> is not a subject listed in the summary data."
    when 'gfs_item_type'
      "<em>#{id}</em> is not an item type listed in the summary data."
    when 'gfs_author'
      "We don't have person data in the summary data used to generate the homepage visulaisation."
    end


  end

end
