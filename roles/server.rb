name "server"
description "A basic server with sudo, users, etc." 

run_list "recipe[sudo]", "recipe[users::sysadmins]", "recipe[vim]", "recipe[curl]", 
         "recipe[chef-client::delete_validation]"

default_attributes(
  :authorization => {
    :sudo => {
      :groups => ["admin", "wheel", "sysadmin"],
      :passwordless => true
    }
  }
)