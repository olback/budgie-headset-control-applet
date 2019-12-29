namespace BudgieHeadsetControl {

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
    private Gtk.Image panel_battery_icon;

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

    // Budgie Popover
    private Budgie.Popover? popover = null;
    private unowned Budgie.PopoverManager? manager = null;

    // Notification
    private HeadsetControlNotify notif;

    // State
    private bool show_notif = true;
    private int? last_timeout = null;

    // Settings
    private HeadsetControlSettings settings;

    public HeadsetControlApplet(string uuid) {

        GLib.Object(uuid: uuid);

        // Notify service
        this.notif = new HeadsetControlNotify();

        // Settings
        this.settings = new HeadsetControlSettings();

        // Create widget
        this.widget = new Gtk.EventBox();

        // Builder
        Gtk.Builder builder = new Gtk.Builder.from_resource("/net/olback/budgie-headset-control-applet/glade-ui");

        // Panel
        this.panel_layout = (Gtk.Box)builder.get_object("panel_layout");
        this.panel_battery_icon = (Gtk.Image)builder.get_object("panel_battery_icon");
        this.widget.add(panel_layout);

        // Popover
        this.popover_layout = (Gtk.Box)builder.get_object("popover_layout");
        this.device_name = (Gtk.Label)builder.get_object("device_name");
        this.battery_status = (Gtk.Label)builder.get_object("battery_status");
        this.lightning_on = (Gtk.Button)builder.get_object("lightning_on");
        this.lightning_off = (Gtk.Button)builder.get_object("lightning_off");
        this.sidetone_slider = (Gtk.Scale)builder.get_object("sidetone_slider");
        this.sidetone_set = (Gtk.Button)builder.get_object("sidetone_set");
        this.notification_0 = (Gtk.Button)builder.get_object("notification_0");
        this.notification_1 = (Gtk.Button)builder.get_object("notification_1");
        this.refresh = (Gtk.Button)builder.get_object("refresh");
        ((Gtk.Label)builder.get_object("version")).set_text(BHCA_VERSION);

        this.popover = new Budgie.Popover(widget);
        this.popover.add(popover_layout);

        // Connect signals
        this.widget.button_press_event.connect((e) => {
            if (e.button != 1) {
                return Gdk.EVENT_PROPAGATE;
            }
            if (this.popover.get_visible()) {
                this.popover.hide();
            } else {
                this.manager.show_popover(this.widget);
            }
            return Gdk.EVENT_STOP;
        });

        this.lightning_on.button_press_event.connect((e) => {
            Commands.enable_lightning(true);
            return Gdk.EVENT_PROPAGATE;
        });

        this.lightning_off.button_press_event.connect((e) => {
            Commands.enable_lightning(false);
            return Gdk.EVENT_PROPAGATE;
        });

        this.sidetone_set.button_press_event.connect((e) => {
            int val = (int)sidetone_slider.get_value();
            Commands.set_sidetone(val);
            return Gdk.EVENT_PROPAGATE;
        });

        this.notification_0.button_press_event.connect((e) => {
            Commands.play_notification(0);
            return Gdk.EVENT_PROPAGATE;
        });

        this.notification_1.button_press_event.connect((e) => {
            Commands.play_notification(1);
            return Gdk.EVENT_PROPAGATE;
        });

        this.refresh.button_press_event.connect((e) => {
            this.check_battery();
            return Gdk.EVENT_PROPAGATE;
        });

        // Add
        this.add(widget);
        this.show_all();

        // Start checking...
        this.loop();

    }

    private bool loop() {

        this.check_battery();

        if (this.last_timeout == null || this.last_timeout != this.settings.interval) {
            this.last_timeout = this.settings.interval;
            Timeout.add_seconds_full(Priority.LOW, this.last_timeout, this.loop);
            return false;
        } else {
            return true;
        }

    }

    private void check_battery() {

        Result res = Commands.check_battery();

        if (res.is_success()) {

            this.panel_battery_icon.set_visible(true);

            string[] lines = res.get_result().split("\n");

            if (lines.length >= 3) {

                string name = lines[0].replace("Found ", "").replace("!", "");
                string battery = lines[2].replace("Battery: ", "").replace("Loading", "Charging");

                this.device_name.set_text(name);
                this.battery_status.set_text(battery);

                this.panel_layout.set_tooltip_text("%s: %s".printf(name, battery));

                if (battery == "Charging") {

                    this.panel_battery_icon.set_from_resource(BATTERY_CHARGING);

                } else {

                    int level = int.parse(battery);

                    if (level > 75) { // over 75%

                        this.panel_battery_icon.set_from_resource(BATTERY_100);

                    } else if (level > 50) { // over 50%

                        this.panel_battery_icon.set_from_resource(BATTERY_75);

                    } else if (level > 25) { // over 25%

                        this.panel_battery_icon.set_from_resource(BATTERY_50);

                    } else { // 0-25%

                        this.panel_battery_icon.set_from_resource(BATTERY_25);

                    }

                    // Show a notification when battery dips below this.settings.notify_below
                    // But only show it once and only if enabled.
                    if (this.settings.battery_notification && this.settings.notify_below > level) {

                        if (this.show_notif) {

                            this.notif.show(name, "Battery is getting low! (%s)".printf(battery));
                            this.show_notif = false;

                        }


                    } else {

                        this.show_notif = true;

                    }

                }

            } // else, unknown error?

        } else {

            this.panel_battery_icon.set_visible(false);

        }

    }

    public override bool supports_settings() {

        return true;

    }

    public override Gtk.Widget? get_settings_ui() {

        return this.settings.get_ui();

    }

    public override void update_popovers(Budgie.PopoverManager? manager) {

        this.manager = manager;
        this.manager.register_popover(widget, popover);

    }

}

} // eon

[ModuleInit]
public void peas_register_types(TypeModule module) {

    // boilerplate - all modules need this
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(BudgieHeadsetControl.HeadsetControlPlugin));

}
