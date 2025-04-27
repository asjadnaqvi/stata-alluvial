{smcl}
{* 27Apr2025}{...}
{hi:help alluvial}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-alluvial":alluvial v1.5 (GitHub)}}

{hline}

{title:alluvial}: A Stata package for Alluvial plots. 

{marker syntax}{title:Syntax}

{p 8 15 2}

{cmd:alluvial} {it:varlist} {ifin} {weight}, 
                {cmd:[} {cmd:value}({it:numvar}) {cmd:palette}({it:str}) {cmd:colorby}({it:layer}|{it:level}) {cmd:smooth}({it:1-8}) {cmd:gap}({it:num}) {cmdab:recen:ter}({it:mid}|{it:bot}|{it:top}) {cmdab:share:s} {cmdab:percent} {cmdab:percent2}
                  {cmdab:laba:ngle}({it:str}) {cmdab:labs:ize}({it:str}) {cmdab:labpos:ition}({it:str}) {cmdab:labc:olor}({it:str}) {cmdab:labg:ap}({it:str}) 
                  {cmdab:cata:ngle}({it:str}) {cmdab:cats:ize}({it:str}) {cmdab:catpos:ition}({it:str}) {cmdab:catc:olor}({it:str}) {cmdab:catg:ap}({it:str}) 
                  {cmdab:vals:ize}({it:str}) {cmdab:valcond:ition}({it:num}) {cmd:format}({it:str}) {cmdab:valg:ap}({it:str}) {cmdab:noval:ues} {cmdab:showtot:al} {cmdab:novall:eft} {cmdab:novalr:ight} 
                  {cmdab:lw:idth}({it:str}) {cmdab:lc:olor}({it:str}) {cmd:alpha}({it:num}) {cmd:offset}({it:num}) {cmdab:boxw:idth}({it:str})
                  {cmdab:wraplab:el}({it:num}) {cmdab:wrapcat}({it:num}) {cmd:valprop} {cmd:labprop} {cmdab:valscale}({it:num}) {cmdab:labscale}({it:num}) {cmdab:n}({it:num}) {cmdab:*} {cmd:]}

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt alluvial} varlist}The command requires a set of categorical variables. The command tabulates the combinations based on the number of rows for each category.
If a variable has more than 20 categories, the program will throw and error and exit. Weights are allowed but use them cautiously.
They still needed to be fully tested.{p_end}

{p2coldent : {opt value(numvar)}}Define a numerical variable that will be aggregated over the categories for the flows. The default is the count of rows.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(option)}}Users can color the diagram by {ul:layer} or {ul:level}. The {it:layer} option, determined by the {opt by()} variable, will give 
each layer a unique color. The {it:level} option will give each category a unique color, even if they exist across multiple layers. 
The default value is {opt colorby(level)}.{p_end}

{p2coldent : {opt shares}}Convert column values into shares. Weighted if {opt weights} are specified.{p_end}

{p2coldent : {opt percent}}Convert column values into percentages. Weighted if {opt weights} are specified.{p_end}

{p2coldent : {opt showmiss}}Add a missing values category on the graph. The shares of existing categories plus the missing category for each layer add up to one.{p_end}

{p2coldent : {opt smooth(num)}}This option allows users to smooth out the spider plots connections. It can take on values between [1,8], where 1 is for straight lines, and 8 is stepwise.
The middle range between 3-6 gives more curvy links. The default value is {opt smooth(4)}.{p_end}

{p2coldent : {opt gap(num)}}Gap between categories is defined as a percentage of the highest y-axis range across the layers. Default value is {opt gap(2)} for 2%.{p_end}

