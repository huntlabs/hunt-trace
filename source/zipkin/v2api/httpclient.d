module zipkin.v2api.httpclient;
import std.net.curl;

import hunt.logging;

//alias get = std.net.curl.get;

enum CONTENT_PLAIN = "plain/text";
enum CONTENT_JSON = "application/json";
enum CONTENT_ENCODE = "application/x-www-form-urlencoded";


bool get(string url  ,
 string[string] in_headers , 
 out string[string] out_headers ,
 out string result )
{
    auto http = HTTP(url);
    import std.array;
    auto w = appender!string;

    foreach( k , v ; in_headers)
        http.addRequestHeader(k , v);
    http.onReceiveHeader =(in char[] key, in char[] value) { out_headers[cast(string)key] =cast(string) value; };
    http.onReceive = (ubyte[] data) { w.put(cast(string)data); return data.length; };
    CurlCode code = http.perform(ThrowOnError.no);
    bool flag = (code == 0);
    if(!flag)
    {
        logError(url , " " , http.statusLine , " code " , code);
    }
    result = w.data;
    return flag;
}

bool get(string url  , out string result  ,string[string] in_headers = string[string].init)
{
    string[string] out_headers;
    return get(url ,in_headers ,out_headers, result);
}

bool post(string url , 
string text ,
out string result,
string content_type = CONTENT_PLAIN,
string[string] in_headers = string[string].init 
)
{
   string[string] out_header;
   return post(url , text,content_type, in_headers , result, out_header);
}



bool post(string url , 
string text ,
string content_type,
string[string] in_headers , 
out string result,
out string[string] out_headers ,
)
{
    auto http = HTTP(url);
    import std.array;
    auto w = appender!string;
   
    if(content_type != "")
        http.setPostData(text , content_type);

    foreach( k , v ; in_headers)
        http.addRequestHeader(k , v);
    http.onReceiveHeader =(in char[] key, in char[] value) { out_headers[cast(string)key] = cast(string)value; };
    http.onReceive = (ubyte[] data) { w.put(cast(string)data); return data.length; };
    CurlCode code = http.perform();
    result = w.data;
    bool flag = (code == 0);
    if(!flag)
    {
        logError(url , " " , http.statusLine , " code " , code);
    }
    return flag;
}
unittest{
  
}