EditorSources = [
    'editor.vala',
    'iconpicker.vala',
]

EditorDependencies = [
    dependency('gtk+-3.0', version: '>=3.18'),
    dependency('gee-0.8'),
]

EditorValaArgs = [
'--pkg=config',
'--vapidir=' + VAPI_DIR,
]

executable('action-button-editor',
            EditorSources,
            vala_args: EditorValaArgs,
            dependencies: EditorDependencies,
            include_directories: config_inc_dir,
            install: true, install_dir: LIB_INSTALL_DIR)