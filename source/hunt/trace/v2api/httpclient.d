module hunt.trace.v2api.HttpClient;
import std.net.curl;
import hunt.trace.Span;
import hunt.trace.Constrants;
import hunt.trace.Plugin;
import hunt.logging;



//// b3 header
/// https://github.com/openhunt.trace/b3-propagation

enum CONTENT_PLAIN = "plain/text";
enum CONTENT_JSON = "application/json";
enum CONTENT_ENCODE = "application/x-www-form-urlencoded";




bool b3Get(string url  , out string result  , string[string] in_headers = string[string].init)
{
    string[string] out_headers;
    return b3Get(url ,in_headers ,out_headers, result);
}

bool b3Get(string url  , string[string] in_headers ,  out string[string] out_headers , out string result )
{
    auto http = HTTP(url);
    import std.array;
    import std.conv;
    import std.string;
    auto w = appender!string;

    string[string] tags;
    string path = url;
    auto pos = url.indexOf('?');
    if(pos != -1)
    {
        path = url[0 .. pos];
    }

    tags[HTTP_HOST] = url;
    tags[HTTP_URL] = path;
    tags[HTTP_PATH] = path;
    tags[HTTP_REQUEST_SIZE] = "0";
    tags[HTTP_METHOD] = "GET";
    auto span = traceSpanBefore(path);
    if(span !is null)
        in_headers["b3"] = span.traceId ~ "-" ~ span.parentId ~ "-" ~ "1" ~ "-" ~ span.id;

    foreach( k , v ; in_headers)
        http.addRequestHeader(k , v);
    http.onReceiveHeader =(in char[] key, in char[] value) { out_headers[cast(string)key] =cast(string) value; };
    http.onReceive = (ubyte[] data) { w.put(cast(string)data); return data.length; };
    CurlCode code = http.perform(ThrowOnError.no);
    bool flag = (code == 0);
    string error = "";
    if(!flag)
    {
        logError(url , " " , http.statusLine , " code " , code);
        error = "curl code " ~ to!string(code);
    }
    result = w.data;

    tags[HTTP_STATUS_CODE] = to!string(http.statusLine.code);
    tags[HTTP_RESPONSE_SIZE] = to!string(result.length);

    traceSpanAfter(span , tags , error);

    return flag;
}



bool b3Post(string url , 
string text ,
out string result,
string content_type = CONTENT_PLAIN,
string[string] in_headers = string[string].init 
)
{
   string[string] out_header;
   return b3Post(url , text,content_type, in_headers , result, out_header);
}



bool b3Post(string url , 
string text ,
string content_type,
string[string] in_headers , 
out string result,
out string[string] out_headers ,
)
{
    import std.conv;
    import std.string;
    auto http = HTTP(url);
    import std.array;
    auto w = appender!string;

    string[string] tags;
    string path = url;
    auto pos = url.indexOf('?');
    if(pos != -1)
    {
        path = url[0 .. pos];
    }

    tags[HTTP_HOST] = url;
    tags[HTTP_URL] = path;
    tags[HTTP_PATH] = path;
    tags[HTTP_REQUEST_SIZE] = to!string(text.length);
    tags[HTTP_METHOD] = "POST";
    auto span = traceSpanBefore(path);
    if(span !is null)
        in_headers["b3"] = span.traceId ~ "-" ~ span.parentId ~ "-" ~ "1" ~ "-" ~ span.id;
   
    if(content_type != "")
        http.setPostData(text , content_type);

    foreach( k , v ; in_headers)
        http.addRequestHeader(k , v);
    http.onReceiveHeader =(in char[] key, in char[] value) { out_headers[cast(string)key] = cast(string)value; };
    http.onReceive = (ubyte[] data) { w.put(cast(string)data); return data.length; };
    CurlCode code = http.perform();
    result = w.data;
    string error = "";
    bool flag = (code == 0);
    if(!flag)
    {
        logError(url , " " , http.statusLine , " code " , code);
        error = "curl code:" ~ to!string(code);
    }

    tags[HTTP_STATUS_CODE] = to!string(http.statusLine.code);
    tags[HTTP_RESPONSE_SIZE] = to!string(result.length);


    traceSpanAfter(span , tags , error);

    return flag;
}
