#!/bin/bash

# install dependencies
/usr/bin/yum install git -y
/usr/bin/yum install jq -y
/usr/bin/gem2.0 install puppet -v '~> 3.7' --no-ri --no-rdoc
/usr/bin/gem2.0 install hiera --no-ri --no-rdoc

# classify this node as a webapp
/bin/mkdir -p /etc/facter/facts.d
/bin/echo 'type=webapp' > /etc/facter/facts.d/classify.txt

# install git repo
/usr/bin/git clone https://github.com/relud/puppet-demo /etc/puppet

# install secrets
/bin/mkdir -p /etc/puppet/yaml/secrets
/usr/bin/aws s3 cp s3://relud-demo-1/secrets.yaml /etc/puppet/secrets/secrets.yaml

# install forge modules

## list the modules to install via hiera
json_modules="$(/usr/local/bin/hiera -c /etc/puppet/hiera.yaml -a modules)"
## convert modules from list of json strings, to newline separated strings
modules="$(echo "$json_modules" | /usr/bin/jq '.[]')"
## convert module strings to puppet module install commands
commands="$(echo "$modules" | /usr/bin/sed 's,^,/usr/local/bin/puppet module install --force ,')"
## execute commands
echo "$commands" | /bin/bash

# run puppet
/usr/local/bin/puppet apply /etc/puppet/site.pp
