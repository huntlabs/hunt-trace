module test.test;
import zipkin;
import core.thread;
import test.http;
import hunt.logging;

///             1
///             |
///         -----------
///          |       |
///          2       3
///          |
///     -------------
///       |       |
///       4       5


void test1()
{
    
    auto TRACEID = LID;

    auto span1 = new Span();
    span1.start();
    span1.traceId = TRACEID;
    span1.id = ID;
    span1.name = "1";
    span1.kind = KindOfClient;
    
    auto local = new EndPoint();
    local.serviceName = "blockclient";
    span1.localEndpoint = local;
    auto remote = new EndPoint();
    remote.serviceName = "blockserver";
    span1.remoteEndpoint = remote;
    span1.addTag("test1" , "value1");
    span1.addAnnotation("begin request");


    auto span2 = new Span();
    span2.traceId = TRACEID;
    span2.id = ID;
    span2.parentId = span1.id;
    span2.start();
    span2.name = "2";
    span2.kind = KindOfServer;
    local = new EndPoint();
    local.serviceName = "blockserver";
    span2.localEndpoint = local;
    Thread.sleep(dur!"msecs"(2100));
    span2.addTag("test2" , "value2");

    auto span4 = new Span();
    span4.traceId = TRACEID;
    span4.id = ID;
    span4.parentId = span2.id;
    span4.start();
    span4.name = "4";
    span4.kind = KindOfServer;
    Thread.sleep(dur!"msecs"(2100));
    span4.end();
    local = new EndPoint();
    local.serviceName = "passport";
    span4.localEndpoint = local;
    span4.addTag("test4" , "value4");

    auto span5 = new Span();
    span5.traceId = TRACEID;
    span5.parentId = span2.id;
    span5.id = ID;
    span5.start();
    span5.name = "5";
    span5.kind = KindOfServer;
    Thread.sleep(dur!"msecs"(2100));
    local = new EndPoint();
    local.serviceName = "tokenmanger";
    span5.localEndpoint = local;
    span5.addTag("test5" , "value5");
    span5.end();

    span2.end();

    auto span3 = new Span();
    span3.start();
    span3.parentId = span1.id;
    span3.id = ID;
    span3.traceId = TRACEID;
    span3.name = "3";
    span3.kind = KindOfServer;
    Thread.sleep(dur!"msecs"(2100));
    local = new EndPoint();
    local.serviceName = "for-crm";
    span3.localEndpoint = local;
    span3.end();

    span1.end();

    string[string] in_header;
    string[string] out_header;
    string result;
    logInfo(TRACEID);
    post("http://10.1.11.34:9411/api/v2/spans" , "["~span1.toString()~"]" ,"application/json" , in_header , out_header , result);
    logInfo(span1.toString);
    post("http://10.1.11.34:9411/api/v2/spans" , "["~span2.toString()~"]" ,"application/json" , in_header , out_header , result);
    post("http://10.1.11.34:9411/api/v2/spans" , "["~span3.toString()~"]" ,"application/json" , in_header , out_header , result);
    post("http://10.1.11.34:9411/api/v2/spans" , "["~span4.toString()~"]" ,"application/json" , in_header, out_header , result);
    post("http://10.1.11.34:9411/api/v2/spans" , "["~span5.toString()~"]" ,"application/json" , in_header,out_header , result);
}

