
project('com.github.samlane-ma.budgie-action-buttons',
        ['vala', 'c'],
        version: '0.1.0',
        meson_version: '>=0.57.0',
        license: 'GPL3')

# Global path variable
prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))

PIXMAPS_DIR = join_paths(datadir, 'pixmaps')
LIB_INSTALL_DIR = join_paths(prefix, libdir, 'budgie-desktop', 'raven-plugins', meson.project_name())
SCHEMADIR = join_paths(prefix, 'share', 'glib-2.0', 'schemas')
VAPI_DIR = join_paths(meson.source_root(), 'vapi')

vala = meson.get_compiler('vala')
conf = configuration_data()
conf.set('PACKAGE_NAME', 'com.github.samlane-ma.budgie-action-buttons' )
conf.set_quoted('PACKAGE_LIBDIR', libdir)

config_h = configure_file(
	output: 'config.h',
	configuration: conf
)

config_dep = declare_dependency(
	dependencies: vala.find_library('config', dirs: VAPI_DIR),
	sources: config_h
)

config_inc_dir = include_directories('.')

# Why? Because Raven Widget schemas must be named the same as the
# module, so why not...
schema_name = meson.project_name() + '.gschema.xml'
install_data('schema' / schema_name, install_dir: SCHEMADIR)

subdir('src')
subdir('icons')
subdir('data')

gnome = import('gnome')
gnome.post_install(glib_compile_schemas: true)
