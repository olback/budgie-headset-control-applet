gnome = import('gnome')

assets_dir = join_paths(meson.source_root(), 'assets')
vapi_dir = join_paths(meson.source_root(), 'vapi')

gresource_file = join_paths(assets_dir, 'net.olback.budgie-headset-control-applet.gresource.xml')
res = gnome.compile_resources('bhca-resources', gresource_file, source_dir: assets_dir)

version_data = configuration_data()
version_data.set('VERSION', meson.project_version())
configure_file(input: 'version.h.in', output: 'version.h', configuration: version_data)

bhca_sources = [
    'BHCNotify.vala',
    'Result.vala',
    'Commands.vala',
    'HeadsetControlApplet.vala',
    res
]

bhca_dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('libnotify'),
    dependency('libpeas-1.0', version: '>= 1.8.0'),
    dependency('budgie-1.0', version: '>=2'),
]

bhca_vala_args = [
    '--pkg=version',
    '--vapidir=' + vapi_dir,
    '--gresources=' + gresource_file,
]

bhca_c_args = [
    '-include',
    'version.h'
]

shared_library('headsetcontrolapplet', bhca_sources,
               dependencies: bhca_dependencies,
               vala_args: bhca_vala_args,
               c_args: bhca_c_args,
               install: true,
               install_dir: LIB_INSTALL_DIR)
