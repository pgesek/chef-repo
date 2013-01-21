name "oracle-jdk6"
description "Installs oracle java version 6"

run_list "recipe[java]"

override_attributes(
  :java => {
    :install_flavor => "oracle",
    :jdk_version => 6,
    :oracle => {
      :accept_oracle_download_terms => true
    }
  }
)
