*! alluvial v1.4 (26 Sep 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

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
		[ palette(string) colorby(string) smooth(numlist >=1 <=8 max=1) gap(real 2) RECENter(string) SHAREs showmiss alpha(real 75) ]  ///
		[ LABAngle(string) LABSize(string) LABPOSition(string) LABGap(string) SHOWTOTal  ] ///
		[ VALSize(string) format(string) VALGap(string) NOVALues  ]  ///
		[ LWidth(string) LColor(string)  ]  ///
		[ VALCONDition(real 0) offset(real 0) ]  ///  // v1.1
		[ BOXWidth(string) ] /// // v1.2 
		[ CATGap(string) CATSize(string) CATAngle(string) CATColor(string) CATPOSition(string) LABColor(string)  *  ]  ///   // v1.3 options
		[ WRAPLABel(numlist >=0 max=1) wrapcat(numlist >=0 max=1) valprop labprop valscale(real 0.33333) labscale(real 0.33333) n(real 30) NOVALLeft NOVALRight percent ]    // v1.4 updates
		

	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	
	marksample touse, strok

quietly {
preserve 	

	*keep if `touse'   // this is dropping missing values. DO NOT ENABLE
	keep `varlist' `exp'

	foreach x of local varlist {
		
		cap confirm numeric var `x'  // convert from numeric to string.
		if _rc!=0 {
			decode `x', gen(`x'2)
			drop `x'
			ren `x'2 `x'
		}
		else { 	
			qui levelsof `x'

			if `r(r)' > 20 {
				di as error "`x' has more than 20 categories. The variable might be continuous."
				di as error "Please simplify or drop the variable."
				exit
			}
		}
	}
	
	
	if "`novalleft'" != "" & "`novalright'" != "" {
		display as error "Both {it:novalleft} and {it:novalright} are not allowed. If you want to hide values use the {it:novalues} option instead."
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
	local items : word count `varlist'
	local items2 = `items' - 1

	
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
	gen value = 1
	
	if "`showmiss'" != "" {
		replace labf = "_missing" if missing(f)
		replace labt = "_missing" if missing(t)
		
		replace f = 99999 if missing(f)
		replace t = 99999 if missing(t)
		
	}
	else {
		drop if missing(f)
		drop if missing(t)
	}	
	
	if "`weight'" != "" local myweight  [`weight' = `exp']
	
	
	
	collapse (sum) value `myweight', by(f t layer labt labf catf catt)
	sort layer f t
	
	

	if "`shares'" != ""  {
			bysort layer: egen _mysum = sum(value)
			summ _mysum, meanonly
			replace value =  (value / `r(max)') 
	}
	
	if "`percent'" != "" {
		bysort layer: egen _mysum = sum(value)
		summ _mysum, meanonly
		replace value =  (value / `r(max)') * 100
	}

	if "`format'" == "" {
		if "`shares'"!="" | "`percent'"!="" {
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
	
	ren value val1
	gen val2 = val1
	
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
	by x1: gen y1 = sum(val1) 

	sort x2 grp2 grp1
	by x2: gen y2 = sum(val2) 

	sort x1 f t

	gen layer = x1 + 1
	
	ren f flo1
	ren t flo2
	
			
	reshape long x flo val grp y cat lab, i(id layer) j(tt)
	drop tt

	ren lab _lab
	
	order grp id _lab x		
	sort id x _lab
		
	
	sort layer x y

	by layer x: gen y1 = y[_n-1]
	recode y1 (.=0)
	gen y2 = y
	drop y

	order layer grp id _lab x y1 y2 val

	// mark the highest value and the layer

	levelsof x, local(lvls)

	local hival = 0 // track the value

	foreach x of local lvls {

		summ y2 if x==`x', meanonly
		if r(max) > `hival' {
			local hilayer = `x'
			local hival = r(max)
		}
	}
	
	
	*** add gaps
	
	local propgap = `hival' * `gap' / 100
	
	sort x layer flo id
	egen tag = tag(x flo)
	bysort x: replace tag = sum(tag)
	
	gen offset = (tag - 1) * `propgap' 
	replace y1 = y1 + offset
	replace y2 = y2 + offset
	
	drop tag offset
	encode _lab, gen(order)
	
	
	*** transform the groups to be at the mid points	

	sort x id y1 y2
	gen y1t = .
	gen y2t = .


	levelsof layer
	local tlayers = r(r) - 1


	forval i = 1/`tlayers' {
		
	local left  = `i'	
	local right = `i' + 1

		
	levelsof flo if layer== `left', local(lleft)  // y:   to in the  first cut 
	levelsof flo if layer==`right', local(lright) // x: from in the second cut


	foreach y of local lleft {  // left
		foreach x of local lright {      // right

		
			if `x' == `y' & (`x'!=99999 & `y'!=99999) {  // check if the groups are equal

				// in layer range	
				summ y1 if flo==`x' & layer==`left' & x==`left', meanonly 
				if r(N) > 0 {
					local y1max `r(max)'
					local y1min `r(min)'
				}
				else {
					local y1max 0
					local y1min 0				
				}	
					
				summ y2 if flo==`x' & layer==`left' & x==`left', meanonly 
				if r(N) > 0 {
					local y2max `r(max)'
					local y2min `r(min)'
				}
				else {
					local y2max 0
					local y2min 0				
				}	
					
				local l1max = max(`y1max',`y2max')
				local l1min = min(`y1min',`y2min')
				
				// out layer range		
				summ y1 if flo==`x' & layer==`right' & x==`left', meanonly 
				if r(N) > 0 {	
					local y1max `r(max)'
					local y1min `r(min)'
				}
				else {
					local y1max 0
					local y1min 0
				}

				summ y2 if flo==`x' & layer==`right' & x==`left', meanonly 
				if r(N) > 0 {	
					local y2max `r(max)'
					local y2min `r(min)'
				}
				else {
					local y2max 0
					local y2min 0
				}	
					
				local l2max = max(`y1max',`y2max')
				local l2min = min(`y1min',`y2min')				
					
				
				// calculate the displacement	
				local displace = ((`l1max' - `l1min') - (`l2max' - `l2min')) / 2
				
			
				// displace the top and bottom parts
				replace y1t = y1 + `displace' + `l1min' - `l2min' if flo==`x' & layer==`right' & x==`left' 			
				replace y2t = y2 + `displace' + `l1min' - `l2min' if flo==`x' & layer==`right' & x==`left' 
					
				}
			}
		}	
	}


	replace y1t = y1 if missing(y1t)
	replace y2t = y2 if missing(y2t)

	drop y1 y2

	ren y1t y1	
	ren y2t y2
	
	
	*** recenter

	levelsof x, local(lvls)		

	foreach x of local lvls {
		
		qui summ y1 if x==`x', meanonly
		local ymin = r(min)
		qui summ y2 if x==`x', meanonly
		local ymax = r(max)
		
		
		if "`recenter'" == "bot" {
			local displace = 0
		}
		
		
		if "`recenter'" == "" | "`recenter'" == "mid" {
			local displace = (`hival' - `ymax') / 2
		}
		
		if "`recenter'" == "top" {
			local displace = `hival' - `ymax'
		}		
				
		replace y1 = y1 + `displace' if x==`x'
		replace y2 = y2 + `displace' if x==`x'
		
	}
	
	cap drop sums
	bysort layer x _lab: egen sums = sum(val)
		

	*** generate the curves	
	local newobs = `n'	
	expand `newobs'
	sort id x
	cap drop xtemp
	bysort id: gen xtemp =  (_n / (`newobs' * 2))

	if "`smooth'" == "" local smooth = 4
	
	gen ytemp =  (1 / (1 + (xtemp / (1 - xtemp))^-`smooth'))

	gen y1temp = .
	gen y2temp = .


	levelsof layer	, local(cuts)
	levelsof id		, local(lvls)

	foreach x of local lvls {   // each id is looped over

		foreach y of local cuts {

			summ ytemp if id==`x' & layer==`y', meanonly
			
			if r(N) > 0 {
				local ymin = r(min)
				local ymax = r(max)
			}	
			else {
				local ymin = 0
				local ymax = 0
			}

			sum x if layer==`y', meanonly
				local x0 = r(min)
				local x1 = r(max)

			
			summ y1 if id==`x' & x==`x0' & layer==`y', meanonly
			if r(N) > 0 {
				local y1min = r(min)
			}
			else {
				local y1min = 0
			}
				
			summ y1 if id==`x' & x==`x1' & layer==`y', meanonly
			if r(N) > 0 {
				local y1max = r(max)
			}
			else {
				local y1max = 0	
			}
			
			replace y1temp = (`y1max' - `y1min') * (ytemp - `ymin') / (`ymax' - `ymin') + `y1min' if id==`x' & layer==`y'
			
			summ y2 if id==`x' & x==`x0' & layer==`y', meanonly
			if r(N) > 0 {
				local y2min = r(min)
			}
			else {
				local y2min = 0
			}	
			
			summ y2 if id==`x' & x==`x1' & layer==`y', meanonly
			if r(N) > 0 {
				local y2max = r(max)
			}
			else {
				local y2max = 0.0000001	
			}
					
			replace y2temp = (`y2max' - `y2min') * (ytemp - `ymin') / (`ymax' - `ymin') + `y2min' if id==`x' & layer==`y'
		}
	}



	replace xtemp = xtemp + layer - 1

		
	***** mid points for wedges
			 
			 
	egen tag = tag(x flo)
			 
	cap gen midy = .

	levelsof x, local(lvls)
	foreach x of local lvls {

	levelsof flo if x ==`x', local(odrs)

		foreach y of local odrs {
		
		summ y1 if x==`x' & flo==`y', meanonly
		local min = r(min)
		
		summ y2 if x==`x' & flo==`y', meanonly
		local max = r(max)
		
		replace midy = (`min' + `max') / 2 if tag==1 & x==`x' & flo==`y'
		
		}
	}


	***** mid points for labels

	egen tagp = tag(id)

	gen midpout   = .  // outgoing
	gen xout   	  = .  
	gen valout	  = ""
	
	gen midpin   = .  // incoming
	gen xin      = .
	gen valin	  = ""
	

	levelsof id, local(lvls)
	foreach x of local lvls {

	// outbound values
		summ x if id==`x', meanonly
		local xval = r(min)
		
		summ y1 if id==`x' & x==`xval', meanonly
		local min = r(min)
		
		summ y2 if id==`x'  & x==`xval', meanonly
		local max = r(max)
		
		replace midpout = (`min' + `max') / 2 if id==`x' & tagp==1
		replace xout = x if id==`x' & tagp==1	
		
		
		if "`percent'" != "" {
			replace valout = string(val, "`format'") + "%" if id==`x' & tagp==1
		}
		else {
			replace valout = string(val, "`format'") if id==`x' & tagp==1
		}
		
		*replace valout = val if id==`x' & tagp==1	
		
	// inbound values
		summ x if id==`x', meanonly
		local xval = r(max)
		
		summ y1 if id==`x' & x==`xval', meanonly
		local min = r(min)
		
		summ y2 if id==`x'  & x==`xval', meanonly
		local max = r(max)
		
		replace midpin = (`min' + `max') / 2 if id==`x' & tagp==1		
		replace xin = x + 1 if id==`x' & tagp==1	
		
		if "`percent'" != "" {
			replace valin = string(val, "`format'") + "%" if id==`x' & tagp==1
		}
		else {
			replace valin = string(val, "`format'") if id==`x' & tagp==1
		}		
		

	}

		
		
		
	*** fix boxes
						
	sort layer grp x y1 y2
	bysort x order: egen ymin = min(y1)
	bysort x order: egen ymax = max(y2)
			 
	egen wedge = group(x flo)		 
	egen tagw = tag(wedge)		
	
	replace _lab = "{it:missing}" if flo== 99999
	
	*** tag the category labels
	
	summ ymin, meanonly
		local catmin = r(min)
	summ ymax, meanonly
		local catmax = r(max)
	
	egen tagc = tag(cat)
	if "`catgap'"		== "" local catgap 3
	
	gen grpy = `catmin' - ((`catmax' - `catmin') * `catgap' / 100) if tagc==1
	
	gen grpnm = ""
	
	foreach x of local varlist {
		replace grpnm = "`mylab`x''" if cat=="`x'" & tagc==1		
	}
	
	if "`wrapcat'" != "" {
		gen _length = length(grpnm) if grpnm!=""
		summ _length, meanonly		
		local _wraprounds = floor(`r(max)' / `wrapcat')
		
		forval i = 1 / `_wraprounds' {
			local wraptag = `wrapcat' * `i'
			replace grpnm = substr(grpnm, 1, `wraptag') + "`=char(10)'" + substr(grpnm, `=`wraptag' + 1', .) if _length > `wraptag' & _length!=.
		}
		
		drop _length
		
	}		
	
	
	sort x flo 
	
	if "`boxwidth'"    == "" local boxwidth 3.2
	

	********************
	*** final plot   ***
	********************

		if "`palette'" == "" {
			local palette tableau
		}
		else {
			tokenize "`palette'", p(",")
			local palette  `1'
			local poptions `3'
		}

		
		if "`colorby'" == "layer" | "`colorby'" == "level" {
			local switch 1
		}
		else {
			local switch 0
		}
		

	sort layer x order xtemp y1temp y2temp


	// boxes

	local boxes

	levelsof wedge, local(lvls)
	local items = r(r)


	foreach x of local lvls {


		if `switch' == 1 { // by layer
			summ x if wedge==`x', meanonly
			local clr = r(mean) + 1
		}
		else {  			// by category
			summ order if wedge==`x', meanonly
			local clr = r(mean) 
		}

		colorpalette `palette' , nograph `poptions'
		local boxes `boxes' (rspike ymin ymax x if wedge==`x' & tagw==1, lcolor("`r(p`clr')'%100") lw(`boxwidth')) 
		
	}

	// arcs
	
	if "`lcolor'"  == "" local lcolor white
	if "`lwidth'"  == "" local lwidth none

	levelsof wedge
	local groups = r(r)
		
	local shapes	

		
	levelsof id, local(lvls)

	foreach x of local lvls {
		
		if `switch' == 1 { 	// by layer
			qui sum layer if id==`x'
		}
		else {  			// by category
			qui sum x if id==`x'
			qui sum order if id==`x' & x == r(min)
		}

		

		if r(N) > 0 {
			local clr = r(mean)
			colorpalette `palette' , nograph `poptions'
			local shapes `shapes' (rarea y1temp y2temp xtemp if id==`x', lc(`lcolor') lw(`lwidth') fi(100) fcolor("`r(p`clr')'%`alpha'"))  
		}
	}	
			
			
	**** PLOT EVERYTHING ***
	

	
	if "`labangle'" 	== "" local labangle 90
	if "`labsize'" 		== "" local labsize 2	
	if "`labposition'"  == "" local labposition 0	
	if "`labgap'" 		== "" local labgap 0
	if "`labcolor'" 	== "" local labcolor black
	
	if "`catsize'"		== "" local catsize 2.3	
	if "`catposition'"	== "" local catposition 0
	if "`catcolor'"		== "" local catcolor black
	if "`catangle'"		== "" local catangle 0	
	
	
	if "`valsize'"  == "" local valsize 1.5

	local labcon "if val >= `valcondition'"

	

	
	
	format val `format'
	
	
	if "`valgap'" 	 == "" local valgap 2	
	
	summ ymax, meanonly
	local yrange = r(max)
	
	if "`showtotal'" != "" {
		if "`percent'" != "" {
			replace _lab = _lab + " (" + string(sums, "`format'") + "%)"
		}
		else {
			replace _lab = _lab + " (" + string(sums, "`format'") + ")"
		}
	}	
	

	if "`wraplabel'" != "" {
		gen _length = length(_lab) if _lab!=""
		summ _length, meanonly		
		local _wraprounds = floor(`r(max)' / `wraplabel')
		
		forval i = 1 / `_wraprounds' {
			local wraptag = `wraplabel' * `i'
			replace _lab = substr(_lab, 1, `wraptag') + "`=char(10)'" + substr(_lab, `=`wraptag' + 1', .) if _length > `wraptag' & _length!=.
		}
		
		drop _length
		
	}		

	
	if "`labprop'" != "" {
	
		summ sums if tag==1, meanonly
		gen double _labwgt = `labsize' * (sums / r(max))^`labscale' if tag==1
			
		levelsof _lab, local(lvls)
			
		foreach x of local lvls {
			summ _labwgt if _lab=="`x'" & tag==1, meanonly
			local labw = r(max)
				
			local labels `labels' (scatter midy x if _lab=="`x'" & tag==1, msymbol(none) mlabel(_lab) mlabgap(`labgap') mlabsize(`labw') mlabpos(`labposition') mlabcolor(`labcolor') mlabangle(`labangle'))
			
		}
	
	}
	else {
		local labels (scatter midy x if  tag==1, msymbol(none) mlabel(_lab) mlabgap(`labgap') mlabsize(`labsize') mlabpos(`labposition') mlabcolor(`labcolor') mlabangle(`labangle'))
	}
	
	// arc values 
	
	if "`valprop'" != "" {
		summ val if tagp==1, meanonly
		gen _valwgt = `valsize' * (val / r(max))^`valscale'
	}
	
	
	if "`novalues'" == "" {
		if "`novalleft'" == "" {
			if "`valprop'" != "" {
				levelsof id if !missing(xout) & tagp==1, local(lvls)
				
				foreach x of local lvls {
					summ _valwgt if id==`x' & tagp==1, meanonly
					local valw = r(mean)	
				
					local valuesL `valuesL' (scatter midpout xout `labcon' & id==`x' & tagp==1, msymbol(none) mlabel(valout) mlabsize(`valw') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			
			}
			else {
				local valuesL `valuesL' (scatter midpout xout `labcon', msymbol(none) mlabel(valout) mlabsize(`valsize') mlabpos(3) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}	
		}
		
		if "`novalright'" == "" {
			if "`valprop'" != "" {
				levelsof id if !missing(xin) & tagp==1, local(lvls)
				
				foreach x of local lvls {
					summ _valwgt if id==`x' & tagp==1, meanonly
					local valw = r(mean)	
				
					local valuesR `valuesR' (scatter midpin xin `labcon' & id==`x' & tagp==1, msymbol(none) mlabel(valin) mlabsize(`valw') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
				}
			
			}
			else {
				local valuesR `valuesR' (scatter midpin xin `labcon', msymbol(none) mlabel(valin) mlabsize(`valsize') mlabpos(9) mlabgap(`valgap') mlabcolor(`labcolor')) 
			}
		}
	}	
	
	

	// offset
	
	summ x, meanonly
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * `offset' / 100) 
	
		
	// FINAL PLOT //
	
	
	twoway ///
		`shapes' ///
			`boxes' ///
			`labels' ///
			`valuesL' ///
			`valuesR' ///
			(scatter grpy x if tagc==1, msymbol(none) mlabel(grpnm) mlabsize(`catsize') mlabpos(`catposition') mlabcolor(`catcolor') mlabangle(`catangle')) ///
			, ///
				legend(off) ///
					xlabel(, nogrid) ylabel(0 `yrange', nogrid)     ///
					xscale(off range(`xrmin' `xrmax')) yscale(off)	 ///
					`options'
*/
restore
}	

 
end




*********************************
******** END OF PROGRAM *********
*********************************


