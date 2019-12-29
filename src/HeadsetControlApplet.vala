public class HeadsetControlPlugin : Budgie.Plugin, Peas.ExtensionBase {

    public Budgie.Applet get_panel_widget(string uuid) {

        return new HeadsetControlApplet(uuid);

    }

}

public class HeadsetControlApplet : Budgie.Applet {

    public string uuid { public set; public get; }

    // Consts
    private const string BATTERY_25 = "/net/olback/budgie-headset-control-applet/battery-25";
    private const string BATTERY_50 = "/net/olback/budgie-headset-control-applet/battery-50";
    private const string BATTERY_75 = "/net/olback/budgie-headset-control-applet/battery-75";
    private const string BATTERY_100 = "/net/olback/budgie-headset-control-applet/battery-100";
    private const string BATTERY_CHARGING = "/net/olback/budgie-headset-control-applet/battery-charging";

    // Event box
    private Gtk.EventBox widget;

    // Panel content
    private Gtk.Box panel_layout;
    private Gtk.Image panel_battery_image;

    // Popover content
    private Gtk.Box popover_layout;
    private Gtk.Label device_name;
    private Gtk.Label battery_status;
    private Gtk.Button lightning_on;
    private Gtk.Button lightning_off;
    private Gtk.Scale sidetone_slider;
    private Gtk.Button sidetone_set;
    private Gtk.Button notification_0;
    private Gtk.Button notification_1;
    private Gtk.Button refresh;
    private Gtk.Label version_label;

    // Budgie Popover
    private Budgie.Popover? popover = null;
    private unowned Budgie.PopoverManager? manager = null;

    // Notification
    private BHCNotify notif;
    private bool show_notif = true;

    public HeadsetControlApplet(string uuid) {

        GLib.Object(uuid: uuid);

        this.notif = new BHCNotify();

        // Create widget
        widget = new Gtk.EventBox();

        // Panel
        panel_layout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 1);
        panel_battery_image = new Gtk.Image.from_resource(BATTERY_CHARGING);
        panel_battery_image.valign = Gtk.Align.CENTER;
        widget.add(panel_layout);
        panel_layout.pack_start(panel_battery_image, false, false, 0);
        panel_layout.margin = 0;
        panel_layout.border_width = 0;

        // Popover
        Gtk.Builder builder = new Gtk.Builder();
        builder.add_from_resource("/net/olback/budgie-headset-control-applet/glade-ui");

        popover_layout = (Gtk.Box)builder.get_object("main");
        device_name = (Gtk.Label)builder.get_object("device_name");
        battery_status = (Gtk.Label)builder.get_object("battery_status");
        lightning_on = (Gtk.Button)builder.get_object("lightning_on");
        lightning_off = (Gtk.Button)builder.get_object("lightning_off");
        sidetone_slider = (Gtk.Scale)builder.get_object("sidetone_slider");
        sidetone_set = (Gtk.Button)builder.get_object("sidetone_set");
        notification_0 = (Gtk.Button)builder.get_object("notification_0");
        notification_1 = (Gtk.Button)builder.get_object("notification_1");
        refresh = (Gtk.Button)builder.get_object("refresh");
        version_label = (Gtk.Label)builder.get_object("version");
        version_label.set_text(BHCA_VERSION);

        popover = new Budgie.Popover(widget);
        popover.add(popover_layout);

        // Connect signals
        widget.button_press_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            if (popover.get_visible()) {
                popover.hide();
            } else {
                manager.show_popover(widget);
            }
            return Gdk.EVENT_STOP;
        });

        lightning_on.button_press_event.connect((e) => {
            Commands.enable_lightning(true);
            return Gdk.EVENT_PROPAGATE;
        });

        lightning_off.button_press_event.connect((e) => {
            Commands.enable_lightning(false);
            return Gdk.EVENT_PROPAGATE;
        });

        sidetone_set.button_press_event.connect((e) => {
            int val = (int)sidetone_slider.get_value();
            Commands.set_sidetone(val);
            return Gdk.EVENT_PROPAGATE;
        });

        notification_0.button_press_event.connect((e) => {
            Commands.play_notification(0);
            return Gdk.EVENT_PROPAGATE;
        });

        notification_1.button_press_event.connect((e) => {
            Commands.play_notification(1);
            return Gdk.EVENT_PROPAGATE;
        });

        refresh.button_press_event.connect((e) => {
            check_battery();
            return Gdk.EVENT_PROPAGATE;
        });

        // ! TODO: Remove this
        Gtk.Button dev_button = (Gtk.Button)builder.get_object("dev_button");
        dev_button.set_visible(true);
        dev_button.button_press_event.connect((e) => {
            this.notif.show("foo", "bar");
            return Gdk.EVENT_PROPAGATE;
        });

        // Check battery level every 10 seconds
        Timeout.add_seconds_full(Priority.LOW, 10, this.check_battery);

        // Add
        add(widget);
        show_all();

        check_battery();

    }

    protected bool check_battery() {

        Result res = Commands.check_battery();

        if (res.is_success()) {

            panel_battery_image.set_visible(true);

            string[] lines = res.get_result().split("\n");

            if (lines.length >= 3) {

                string name = lines[0].replace("Found ", "").replace("!", "");
                string battery = lines[2].replace("Battery: ", "").replace("Loading", "Charging");

                device_name.set_text(name);
                battery_status.set_text(battery);

                panel_layout.set_tooltip_text("%s: %s".printf(name, battery));

                if (battery == "Charging") {

                    panel_battery_image.set_from_resource(BATTERY_CHARGING);

                } else {

                    int level = int.parse(battery);

                    if (level > 75) { // over 75%

                        panel_battery_image.set_from_resource(BATTERY_100);
                        show_notif = true;

                    } else if (level > 50) { // over 50%

                        panel_battery_image.set_from_resource(BATTERY_75);
                        show_notif = true;

                    } else if (level > 25) { // over 25%

                        panel_battery_image.set_from_resource(BATTERY_50);
                        show_notif = true;

                    } else { // 0-25%

                        panel_battery_image.set_from_resource(BATTERY_25);

                        // Show a notification when battery dips below 25%
                        // But only show it once
                        if (show_notif) {

                            // TODO:FIXME:
                            //  this.notif.show("Headset Control", "Battery in your %s is getting low! (%s)".printf(name, battery));
                            show_notif = false;

                        }

                    }

                }

            } // else, unknown error?

        } else {

            panel_battery_image.set_visible(false);

        }

        return true;

    }

    public override void update_popovers(Budgie.PopoverManager? manager) {
        this.manager = manager;
        this.manager.register_popover(widget, popover);
    }

}

[ModuleInit]
public void peas_register_types(TypeModule module)
{
    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(HeadsetControlPlugin));
}
