// http://blackedder.github.io/ggplotd/images/axes.svg
import std.array : array;
import std.math : sqrt;
import std.algorithm;
import std.range : iota;

import ggplotd.aes : aes;
import ggplotd.axes : xaxisLabel, yaxisLabel, xaxisOffset, yaxisOffset, xaxisRange, yaxisRange;
import ggplotd.ggplotd : GGPlotD, putIn, Margins, title;
import ggplotd.stat : statFunction;
import ggplotd.geom : geomLine, geomPoint;
import ggplotd.range : mergeRange;
import ggplotd.colour : colourGradient;
import ggplotd.colourspace : XYZ;

import std.typecons : Tuple;

struct Point
{
    double x;
    double y;
}

immutable ulong n = 4;

Point[n + 1] p = [
    Point(-1.5, -14.1014), Point(-0.75, -0.931596), Point(0, 0),
    Point(0.75, 0.931596), Point(1.5, 14.1014)
];

auto l = (ulong i, double x) {
    double prod = 1;
    foreach (j; 0 .. n + 1)
    {
        if (j != i)
        {
            prod *= (x - p[j].x) / (p[i].x - p[j].x);
        }
    }
    return prod;
};

auto L = (double x) {
    double summ = 0;
    foreach (i; 0 .. n + 1)
    {
        summ += p[i].y * l(i, x);
    }
    return summ;
};

auto minX = -2.0;
auto maxX = 2.0;
auto minY = -20.0;
auto maxY = 20.0;
auto xAxisOffset = -20.0;
auto yAxisOffset = -2.0;

void main()
{
    auto f = (double x) { return 4.834848 * x ^^ 3 - 1.477474 * x; };

    auto gg = GGPlotD();
    drawGraphics(gg, L, "blue");
    drawGraphics(gg, f, "green");
    drawPoints(gg, p, "red");
    customizeAxis(gg);

    // Change Margins 
    gg.put(Margins(60, 60, 60, 60));

    // Use a different colour scheme
    gg.put(colourGradient!XYZ("white-cornflowerBlue-crimson"));

    // Set a title
    gg.put(title("And now for something completely different"));

    // Saving on a 500x300 pixel surface
    gg.save("demo/output/axes.svg", 500, 300);
}

void drawGraphics(ref GGPlotD gg, double function(double x) nothrow @nogc @safe func, string colour)
{
    auto aes = statFunction(func, minX, maxX);
    // Show line in different colour
    auto withColour = Tuple!(string, "colour")(colour).mergeRange(aes);
    gg.put(withColour.geomLine);
}

void drawPoints(ref GGPlotD gg, ref Point[n+1] points, string colour)
{
    // Show points in different colour
    auto withColour = Tuple!(string, "colour")(colour).mergeRange(points.array);
    gg.put(withColour.geomPoint);
}

void customizeAxis(ref GGPlotD gg)
{
    // Setting range and label for xaxis
    gg.put(xaxisRange(minX, maxX)).put(xaxisLabel("x"));
    // Setting range and label for yaxis
    gg.put(yaxisRange(minY, maxY)).put(yaxisLabel("y(x)"));

    // change offset
    gg.put(xaxisOffset(xAxisOffset)).put(yaxisOffset(yAxisOffset));

}
