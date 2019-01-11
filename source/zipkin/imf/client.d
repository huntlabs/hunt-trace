module zipkin.imf.client;

import hunt.imf;
import zipkin.endpoint;
import zipkin.annotation;
import zipkin.span;
import zipkin.constrants;
import zipkin.proto3.zipkin;

alias PSpan = zipkin.proto3.zipkin.Span;
alias CSpan = zipkin.span.Span;

__gshared Context g_context = null;
__gshared Application g_app = null;

import hunt.logging;
import hunt.util.serialize;

void initIMF(string host, ushort port)
{
    g_app = new Application(); 
    auto client = g_app.createClient(host , port);
    client.setOpenHandler((Context context){
        g_context = context;
    });
    g_app.run();
}


void uploadFromIMF(CSpan[] spans ...)
{
    ListOfSpans pspans = new ListOfSpans();
    foreach(s ; spans)
    {
        pspans.spans ~= toPSpan(s);
    }
    if(g_context is null)
    {
        logError("disconnected imf ");
    }
    else   
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
    
    cspan.localEndpoint =  toOBJ!(zipkin.endpoint.EndPoint)(toJSON(pspan.localEndpoint));
    cspan.remoteEndpoint = toOBJ!(zipkin.endpoint.EndPoint)(toJSON(pspan.remoteEndpoint));
    cspan.annotations = toOBJ!(zipkin.annotation.Annotation[])(toJSON(pspan.annotations));
    cspan.tags = pspan.tags;

    return cspan;
}