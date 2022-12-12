
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
alluvial varlist
```

where `varlist` are categorival variables given at the unit of observation. If any variable has more than 10 categories, or it is continuous, the command will throw an error. This is to avoid over-crowding the figure. For suggestions on how to automate this, please open an issue!



## Examples

Load the Stata dataset

```
sysuse nlsw88.dta, clear
```

Let's test the `alluvial` command:


```
alluvial race married collgrad smsa union
```

<img src="/figures/alluvial1.png" height="600">

### Smooth

```
alluvial race married collgrad smsa union, smooth(1)
```

<img src="/figures/alluvial1_1.png" height="600">

```
alluvial race married collgrad smsa union, smooth(8)
```

<img src="/figures/alluvial1_2.png" height="600">


### colors

```
alluvial race married collgrad smsa union, colorby(layer)
```

<img src="/figures/alluvial2.png" height="600">

```
alluvial race married collgrad smsa union, palette(carto)
```

<img src="/figures/alluvial6.png" height="600">

```
alluvial race married collgrad smsa union, palette(CET I2)
```

<img src="/figures/alluvial6_1.png" height="600">


### shares

```
alluvial race married collgrad smsa union, shares
```

<img src="/figures/alluvial3.png" height="600">

### showmiss

```
alluvial race married collgrad smsa union, showmiss shares
```

<img src="/figures/alluvial4.png" height="600">

### gap


```
alluvial race married collgrad smsa union, gap(0)
```

<img src="/figures/alluvial5_1.png" height="600">

```
alluvial race married collgrad smsa union, gap(10)
```

<img src="/figures/alluvial5_2.png" height="600">

### all together

```
local vars race married collgrad smsa union

alluvial `vars',  smooth(8) alpha(60) palette(CET C7) gap(10) valcond(>100) valsize(2) showtot ///
	xsize(2) ysize(1) lc(black) lw(0.1) 
```

<img src="/figures/alluvial7.png" height="500">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-alluvial/issues) to report errors, feature enhancements, and/or other requests.


## Versions

**v1.0 (08 Dec 2022)**
- Public release.







