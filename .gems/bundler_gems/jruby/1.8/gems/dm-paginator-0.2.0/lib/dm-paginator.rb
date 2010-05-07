require "dm-core"
require "erb"
require "dm-paginator/paginator"
require "dm-paginator/default"
require "dm-paginator/main"
require "dm-paginator/control"
require "dm-paginator/control/control_helper_abstract"
require "dm-paginator/control/all"
require "dm-paginator/control/sliding"
require "dm-paginator/control/elastic"
require "dm-paginator/control/jumping"

DataMapper::Model.append_extensions DataMapper::Paginator
DataMapper::Collection.send :include, DataMapper::Paginator
DataMapper::Query.send :include, DataMapper::Paginator