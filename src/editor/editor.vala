public class ActionButtonEditor : Gtk.Application {
    public ActionButtonEditor () {
        Object(application_id: "com.github.samlane-ma.action-button-editor",
                flags: ApplicationFlags.FLAGS_NONE);
    }

    private Gtk.ApplicationWindow window;

    protected override void activate () {
        if (window != null) {
            window.present();
            return;
        }   
        window = new Gtk.ApplicationWindow (this);
        window.set_default_size (400, 400);
        window.title = "Budgie Action Buttons";

        Gtk.Grid grid = new Gtk.Grid();
        Gtk.FlowBox large_box = new Gtk.FlowBox();
        Gtk.FlowBox small_box = new Gtk.FlowBox();
        large_box.set_size_request (250, -1);
        small_box.set_size_request (250, -1);

        Gtk.Label label = new Gtk.Label ("Action Button Editor");
        label.set_halign(Gtk.Align.CENTER);
        label.set_hexpand(true);
        grid.attach(label, 0, 1, 3, 1);
        grid.attach(small_box, 1, 1, 1, 1);
        grid.attach(large_box, 1, 2, 1, 1);

        window.add (grid);
        window.show_all ();
    }

    public static int main (string[] args) {
        ActionButtonEditor app = new ActionButtonEditor();
        return app.run (args);
    }
}