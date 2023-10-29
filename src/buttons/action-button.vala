
public class ActionButton : Gtk.Button {

    protected Gtk.Grid button_grid;
    protected Gtk.Image button_image;
    protected string default_image;
    protected string? toggle_image = null;
    protected Gtk.Label button_label;
    protected string button_text;
    protected bool small_size = false;
    protected bool can_toggle = false;
    protected bool is_clicked = false;
    protected bool is_builtin = false;
    protected Gtk.IconSize icon_size = Gtk.IconSize.LARGE_TOOLBAR;

    protected string? default_action = null;
    protected string? untoggled_action = null;

    public ActionButton(string text, string image_name) {

        button_text = text;
        default_image = image_name;
        button_grid = new Gtk.Grid();
        button_label = new Gtk.Label(button_text);
        button_label.set_halign(Gtk.Align.START);
        get_style_context().add_class("action_button");

        button_image = new Gtk.Image.from_icon_name(default_image, icon_size);

        button_grid.attach(button_image, 0, 0, 1, 1);
        button_grid.attach(new Gtk.Label(""), 0, 1, 2, 1);
        button_grid.attach(button_label, 0, 2, 2, 1);
        button_grid.set_column_homogeneous(true);
        
        add(button_grid);

        clicked.connect(on_button_clicked);

        set_can_focus(false);
        //set_relief(Gtk.ReliefStyle.NONE);

        show_all();
    }

    private void on_button_clicked() {
        if (!can_toggle || !is_clicked) {
            is_clicked = can_toggle;
            button_default_action();
            if (toggle_image != null) {
                button_image.set_from_icon_name(toggle_image, icon_size);
            }
        } else {
            is_clicked = false;
            button_untoggled_action();
            if (toggle_image != null) {
                button_image.set_from_icon_name(default_image, icon_size);
            }
        }
    }

    protected virtual void button_default_action() {
        if (default_action == null) return;
        run_command(default_action);
    }

    protected virtual void button_untoggled_action() {
        if (untoggled_action == null) return;
        can_toggle = true;
        run_command(untoggled_action);
    }

    public void set_default_action(string action) {
        if (is_builtin) return;
        default_action = action;
    }

    public void set_untoggled_action(string action) {
        if (is_builtin) return;
        can_toggle = true;
        untoggled_action = action;
    }

    public void set_toggle_icon(string name) {
        toggle_image = name;
    }

    public virtual void update_state () {
    }

    private void run_command(string command) {
        try {
            Process.spawn_command_line_async(command);
        } catch (SpawnError e) {
            warning("Failed to run %s: %s", command, e.message);
        }
    }

    public void set_small_button(bool small) {
        if (small) {
            icon_size = Gtk.IconSize.DND;
            button_grid.remove(button_image);
            remove(button_grid);
            add(button_image);
            set_tooltip_text(button_text.strip());
        } else {
            icon_size = Gtk.IconSize.LARGE_TOOLBAR;
            remove(button_image);
            button_grid.attach(button_image, 0, 0, 1, 1);
            add(button_grid);
            has_tooltip = false;
        }
        if (!can_toggle || !is_clicked) {
            button_image.set_from_icon_name(default_image, icon_size);
        } else {
            button_image.set_from_icon_name(toggle_image, icon_size);
        }
    }
}
