require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_ntpserver).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "ntpserver"
  end

  def self.instances
    instances = []
    servers = Puppet::Provider::Netscaler.call('/config/ntpserver')
    return [] if servers.nil?

    servers.each do |server|
      instances << new(
        :ensure                => :present,
        :name                  => server['serverip'] || server['servername'],
        :minimum_poll_interval => server['minpoll'],
        :maximum_poll_interval => server['maxpoll'],
        :auto_key              => server['autokey'],
        :key                   => server['key'],
        :preferred_ntp_server  => server['preferredntpserver'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name                  => :servername,
      :minimum_poll_interval => :minpoll,
      :maximum_poll_interval => :maxpoll,
    }
  end

  def immutable_properties
    [
    ]
  end
  def per_provider_munge(message)
    # Not accepted on create
    # XXX But can we fix this so it can?
    if ! @original_values[:ensure]
      message.delete(:preferred_ntp_server)
    end
    message
  end
end