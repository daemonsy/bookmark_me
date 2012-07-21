class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      #t.string :subdomain_name # I do not know if domain name should be separated out. But I will separate the storage for convenience.
      t.string :hostname # Avoiding using the naked word domain/subdomain out of superstition of conflicts in methods etc. 
      
      t.timestamps
    end
  end
end
