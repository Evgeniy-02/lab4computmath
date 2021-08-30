import std.algorithm : map;
import std.format : format;
import ggplotd.aes : aes;
import ggplotd.axes : xaxisLabel, yaxisLabel;
import ggplotd.geom : geomDensity, geomDensity2D;
import ggplotd.ggplotd : Facets, GGPlotD, putIn;
import ggplotd.colour : colourGradient;
import ggplotd.colourspace : XYZ;

void main2()
{
    // Running MCMC for a model that takes 3 parameters
    // Will return 1000 posterior samples for the 3 parameters
    // [[par1, par2, par3], ...]
    auto samples = runMCMC();

    // Facets can be used for multiple subplots
    Facets facets;

    // Cycle over the parameters
    foreach (i; 0 .. 3)
    {
        foreach (j; 0 .. 3)
        {
            auto gg = GGPlotD();

            gg = format("Parameter %s", i).xaxisLabel.putIn(gg);
            if (i != j)
            {
                // Change the colourGradient used
                gg = colourGradient!XYZ("white-cornflowerBlue-crimson").putIn(gg);
                gg = format("Parameter %s", j).yaxisLabel.putIn(gg);
                gg = samples.map!((sample) => aes!("x", "y")(sample[i],
                        sample[j])).geomDensity2D.putIn(gg);
            }
            else
            {
                gg = "Density".yaxisLabel.putIn(gg);
                gg = samples.map!((sample) => aes!("x", "y")(sample[i],
                        sample[j])).geomDensity.putIn(gg);
            }
            facets = gg.putIn(facets);
        }
    }
    facets.save("parameter_distribution.png", 670, 670);
}

// Running MCMC for a model that takes 3 parameters
// Will return 1000 posterior samples for the 3 parameters
// [[par1, par2, par3], ...]
auto runMCMC()
{
    import std.random : uniform, Random, unpredictableSeed;

    auto rnd = Random(unpredictableSeed);
    auto r = new double[][1000];

    for (int i = 0; i < 1000; i++)
    {
    	r[i] = new double[3];
        for (int j = 0; j < 3; j++)
        {
            r[i][j] = uniform(0, 1024, rnd);
        }
    }
	return r;
}
