# Third party requirements.
require "marten"
require "marten_auth"
require "sqlite3"

# Project requirements.
require "./auth/app"
require "./handlers/**"
require "./models/**"
require "./schemas/**"

# Configuration requirements.
require "../config/routes"
require "../config/settings/base"
require "../config/settings/**"
require "../config/initializers/**"
