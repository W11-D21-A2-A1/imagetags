#!/usr/bin/tclsh
package require Tk
#TODO scrollbar
#TODO bindings
#TODO GUI data entry
#TODO thumbnails
#TODO closing a window shouldn't delete it

array set img {}
array set tag {}

proc init {} {
	tk::appname {Strokes}
	wm geometry . 320x200
	panedwindow .p -orient vertical -sashrelief raised
	labelframe .p.stk -text strokes
	labelframe .p.gly -text glyphs
	.p add .p.stk -minsize 100
	.p add .p.gly -minsize 100
	pack .p -fill both -expand yes

}

proc refresh {tags} {
	upvar tag tag
	grid forget {*}[winfo children .p.stk]
	grid forget {*}[winfo children .p.gly]
	#TODO calculate num_cols
	set num_cols 5
	set col_idx 0
	set row_idx 0
	foreach stroke [winfo children .p.stk] {
		grid configure $stroke -column $col_idx -row $row_idx
		set col_idx [expr ($col_idx + 1) % $num_cols]
		if {$col_idx == 0} {incr row_idx}
	}
	set col_idx 0
	set row_idx 0
	foreach glyph [winfo children .p.gly] {
		if [is_subset .$tag($glyph) $tags] {
					grid configure $glyph -column $col_idx -row $row_idx
					set col_idx [expr ($col_idx + 1) % $num_cols]
					if {$col_idx == 0} {incr row_idx}
		}
	}
}

proc is_subset {sup sub} {
	foreach elm $sub {
		if {[lsearch -exact $sup $elm] == -1} {
			return 0
		}
	}
	return 1
}

proc add_stroke {path name} {
	upvar img img
	set img(.p.stk.$name) [image create photo -file $path]
	button .p.stk.$name -height 40 -width 40 -image $img(.p.stk.$name) \
	-command "click_stroke $name"
}

proc click_stroke {name} {
	upvar tag tag
	if {[string compare [.p.stk.$name cget -relief] raised] == 0} {
		.p.stk.$name configure -relief sunken
	} elseif {[string compare [.p.stk.$name cget -relief] sunken] == 0} {
		.p.stk.$name configure -relief raised
	}
	
	set pressed {}
	foreach stk [winfo children .p.stk] {
		if {[string compare [$stk cget -relief] sunken] == 0} {
			lappend pressed $stk
		}
	}
	refresh "$pressed"
}

proc add_glyph {path name tags desc} {
	upvar img img
	upvar tag tag
	set img(.p.gly.$name) [image create photo -file $path]
	set tag(.p.gly.$name) [list {}]
	#the first element of the tag list is a dummy that gets mangeled
	foreach stk $tags {
		lappend tag(.p.gly.$name) .p.stk.$stk
	}
	button .p.gly.$name -height 40 -width 40 -image $img(.p.gly.$name) \
	-command "click_gly $name $img(.p.gly.$name)"
	frame .p.gly.$name.f
	label .p.gly.$name.f.ico -image $img(.p.gly.$name)
	label .p.gly.$name.f.txt -text $desc
	pack .p.gly.$name.f.ico .p.gly.$name.f.txt
}

proc click_gly {name ico} {
	wm manage .p.gly.$name.f
	wm iconphoto .p.gly.$name.f $ico
	wm title .p.gly.$name.f $name
}

init
add_stroke {test/red.png} red
add_stroke {test/blue.png} blue
add_stroke {test/yellow.png} yellow
add_glyph {test/green.png} green {blue yellow} {The color of grass and leaves.}
add_glyph {test/orange.png} orange {red yellow} {The color of sunrise and sunset.}
add_glyph {test/purple.png} purple {red blue} {A color near violet.}
add_glyph {test/black.png} black {red blue yellow} {The color of ink.}
refresh ""
