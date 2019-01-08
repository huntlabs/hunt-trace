module zipkin.utils;

import core.stdc.time;
import std.datetime;
import std.bitmanip;
import std.digest;
import hunt.logging;

long hnsecs() @property
{
    return Clock.currStdTime - unixTimeToStdTime(0);
} 

long usecs() @property
{
    return hnsecs / 10;
}

int secs() @property
{
    return cast(int)time(null);
}

//16bytes
string LID() @property
{
    ubyte[8] bs = nativeToBigEndian(hnsecs);   
    return toHexString!(LetterCase.lower)(bs.dup);
}

string ID() @property
{
    auto id = LID();
    return id[8 .. $ - 1];
}