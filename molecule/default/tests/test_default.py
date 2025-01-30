

def test_smartmontools_install(host):
    pkg = host.package('smartmontools')

    assert pkg.is_installed


def test_smartd_is_running(host):
    # This test helps validate the install also configures the service to run
    service = host.service('smartd')

    # This doesn't work well in molecule tests running inside Docker containers
    # assert service.is_running
    assert service.is_enabled


def test_smartd_config_file(host):
    config_file = host.file('/etc/smartd.conf')

    assert config_file.exists
    assert config_file.is_file
    assert config_file.user == 'root'
    assert config_file.group == 'root'
    assert config_file.mode == 0o644


def test_smartd_config_contains_line(host):
    config_file = host.file('/etc/smartd.conf')

    assert config_file.contains('DEVICESCAN test')
