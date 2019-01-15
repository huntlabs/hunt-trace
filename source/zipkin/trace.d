module zipkin.trace;

import zipkin.endpoint;
import zipkin.span;
import zipkin.utils;
import zipkin.constrants;

private static Trace g_trace;

Trace getTrace()
{
    return g_trace;
}

void setTrace(Trace trace)
{
    g_trace = trace;
}

class Trace
{   
    __gshared EndPoint localEndpoint;
    __gshared bool upload;
    Span    root;
    Span[]  children;

    this(string spanName)
    {
        root = new Span();
        root.traceId = LID;
        root.id = ID;
        root.name = spanName;
        root.kind = KindOfServer;
        root.localEndpoint = localEndpoint;
    }

    Span addSpan( string spanName)
    {
        auto span = new Span();
        span.traceId = root.traceId;
        span.id = ID;
        span.kind = KindOfClient;
        span.localEndpoint = localEndpoint;
        children ~= span;
        return span;
    }
}