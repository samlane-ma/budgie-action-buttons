[DBus (name = "org.gnome.SettingsDaemon.Rfkill")]
interface RfKill : Object {
    [DBus (name = "AirplaneMode")]
    public abstract bool airplanemode { owned get; set; }
}

public class AirplaneActionButton : ActionButton {

    private RfKill rfkill;
    private bool enabled = false;

    public AirplaneActionButton() {
        base("Airplane Mode", "airplane-mode-disabled-symbolic" );
        can_toggle = true;
        is_builtin = true;
        set_toggle_icon("route-transit-airplane-symbolic");
        try {
            rfkill = Bus.get_proxy_sync(BusType.SESSION,
                     "org.gnome.SettingsDaemon.Rfkill",
                     "/org/gnome/SettingsDaemon/Rfkill");
            enabled = true;
        } catch (Error e) {
            message("Unable to connect get session bus: %s", e.message);
            enabled = false;
        }
    }

    protected override void button_default_action() {
        if (!enabled) return;
        rfkill.airplanemode = true;
    }

    protected override void button_untoggled_action() {
        if (!enabled) return;
        rfkill.airplanemode = false;
    }

    public override void update_state() {
        if (!enabled) return;
        is_clicked = rfkill.airplanemode;
        string use_image = rfkill.airplanemode ? toggle_image : default_image;
        button_image.set_from_icon_name(use_image, Gtk.IconSize.LARGE_TOOLBAR);
    }
}