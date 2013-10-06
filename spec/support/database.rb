module Database

  def self.database_file
    @database_file || File.expand_path('../test.db', __FILE__)
  end

  def self.setup
    create

    # Hide migration logs
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: database_file)
  end

  def self.clean
    destroy
  end


  protected

  def self.create
    SQLite3::Database.new FileUtils.touch(File.expand_path('../test.db', __FILE__)).first
  end

  def self.destroy
    FileUtils.rm(database_file) if File.exists?(database_file)
  end
end
