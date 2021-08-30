import std.stdio : writeln, writefln;
import std.range : iota;
import std.math : PI_2;

auto range = iota!(double, real, double)(0, PI_2, 0.001);

void main2()
{
    writefln("%(%f, %)", range);
}
