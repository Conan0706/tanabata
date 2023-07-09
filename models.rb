require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection


class Post < ActiveRecord::Base
  self.table_name = 'posts'
end
