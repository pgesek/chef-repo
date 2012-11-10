name "jenkins"
description "Jenkins CI server"

run_list "role[oracle-jdk7]",
         "recipe[apt]",
         "recipe[maven::maven3]",
         "recipe[ant]",
         "recipe[git]",
         "recipe[mysql::server]",
         "recipe[mysql::client]",
         "recipe[sqlite]",
         "recipe[couchdb]",
         "recipe[activemq]",
         "recipe[perl]",
         "recipe[jenkins]"

override_attributes(
  :jenkins => {
    :server => { 
      :plugins => ["git", "greenballs", "locks-and-latches", "sonar", "performance", "github-api", "github", "ci-game", 
                   "emotional-jenkins-plugin", "chucknorris", "monitoring", "statusmonitor", "mask-passwords", 
                   "build-timeout", "jsgames" ],
      :host => "localhost",
      :port => 8060
    }
  },
  :maven => {
    :version => 3,
    "3" => {
        :url => "http://www.apache.org/dist/maven/maven-3/3.0.4/binaries/apache-maven-3.0.4-bin.tar.gz"
    }
  }
)
