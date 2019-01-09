module test.test;
import zipkin;
import core.thread;
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

enum HOST = "http://10.1.11.34:9411/api/v2/spans";

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
    span4.finish();
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
    span5.finish();

    span2.finish();

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
    span3.finish();

    span1.finish();

    upload(HOST , span1,span2,span3,span4 , span5);
    logInfo(TRACEID);
}


void test2()
{
    auto TRACEID = LID;

    auto span1 = new Span();
    span1.start();
    span1.traceId = TRACEID;
    span1.id = ID;
    span1.name = "test1";
    span1.kind = KindOfClient;
    span1.start();
    auto local = new EndPoint();
    local.serviceName = "clientrequest";
    span1.localEndpoint = local;

    string[string] in_header;
    string[string] out_header;
    
    auto span2 = new Span();
    span2.traceId = TRACEID;
    span2.id = span1.id;
    span2.name = "test2";
    span2.kind = KindOfServer;

    local = new EndPoint();
    local.serviceName = "serverresponse";
    span2.localEndpoint = local;
   
    Thread.sleep(dur!"msecs"(500));
    span2.start();
    span2.addAnnotation("server recv");
    span2.addTag("server" , "ok");
    Thread.sleep(dur!"msecs"(500));
    span2.finish();

    upload(HOST , span2);
    logInfo(TRACEID);

    span1.finish();
    upload(HOST , span1);
    

}

