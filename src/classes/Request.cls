/**
 * Created by klukawski on 12/12/18.
 */

public abstract class Request{
    public final transient String url;
    public final transient String method;
    public final transient Type responseType;

    public Request(String url, String method, Type responseType){
        this.url = url;
        this.method = method;
        this.responseType = responseType;
    }

    public Response sendRequest(Map<String, String> params, String body, String getParams){
        Http http = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint(url + getParams);
        if(body != null && body != '') {
            req.setBody(body);
        }
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        for(String key: params.keySet()){
            req.setHeader(key, params.get(key));
        }

        HttpResponse resp = http.send(req);

        return (Response) JSON.deserialize(processResponse(resp.getBody()), responseType);
    }

    public virtual String processResponse(String response){
        return response;
    }
}