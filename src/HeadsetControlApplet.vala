public class HeadsetControlPlugin : Budgie.Plugin, Peas.ExtensionBase {

    public Budgie.Applet get_panel_widget(string uuid) {

        return new HeadsetControlApplet(uuid);

    }

}

public class HeadsetControlApplet : Budgie.Applet {

    protected Gtk.EventBox widget;

    protected Gtk.Box panel_layout;
    protected Gtk.Label panel_battery_status;

    protected Gtk.Box popover_layout;
    protected Gtk.Label device_name;
    protected Gtk.Label battery_status;
    protected Gtk.Button refresh;

    public string uuid { public set; public get; }

    Budgie.Popover? popover = null;
    private unowned Budgie.PopoverManager? manager = null;

    public HeadsetControlApplet(string uuid) {

        Object(uuid: uuid);

        widget = new Gtk.EventBox();
        panel_layout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 1);

        // Panel
        panel_battery_status = new Gtk.Label("<loading...>");
        panel_battery_status.valign = Gtk.Align.CENTER;
        widget.add(panel_layout);
        panel_layout.pack_start(panel_battery_status, false, false, 0);
        panel_layout.margin = 0;
        panel_layout.border_width = 0;

        // Popover
        Gtk.Builder builder = new Gtk.Builder();
        builder.add_from_resource("/net/olback/budgie-headset-control-applet/applet.glade");
        popover_layout = (Gtk.Box)builder.get_object("main");
        device_name = (Gtk.Label)builder.get_object("device_name");
        battery_status = (Gtk.Label)builder.get_object("battery_status");
        refresh = (Gtk.Button)builder.get_object("refresh");
        popover = new Budgie.Popover(widget);
        popover.add(popover_layout);

        widget.button_press_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            if (popover.get_visible()) {
                popover.hide();
            } else {
                this.manager.show_popover(widget);
            }
            return Gdk.EVENT_STOP;
        });

        refresh.button_press_event.connect((e) => {
            this.check_battery();
            return Gdk.EVENT_PROPAGATE;
        });

        Timeout.add_seconds_full(Priority.LOW, 10, check_battery);

        this.add(widget);
        this.show_all();

        this.check_battery();

    }

    private void show_error(string? msg, bool panel) {

        if (msg != null) {
            this.device_name.set_text(msg);
        }

        if (panel) {
            this.panel_battery_status.set_text("Err");
        } else {
            this.panel_battery_status.set_text("");
        }

        this.battery_status.set_text("Error");

    }

    private string? run_command(string args) {

        string command = "/usr/local/bin/headsetcontrol %s".printf(args);

        string hc_out;
        string hc_err;
        int hc_status;

        try {

            Process.spawn_command_line_sync(command, out hc_out, out hc_err, out hc_status);

            if (hc_status == 0) {

                return hc_out;

            } else if (hc_status % 255 == 1) {

                this.show_error("No headset found", false);

            } else {

                this.show_error("Unknown error", true);

            }

        } catch (SpawnError e) {

            this.show_error("headsetcontrol not installed", true);

        }

        return null;

    }

    protected bool check_battery() {

        string? val = this.run_command("-b");

        if (val != null) {

            string[] lines = val.split("\n");

            if (lines.length >= 3) {

                string name = lines[0].replace("Found ", "").replace("!", "");
                string battery = lines[2].replace("Battery: ", "").replace("Loading", "Charging");

                this.device_name.set_text(name);
                this.battery_status.set_text(battery);
                if (battery.length > 3) {
                    this.panel_battery_status.set_text("H+");
                } else {
                    this.panel_battery_status.set_text(battery);
                }

            }

        }

        return true;

    }

    public override void update_popovers(Budgie.PopoverManager? manager) {
        this.manager = manager;
        manager.register_popover(widget, popover);
    }

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(HeadsetControlPlugin));
}
