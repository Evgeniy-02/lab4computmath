import std.array : array;
import std.math : sqrt, PI_2, cos, sin, abs;
import std.algorithm;
import std.range : iota;
import std.stdio : writeln, writefln;

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

immutable ulong n = 2;

auto f = (double x) { return (x - sin(x)) / x ^^ 3; };

Point[n + 1] p;

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

float minX = 0.0;
float maxX = 3.141592;
float minY = 0.0;
float maxY = 0.5;
float xAxisOffset = 0.0;
float yAxisOffset = 0.0;

double eps = 1e-5;
auto a = (ulong k) => (((-1) ^^ long(k)) * 3.141592 ^^ (2 * k + 1)) / (
        factorial(2 * k + 3) * (2 * k + 1));

void main()
{
    getPoints();

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
    gg.put(title(
            "Зеленый - график функции, синий - многочлен Лагранжа"));

    // Saving on a 500x300 pixel surface
    gg.save("Plot.svg", 500, 300);

    writeln("График записан в файл Plot.svg");

    ulong k = 0;
    double a_k;
    double summ = 0;
    while (abs(a_k = a(k)) >= eps)
    {
        summ += a_k;
        writefln("k = %d, a(k) = %f, S(k) = %f", k, a_k, summ);
        k++;
    }

    writefln("Интеграл через ряды вычислен, S = %f, k = %d, a(%d) = %f",
            summ, k - 1, k, a_k);
    writefln("|a(%d)| < epsilon = %f", k, eps);
}

void drawGraphics(ref GGPlotD gg, double function(double x) nothrow @nogc @safe func, string colour)
{
    auto aes = statFunction(func, minX, maxX);
    // Show line in different colour
    auto withColour = Tuple!(string, "colour")(colour).mergeRange(aes);
    gg.put(withColour.geomLine);
}

void drawPoints(ref GGPlotD gg, ref Point[n + 1] points, string colour)
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

void getPoints()
{
    foreach (k; 0 .. n + 1)
    {
        p[k].x = PI_2 / 2 * (1 + cos((2 * k + 1) * PI_2 / 8));
        p[k].y = f(p[k].x);
    }
}

ulong factorial(ulong n)
{
    if (n == 1)
        return 1;
    else
        return n * factorial(n - 1);
}

unittest
{
    assert(factorial(1) == 1);
    assert(factorial(2) == 2);
    assert(factorial(4) == 24);
    assert(factorial(5) == 120);
}

unittest
{
    uint k = 1;
    writefln("%d", (-1) ^^ int(k));
    writeln(((-1) ^^ int(k)) * 3.141592 ^^ (2 * k + 1));
    writeln(factorial(2 * k + 3) * (2 * k + 1));
    //(((-1) ^^ k )* 3.141592 ^^ (2 * k + 1)) / (factorial(2 * k + 3) * (2 * k + 1))	
}
