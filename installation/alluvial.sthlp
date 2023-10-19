{smcl}
{* 19Oct2023}{...}
{hi:help alluvial}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-alluvial":alluvial v1.21 (GitHub)}}

{hline}

{title:alluvial}: A Stata package for Alluvial plots. 

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:alluvial} {it:varlist} {ifin} {weight}, 
                {cmd:[} 
                  {cmd:palette}({it:str}) {cmd:colorby}({it:layer}|{it:level}) {cmd:smooth}({it:1-8}) {cmd:gap}({it:num}) {cmdab:recen:ter}({it:mid}|{it:bot}|{it:top}) 
                  {cmdab:laba:ngle}({it:str}) {cmdab:labs:ize}({it:str}) {cmdab:labpos:ition}({it:str}) {cmdab:labg:ap}({it:str}) {cmdab:showtot:al}
                  {cmdab:vals:ize}({it:str}) {cmdab:valcond:ition}({it:num}) {cmdab:valf:ormat}({it:str}) {cmdab:valg:ap}({it:str}) {cmdab:noval:ues}
                  {cmdab:lw:idth}({it:str}) {cmdab:lc:olor}({it:str}) {cmd:alpha}({it:num}) {cmd:offset}({it:num}) {cmdab:boxw:idth}({it:str})
                  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:xsize}({it:num}) {cmd:ysize}({it:num}) 
                {cmd:]}


{p 4 4 2}
Please note that {opt alluvial} is still in beta and not all checks and balances have been added.
Please report errors/bugs/enhancement requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} 


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt alluvial} varlist}The command requires a set of categorical variables. The command tabulates the combinations based on the number of rows for each category.
If a variable has more than 20 categories, the program will throw and error and exit. Weights are allowed but use them cautiously.
They still needed to be fully tested.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(option)}}Users can color the diagram by {ul:layer} or {ul:level}. The {it:layer} option, determined by the {cmd:by()} variable, will give 
each layer a unique color. The {it:level} option will give each category a unique color, even if they exist across multiple layers. 
The default value is {cmd:colorby(level)}.{p_end}

{p2coldent : {opt shares}}Convert the values into shares. If weights are used, these will be weighted shares.{p_end}

{p2coldent : {opt showmiss}}Add a missing values category on the graph. The shares of existing categories plus the missing category for each layer add up to one.{p_end}

{p2coldent : {opt smooth(num)}}This option allows users to smooth out the spider plots connections. It can take on values between [1,8], where 1 is for straight lines, and 8 is stepwise.
The middle range between 3-6 gives more curvy links. The default value is {cmd:smooth(4)}.{p_end}

{p2coldent : {opt gap(num)}}Gap between categories is defined as a percentage of the highest y-axis range across the layers. Default value is {cmd:gap(2)} for 2%.{p_end}

{p2coldent : {opt recen:ter(option)}}Users can recenter the graph {ul:middle} ({ul:mid} or {ul:m} also accepted), {ul:top} (or {ul:t}), or {ul:bottom} (or {ul:bot} or {ul:b}).
This is mostly an aesthetic choice. Default value is {cmd:recen(mid)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency control of the area fills. The value ranges from 0-100, where 0 is no fill and 100 is fully filled.
Default value is {cmd:alpha(75)} for 75% transparency.{p_end}

{p2coldent : {opt boxw:idth(str)}}The width of the boxes. Default is {op boxw(3.2)}.{p_end}

{p2coldent : {opt lw:idth(str)}}The outline width of the area fills. Default is {cmd:lw(none)}. This implies that they are turned off by default.{p_end}

{p2coldent : {opt lc:olor(str)}}The outline color of the area fills. Default is {cmd:lc(white)}.{p_end}

{p2coldent : {opt labs:ize(str)}}The size of the category labels. Default is {cmd:labs(2)}.{p_end}

{p2coldent : {opt laba:ngle(str)}}The angle of the category labels. Default is {cmd:laba(90)} for vertical labels.{p_end}

{p2coldent : {opt labpos:ition(str)}}The position of the category labels. Default is {cmd:labpos(0)} for centered.{p_end}

{p2coldent : {opt offset(num)}}The value, in percentage of x-axis width, to extend the x-axis on the right-hand side. Default is {cmd:offset(0)}.
This option is highly useful if labels are rotated horizontally, and for example, positioned at 3 o'clock.{p_end}

{p2coldent : {opt labg:ap(str)}}The gap of the category labels from the mid point of the wedges. Default is {cmd:labg(0)} for no gap.
If the label angle is change to horitzontal or the label position is changed from 0, then {cmd:labg()} can be used to fine-tune the placement.{p_end}

{p2coldent : {opt showtot:al}}Display the category totals.{p_end}

{p2coldent : {opt vals:ize(str)}}The size of the displayed values. Default is {cmd:vals(1.5)}.{p_end}

{p2coldent : {opt valcond:ition(num)}}The condition for showing value labels. For example, if we only want to display categories with a greater than a value of 100, 
we can specify {opt valcond(100)}. If the {opt share} is used, then please specify the share threshold (out of 100). Default is {opt valcond(0)}.{p_end}

{p2coldent : {opt valf:ormat(str)}}The format of the displayed values. Default is {cmd:valf(%12.0f)}.{p_end}

{p2coldent : {opt noval:ues}}Hide the values.{p_end}

{p2coldent : {opt title()}, {opt subtitle()}, {opt note()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme()}, {opt name()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt xsize()}, {opt ysize()}}These standard twoway options can be used to space out the layers.
This is particularly helpful if several layers are plotted.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {cmd:alluvial}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-alluvial":GitHub} for examples.


{hline}

{title:Package details}

Version      : {bf:alluvial} v1.21
This release : 19 Oct 2023
First release: 10 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-alluvial":GitHub}
Keywords     : Stata, graph, alluvial
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}