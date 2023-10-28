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

    public ActionButtonsRavenWidget(string uuid, GLib.Settings? settings) {
        initialize(uuid, settings);

        var screen = this.get_screen ();
        var css_provider = new Gtk.CssProvider();
        try {
            css_provider.load_from_data(".action_button { border-style: solid; border-width: 0.2px; padding: 2px; font-size: 11px; }" +
                                        ".small_action_button { border-style: solid; border-width: 0.2px; padding: 2px; font-size: 10px; }");
            Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        } catch (GLib.Error e) {
            message("Unable to load css data: %s", e.message);
        }

        button_box = new ActionButtonBox();

        add(button_box);
        show_all();

        // raven_expanded is triggered when the panel is opened or closed
        raven_expanded.connect((expanded) => {
            if (expanded) {
                // update buttons
                button_box.refresh();
            } else {

            }
        });
    }

    public override Gtk.Widget build_settings_ui() {
        return new ActionButtonsRavenWidgetSettings(get_instance_settings());
    }
}

public class ActionButtonsRavenWidgetSettings : Gtk.Grid {
    Gtk.CheckButton checkbutton;

    public ActionButtonsRavenWidgetSettings (Settings? settings) {
        checkbutton = new Gtk.CheckButton.with_label("Settings");
        attach(checkbutton, 0, 1, 1, 1);
        settings.bind("settings", checkbutton, "active", GLib.SettingsBindFlags.DEFAULT);
        show_all();
    }
}

[ModuleInit]
public void peas_register_types(TypeModule module) {
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.RavenPlugin), typeof(ActionButtonsRavenPlugin));
}
