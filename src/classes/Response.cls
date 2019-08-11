/**
 * Created by klukawski on 12/12/18.
 */

public abstract class Response{
    public Boolean success;
    public List<Reason> reasons;

    public class Reason{
        public Integer code;
        public String message;
    }
}