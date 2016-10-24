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

end
