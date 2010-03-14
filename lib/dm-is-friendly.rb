require 'pathname'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'is' / 'friendly'

# Include the plugin in Model
DataMapper::Model.append_extensions(DataMapper::Is::Friendly)
