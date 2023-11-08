public struct ButtonInfo {
    public int index;
    public string name;
    public string type;
    public string default_icon;
    public string default_action;
    public string toggled_icon;
    public string untoggled_action;
    public bool is_toggle;
}

public class LargeButton : Gtk.Box {

    public ButtonInfo button_info;

    public LargeButton (ButtonInfo info) {
        button_info = info;
        Gtk.Grid grid = new Gtk.Grid();
        grid.set_column_homogeneous(true);
        grid.attach(new Gtk.Image.from_icon_name(button_info.default_icon, Gtk.IconSize.DND), 0, 0, 1, 1);
        grid.attach(new Gtk.Label(""), 0, 1, 3, 1);
        Gtk.Label button_label = new Gtk.Label(button_info.name);
        button_label.set_halign(Gtk.Align.START);
        button_label.set_hexpand(true);
        grid.attach(button_label, 0, 2, 3, 1);
        Gtk.Frame frame = new Gtk.Frame(null);
        frame.add(grid);
        add(frame);
        margin = 5;
        show_all();
    }
}

public class SmallButton : Gtk.Button {

    public ButtonInfo button_info {get; private set;}

    public SmallButton (ButtonInfo info) {
        button_info = info;
        add(new Gtk.Image.from_icon_name(button_info.default_icon, Gtk.IconSize.DND));
        set_sensitive(false);
    }
}

public class EditorGrid: Gtk.Grid {

    private Gtk.Entry entry_name = new Gtk.Entry();
    private Gtk.Entry entry_icon = new Gtk.Entry();
    private Gtk.Entry entry_custom_command = new Gtk.Entry();
    private Gtk.Entry entry_toggled_icon = new Gtk.Entry();
    private Gtk.Entry entry_untoggle_command = new Gtk.Entry();
    private Gtk.Switch switch_istoggle = new Gtk.Switch();
    private Gtk.ComboBoxText combobox_type = new Gtk.ComboBoxText();
    private IconPicker.IconPicker icon_default = new IconPicker.IconPicker();
    private IconPicker.IconPicker icon_toggled = new IconPicker.IconPicker();

    public EditorGrid() {
        string[] label_text = { "Button Name", "Default Icon", "Type", "Custom Command",
                              "Toggles", "Toggle Command", "Toggled Icon"};

        string[] builtin_types = { "Airplane Mode", "Screen Snip", "Custom" };

        int i = 1;
        foreach(string text in label_text) {
            Gtk.Label label = new Gtk.Label(text);
            label.set_halign(Gtk.Align.START);
            attach(label, 0, i++, 2, 1);
        }

        foreach (string type in builtin_types) {
            combobox_type.append_text(type);
        }

        Gtk.Widget[] widgets = { entry_name, entry_icon, combobox_type, entry_custom_command,
                                  switch_istoggle, entry_untoggle_command, entry_toggled_icon };

        icon_default.set_hexpand(false);
        icon_default.set_halign(Gtk.Align.START);
        icon_toggled.set_hexpand(false);
        icon_toggled.set_halign(Gtk.Align.START);

        i = 1;
        foreach(Gtk.Widget w in widgets) {
            w.set_hexpand(w != switch_istoggle);
            w.set_halign(w == switch_istoggle ? Gtk.Align.START : Gtk.Align.FILL);
            int span = 2;
            if (w == entry_icon) {
                attach(icon_default, 3, i, 1, 1);
                span = 1;
            }
            if (w == entry_toggled_icon) {
                attach(icon_toggled, 3, i, 1, 1);
                span = 1;
            }
            attach(w, 2, i++, span, 1);
        }

        set_column_homogeneous(false);
        set_hexpand(true);
        set_halign(Gtk.Align.FILL);
        set_column_spacing(5);
        set_row_spacing(5);

        icon_default.icon_selected.connect(() => {
            on_icon_selected(icon_default.get_icon(), entry_icon);
        });
        icon_toggled.icon_selected.connect(() => {
            on_icon_selected(icon_toggled.get_icon(), entry_toggled_icon);
        });

        show_all();
    }

    public void on_icon_selected(string name, Gtk.Entry entry) {
        entry.set_text(name);
    }

    public void set_selected(LargeButton button) {
        ButtonInfo info = button.button_info;
        if (info.is_toggle) {

        }
        if (info.type != "Custom") {
            switch_istoggle.set_sensitive(false);
            switch_istoggle.set_active(false);
            entry_untoggle_command.set_text("");
            entry_untoggle_command.set_sensitive(false);
            entry_toggled_icon.set_text("");
            entry_toggled_icon.set_sensitive(false);
        } else {
            switch_istoggle.set_active(info.is_toggle);
            switch_istoggle.set_sensitive(true);
        }
        entry_name.set_text(info.name);
        entry_icon.set_text(info.default_icon);
        icon_default.set_icon(info.default_icon);
        if (info.toggled_icon != "") {
            icon_toggled.set_icon(info.toggled_icon);
            entry_toggled_icon.set_text(info.toggled_icon);
        }
    }
 }

