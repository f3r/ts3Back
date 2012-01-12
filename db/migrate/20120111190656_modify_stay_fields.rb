class ModifyStayFields < ActiveRecord::Migration
  def change
    rename_column :places, :minimum_stay_days, :minimum_stay
    rename_column :places, :maximum_stay_days, :maximum_stay
    add_column    :places, :stay_unit, :string
  end
end
