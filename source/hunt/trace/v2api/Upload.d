module hunt.trace.v2api.Upload;
import hunt.trace.Span;
import hunt.trace.v2api.HttpClient;
import hunt.logging;

bool upload(string host , Span[] spans...)
{
    if(spans.length == 0)
        return false;

    string str = "[";
    foreach(i , s ; spans)
    {
        str ~= s.toString();
        if(i != spans.length - 1 )
            str ~= ",";
    }
    str ~= "]";

    string result;
    bool ret = b3Post(host , str , result , CONTENT_JSON);
    if( ! ret)
        return false;

    if(result.length > 0)
    {
        logError( "post " , host , " " , str , " " , result);
        return false;
    }

    return true;
    
}