ActionButtonsSources = ['ActionButtons.vala',
                        'ButtonBox.vala',
                        'buttons/action-button.vala',
                        'buttons/airplane-button.vala',
                        'buttons/screenclip-button.vala'
]

ActionButtonsDependencies = [
    dependency('gtk+-3.0', version: '>=3.18'),
    dependency('libpeas-gtk-1.0'),
    dependency('budgie-raven-plugin-1.0'),
    meson.get_compiler('c').find_library('m', required: false)
]

ActionButtonsValaArgs = [
'--pkg=config',
'--vapidir=' + VAPI_DIR,
]

shared_library(meson.project_name(),
               ActionButtonsSources,
               vala_args: ActionButtonsValaArgs,
               include_directories: config_inc_dir,
               dependencies: ActionButtonsDependencies,
               install: true, install_dir: LIB_INSTALL_DIR)

subdir('editor')
