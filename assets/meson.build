datadir = get_option('datadir')

# Plugin
install_data('HeadsetControlApplet.plugin',
             install_dir: LIB_INSTALL_DIR)

# Schemas
install_data('net.olback.budgie-headset-control-applet.gschema.xml',
            install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))

# Appdata
install_data('net.olback.budgie-headset-control-applet.appdata.xml',
             install_dir: join_paths(datadir, 'appdata'))

# Compile schemas
meson.add_install_script('meson_post_install.py')
