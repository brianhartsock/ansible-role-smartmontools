

def test_smartmontools_install(host):
    pkg = host.package('smartmontools')

    assert pkg.is_installed
