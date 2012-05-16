class MigrateRouteAs < ActiveRecord::Migration
  def up
     execute "UPDATE `cmspages` SET `route_as`= 'home_why' where id =1" 
     execute "UPDATE `cmspages` SET `route_as`= 'home_how' where id =2" 
     execute "UPDATE `cmspages` SET `route_as`= 'cityguide_sg' where id =3" 
     execute "UPDATE `cmspages` SET `route_as`= 'cityguide_hk' where id =4" 
     execute "UPDATE `cmspages` SET `route_as`= 'cityguide_kl' where id =5" 
  end

  def down
  end
end
