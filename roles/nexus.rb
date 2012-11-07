name "nexus"
description "Sonatype Nexus"

run_list "recipe[build-essential]", "recipe[ruby::1.9.1]", "recipe[nexus]"
  
override_attributes(
  :nexus => {
    :cli => {
      :packages => ["libxml2-dev", "libxslt-dev"]
    }
  }
)