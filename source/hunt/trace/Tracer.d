module hunt.trace.Tracer;

import hunt.trace.Endpoint;
import hunt.trace.Span;
import hunt.trace.Utils;
import hunt.trace.Constrants;

import std.string;

private static Tracer g_tracer;

Tracer getTracer()
{
    return g_tracer;
}

void setTracer(Tracer tracer)
{
    g_tracer = tracer;
}

class Tracer
{   
    __gshared EndPoint localEndpoint;
    __gshared bool upload;
    Span    root;
    Span[]  children;

    this(string spanName , string b3Header = string.init)
    {
        root = new Span();
        if( b3Header != string.init )
        {
            string[] args = b3Header.split("-");
            if(args.length >= 4)
            {
                root.traceId = args[0];
                root.parentId = args[1];
                root.id = args[3];
            }
        }

        if(root.traceId == string.init)
        {
            root.traceId = LID;
            root.id = ID;
        }

        root.name = spanName;
        root.kind = KindOfServer;
        root.localEndpoint = localEndpoint;
    }

    Span addSpan( string spanName)
    {
        auto span = new Span();
        span.traceId = root.traceId;
        span.name = spanName;
        span.id = ID;
        span.parentId = root.id;
        span.kind = KindOfClient;
        span.localEndpoint = localEndpoint;
        children ~= span;
        return span;
    }
}