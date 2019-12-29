public class Result {

    private int status;
    private string? data;

    public Result(int status, string? data) {
        this.status = status;
        this.data = data;
    }

    public bool is_success() {
        return status == 0;
    }

    public string? get_result() {
        return data;
    }

}
