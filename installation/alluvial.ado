*! alluvial v1.5 (27 Apr 2025):
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.5	(27 Apr 2025): reworked the baseline routines. better handling of missings.
* v1.42	(06 Mar 2025): fixed the program dropping missing values. fixed label wrapping for missing.
* v1.41	(11 Nov 2024): value(numvar) for a flow var. fixed string checks. if condition fixed.
* v1.4	(26 Sep 2024): valformat is now format(). wrap options added, labprop options added, novall, novalr options added.
* v1.3	(10 Feb 2024): Better control over category variables.
* v1.21 (19 Oct 2023): Fixed the showmiss bug (reported by Matthias Schonlau)
* v1.2  (04 Apr 2023): Minor fixes. If/in added back in.
* v1.1  (15 Jan 2023): fix label pass through. Weights added. offset added. valcond is just numeric. missing now has a color.
* v1.0  (10 Dec 2022): Beta release.        

cap program drop alluvial


program alluvial, sortpreserve

version 15
 
	syntax varlist [if] [in] [aw fw pw iw/],  ///
		[ value(varlist max=1 numeric) palette(string) colorby(string) smooth(numlist >=1 <=8 max=1) gap(real 2) RECENter(string) SHAREs showmiss alpha(real 75) ]  ///
		[ LABAngle(string) LABSize(string) LABPOSition(string) LABGap(string) SHOWTOTal  ] ///
		[ VALSize(string) format(string) VALGap(string) NOVALues  ]  ///
		[ LWidth(string) LColor(string)  ]  ///
		[ VALCONDition(real 0) offset(real 0) ]  ///  // v1.1
		[ BOXWidth(string) ] /// // v1.2 
		[ CATGap(real 4) CATSize(string) CATAngle(string) CATColor(string) CATPOSition(string) LABColor(string)  *  ]  ///   // v1.3 options
		[ WRAPLABel(numlist >0 max=1) wrapcat(numlist >0 max=1) valprop labprop valscale(real 0.33333) labscale(real 0.33333) n(real 30) NOVALLeft NOVALRight percent percent2 ]    // v1.4 updates
		

	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	cap findfile labsplit.ado
		if _rc != 0 quietly ssc install graphfunctions, replace		
	
	marksample touse, strok novarlist
	
