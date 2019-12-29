namespace BudgieHeadsetControl {

namespace Commands {

    private const string HC_PATH = "/usr/local/bin/headsetcontrol";

    private Result run_command(string args) {

        string command = "%s %s".printf(HC_PATH, args);

        string hc_out;
        string hc_err;
        int hc_status;

        try {

            Process.spawn_command_line_sync(command, out hc_out, out hc_err, out hc_status);

            if (hc_status == 0) {
                return new Result(hc_status, hc_out);
            } else {
                return new Result(hc_status, hc_err);
            }

        } catch (SpawnError e) {

            return new Result(-1, "Process spawn error");

        }

    }

    public Result check_battery() {

        return run_command("-b");

    }

    public Result enable_lightning(bool state) {

        return run_command("-l %s".printf(state == true ? "1" : "0"));

    }

    public Result set_sidetone(int level) {

        return run_command("-s %d".printf(level));

    }

    public Result play_notification(int n) {

        return run_command("-n %d".printf(n));

    }


}

} // eon
