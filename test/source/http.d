module test.http;
import std.net.curl;

import hunt.logging;

alias get = std.net.curl.get;


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
string[string] in_headers = string[string].init ,
string content_type = "plain/text"
)
{
   string[string] out_header;
   return post(url , text,content_type, in_headers , out_header , result);
}



bool post(string url , 
string text ,
string content_type,
string[string] in_headers , 
out string[string] out_headers ,
out string result)
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
  /*  string text = `{"appid":"8100","token":"c8b32a850f2615f3a7c99b3f066fb153","type":1,"uid":"60000332"}`;
    string[string] out_header;
    string result;
    post("http://member-test.ptdev.cn/child/children" , text ,"application/json" , out_header , result);
    import kiss.logger;
    logInfo(result);*/
}