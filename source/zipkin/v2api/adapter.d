module zipkin.v2api.adapter;

import zipkin.span;
import zipkin.v2api.httpclient;
//// b3 header
/// https://github.com/openzipkin/b3-propagation

bool b3Get(string url  ,
 string[string] in_headers , 
 Span span  ,
 out string[string] out_headers ,
 out string result )
 {
    if(span !is null)
        in_headers["b3"] = span.traceId ~ "-" ~ span.parentId ~ "-" ~ "1" ~ "-" ~ span.id;
    return get(url , in_headers , out_headers , result);
 }

///

bool b3Get(string url  ,  out string result   , Span span = null  , string[string] in_headers = string[string].init)
{
    string[string] out_headers;
    return b3Get(url , in_headers , span , out_headers , result);
}

bool b3Post(string url , 
string text ,
out string result,
Span span = null ,
string content_type = CONTENT_ENCODE,
string[string] in_headers = string[string].init 
)
{
   string[string] out_header;
   return b3Post(url , text,content_type, in_headers  , span, result, out_header);
}



bool b3Post(string url , 
string text ,
string content_type,
string[string] in_headers , 
Span span,
out string result,
out string[string] out_headers ,
)
{
    if(span !is null)
        in_headers["b3"] = span.traceId ~ "-" ~ span.parentId ~ "-" ~ "1" ~ "-" ~ span.id;
    return post(url , text , content_type , in_headers , result , out_headers);
}





