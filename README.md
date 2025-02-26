Ansible Role: smartmontools
=========
[![CI](https://github.com/brianhartsock/ansible-role-smartmontools/actions/workflows/ci.yml/badge.svg)](https://github.com/brianhartsock/ansible-role-smartmontools/actions/workflows/ci.yml)

A simple role to install and configure smartmontools, including smartd.

Requirements
------------

This role has been tested on Ubuntu 20.04, 22.04, and 24.04.

Role Variables
--------------

The following variables are defined in `defaults/main.yml` and can be used to further configure smartd service.

```yaml
smartmon_configuration_lines:
  - DEVICESCAN ... whatever configuration you want here
```

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - brianhartsock.smartmontools

License
-------

MIT

Author Information
------------------

Created with love by [Brian Hartsock](http://blog.brianhartsock.com).