public class ActionButtonEditor : Gtk.Application {
    public ActionButtonEditor () {
        Object(application_id: "com.github.samlane-ma.action-button-editor",
                flags: ApplicationFlags.FLAGS_NONE);
    }

    private Gtk.ApplicationWindow window;
    private SmallButton[] small_buttons = {};
    private LargeButton[] large_buttons = {};
    private Gtk.FlowBox large_box;
    private Gtk.FlowBox small_box;
    private ButtonInfo[] button_infos;

    private EditorGrid editor_grid;
    private Gtk.Button button_enable_edit;
    private Gtk.Button button_apply;
    private Gtk.Button button_cancel;

    private Gtk.Button button_left;
    private Gtk.Button button_right;
    private Gtk.Label label_title;

    protected override void activate () {
        if (window != null) {
            window.present();
            return;
        }

        window = new Gtk.ApplicationWindow (this);
        window.set_default_size (600, 500);
        window.title = "Budgie Action Buttons";

        Gtk.Grid grid = new Gtk.Grid();
        large_box = new Gtk.FlowBox();
        large_box.set_homogeneous(true);
        large_box.set_hexpand(false);
        large_box.set_halign(Gtk.Align.FILL);
        large_box.set_max_children_per_line(3);
        large_box.set_min_children_per_line(3);
        large_box.set_column_spacing(1);
        large_box.set_can_focus(false);
        large_box.set_selection_mode(Gtk.SelectionMode.BROWSE);
        small_box = new Gtk.FlowBox();
        small_box.set_homogeneous(true);
        small_box.set_max_children_per_line(6);
        small_box.set_max_children_per_line(6);
        small_box.set_column_spacing(1);
        small_box.set_hexpand(false);
        small_box.set_can_focus(false);
        small_box.set_halign(Gtk.Align.CENTER);
        small_box.set_selection_mode(Gtk.SelectionMode.NONE);

        large_box.set_size_request (240, -1);
        small_box.set_size_request (240, -1);
        Gtk.Frame frame_small = new Gtk.Frame("Compact");
        frame_small.set_can_focus(false);
        frame_small.add(small_box);
        Gtk.Frame frame_large = new Gtk.Frame("Large");
        frame_large.set_can_focus(false);
        frame_large.add(large_box);

        Gtk.Label label = new Gtk.Label ("Action Button Editor");
        label.set_halign(Gtk.Align.CENTER);
        label.set_hexpand(true);

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
        box.set_hexpand(false);
        box.set_halign(Gtk.Align.CENTER);
        box.set_size_request(240, -1);
        box.pack_start(label, false, false, 2);
        box.pack_start(frame_small, false, false, 2);
        box.pack_start(frame_large, false, false, 2);

        Gtk.Box move_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        button_left = new Gtk.Button.from_icon_name("stock_left");
        button_left.set_hexpand(false);
        button_right = new Gtk.Button.from_icon_name("stock_right");
        button_right.set_hexpand(false);
        label_title = new Gtk.Label("");
        label_title.set_hexpand(true);
        label_title.set_halign(Gtk.Align.CENTER);
        move_box.pack_start(button_left, false, false, 5);
        move_box.pack_start(label_title, false, false, 5);
        move_box.pack_start(button_right, false, false, 5);
        box.pack_start(move_box, false, false, 2);

        editor_grid = new EditorGrid();
        box.pack_start(editor_grid, false, false, 2);

        Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        button_enable_edit = new Gtk.Button.with_label("Edit");
        button_apply = new Gtk.Button.with_label("Apply");
        button_cancel = new Gtk.Button.with_label("Cancel");
        button_box.pack_start(button_enable_edit, true, true, 2);
        button_box.pack_start(button_apply, true, true, 2);
        button_box.pack_start(button_cancel, true, true, 2);
        button_box.set_hexpand(true);
        button_box.set_halign(Gtk.Align.FILL);
        editor_grid.set_sensitive(false);
        button_apply.set_sensitive(false);
        button_cancel.set_sensitive(false);

        box.pack_start(button_box, false, false, 2);

        button_enable_edit.clicked.connect(() => {
            large_box.set_sensitive(false);
            button_enable_edit.set_sensitive(false);
            editor_grid.set_sensitive(true);
            button_apply.set_sensitive(true);
            button_cancel.set_sensitive(true);
        });

        button_apply.clicked.connect(() => {
            large_box.set_sensitive(true);
            button_enable_edit.set_sensitive(true);
            button_apply.set_sensitive(false);
            button_cancel.set_sensitive(false);
            editor_grid.set_sensitive(false);
        });

        button_cancel.clicked.connect(() => {
            large_box.set_sensitive(true);
            button_apply.set_sensitive(false);
            button_cancel.set_sensitive(false);
            button_enable_edit.set_sensitive(true);
            editor_grid.set_sensitive(false);

        });

        button_left.clicked.connect(() => {
            var current_children = large_box.get_selected_children();
            foreach(var child in current_children) {
                button_moved(child, false);
            }
            });

        button_right.clicked.connect(() => {
            var current_children = large_box.get_selected_children();
            foreach(var child in current_children) {
                button_moved(child, true);
            }
        });

        window.add (box);

        string configdir = GLib.Environment.get_user_config_dir();
        var filename = GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S, configdir, "action-buttons.ini");
        button_infos = load_buttons(filename);

