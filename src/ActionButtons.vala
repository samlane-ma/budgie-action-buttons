/*
 *  Action Button Widget for Budgie Desktop Raven Panel
 *
 *  Copyright © 2023 Samuel Lane
 *  http://github.com/samlane-ma/
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

public class ActionButtonsRavenPlugin : Budgie.RavenPlugin, Peas.ExtensionBase {
    public Budgie.RavenWidget new_widget_instance(string uuid, GLib.Settings? settings) {
        return new ActionButtonsRavenWidget(uuid, settings);
    }

    public bool supports_settings() {
        return true;
    }
}

public class ActionButtonsRavenWidget : Budgie.RavenWidget {

    private ActionButtonBox button_box;
    private Settings? settings;

    public ActionButtonsRavenWidget(string uuid, GLib.Settings? settings) {
        initialize(uuid, settings);

        this.settings = settings;

        var screen = this.get_screen ();
        var css_provider = new Gtk.CssProvider();
        try {
            css_provider.load_from_data(".action_button { border-style: none; border-width: 0.2px; padding: 1px; font-size: 11px; }" +
                                        ".small_action_button { border-style: solid; border-width: 0.2px; padding: 1px; font-size: 10px; }");
            Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        } catch (GLib.Error e) {
            message("Unable to load css data: %s", e.message);
        }

        button_box = new ActionButtonBox();

        add(button_box);
        on_compact_changed();
        show_all();

        // raven_expanded is triggered when the panel is opened or closed
        raven_expanded.connect((expanded) => {
            if (expanded) {
                // update buttons
                button_box.refresh();
            } else {

            }
        });

        settings.changed["compact-buttons"].connect(on_compact_changed);
    }

    private void on_compact_changed() {
        button_box.set_compact_mode(settings.get_boolean("compact-buttons"));
    }

    public override Gtk.Widget build_settings_ui() {
        return new ActionButtonsRavenWidgetSettings(get_instance_settings());
    }
}

public class ActionButtonsRavenWidgetSettings : Gtk.Grid {

    private string editor;

    public ActionButtonsRavenWidgetSettings (Settings? settings) {

        string libdir = Config.PACKAGE_LIBDIR;
        editor = GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S, libdir, "budgie-desktop", "raven-plugins",
                                      "com.github.samlane-ma.budgie-action-buttons", "action-button-editor");

        Gtk.Switch switch_compact = new Gtk.Switch();
        settings.bind("compact-buttons", switch_compact, "active", SettingsBindFlags.DEFAULT);

        attach(new Gtk.Label("Compact Mode"), 0, 0, 1, 1);
        attach(switch_compact, 1, 0, 1, 1);

        Gtk.Button button = new Gtk.Button.with_label("Editor");
        attach(button, 0, 1, 2, 1);
        button.clicked.connect(on_editor_button_clicked);
        show_all();
    }

    private void on_editor_button_clicked() {
        try {
            Process.spawn_command_line_async(editor);
        } catch (SpawnError e) {
            warning("Failed to run editor: %s", e.message);
        }
    }

}

[ModuleInit]
public void peas_register_types(TypeModule module) {
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.RavenPlugin), typeof(ActionButtonsRavenPlugin));
}
