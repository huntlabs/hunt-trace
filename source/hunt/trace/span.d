module hunt.trace.span;

import hunt.trace.endpoint;
import hunt.trace.annotation;
import hunt.trace.utils;
import std.json;
import hunt.util.Serialize;






class Span
{
    /// 16bytes
    string traceId;
    string name;
    @IGNORE
    string parentId;
    /// 8bytes
    string id;
    string kind;
    long timestamp;
    long duration;
    @IGNORE
    bool debug_;
    @IGNORE
    bool shared_;

    EndPoint localEndpoint;
    EndPoint remoteEndpoint;
    Annotation[] annotations;
    string[string]  tags;

    void addTag(string key , string value)
    {
        tags[key] = value;
    }

    void addAnnotation(string value , long timestamp = 0)
    {
        auto anno = new Annotation();
        anno.value = value;
        if(timestamp == 0)
            timestamp = usecs;
        anno.timestamp = timestamp ;
        annotations ~= anno;
    }

    void start(long timestamp = 0)
    {
        if(timestamp != 0)
            this.timestamp = timestamp;
        else
            this.timestamp = usecs;
    }

    void finish(long timestamp = 0)
    {
        if(timestamp != 0)
            this.duration = timestamp - this.timestamp;
        else
            this.duration = usecs - this.timestamp;

    }

    override string toString()
    {
        auto json = toJSON(this);       
        json["debug"] = (debug_);
        json["shared"] = (shared_);
        if(parentId.length != 0)
            json["parentId"] = parentId;
        return json.toString;
    }
}