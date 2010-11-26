require "dm-is-friendly/is/friendly"

# Include the plugin in Model
DataMapper::Model.append_extensions(DataMapper::Is::Friendly)
