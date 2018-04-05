# Manage fpm service
#
# === Parameters
#
# [*service_name*]
#   name of the php-fpm service
#
# [*ensure*]
#   'ensure' value for the service
#
# [*enable*]
#   Defines if the service is enabled
#
class php::fpm::service(
  $service_name = "${::php::fpm_servicename_prefix}fpm",
  $ensure       = 'running',
  $enable       = $::php::params::fpm_service_enable,
) inherits ::php::params {

  if $caller_module_name != $module_name {
    warning('php::fpm::service is private')
  }


  #
  ## Use of '${service_name}' here is not correct; we should be
  ## referring to the Service's 'namevar'.
  ##
  ## Also, assuming that the 'service' utility is available everywhere
  ## is less than ideal..
  ##
  ## XXX - for now, punt on it. Just go with the system's
  ##       implementation of restart
  #
#  $reload = "service ${service_name} reload"

  $reload = undef

  if $::osfamily == 'Debian' {
    # Precise upstart doesn't support reload signals, so use
    # regular service restart instead
    $restart = $::lsbdistcodename ? {
      'precise' => undef,
      default   => $reload
    }
  } else {
    $restart = $reload
  }

  service { $service_name:
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    restart    => $restart,
    hasstatus  => true,
  }

  ::Php::Extension <| |> ~> Service[$service_name]
}
