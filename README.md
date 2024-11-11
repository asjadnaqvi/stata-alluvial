
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-alluvial) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-alluvial) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-alluvial) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-alluvial) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-alluvial)

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

![alluvial-1](https://github.com/asjadnaqvi/stata-alluvial/assets/38498046/7690794e-dc07-482d-9c19-46dc3f658a77)



# alluvial v1.41
(11 Nov 2024)

## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.4**):

```
ssc install alluvial, replace
```

GitHub (**v1.41**):

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

```stata
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
alluvial varlist [if] [in] [weight], 
                [ value(var) palette(str) colorby(layer|level) smooth(1-8) gap(num) recenter(mid|bot|top) shares percent
                  labangle(str) labsize(str) labposition(str) labcolor(str) labgap(str) 
                  catangle(str) catsize(str) catposition(str) catcolor(str) catgap(str) 
                  valsize(str) valcondition(num) format(str) valgap(str) novalues showtotal novalleft novalright 
                  lwidth(str) lcolor(str) alpha(num) offset(num) boxwidth(str)
                  wraplabel(num) wrapcat(num) valprop labprop valscale(num) labscale(num) n(num) * ]
```

See the help file `help alluvial` for details.

The most basic use is as follows:

```
alluvial varlist
```

where `varlist` are categorival variables given at the unit of observation. If any variable has more than 10 categories, or it is continuous, the command will throw an error. This is to avoid over-crowding the figure. For suggestions on how to automate this, please open an issue!



## Examples

Load a Stata dataset:

```stata
sysuse nlsw88.dta, clear
```

Let's test the `alluvial` command:


```stata
alluvial race married collgrad smsa union
```

<img src="/figures/alluvial1.png" width="100%">

### Smooth

```stata
alluvial race married collgrad smsa union, smooth(1)
```

<img src="/figures/alluvial1_1.png" width="100%">

```stata
alluvial race married collgrad smsa union, smooth(8)
```

<img src="/figures/alluvial1_2.png" width="100%">


### colors

```stata
alluvial race married collgrad smsa union, colorby(layer)
```

<img src="/figures/alluvial2.png" width="100%">

```stata
alluvial race married collgrad smsa union, palette(carto)
```

<img src="/figures/alluvial6.png" width="100%">

```stata
alluvial race married collgrad smsa union, palette(CET I2)
```

<img src="/figures/alluvial6_1.png" width="100%">


### showmiss + shares

```stata
alluvial race married collgrad smsa union, shares
```

<img src="/figures/alluvial3.png" width="100%">


```stata
alluvial race married collgrad smsa union, showmiss shares
```

<img src="/figures/alluvial4.png" width="100%">

```stata
alluvial race married collgrad smsa union, showmiss shares colorby(layer)
```

<img src="/figures/alluvial4_1.png" width="100%">

### gap


```stata
alluvial race married collgrad smsa union, gap(0)
```

<img src="/figures/alluvial5_1.png" width="100%">

```stata
alluvial race married collgrad smsa union, gap(10)
```

<img src="/figures/alluvial5_2.png" width="100%">

### all together

```stata
local vars race married collgrad smsa union

alluvial `vars',  smooth(8) alpha(60) palette(CET C7) gap(10) valcond(100) valsize(2) showtot ///
	xsize(2) ysize(1) lc(black) lw(0.1) 
```

<img src="/figures/alluvial7.png" width="100%">

### Offset and label rotation (v1.1)

```stata
local vars race married collgrad smsa union
alluvial `vars',  smooth(8) alpha(60) palette(CET C7) gap(10) valcond(100) valsize(2) showtot ///
	xsize(2) ysize(1) lc(black) lw(0.1) ///
	laba(0) labpos(3) noval offset(6)
```

<img src="/figures/alluvial8.png" width="100%">

### Box width (v1.2)

```stata
local vars race married collgrad smsa union
alluvial `vars',  smooth(8) alpha(60) palette(CET C7) gap(10) valcond(100) valsize(2) showtot ///
	xsize(2) ysize(1) lc(black) lw(0.1) ///
	laba(0) labpos(3) noval offset(6) boxwid(6)
```

<img src="/figures/alluvial9.png" width="100%">

### v1.4 features

```stata
alluvial  race married collgrad smsa union,  smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	lw(0.1) lc(black)  ///
	laba(0) gap(2) novalright showtotal  ///
	xsize(2) ysize(1) 
```

<img src="/figures/alluvial10.png" width="100%">



```stata
alluvial  race married collgrad smsa union,  smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	lw(0.1) lc(black)  ///
	laba(0) labs(1.6) boxw(10) gap(2) novalues ///
	showtotal wrapcat(20) wraplab(15) catgap(8) plotregion(margin(b+5 l+10 r+10)) ///
	xsize(2) ysize(1) 	
```

<img src="/figures/alluvial11.png" width="100%">


```stata
alluvial  race married collgrad smsa union,  smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	laba(0) labs(1.6) boxw(11) gap(2) novalues ///
	showtotal  wraplab(15) catgap(8) plotregion(margin(b+5 l+10 r+10)) ///
	xsize(2) ysize(1) labprop showmiss
```

<img src="/figures/alluvial12.png" width="100%">


```stata
alluvial race married collgrad smsa union, smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	laba(0) labs(1.6) boxw(11) gap(2) novalues ///
	showtotal wrapcat(20) wraplab(15) catgap(8) plotregion(margin(b+5 l+10 r+10)) ///
	xsize(2) ysize(1) labprop showmiss percent	
```

<img src="/figures/alluvial13.png" width="100%">

```stata
alluvial race married collgrad smsa union [w = wage], smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	laba(0) labs(1.6) boxw(11) gap(2) novalues ///
	showtotal wrapcat(20) wraplab(15) catgap(8) plotregion(margin(b+5 l+10 r+10)) ///
	xsize(2) ysize(1) showmiss labprop percent	
```

<img src="/figures/alluvial14.png" width="100%">


### v1.41 

```stata
alluvial race married collgrad smsa union, value(wage) smooth(8) alpha(60) palette(CET C6) valsize(2)  ///
	laba(0) labs(1.6) boxw(11) gap(2) novalues ///
	showtotal wrapcat(20) wraplab(15) catgap(8) plotregion(margin(b+5 l+10 r+10)) ///
	xsize(2) ysize(1) showmiss labprop percent	
```

<img src="/figures/alluvial15.png" width="100%">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-alluvial/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.41 (11 Nov 2024)**
- Added `value()` to allow users to specify a numeric variable that can be aggregated over the categories.
- Fixed a bug where string variable checks were not working properly.
- Minor improvements to the code.

**v1.4 (26 Sep 2024)**
- Added `wraplabel()` and `wrapcat()` options that allow users to wrap long labels after specific characters.
- Added `valprop` and `labprop` to scale labels proportional to their values. The scaling can be adjusted using `labscale()` and `valscale()` options.
- Added `novalleft` and `novalright` to hide left (outgoing) and right (incoming) labels respectively.
- Added `percent` which now shows percentages based on column (layer) height. Note that `shares` is still available but will scale to [0,1] range.
- Added option `n()` to control how many points are used for calculating the sigmoid curves.
- All generic `twoway graph` options can now be passed onto `alluvial` such as `plotregion()`, `graphregion()` and many others for more control.
- Improvements to how weights are used in the command.
- Major code cleanup resulting in major speed improvements.


**v1.3 (10 Feb 2024)**
- Options added to control category variables including size, color, gap, angle, position.
- Option `labcolor()` added.
- Options `graphregion()` and `plotregion()` added.
- Minor code cleanups.

**v1.21 (19 Oct 2023)**
- `showmiss` was not generating the missing values category (reported by Matthias Schonlau). This has been fixed.

**v1.2 (04 Apr 2023)**
- `if/in` added back in the command.
- `boxwidth()` added to the command.
- Minor bug fixes.

**v1.1 (15 Jan 2023)**
- Variable labels are now correctly passing to the final graph (requested by Marc Kaulisch and Ana Karen Díaz Méndez).
- Weights option added. Still in beta so more testing is required (requested by Ana Karen Díaz Méndez).
- `offset` option added to extend the x-axis (requested by Marc Kaulisch).
- `valcond` is now just a numeric. It is assumed that the condition implies `>= <valcond>`.
- The missing category, enabled using the `showmiss` option, now has its own color (requested by Marc Kaulisch).

**v1.0 (08 Dec 2022)**
- Public release.