quietly {
preserve 	

	keep if `touse'   // do not enable. drops missing values.
	keep `varlist' `exp' `value'

	
	foreach x of local varlist {
	
		cap confirm numeric var `x' // check if numeric
	
		if _rc!=0 {  // if string, convert to numeric.
			encode `x', gen(`x'2)
			drop `x'
			ren `x'2 `x'
		}

		levelsof `x'

		if `r(r)' > 20 {
			di as error "Variable {it:`x'} has more than 20 categories. Either reduce the categories or drop the variable."
			exit
		}		
	}

	
	if "`novalleft'" != "" & "`novalright'" != "" {
		display as error "Both {it:novalleft} and {it:novalright} are not allowed. If you want to hide all values use the {it:novalues} option instead."
		exit 198
	}	
	
	if "`showmiss'" != "" & "`percent2'" != "" {
		display as error "Both {it:showmiss} & {it:percent2} are not allowed."
		exit 198
	}
	

	// store labels for later passthru
	foreach x of local varlist {
		if "`: var label `x''" != "" {
			local mylab`x' : var label `x'
		}
		else {
			local mylab`x' `x'
		}
	}
	
	
	gen temp = 1
	local varcount : word count `varlist'
	local items2 = `varcount' - 1

	
	tokenize `varlist'

	local obs = _N
	
	
	forval i = 1/`items2' {	
		
		local j = `i' + 1
		gen f`i' = ``i''	
		gen t`i' = ``j''	
			
		gen catf`i' = "``i''"
		gen catt`i' = "``j''"
		
	
		if "`: value label ``i'''" != "" {
			decode ``i'', gen(labf`i')
		}
		else {
			gen labf`i' = string(``i'')
		}
		
		if "`: value label ``j'''" != "" {
			decode ``j'', gen(labt`i')
		}
		else {
			gen labt`i' = string(``j'')
		}
			
	}
	
	drop `varlist'
	
	
	drop temp
	gen id = _n
	order id

	reshape long f t labf labt catf catt, i(id) j(layer)
	
	
	drop id
	
	sort layer f
	
	if "`value'" == "" {
		gen _value = 1
		local value _value
	}
	
	
	replace f = 99999 if missing(f)
	replace t = 99999 if missing(t)	
	

	if "`weight'" != "" local myweight  [`weight' = `exp']
	


	collapse (sum) `value' `myweight', by(f t layer labt labf catf catt)
	sort layer f t

	
	gen double _raw = `value'

	replace labf = "_missing" if f == 99999
	replace labt = "_missing" if t == 99999

	gen _mtag = 1 if f == 99999 | t == 99999


	if "`shares'" != ""  {
		bysort layer: egen double _mysum = sum(`value')
		summ _mysum, meanonly
		replace `value' =  (`value' / `r(max)') 
	}
	
	if "`percent'" != "" {
		bysort layer: egen double _mysum = sum(`value')
		summ _mysum, meanonly
		replace `value' =  (`value' / `r(max)') * 100
	}
	
	
	if "`percent2'" != "" {
		bysort layer: egen double _mysum  = sum(`value') 
		bysort layer: egen double _mysum2 = sum(`value') if missing(_mtag) // for labels only
		
		gen double _pct2 = (`value' / _mysum2) * 100
		replace    `value' = (`value' / _mysum) * 100

	}
	


	if "`format'" == "" {
		if "`shares'"!="" | "`percent'"!="" | "`percent2'"!="" {
			local format "%4.2f"	
		}
		else {
			local format "%12.0fc"	
		}
	}		
	


	**** SANKEY ROUTINE BELOW

	ren layer x1
	summ x1, meanonly
	replace x1 = x1 - r(min) // rebase to 0

	gen x2 = x1 + 1
	
	ren `value' val1
	gen val2 = val1
	
	
	if "`percent2'" != "" {
		gen double _pct1 = _pct2
		
		local pctlist _pct
	
	}

	
	ren catf cat1
	ren catt cat2
	
	ren labf lab1
	ren labt lab2


	sort x1 f t  // this affects the draw order

	gen id = _n
	order id

	egen grp1 = group(x1 f)  // draw order
	egen grp2 = group(x1 t)

	sort x1 grp1 grp2
	by x1:	gen  double y1	= sum(val1) 
	
	sort x2 grp2 grp1
	by x2: 	gen  double y2	= sum(val2) 

	sort x1 f t

	gen layer = x1 + 1
	
	ren f flo1
	ren t flo2
		
	reshape long x flo val `pctlist' grp y cat lab, i(id layer) j(marker)
	*drop tt


	ren lab var
	
	// variable type check
	
	if substr("`: type var'",1,3) != "str" {
		if "`: value label var '" != "" { 	// has value label
			decode var, gen(name)
		}
		else {								// has no value label
			gen name = string(var)
		}
	}
	else {
		cap ren var name
		encode name, gen(var) // alphabetical organization
	}	
	


	
	**** from sankey	
	
	gen layer2 = layer
	replace layer2 = layer2 + 1 if marker==2	
	
	
	sort layer2 var marker


	if "`percent2'" != "" {
		bysort layer2 var: egen double val_out_temp2 = sum(_pct) if marker==1 & missing(_mtag) // how much value is sent out
		bysort layer2 var: egen double val_in_temp2  = sum(_pct) if marker==2 & missing(_mtag) // how many value comes in
		
		bysort layer2 var: egen double val_out2 = max(val_out_temp2)  if missing(_mtag)
		bysort layer2 var: egen double val_in2  = max(val_in_temp2)   if missing(_mtag)
	
		drop *temp2
		recode val_in2 val_out2 (.=0)
	

		egen double height2 = rowmax(val_in2 val_out2) if missing(_mtag)
	}


	
	
	bysort layer2 var: egen double val_out_temp = sum(val) if marker==1 // how much value is sent out
	bysort layer2 var: egen double val_in_temp  = sum(val) if marker==2 // how many value comes in
	
	bysort layer2 var: egen double val_out = max(val_out_temp)
	bysort layer2 var: egen double val_in  = max(val_in_temp)
	
	drop *temp
	recode val_in val_out (.=0)
	
	egen double height = rowmax(val_in val_out) // this is the maximum height for each category for each group.

	drop val_in* val_out*
	


	// layer order
	*labmask flo, val(name)
	drop var 
	ren flo var	
		
	gsort layer2  var id
		
	egen tag2 = tag(layer2 var)
	by layer2 : gen order = sum(tag2) // take it as it is
	cap drop tag2
			
	
	// bar order
	egen temp = tag(layer2 var)
	gen bar_order = sum(temp)
	drop temp

	
	if "`percent2'" != "" {
		egen _pct2tag = tag(x name)
		bysort x: egen _pct2total = sum(height) if _pct2tag==1 & missing(_mtag)
		
		gen double height3 = (height / _pct2total) * 100
		
	}
	
	
	
	
	
	*****************************
	**** generate the boxes   ***
	*****************************

	egen tag = tag(layer2 height order)
	sort layer2 tag order

	
	
	if "`percent2'" == "" {
		by layer2: gen double heightsum = sum(height) if tag==1 
	}
	else {
		by layer2: gen double heightsum = sum(height2) if tag==1 & missing(_mtag) 
	}

	

	
	// gen spike coordinates
	bysort layer2: gen double y1 = heightsum[_n-1] if tag==1  // 
	recode y1 (.=0)  if tag==1
	gen double y2 = heightsum

	
	if "`percent2'" != "" {
		bysort layer2: egen double _max = max(y2) if tag==1 
		replace y1 = (y1 / _max) * 100
		replace y2 = (y2 / _max) * 100
		
		drop _max
	}
	
	*** control missing

	if "`showmiss'" == "" | "`percent2'" != ""  {
		replace y1 = . if _mtag==1
		replace y2 = . if _mtag==1
	}
	
	
	*** add gap

	tempvar mygap
	summ heightsum if tag==1, meanonly
	local maxval = r(max) * `gap' / 100  
	gen `mygap' = (order - 1) * `maxval' if tag==1 

	replace y1 = y1 + `mygap'
	replace y2 = y2 + `mygap'

	cap drop heightsum

	

			
	*************************
	** generate the links  **
	*************************

	gen markme = .
	
	sort layer2 var markme marker  

	// marker = 1 = outgoing
	// marker = 2 = incoming

	//////////////////////
	///  second sort   ///
	//////////////////////

	
	if "`stype2'"=="" | "`stype2'"=="order" {
		if "`srev2'" == "reverse" {
			local ssort2 -id // by order	
		}
		else {
			local ssort2 id // by order	
		}
		 
	}
	if "`stype2'"=="value" {
		if "`srev2'" == "reverse" {
			local ssort2 -val // by value	
		}
		else {
			local ssort2 val // by value	
		}
	}
	

	if "`showmiss'" == "" drop if _mtag == 1
	
	
	gsort layer2 marker var markme `ssort2'   // this determines the second sort

	by layer2 marker var: gen double stack_end   = sum(val) 		  if markme!=1
	by layer2 marker var: gen double stack_start = stack_end[_n - 1]  if markme!=1
	recode stack_start (.=0) if markme!=1	

	
	
	levelsof layer2, local(lvls)

	foreach x of local lvls {

		// outgoing levels
		levelsof var if layer2==`x' & marker==1, local(vars)
		
		foreach y of local vars {
			summ y1 if layer2==`x' & var==`y', meanonly
			local ymin = r(min)
			summ y2 if layer2==`x' & var==`y', meanonly
			local ymax = r(max)
			
			summ stack_end if layer2==`x' & var==`y' & marker==1, meanonly
			local smax = r(max)
			
			local displace = ((`ymax' - `ymin') - `smax' ) / 2
		
			replace stack_start = stack_start + `ymin' + `displace' if layer2==`x' & marker==1 & var==`y'
			replace stack_end   = stack_end   + `ymin' + `displace' if layer2==`x' & marker==1 & var==`y'
			
		}
		
		// incoming levels
		levelsof var if layer2==`x' & marker==2, local(vars)
		
		foreach y of local vars {
			summ y1 if layer2==`x' & var==`y', meanonly
			local ymin = r(min)
			summ y2 if layer2==`x' & var==`y', meanonly
			local ymax = r(max)
			
			summ stack_end if layer2==`x' & var==`y' & marker==2 , meanonly
			local smax = r(max)
			
			local displace = ((`ymax' - `ymin') - `smax' ) / 2
			
			replace stack_start = stack_start + `ymin' + `displace' if layer2==`x' & marker==2 & var==`y'
			replace stack_end   = stack_end   + `ymin' + `displace' if layer2==`x' & marker==2 & var==`y'
			
		}	
	}
	
	
	gen stack_x = layer2
	sort layer2 markme id
	
	
	// mark the highest value and the layer

	summ y2, meanonly
	local hival = r(max)
	
	// recenter
	
	*** recenter to middle

	levelsof layer2, local(lvls)		
			
	foreach x of local lvls {
		
		qui summ y1 if layer2==`x', meanonly
		local ymin = r(min)
		qui summ y2 if layer2==`x', meanonly
		local ymax = r(max)
		
		if "`recenter'" == "bottom" | "`recenter'" == "bot"  | "`recenter'" == "b" { 		
			local displace = cond(`ymin' < 0, `ymin' * -1, 0)
		}
			
		if "`recenter'" == "" | "`recenter'" == "middle" | "`recenter'" == "mid"  | "`recenter'" == "m" { 
			local displace = (`hival' - `ymax') / 2
		}
			
		if "`recenter'" == "top" | "`recenter'" == "t"  {
			local displace = `hival' - `ymax'
		}		
		
		replace y1 = y1 + `displace' if layer2==`x'
		replace y2 = y2 + `displace' if layer2==`x'
		
		replace stack_end   = stack_end   + `displace' if layer2==`x'
		replace stack_start = stack_start + `displace' if layer2==`x'		
	}
	
	
	*** generate the curves	
	

	local newobs = `n'	
	expand `newobs'
	sort id layer2
	
	tempvar xtemp ytemp

	bysort id: gen double `xtemp' =  (_n / (`newobs' * 2))

	
	if "`smooth'" == "" local smooth = 4
	
	gen double `ytemp' =  (1 / (1 + (`xtemp' / (1 - `xtemp'))^-`smooth'))

	gen archi = .
	gen arclo = .

	
	levelsof layer	, local(cuts)
	levelsof id		, local(lvls)

	foreach x of local lvls {   // each id is looped over

		foreach y of local cuts {

			summ `ytemp' if id==`x' & layer==`y'
		
			
			// x-coordinates
			local ymin = cond(r(N) > 0, r(min), 0)
			local ymax = cond(r(N) > 0, r(max), 0)
			
			summ layer2 if layer==`y', meanonly
				local x0 = r(min)
				local x1 = r(max)

			
			// left y values
			summ stack_start if id==`x' & layer2==`x0' & layer==`y', meanonly
			local y1min = cond(r(N) > 0, r(min), 0)
							
			summ stack_start if id==`x' & layer2==`x1' & layer==`y', meanonly
			local y1max = cond(r(N) > 0, r(max), 0)			
			
			
			replace archi = (`y1max' - `y1min') * (`ytemp' - `ymin') / (`ymax' - `ymin') + `y1min' if id==`x' & layer==`y'
			
			
			// right y values
			summ stack_end if id==`x' & layer2==`x0' & layer==`y', meanonly
			local y2min = cond(r(N) > 0, r(min), 0)
			
			summ stack_end if id==`x' & layer2==`x1' & layer==`y', meanonly
			local y2max = cond(r(N) > 0, r(max), 0)	
			
			replace arclo = (`y2max' - `y2min') * (`ytemp' - `ymin') / (`ymax' - `ymin') + `y2min' if id==`x' & layer==`y'
			
		}
	}

	gen arcx = `xtemp' + layer


		
	***** mid points for wedges
	egen tag_spike = tag(layer2 var tag)
	gen double ymid = (y1 + y2) / 2 if tag_spike==1
	
	
	***** mid points for sankey labels
	egen tag_id = tag(id marker)
	gen double arcmid = (stack_end + stack_start) / 2 if tag_id==1
	
	egen layer_id = group(layer2) // layer id for coloring


	// wrappers

	
	
	// define all the locals before drawing
	
	if "`lcolor'"       == "" local lcolor black
	if "`labcolor'"     == "" local labcolor black
	if "`lwidth'"       == "" local lwidth 0.02	
	if "`colorvarmiss'" == "" local colorvarmiss gs12
	if "`labangle'" 	== "" local labangle 90
	if "`labsize'"  	== "" local labsize 2	
	if "`labposition'"  == "" local labposition 0	
	if "`labgap'" 		== "" local labgap 0
	if "`valsize'"  	== "" local valsize 1.5
	if "`valgap'" 	 	== "" local valgap 2
	if "`boxwidth'"    	== "" local boxwidth 3.2
	if "`colorboxmiss'" == "" local colorboxmiss gs10
	
	if "`format'" 		== "" {
		if "`percent'" != "" | "`percent2'" != "" {
			local format "%5.2f"
		}
		else {
			local format "%12.0f"
		}
	}
	
	format val `format'	
	
	
	if "`colorby'" == "layer" | "`colorby'" == "level" {
		local switch 1
	}
	if "`colorby'"  == "" local switch 0		
	if "`colorvar'" != "" local switch 2	
	
	if "`palette'" == "" {
		local palette tableau
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}	
	
	
	
	// draw bars
	
	
	encode name, gen(name2)
	
	local bars
	
	if `switch'==0 {
		levelsof name2, local(lvls)
		local items = r(r)
		
		colorpalette `palette' , n(`items') nograph `poptions'
		foreach x of local lvls {			
			local bars `bars' (rspike y2 y1 layer2 if name2==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`r(p`x')'")) 
		}	
	}
	
	if `switch'==1 {
		levelsof layer_id, local(lvls)
		local items = r(r)
		
		colorpalette `palette' , n(`items') nograph `poptions'
		foreach x of local lvls {	
			local bars `bars' (rspike y2 y1 layer2 if layer_id==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`r(p`x')'")) 
		}
	}
	
	if `switch'==2 {

		levelsof clrlvl
		local items = r(r)
		
		levelsof bar_order, local(lvls)
		foreach x of local lvls {			
			
			summ clrlvl if bar_order==`x' , meanonly
			
			if r(max) > 0 {
				local clr = r(max)
				colorpalette `palette' , n(`items') nograph `poptions'
				local myclr  `r(p`clr')'
			}
			else {
				local myclr  `colorboxmiss'
			}
			
			local bars `bars' (rspike y2 y1 layer2 if bar_order==`x' & tag==1 & tag_spike==1, lw(`boxwidth')  lc("`myclr'")) 
		}			
			
	}

	
	// draw arcs
	
	local shapes
	
	levelsof id if markme!=1, local(lvls)

	foreach x of local lvls {
		
		if `switch'==0 {
			summ name2 if id==`x' & marker==1, meanonly
		}
		if `switch'==1 {
			summ layer_id if id==`x' & marker==1, meanonly
		}
		if `switch'==2 {		 	// by layer
			sum clrlvl if id==`x' & tag_id==1, meanonly
		}		
		
		
		if r(N) > 0 {
			local clr = r(mean)
			
			if `clr' > 0 {
				colorpalette `palette' , n(`items') nograph `poptions'
				local myclr  `r(p`clr')'
			}
			else {
				local myclr  `colorvarmiss'
			}
		
		
			local shapes `shapes' (rarea archi arclo arcx if id==`x', lc(`lcolor') lw(`lwidth') fi(100) fcolor("`myclr'%`alpha'") ) 
		}
	}
	
		
	
	**** box labels
	
	if "`nolabels'" == "" {
		if "`showtotal'" != "" {
			if "`percent'" != "" { 
				gen lab2 = name + " (" + string(height, "`format'") + "%)" if tag_spike==1
			}
			else if "`percent2'" != "" { 
				gen lab2 = name + " (" + string(height3, "`format'") + "%)" if tag_spike==1
			}
			else {
				gen lab2 = name + " (" + string(height, "`format'") + ")" if tag_spike==1
			}
		}
		else {
			gen lab2 = name if tag_spike==1
		}
		

		if "`wraplabel'" != "" {
			ren lab2 lab2_temp
			labsplit lab2_temp, wrap(`wraplabel') gen(lab2)
			drop lab2_temp	
		}			
		
		replace lab2 = subinstr(lab2, "_missing", "{it:missing}", .)
		
		if "`labprop'" != "" {
			summ height if tag_spike==1, meanonly
			gen labwgt = `labsize' * (height / r(max))^`labscale' if tag_spike==1
			
			tempvar _lablyr
			egen `_lablyr' = group(id layer2) if tag_spike==1  // to prevent duplicates names
			
			levelsof `_lablyr', local(lvls)
			
			foreach x of local lvls {
				summ labwgt if `_lablyr'==`x' & tag_spike==1 & ymid!=., meanonly
				local labw = r(max)
				
				local boxlabel `boxlabel' (scatter ymid layer2 if tag_spike==1 & `_lablyr'==`x' & height > `valcondition',  msymbol(none) mlabel(lab2) mlabsize(`labw') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
			}
		}
		else {
			local boxlabel (scatter ymid layer2 if tag_spike==1  & height > `valcondition',  msymbol(none) mlabel(lab2) mlabsize(`labsize') mlabpos(`labposition') mlabgap(`labgap') mlabangle(`labangle') mlabcolor(`labcolor')) 
		}	
	}	

	
	local flowval val
	
	if "`percent'" != "" {
		gen valper = string(val, "`format'") + "%" if (marker==1 | marker==2)
		local flowval valper
	}
	

	**** arc labels
	
	if "`valprop'" != "" {
		summ val if tag==1, meanonly
		gen valwgt = `valsize' * (val / r(max))^`valscale' if tag_id==1
	}
	else {
		gen valwgt = 1 if tag_id==1
	}	
	
	if "`novalues'" == "" {
		if "`valprop'" == "" {
			
			if  "`novalleft'" == "" {
				local values `values' (scatter arcmid layer2  if val >= `valcondition' & marker==1, msymbol(none) mlabel(`flowval') mlabsize(`valsize') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}
			
			if  "`novalright'" == "" {
				local values `values' (scatter arcmid layer2  if val >= `valcondition' & marker==2, msymbol(none) mlabel(`flowval') mlabsize(`valsize') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}
		}
		else {
			
			levelsof id, local(lvls)
			
			foreach x of local lvls {
				summ valwgt if id==`x', meanonly
				local valw = r(mean)
			
				if  "`novalleft'" == "" {
					local values `values' (scatter arcmid layer2 if val >= `valcondition' & id==`x' & marker==1, msymbol(none) mlabel(val) mlabsize(`valw') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			
				if  "`novalright'" == "" {
					local values `values' (scatter arcmid layer2 if val >= `valcondition' & id==`x' & marker==2, msymbol(none) mlabel(val) mlabsize(`valw') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			}
		}		
	}
	
	
	**** level titles
	
	if "`catsize'"		== "" local catsize 2.3	
	if "`catposition'"	== "" local catposition 0
	if "`catcolor'"		== "" local catcolor black
	if "`catangle'"		== "" local catangle 0		
	
	summ stack_end, meanonly
	local _ctgap = `r(max)' * `catgap' / 100
	
		
	gen _ctlab = ""
	gen _cty   = 0 - `_ctgap' in 1/`varcount'
	gen _ctx   = . 
	
	local i = 1
	
	foreach x of local varlist {
		replace _ctlab =  "`mylab`x''" in `i'
		replace _ctx = `i'  in `i'
		
		local ++i
	}
	
	
	if "`wrapcat'" != "" {
		ren _ctlab _ctlab2
		labsplit _ctlab2, wrap(`wrapcat') gen(_ctlab)
	}		
	
	
	// offset	
	summ layer2, meanonly
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * `offset' / 100)

	**** PLOT EVERYTHING ***
	
	twoway 			///
		`shapes' 	///
		`bars' 		///
		`boxlabel' 	///
		`values'  	///
		(scatter _cty _ctx , msymbol(none) mlabel(_ctlab) mlabsize(`catsize') mlabpos(`catposition') mlabcolor(`catcolor') mlabangle(`catangle')) ///
			, 		///
				legend(off) 										 ///
					xlabel(, nogrid) ylabel(0 `yrange' , nogrid)     ///
					xscale(off range(`xrmin' `xrmax')) yscale(off)	 ///
					`options'
		
*/

restore
}	


end




*********************************
******** END OF PROGRAM *********
*********************************