        form_flowboxes();

        large_box.child_activated.connect(button_selected);
        window.show_all ();
    }

    private void button_selected(Gtk.FlowBoxChild child) {
        int index = child.get_index();
        LargeButton selected = (LargeButton) child.get_child();
        editor_grid.set_selected(selected);
        label_title.set_label(selected.button_info.name);
        //button_moved(child, false);

    }

    private void button_moved(Gtk.FlowBoxChild child, bool up) {
        int index = child.get_index();
        int small_index = index;
        var total_children = large_buttons.length;
        stdout.printf("index: %i      total children: %i\n", index, total_children);
        if (up) {
            if (index == 5) { 
                return;
            } else {
                index = index + 1;
            }
        } else {
            if (index == 0) return;
            index = index - 1;
        }

        LargeButton selected = (LargeButton) child.get_child();
        child.remove(selected);
        large_box.remove(child);
        large_box.insert(selected, index);
        large_box.select_child(large_box.get_child_at_index(index));

        Gtk.FlowBoxChild small_child = small_box.get_child_at_index(small_index);
        SmallButton small_selected = (SmallButton) small_child.get_child();
        small_child.remove(small_selected);
        small_box.remove(small_child);
        small_box.insert(small_selected, index);
    }


    private void form_flowboxes() {
        large_box.foreach ((element) => large_box.remove (element));
        small_box.foreach ((element) => small_box.remove (element));
        foreach (ButtonInfo b in button_infos) {
            var l_but = new LargeButton(b);
            var s_but = new SmallButton(b);
            large_buttons += l_but;
            small_buttons += s_but;
            large_box.add(l_but);
            small_box.add(s_but);
        }
    }

    private int sort_func(Gtk.FlowBoxChild child_a, Gtk.FlowBoxChild child_b) {
        LargeButton a = (LargeButton) child_a.get_child();
        LargeButton b = (LargeButton) child_b.get_child();
        return (a.button_info.index - b.button_info.index);
    }

    private ButtonInfo[] load_buttons(string filename) {
        ButtonInfo[] button_infos = {};
        GLib.KeyFile keyfile = new GLib.KeyFile();
        try{
            keyfile.load_from_file(filename, GLib.KeyFileFlags.NONE);
        } catch (Error e) {
            message("Error loading data: %s", e.message);
        }

       string[] groups;
        groups = keyfile.get_groups();
        int index = 0;
        foreach (string item in groups) {
            ButtonInfo button_info = {0, "", "", "", "", "", "" };
            try { 
                string[] keys = keyfile.get_keys(item);
                // Probably should convert to hash...
                foreach (string key in keys) {
                    switch(key) {
                        case "Name":
                            button_info.name = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "Type":
                            button_info.type = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "Icon":
                            button_info.default_icon = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "ToggledIcon":
                            button_info.toggled_icon = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "DefaultAction":
                            button_info.default_action = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "UntoggleAction":
                            button_info.untoggled_action = keyfile.get_string(item, key);
                            stdout.printf("Setting %i button: %s = %s\n", index, item, key);
                            break;
                        case "IsToggle":
                            button_info.is_toggle = keyfile.get_boolean(item, key);
                            break;
                    }
                }
                button_info.index = index;
                index++;
                button_infos += button_info;
            } catch (KeyFileError e) {
                message ("Error in group %s: %s", item, e.message);
                try {
                    keyfile.remove_group(item);
                } catch (KeyFileError x) {
                    message ("Error processing data: %s", x.message);
                }
            }
        }
        while (button_infos.length < 6) {
            ButtonInfo empty_button = {button_infos.length, "", "", "", "", "", "", false };
            button_infos += empty_button;
        }
        return (button_infos);
    }


    public static int main (string[] args) {
        ActionButtonEditor app = new ActionButtonEditor();
        return app.run (args);
    }
}