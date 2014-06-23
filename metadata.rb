name 'drupal'
maintainer 'Neontribe'
maintainer_email 'support@neontribe.co.uk'
license 'Apache 2.0'
description 'Installs drupal using a neontribe manifest'

# only tested on ubuntu but should work on others
#%w{ amazon arch centos debian fedora redhat scientific oracle rhel slackware suse ubuntu }.each do |os|
#  supports os
#end

# supports 'mac_os_x', '>= 10.6.0'

depends 'ntdrush'

