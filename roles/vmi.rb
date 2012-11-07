name "vmi"
description "VMI server"

override_attributes(
  :jenkins => {
    :server => {
      :prefix => "/ci"
    }
  },
  :mysql => {
    :bind_address => "localhost",
    :server_root_password => "password"
  },
  :sonar => {
    :web_context => "/sonar"
  }
)