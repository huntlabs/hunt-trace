module hunt.trace.Client;

import hunt.imf;
import hunt.trace.Endpoint;
import hunt.trace.Annotation;
import hunt.trace.Span;
import hunt.trace.Constrants;
import zipkin.proto3.zipkin;
import hunt.event.timer;
import hunt.util.Timer;
import hunt.net;

alias PSpan = zipkin.proto3.zipkin.Span;
alias CSpan = hunt.trace.Span.Span;

__gshared Context g_context = null;
__gshared Application g_app = null;
__gshared Timer g_timer = null; 

import hunt.logging;
import hunt.util.Serialize;
import core.time;


class SpanController
{
    mixin MakeRouter;

    @route(1)
    void onHeart() {}
}

@property bool tracing()
{
    return g_context !is null;
}


void initIMF(string host, ushort port)
{
    g_app = new Application(); 
    auto client = g_app.createClientExt(host , port);
    client.setOpenHandler((Context context){
        g_context = context;
        g_timer = new Timer(NetUtil.defaultEventLoopGroup.nextLoop , 25.seconds);
        g_timer.onTick((Object sender){
            if(g_context !is null)
            {
                g_context.sendMessage(1);
            }
        });
        g_timer.start();

    });
    client.setCloseHandler((Context context){
        g_context = null;
        if( g_timer !is null)
        {
            g_timer.stop();
            g_timer = null;
        }
    });
    try{
        g_app.run();
    }
    catch(Throwable e)
    {
        logError(e.msg);
    }
}


void uploadFromIMF(CSpan[] spans ...)
{
    ListOfSpans pspans = new ListOfSpans();
    foreach(s ; spans)
    {
        pspans.spans ~= toPSpan(s);
    }
    
    if(g_context !is null)   
    {
        g_context.sendMessage(0 , pspans);
    }
}

PSpan toPSpan(CSpan cspan)
{
    auto pspan = new PSpan();
    
    pspan.traceId = cast(ubyte[])cspan.traceId;
    pspan.name = cspan.name;
    pspan.parentId = cast(ubyte[])cspan.parentId;
    pspan.id = cast(ubyte[])cspan.id;
    switch(cspan.kind)
    {
        case KindOfServer:
            pspan.kind = PSpan.Kind.SERVER;
            break;
        case KindOfClient:
            pspan.kind = PSpan.Kind.CLIENT;
            break;
        case KindOfPRODUCER:
            pspan.kind = PSpan.Kind.PRODUCER;
            break;
        case KindOfCONSUMER:
            pspan.kind = PSpan.Kind.CONSUMER;
            break;
        default:
            pspan.kind = PSpan.Kind.SPAN_KIND_UNSPECIFIED;
    }

    pspan.debug_ = cspan.debug_;
    pspan.timestamp = cspan.timestamp;
    pspan.duration = cspan.duration;
    pspan.debug_ = cspan.debug_;
    pspan.shared_ = cspan.shared_;
    
    pspan.localEndpoint =  toOBJ!(zipkin.proto3.zipkin.Endpoint)(toJSON(cspan.localEndpoint));
    pspan.remoteEndpoint = toOBJ!(zipkin.proto3.zipkin.Endpoint)(toJSON(cspan.remoteEndpoint));
    pspan.annotations = toOBJ!(zipkin.proto3.zipkin.Annotation[])(toJSON(cspan.annotations));
    pspan.tags = cspan.tags;

    return pspan;
}

CSpan toCSpan(PSpan pspan)
{
    auto cspan = new CSpan();
    
    cspan.traceId = cast(string)pspan.traceId;
    cspan.name = pspan.name;
    cspan.parentId = cast(string)pspan.parentId;
    cspan.id = cast(string)pspan.id;
    switch(pspan.kind)
    {
        case PSpan.Kind.SERVER:
            cspan.kind = KindOfServer;
            break;
        case PSpan.Kind.CLIENT:
            cspan.kind = KindOfClient;
            break;
        case PSpan.Kind.PRODUCER:
            cspan.kind = KindOfPRODUCER;
            break;
        case PSpan.Kind.CONSUMER:
            cspan.kind = KindOfCONSUMER;
            break;
        default:
            cspan.kind = "SPAN_KIND_UNSPECIFIED";
    }

    cspan.debug_ = pspan.debug_;
    cspan.timestamp = pspan.timestamp;
    cspan.duration = pspan.duration;
    cspan.debug_ = pspan.debug_;
    cspan.shared_ = pspan.shared_;
    
    cspan.localEndpoint =  toOBJ!(hunt.trace.Endpoint.EndPoint)(toJSON(pspan.localEndpoint));
    cspan.remoteEndpoint = toOBJ!(hunt.trace.Endpoint.EndPoint)(toJSON(pspan.remoteEndpoint));
    cspan.annotations = toOBJ!(hunt.trace.Annotation.Annotation[])(toJSON(pspan.annotations));
    cspan.tags = pspan.tags;

    return cspan;
}