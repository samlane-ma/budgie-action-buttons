namespace IconPicker {

public class IconTreeView : Gtk.TreeView {

    private Gtk.ListStore list_store;
    private Gtk.TreeModelFilter filter;
    private string search = "";
    public Gtk.TreeSelection icon_selection;
    public signal void icon_changed(string icon_name);
    
    public IconTreeView() {

        list_store = new Gtk.ListStore (2, typeof (string), typeof(string));
        Gtk.TreeIter iter;

        var icon_theme = Gtk.IconTheme.get_default();
        List<string> icons_list = icon_theme.list_icons(null);
        CompareFunc<string> strcmp = (a, b) => {
            return GLib.strcmp (a.down(), b.down());
        };

        set_size_request(400, 400);
        icons_list.sort(strcmp);

        foreach(string name in icons_list) {
            list_store.append (out iter);
            list_store.set (iter, 0, name, 1, name);
        }

        filter = new Gtk.TreeModelFilter(list_store, null);
        filter.set_visible_func(cmp);
        set_model (filter);
        set_headers_visible(false);
        set_enable_search(false);

        Gtk.TreeViewColumn icon_col = new Gtk.TreeViewColumn ();
        icon_col.set_sort_column_id(0);
        Gtk.CellRenderer renderer_pixbuf = new Gtk.CellRendererPixbuf();
        renderer_pixbuf.set_property("stock-size", Gtk.IconSize.DND);
        icon_col.pack_start(renderer_pixbuf, false);
        icon_col.add_attribute(renderer_pixbuf, "icon-name", 1);
        append_column(icon_col);

        Gtk.TreeViewColumn text_col = new Gtk.TreeViewColumn();
        text_col.set_sort_column_id(0);
        Gtk.CellRenderer renderer_text = new Gtk.CellRendererText();
        //renderer_text.set_property("ellipsize", Pango.EllipsizeMode.END);
        text_col.pack_start(renderer_text, true);
        text_col.add_attribute(renderer_text, "text", 1);
        append_column(text_col);

        icon_selection = get_selection();
        activate_on_single_click = true;
        row_activated.connect((p, c) => {
            Gtk.TreeIter tv_iter;  
            GLib.Value val;
            var model = get_model();
            model.get_iter(out tv_iter, p);
            model.get_value(tv_iter, 0, out val);
            string x = (string) val;
            icon_changed(x);
        });
    }

    private bool cmp (Gtk.TreeModel? model, Gtk.TreeIter? iter){
        if (search == "") {
            return true;
        }
        GLib.Value? x;
        if (model == null || iter == null) return false;
        model.get_value(iter, 0, out x);
        if (x == null) return false;
        string name = (string) x;
        if (name.down().contains(search.down())) {
           return (true);
        }
        return(false);
    }

    public void update_filter(string find_string) {
        search = find_string;
        icon_selection.unselect_all();
        filter.refilter();
    }
}


public class IconPickerGrid: Gtk.Grid {
    
    public IconTreeView icon_view;
    private Gtk.Entry search_entry;
    private Gtk.Image current_icon;
    private string current_icon_name = "";
    private Gtk.Label icon_label;
    private ulong signal_id = 0;
    private Gtk.ScrolledWindow scrolled;

    public class IconPickerGrid () {

        search_entry = new Gtk.Entry();
        search_entry.set_placeholder_text("Enter text to search");
        icon_view = new IconTreeView();
        icon_label = new Gtk.Label("");
        icon_label.set_halign(Gtk.Align.FILL);
        icon_label.set_hexpand(true);
        current_icon = new Gtk.Image();
        Gtk.Box icon_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        icon_box.set_hexpand(false);
        icon_box.set_halign(Gtk.Align.CENTER);
        icon_box.set_size_request(48, 48);
        icon_box.add(current_icon);
        scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.add(icon_view);
        scrolled.set_hexpand(true);
        scrolled.set_vexpand(true);
        this.attach(search_entry, 0, 0, 3, 1);
        this.attach(scrolled,     0, 1, 3, 1);
        this.attach(icon_box, 1, 2, 1, 1);
        this.attach(icon_label, 0, 3, 3, 1);
        icon_view.grab_focus();
        show_all();

        set_filter_mode_continuous(true);

        icon_view.icon_changed.connect(on_icon_changed);
    }

    private void on_icon_changed(string name) {
        current_icon_name = name;
        current_icon.set_from_icon_name(name, Gtk.IconSize.DIALOG);
        icon_label.set_label(current_icon_name);
    }

    public string get_current_icon() {
        return current_icon_name;
    }

    public void set_filter_mode_continuous(bool continuous) {
        if (signal_id != 0) {
            GLib.SignalHandler.disconnect(search_entry, signal_id);
            signal_id = 0;
        }
        if (continuous) {
            signal_id = search_entry.changed.connect(() => {
                icon_view.update_filter(search_entry.get_text());
                Idle.add(() => {
                    if (search_entry.get_text() == "") {
                        icon_view.vadjustment.value = 0;
                    }
                    return false;
                });
            });
        } else {
            signal_id = search_entry.activate.connect(() => {
                icon_view.icon_selection.unselect_all();
                icon_view.update_filter(search_entry.get_text());
                Idle.add(()=> {
                    icon_view.vadjustment.value = 0;
                    return false;
                });
            });
        }
    }
}


public class IconPickerDialog : Gtk.Dialog {

    private IconPickerGrid icon_grid;

	public IconPickerDialog () {
		this.title = "Select an icon";
		this.border_width = 5;
		set_default_size (400, 400);

		// Layout widgets
        icon_grid = new IconPickerGrid ();

		Gtk.Box content = get_content_area () as Gtk.Box;
		content.pack_start (icon_grid, false, true, 0);
		content.spacing = 10;

		// Add buttons to button area at the bottom
		add_button ("Select", Gtk.ResponseType.OK);
		add_button ("Cancel", Gtk.ResponseType.CANCEL);

        set_response_sensitive(Gtk.ResponseType.OK, false);
        icon_grid.icon_view.icon_changed.connect (() => {
            set_response_sensitive(Gtk.ResponseType.OK, true);
        });
	}

    public string get_current_icon() {
        return icon_grid.get_current_icon();
    }
}

public class IconPicker : Gtk.Button{

    private string default_icon = "search-symbolic";
    private string current_icon = "";
    private Gtk.Image icon;

    public signal void icon_selected();

    public class IconPicker() {
        
        icon = new Gtk.Image.from_icon_name(default_icon, Gtk.IconSize.DND);
        add(icon);
        set_always_show_image(true);
        set_hexpand(false);
        set_vexpand(false);
        set_halign(Gtk.Align.CENTER);
        set_valign(Gtk.Align.CENTER);
        clicked.connect (() => {
            IconPickerDialog dialog = new IconPickerDialog();
            var response = dialog.run();
            if (dialog.get_current_icon() != "" && response != Gtk.ResponseType.CANCEL) {
                current_icon = dialog.get_current_icon();
                icon_selected();
                icon.set_from_icon_name(current_icon, Gtk.IconSize.DND);
            }
            dialog.destroy();
        });
    }

    public string get_icon() {
        return current_icon;
    }

    public void set_default_icon(string icon_name) {
        default_icon = icon_name;
        icon.set_from_icon_name(default_icon, Gtk.IconSize.DND);
    }

    public bool has_icon(string name) {
        Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
        if (theme.has_icon(name)){
            return true;
        }
        return false;
    }

    public void set_icon(string name) {
        icon.set_from_icon_name(name, Gtk.IconSize.DND);
    }
}

}
