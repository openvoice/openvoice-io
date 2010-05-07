#!/usr/bin/env ruby1.8
require "rubygems"
require "dm-core"
require "dm-paginator"

class Item
	include DataMapper::Resource
	property :id, Serial
end
 
DataMapper.setup :default, "sqlite3::memory:"
DataMapper.auto_migrate!
( 1..10 ).each { | n | Item.create }

def test_paginator
	@items = Item.limit_page nil, :limit => 2
	p "<ul>"
	@items.each do | item |
		p "<li>" + item.id.to_s + "</li>"
	end
	p "</ul>"

	p "page: " + @items.paginator.page.to_s
	p "count: " + @items.paginator.count.to_s
	p "page_count: " + @items.paginator.page_count.to_s

  p @items.paginator.to_html "All", "control.erb"
end

test_paginator
