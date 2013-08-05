require "active_support/core_ext/hash/deep_merge"
require "configus/version"

module Configus
  autoload "Builder", "configus/builder"
  autoload "Config",  "configus/config"
  autoload "Hasher",  "configus/hasher"
end