{p2coldent : {opt recen:ter(option)}}Users can recenter the graph {ul:middle} ({ul:mid} or {ul:m} also accepted), {ul:top} (or {ul:t}), or {ul:bottom} ({ul:bot} or {ul:b}).
This is mostly an aesthetic choice. Default value is {cmd:recen(mid)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency control of the area fills. The value ranges from 0-100, where 0 is no fill and 100 is fully filled.
Default value is {opt alpha(75)} for 75% transparency.{p_end}

{p2coldent : {opt boxw:idth(str)}}The width of the boxes. Default is {opt boxw(3.2)}.{p_end}

{p2coldent : {opt lw:idth(str)}}The outline width of the area fills. Default is {opt lw(none)}. This implies that they are turned off by default.{p_end}

{p2coldent : {opt lc:olor(str)}}The outline color of the area fills. Default is {opt lc(white)}.{p_end}

{p2coldent : {opt laba:ngle(str)}}The angle of the box labels. Default is {opt laba(90)} for vertical labels.{p_end}

{p2coldent : {opt labs:ize(str)}}The size of the box labels. Default is {opt labs(2)}.{p_end}

{p2coldent : {opt labpos:ition(str)}}The position of the box labels. Default is {opt labpos(0)} for centered.{p_end}

{p2coldent : {opt labc:olor(str)}}The color of the box labels. Default is {opt labc(black)}.{p_end}

{p2coldent : {opt labg:ap(str)}}The gap of the box labels. Default is {opt labg(0)}.{p_end}

{p2coldent : {opt cata:ngle(str)}}The angle of the category labels. Default is {opt cata(0)} for vertical labels.{p_end}

{p2coldent : {opt cats:ize(str)}}The size of the category labels. Default is {opt cats(2.3)}.{p_end}

{p2coldent : {opt catpos:ition(str)}}The position of the category labels. Default is {opt catpos(0)} for centered.{p_end}

{p2coldent : {opt catc:olor(str)}}The color of the category labels. Default is {opt catc(black)}.{p_end}

{p2coldent : {opt catg:ap(str)}}The gap of the category labels from the base of the alluvial as a percentage of the total height.
Default is {opt catg(4)} for 4%.{p_end}

{p2coldent : {opt wraplab:el(num)}}Wrap the box labels after {it:num} characters. Default is no wrapping.{p_end}

{p2coldent : {opt wrapcat(num)}}Wrap the category labels after {it:num} characters. Default is no wrapping.{p_end}

{p2coldent : {opt offset(num)}}The value, in percentage of x-axis width, to extend the x-axis on the right-hand side. Default is {opt offset(0)}.
This option is highly useful if labels are rotated horizontally, and for example, positioned at 3 o'clock.{p_end}

{p2coldent : {opt labg:ap(str)}}The gap of the category labels from the mid point of the wedges. Default is {opt labg(0)} for no gap.
If the label angle is change to horitzontal or the label position is changed from 0, then {opt labg()} can be used to fine-tune the placement.{p_end}

{p2coldent : {opt showtot:al}}Display the box total outflow with the box label.{p_end}

{p2coldent : {opt noval:ues}}Hide the values.{p_end}

{p2coldent : {opt novall:eft}}Hide the outgoing values shown on the left.{p_end}

{p2coldent : {opt novalr:ight}}Hide the incoming values shown on the right.{p_end}

{p2coldent : {opt vals:ize(str)}}The size of the displayed values. Default is {opt vals(1.5)}.{p_end}

{p2coldent : {opt valcond:ition(num)}}The condition for showing value labels. For example, if we only want to display categories with a greater than a value of 100, 
we can specify {opt valcond(100)}. If the {opt share} or {opt percent} are used, then please adjust the thresholds accordingly (out of 1 or 100 respectively).{p_end}

{p2coldent : {opt format(str)}}The format of the displayed values. Defaults are {opt format(%12.0f)} and {opt format(%4.2f)} for percentages.{p_end}

{p2coldent : {opt valprop}}Show flow labels proportional to their value.{p_end}

{p2coldent : {opt catprop}}Show box labels proportional to their value.{p_end}

{p2coldent : {opt valscale(num)}}Scale factor of {opt valprop}. Default value is {opt valscale(0.3333)}. Values closer to zero result in more exponential scaling, while values closer
to one are almost linear scaling. Advance option, use carefully.{p_end}

{p2coldent : {opt labscale(num)}}Scale factor of {opt labprop}. Default value is {opt labscale(0.3333)}. Values closer to zero result in more exponential scaling, while values closer
to one are almost linear scaling. Advance option, use carefully.{p_end}

{p2coldent : {opt n(num)}}Number of points for evaluating the sigmoid function for the flows. Default value is {opt n(30)}.{p_end}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-alluvial":GitHub} for examples.


{title:Package details}

Version      : {bf:alluvial} v1.5
This release : 27 Apr 2025
First release: 10 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-alluvial":GitHub}
Keywords     : Stata, graph, alluvial
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter/X    : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}
BlueSky      : {browse "https://bsky.app/profile/asjadnaqvi.bsky.social":@asjadnaqvi.bsky.social}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} by opening a new issue.


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459153.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions},
	{helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, 
	{helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further information.	



