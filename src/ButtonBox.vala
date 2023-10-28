
public class ActionButtonBox : Gtk.FlowBox {

    private ActionButton[] buttons = {};

    public ActionButtonBox() {

        set_homogeneous(true);
        set_max_children_per_line(3);
        set_column_spacing(2);

        ActionButton button_1 = new ActionButton("  Settings", "ubuntu-budgie-symbolic");
        button_1.set_default_action("budgie-desktop-settings");
        ActionButton button_2 = new AirplaneActionButton();
        ActionButton button_3 = new ClipActionButton();

        buttons += button_1;
        buttons += button_2;
        buttons += button_3;

        foreach (Gtk.Widget item in buttons) {
            add(item);
        }
        show_all();
    }

    public void refresh() {
        foreach(ActionButton item in buttons) {
            item.update_state();
        }
    }
}