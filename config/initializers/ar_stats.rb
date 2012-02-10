require 'ar_stats'
# include the extension 
ActiveRecord::Base.send(:include, ActiveRecord::Stats)