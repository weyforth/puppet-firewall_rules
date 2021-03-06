class firewall_rules::pre {

	Firewall {
		require => undef,
	}

	firewallchain { 'fail2ban-ssh:filter:IPv4':
		ensure => present,
		purge  => false,
	}

	firewallchain { 'fail2ban-ssh-ddos:filter:IPv4':
		ensure => present,
		purge  => false,
	}

	firewallchain { 'INPUT:filter:IPv4':
		ensure => present,
		purge  => true,
		ignore => [
	    # ignore the fail2ban jump rule
	    'fail2ban',
	    # ignore any rules with "ignore" (case insensitive) in the comment in the rule
	    '--comment "[^"](?i:ignore)[^"]"',
    ],
	}

	firewallchain { 'FORWARD:filter:IPv4':
		ensure => present,
		purge  => true,
	}

	firewallchain { 'OUTPUT:filter:IPv4':
		ensure => present,
		purge  => true,
	}

	# Default firewall rules
	firewall { '000 accept all icmp':
		proto   => 'icmp',
		action  => 'accept',
	}

	firewall { '001 accept all to lo interface':
		proto   => 'all',
		iniface => 'lo',
		action  => 'accept',
	}

	firewall { '002 accept related established rules':
		proto   => 'all',
		state   => ['RELATED', 'ESTABLISHED'],
		action  => 'accept',
	}

	firewall { '011 allow ssh':
		dport   => 22,
		proto   => 'tcp',
		action  => 'accept',
	}

	define firewall_rule_all_from_ip {
		firewall { "011 allow traffic from ip: ${name}":
			proto  => 'all',
			action => 'accept',
			source => "${name}",
		}
	}

	$allowed_hosts = hiera('firewall::allowed_hosts', [])
	firewall_rule_all_from_ip { $allowed_hosts: }

}