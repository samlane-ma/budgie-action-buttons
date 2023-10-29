
public class ActionButtonBox : Gtk.FlowBox {

    private ActionButton[] buttons = {};

    public ActionButtonBox() {

        set_homogeneous(true);
        set_max_children_per_line(3);
        set_column_spacing(1);

        ActionButton button_1 = new ActionButton("  Settings", "ubuntu-budgie-symbolic");
        button_1.set_default_action("budgie-desktop-settings");
        ActionButton button_2 = new AirplaneActionButton();
        ActionButton button_3 = new ClipActionButton();
        ActionButton button_4 = new ActionButton("   Home", "folder-symbolic");
        button_4.set_default_action("nemo ~/");
        ActionButton button_5 = new ActionButton("Google Drive", "folder-google-drive-symbolic");
        button_5.set_default_action("xdg-open https://drive.google.com");
        ActionButton button_6 = new ActionButton("Zoom Screen", "zoom-symbolic");
        button_6.set_default_action("magnus");

        buttons += button_1;
        buttons += button_2;
        buttons += button_3;
        buttons += button_4;
        buttons += button_5;
        buttons += button_6;

        foreach (Gtk.Widget item in buttons) {
            add(item);
        }
        button_1.set_small_button(true);
        button_1.set_small_button(false);

        show_all();
    }

    public void refresh() {
        foreach(ActionButton item in buttons) {
            item.update_state();
        }
    }

    public void set_compact_mode(bool compact) {
        set_max_children_per_line(compact ? buttons.length : 3);
        foreach(ActionButton item in buttons) {
            item.set_small_button(compact);
        }
    }
}