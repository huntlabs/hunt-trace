module hunt.trace.Plugin;
import hunt.trace.Span;
import hunt.trace.Tracer;
import hunt.trace.Constrants;

///
///     1 spanName为该条操作名称 
///     比如:
///         get	太宽泛
///         get_account/792	太具体
///         get_account	刚刚好，account_id=792 可作为一个合适的 Span 标签
///
///     2 如果是http 请求  https://github.com/openhunt.trace/b3-propagation
///         请求的时候传入头 in_headers["b3"] = span.traceId ~ "-" ~ span.parentId ~ "-" ~ "1" ~ "-" ~ span.id;
 
Span traceSpanBefore(string spanName)
{
    import std.conv;
    import std.string;
    auto tracer = getTracer();
    if( tracer !is null)
    {
        auto span = tracer.addSpan(spanName);
        span.start();
        return span;
    }
    return null;
}

///
///
/// 1 tags标签的key 可参考 constrants.d定义的key ,也可以自定义
/// 2 当有错误发生时,error不能为空。
///
///

void traceSpanAfter(Span span , string[string] tags , string error = "")
{
    if(span !is null)
    {  
        span.finish();

        foreach( k , v ; tags)
        {
            span.addTag(k,v);
        }

        if(error != "")
        {
            span.addTag(SPAN_ERROR , error);
        }
    }
}