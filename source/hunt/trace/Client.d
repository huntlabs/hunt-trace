module hunt.trace.Client;

import hunt.trace.Endpoint;
import hunt.trace.Annotation;
import hunt.trace.Span;
import hunt.trace.Constrants;
import zipkin.proto3.zipkin;
import hunt.event.timer;
import hunt.util.Timer;
import hunt.net;
import hunt.imf.clients.GatewayTcpClient;
import hunt.imf.protocol.protobuf.ProtobufProtocol;

alias PSpan = zipkin.proto3.zipkin.Span;
alias CSpan = hunt.trace.Span.Span;

__gshared GatewayTcpClient g_context = null;
__gshared Timer g_timer = null;

import hunt.logging;
import hunt.util.Serialize;
import core.time;

@property bool tracing()
{
    return g_context !is null;
}


void initIMF(string host, ushort port)
{
    ProtobufProtocol tcp = new ProtobufProtocol(host,port);
    g_context = new GatewayTcpClient(tcp);
    g_context.connect();
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
        g_context.sendMsg(0 , pspans);
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
    
    pspan.localEndpoint =  toObject!(zipkin.proto3.zipkin.Endpoint)(toJson(cspan.localEndpoint));
    pspan.remoteEndpoint = toObject!(zipkin.proto3.zipkin.Endpoint)(toJson(cspan.remoteEndpoint));
    pspan.annotations = toObject!(zipkin.proto3.zipkin.Annotation[])(toJson(cspan.annotations));
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
    
    cspan.localEndpoint =  toObject!(hunt.trace.Endpoint.EndPoint)(toJson(pspan.localEndpoint));
    cspan.remoteEndpoint = toObject!(hunt.trace.Endpoint.EndPoint)(toJson(pspan.remoteEndpoint));
    cspan.annotations = toObject!(hunt.trace.Annotation.Annotation[])(toJson(pspan.annotations));
    cspan.tags = pspan.tags;

    return cspan;
}