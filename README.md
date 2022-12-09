
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-alluvial) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-alluvial) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-alluvial) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-alluvial) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-alluvial)

# alluvial v1.0


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC ():

```
Coming soon!
```

GitHub (**v1.0**):

```
net install alluvial, from("https://raw.githubusercontent.com/asjadnaqvi/stata-alluvial/main/installation/") replace
```



The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for **v1.0** is as follows:

```
alluvial varlist [if] [in], 
                [ 
                  palette(str) colorby(layer|level) smooth(1-8) gap(num) recenter(mid|bot|top) 
                  labangle(str) labsize(str) labposition(str) labgap(str) showtotal
                  valsize(str) valcondition(str) valformat(str) valgap(str) novalues
                  lwidth(str) lcolor(str) alpha(num)
                  title(str) subtitle(str) note(str) scheme(str) name(str) xsize(num) ysize(num) 
                ]

```

See the help file `help alluvial` for details.

The most basic use is as follows:

```
alluvial value, from(var1) to(var2) by(level variable)
```

where `var1` and `var2` are the string source and destination variables respectively against which the `value` variable is plotted. The `by()` variable defines the levels.



## Examples

Get the example data from GitHub:

```
use "https://github.com/asjadnaqvi/stata-alluvial/blob/main/data/alluvial2.dta?raw=true", clear
```

Let's test the `alluvial` command:



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-alluvial/issues) to report errors, feature enhancements, and/or other requests.


## Versions

**v1.0 (08 Dec 2022)**
- Public release.







