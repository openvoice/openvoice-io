class CreateSysConfigs < ActiveRecord::Migration
  def self.up
    create_table :sys_configs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :sys_configs
  end
end
