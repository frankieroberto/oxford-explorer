class EnableUnaccent < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'unaccent' unless extension_enabled?('unaccent')
  end
end
