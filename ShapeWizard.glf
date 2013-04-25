#
# Copyright 2012 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

################################################################################
# Create a variety of 3D shapes for use as Farfields or Baffles
################################################################################

package require PWI_Glyph 2

pw::Script loadTk

set scriptDir [file dirname [info script]]

# Track the available shapes
set ShapeDict [dict create]

# Track the validity of text entry fields
set ValidDict [dict create]

set CurrentShape {}
set CurrentNS {}

###
# Load shape scripts
###

foreach shapeFile [glob -directory $scriptDir -type f "sw_*.{glf,tcl}"] {
  source $shapeFile

  set s [lindex [dict keys $ShapeDict] end]
  set ns [dict get $ShapeDict $s namespace]
  if { [string length $CurrentShape] == 0 } {
    set CurrentShape $s
    set CurrentNS $ns
  }
}

if { [llength [dict keys $ShapeDict]] == 0 } {
  tk_messageBox -icon error -title "Error..." -message \
  "No shape scripts exist in the ShapeWizard directory\n" -type ok
  exit 2
}

###
# Initialize globals
###

set args(SurfaceType)   "Baffle"
set args(GridType)      "Structured"
set args(EntityType)    "Grid"
set args(DimensionType) "Dimension"
set args(Dimension)     {20 20 20}
set args(Dimension1D)   {20}
set args(Dimension2D)   {20 20}
set args(Dimension3D)   {20 20 20}
set args(DeltaS)        0.8
set args(SpecType)      "explicit"
set args(Size)          {10 10 10}
set args(Size1D)        {10}
set args(Size2D)        {10 10}
set args(Size3D)        {10 10 10}
set args(Origin)        {0.0 0.0 0.0}

set color(Invalid) "#FFCCCC"
set color(Valid)   "#FFFFFF"

###
# Event handlers
###

proc onShapeTypeChanged { force } {
  global ShapeDict CurrentShape CurrentNS args W

  # update the global shape namespace
  set newNS [dict get $ShapeDict $CurrentShape namespace]
  if { $newNS == $CurrentNS && ! $force } {
    return
  }

  if { [${CurrentNS}::numDimensions] == 3 } {
    set args(Dimension3D) $args(Dimension)
  } elseif { [${CurrentNS}::numDimensions] == 2 } {
    set args(Dimension2D) $args(Dimension)
  } else {
    set args(Dimension1D) $args(Dimension)
  }

  if { [${CurrentNS}::numSizes] == 3 } {
    set args(Size3D) $args(Size)
  } elseif { [${CurrentNS}::numSizes] == 2 } {
    set args(Size2D) $args(Size)
  } else {
    set args(Size1D) $args(Size)
  }

  set CurrentNS $newNS

  # configure orientation/plane widgets
  $W(FrameOrient) configure -text [${CurrentNS}::orientationLabel]
  ${CurrentNS}::configureOrientationFrame $W(FrameOrient) args

  # configure baffle/farfield widgets
  if [${CurrentNS}::allowsBaffle] {
    $W(RadioBaffle) configure -state active
  } else {
    $W(RadioBaffle) configure -state disabled
    if { $args(SurfaceType) == "Baffle" } {
      set args(SurfaceType) Farfield
      onSurfaceTypeChanged
    }
  }

  if [${CurrentNS}::allowsFarfield] {
    $W(RadioFarField) configure -state active
  } else {
    $W(RadioFarField) configure -state disabled
    if { $args(SurfaceType) == "Farfield" } {
      set args(SurfaceType) Baffle
      onSurfaceTypeChanged
    }
  }

  # configure grid type widgets
  if [${CurrentNS}::allowsGrid] {
    $W(RadioGrid) configure -state active
  } else {
    $W(RadioGrid) configure -state disabled
    if { $args(EntityType) == "Grid" } {
      set args(EntityType) Database
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsDatabase] {
    $W(RadioDatabase) configure -state active
  } else {
    $W(RadioDatabase) configure -state disabled
    if { $args(EntityType) == "Database" } {
      set args(EntityType) Grid
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsBothGridDb] {
    $W(RadioBoth) configure -state active
  } else {
    $W(RadioBoth) configure -state disabled
    if { $args(EntityType) == "Both" } {
      if [${CurrentNS}::allowsGrid] {
        set args(EntityType) Grid
      } else {
        set args(EntityType) Database
      }
      onEntityTypeChanged
    }
  }

  if [${CurrentNS}::allowsStructured] {
    $W(RadioStructured) configure -state active
  } else {
    $W(RadioStructured) configure -state disabled
    if { $args(GridType) == "Structured" } {
      set args(GridType) Unstructured
      onGridTypeChanged
    }
  }

  if [${CurrentNS}::allowsUnstructured] {
    $W(RadioUnstructured) configure -state active
  } else {
    $W(RadioUnstructured) configure -state disabled
    if { $args(GridType) == "Unstructured" } {
      set args(GridType) Structured
      onGridTypeChanged
    }
  }

  $W(RadioExplicitDim) configure -text [${CurrentNS}::dimensionLabel]
  $W(RadioDeltaS) configure -text [${CurrentNS}::deltaSLabel]

  if { [${CurrentNS}::numDimensions] == 3 } {
    set args(Dimension) $args(Dimension3D)
  } elseif { [${CurrentNS}::numDimensions] == 2 } {
    set args(Dimension) $args(Dimension2D)
  } else {
    set args(Dimension) $args(Dimension1D)
  }
  onDimensionTypeChanged

  if [${CurrentNS}::allowsSelectSpecs] {
    $W(RadioSelectSpecs) configure -state active
  } else {
    $W(RadioSelectSpecs) configure -state disabled
    if { $args(SpecType) == "select" } {
      set args(SpecType) "explicit"
    }
  }

  $W(LabelSize) configure -text [${CurrentNS}::sizeLabel]
  $W(LabelOrigin) configure -text [${CurrentNS}::originLabel]

  if { [${CurrentNS}::numSizes] == 3 } {
    set args(Size) $args(Size3D)
  } elseif { [${CurrentNS}::numSizes] == 2 } {
    set args(Size) $args(Size2D)
  } else {
    set args(Size) $args(Size1D)
  }
  onSpecTypeChanged

  $W(ButtonSelectSpecs) configure -text [${CurrentNS}::selectButtonLabel]

  ${CurrentNS}::drawCanvas $W(Canvas)
  updateWidgets
}

proc onSurfaceTypeChanged {} {
  global args CurrentNS
  ${CurrentNS}::onSurfaceTypeChanged $args(SurfaceType)
  updateWidgets
}

proc onDimensionTypeChanged {} {
  global CurrentNS args W
  switch -exact $args(DimensionType) {
    "Dimension" {
      $W(EntryDimension) configure -state normal
      $W(EntryDeltaS) configure -state disabled
      validateDimension $args(Dimension)
    }

    "AverageDelS" {
      $W(EntryDimension) configure -state disabled
      $W(EntryDeltaS) configure -state normal
      validateDeltaS $args(DeltaS)
    }
  }
  updateWidgets
}

proc onSpecTypeChanged {} {
  global args W CurrentNS
  switch -exact $args(SpecType) {
    "explicit" {
      $W(EntrySize) configure -state normal
      $W(EntryOrigin) configure -state normal
      $W(ButtonSelectSpecs) configure -state disabled
    }

    "select" {
      $W(EntrySize) configure -state disabled
      $W(EntryOrigin) configure -state disabled
      $W(ButtonSelectSpecs) configure -state active
    }
  }
  validateOrigin $args(Origin)
  validateSize $args(Size)

  ${CurrentNS}::onSpecTypeChanged $args(SpecType)
  updateWidgets
}

proc onEntityTypeChanged {} {
  global args W

  switch -exact $args(EntityType) {
    "Grid" -
    "Both" {
      $W(RadioStructured) configure -state active
      $W(RadioUnstructured) configure -state active
      $W(EntryDimension) configure -state normal
      $W(EntryDeltaS) configure -state normal
      $W(RadioExplicitDim) configure -state active
      $W(RadioDeltaS) configure -state active
    }

    "Database" {
      $W(RadioStructured) configure -state disabled
      $W(RadioUnstructured) configure -state disabled
      $W(EntryDimension) configure -state disabled
      $W(EntryDeltaS) configure -state disabled
      $W(RadioExplicitDim) configure -state disabled
      $W(RadioDeltaS) configure -state disabled
    }
  }
  updateWidgets
}

proc onGridTypeChanged { } {
  global CurrentNS args
  ${CurrentNS}::onGridTypeChanged $args(GridType)
  updateWidgets
}

proc updateWidgets { } {
  global CurrentNS ValidDict color W args

  set canApply [${CurrentNS}::canApply args]

  foreach key [dict keys $ValidDict] {
    if [dict exists $ValidDict $key widget] {
      set w [dict get $ValidDict $key widget]
      if [dict get $ValidDict $key valid] {
        $w configure -bg $color(Valid)
      } else {
        $w configure -bg $color(Invalid)
        set canApply 0
      }
    }
  }

  if { ! $canApply } {
    $W(ButtonOk) configure -state disabled
    $W(ButtonApply) configure -state disabled
  } else {
    $W(ButtonOk) configure -state active
    $W(ButtonApply) configure -state active
  }

  return 1
}

###
# validation procs
###

proc validateDimension { value } {
  global ValidDict CurrentNS
  dict set ValidDict Dimension valid [${CurrentNS}::validateDimension $value]
  dict set ValidDict DeltaS valid 1
  return true
}

proc validateDeltaS { value } {
  global ValidDict CurrentNS
  dict set ValidDict DeltaS valid [${CurrentNS}::validateDeltaS $value]
  dict set ValidDict Dimension valid 1
  return true
}

proc validateSize { value } {
  global ValidDict CurrentNS
  dict set ValidDict Size valid [${CurrentNS}::validateSize $value]
  return true
}

proc validateOrigin { value } {
  global ValidDict CurrentNS
  dict set ValidDict Origin valid [${CurrentNS}::validateOrigin $value]
  return true
}

###
# Shape-specific picking
###

proc doPickEntities { } {
  global ValidDict CurrentNS args
  ${CurrentNS}::pickEntities args
  updateWidgets
}

###
# Create the generic GUI
###

proc buildWidgets { } {
  global ShapeDict ValidDict CurrentShape CurrentNS W

  # widget hierarchy
  set W(LabelTitle)             .title
  set W(FrameWork)              .main
   set W(FrameInput)            $W(FrameWork).input
    set W(FrameAtts)            $W(FrameInput).atts
     set W(ShapeMenu)           $W(FrameAtts).shapemenu
     set W(RadioBaffle)         $W(FrameAtts).rbaffle
     set W(RadioFarField)       $W(FrameAtts).rfarfield
     set W(RadioGrid)           $W(FrameAtts).rgrid
     set W(RadioDatabase)       $W(FrameAtts).rdatabase
     set W(RadioBoth)           $W(FrameAtts).rboth
     set W(RadioStructured)     $W(FrameAtts).rstructured
     set W(RadioUnstructured)   $W(FrameAtts).runstructured
     set W(RadioExplicitDim)    $W(FrameAtts).rdimexplicit
     set W(EntryDimension)      $W(FrameAtts).dimension
     set W(RadioDeltaS)         $W(FrameAtts).ravgds
     set W(EntryDeltaS)         $W(FrameAtts).deltas
    set W(FrameSpecs)           $W(FrameInput).specs
     set W(RadioExplicitSpecs)  $W(FrameSpecs).rspecexplicit
     set W(FrameExplicitSpecs)  $W(FrameSpecs).fspecexplicit
      set W(LabelSize)          $W(FrameExplicitSpecs).lsize
      set W(EntrySize)          $W(FrameExplicitSpecs).size
      set W(LabelOrigin)        $W(FrameExplicitSpecs).lorigin
      set W(EntryOrigin)        $W(FrameExplicitSpecs).origin
     set W(RadioSelectSpecs)    $W(FrameSpecs).rselect
     set W(FrameSelectSpecs)    $W(FrameSpecs).fselect
      set W(ButtonSelectSpecs)  $W(FrameSelectSpecs).bselect
    set W(FrameOrient)          $W(FrameInput).forient
   set W(FrameCanvas)           $W(FrameWork).fcanvas
    set W(Canvas)               $W(FrameCanvas).canvas
  set W(FrameButtons)           .buttons
   set W(ButtonOk)              $W(FrameButtons).ok
   set W(ButtonApply)           $W(FrameButtons).apply
   set W(ButtonCancel)          $W(FrameButtons).cancel
   set W(Logo)                  $W(FrameButtons).logo

  # title
  wm title . "Shape Wizard"
  label $W(LabelTitle) -text "Shape Wizard"
  set font [$W(LabelTitle) cget -font]
  set fontSize [font actual $font -size]
  set wfont [font create -family [font actual $font -family] -weight bold \
    -size [expr {int(1.5 * $fontSize)}]]
  $W(LabelTitle) configure -font $wfont

  pack $W(LabelTitle) -side top

  # spacer
  pack [frame .sp -bd 1 -height 2 -relief sunken] -side top -fill x -padx 15

  # work frame
  pack [frame $W(FrameWork) -width 640 -relief sunken] \
    -side top -fill both -expand 1

  # input frame
  pack [frame $W(FrameInput) -bd 1] -side left -anchor n

  # canvas frame
  pack [frame $W(FrameCanvas) -bd 1 -relief sunken] \
    -side right -padx 10 -pady 10 -fill both -expand 1

  # button frame
  pack [frame $W(FrameButtons) -relief sunken] \
    -fill x -side bottom -padx 2 -pady 4

  button $W(ButtonOk) \
         -text "OK" \
         -command {
           ${CurrentNS}::makeShape args
           exit
         }

  button $W(ButtonApply) \
         -text "Apply" \
         -command {
           ${CurrentNS}::makeShape args
           pw::Display update
         }

  button $W(ButtonCancel) -text "Cancel" -command exit

  pack $W(ButtonCancel) -side right -padx 5
  pack $W(ButtonApply)  -side right -padx 5
  pack $W(ButtonOk)     -side right -padx 5

  # Pointwise logo in button frame
  pack [label $W(Logo) -image [pwLogo] -bd 0 -relief flat] -side left

  # Input controls
  labelframe $W(FrameAtts) -text "Attributes" -bd 2 -relief sunken
  grid $W(FrameAtts) -row 0 -column 0 -padx 5 -pady 5 -sticky ew

  grid [label $W(FrameAtts).ml -text "Type: "] -row 0 -column 0 -sticky e

  # build the menu with the available shapes
  set shapeMenu [eval \
    [concat tk_optionMenu $W(ShapeMenu) CurrentShape [dict keys $ShapeDict]]]
  grid $W(ShapeMenu) -row 0 -column 1 -columnspan 2 -sticky w

  grid [label $W(FrameAtts).sl -text "Surface Type: "] \
    -row 1 -column 0 -sticky e

  radiobutton $W(RadioBaffle) \
              -variable args(SurfaceType) \
              -value "Baffle" \
              -text "Baffle" \
              -command { onSurfaceTypeChanged }
  grid $W(RadioBaffle) -row 1 -column 1 -sticky w

  radiobutton $W(RadioFarField) \
              -variable args(SurfaceType) \
              -value "Farfield" \
              -text "Farfield" \
              -command { onSurfaceTypeChanged }
  grid $W(RadioFarField) -row 1 -column 2 -sticky w

  grid [label $W(FrameAtts).el -text "Entity Type: "] -row 2 -column 0 -sticky e

  radiobutton $W(RadioGrid) \
              -variable args(EntityType) \
              -value "Grid" \
              -text "Grid" \
              -command { onEntityTypeChanged }
  grid $W(RadioGrid) -row 2 -column 1 -sticky w -padx 1

  radiobutton $W(RadioDatabase) \
              -variable args(EntityType) \
              -value "Database" \
              -text "Database" \
              -command { onEntityTypeChanged }
  grid $W(RadioDatabase) -row 2 -column 2 -sticky w -padx 1

  radiobutton $W(RadioBoth) \
              -variable args(EntityType) \
              -value "Both" \
              -text "Both" \
              -command { onEntityTypeChanged }
  grid $W(RadioBoth) -row 2 -column 3 -sticky w -padx 1

  grid [label $W(FrameAtts).gl -text "Grid Type: "] -row 3 -column 0 -sticky e

  radiobutton $W(RadioStructured) \
              -variable args(GridType) \
              -value "Structured" \
              -text "Structured" \
              -command { onGridTypeChanged }
  grid $W(RadioStructured) -row 3 -column 1 -sticky w

  radiobutton $W(RadioUnstructured) \
              -variable args(GridType) \
              -value "Unstructured" \
              -text "Unstructured" \
              -command { onGridTypeChanged }
  grid $W(RadioUnstructured) -row 3 -column 2 -sticky w

  # spacer
  grid [frame $W(FrameAtts).sp -height 4 -bd 0] -row 4 -columnspan 4

  radiobutton $W(RadioExplicitDim) \
              -variable args(DimensionType) \
              -value "Dimension" \
              -text {Dimension [ I J K ]} \
              -command { onDimensionTypeChanged; updateWidgets }
  grid $W(RadioExplicitDim) -row 5 -column 0 -sticky w

  entry $W(EntryDimension) \
        -textvariable args(Dimension) \
        -validate key \
        -validatecommand { validateDimension %P; updateWidgets }
  grid $W(EntryDimension) -row 5 -column 1 -sticky w -columnspan 3
  dict set ValidDict Dimension widget $W(EntryDimension)
  dict set ValidDict Dimension valid 1

  radiobutton $W(RadioDeltaS) \
              -variable args(DimensionType) \
              -value "AverageDelS" \
              -text "Average \u394s:" \
              -command { onDimensionTypeChanged; updateWidgets }
  grid $W(RadioDeltaS) -row 6 -column 0 -sticky w

  entry $W(EntryDeltaS) \
        -textvariable args(DeltaS) \
        -validate key \
        -validatecommand { validateDeltaS %P; updateWidgets }
  grid $W(EntryDeltaS) -row 6 -column 1 -sticky w -columnspan 3
  dict set ValidDict DeltaS widget $W(EntryDeltaS)
  dict set ValidDict DeltaS valid 1

  # Specifications frame
  labelframe $W(FrameSpecs) \
             -text "Specifications" \
             -bd 2 \
             -relief sunken
  grid $W(FrameSpecs) -row 1 -column 0 -padx 5 -pady 5 -sticky ew

  radiobutton $W(RadioExplicitSpecs) \
              -variable args(SpecType) \
              -value "explicit" \
              -command { onSpecTypeChanged; updateWidgets }
  grid $W(RadioExplicitSpecs) -row 0 -column 0 -sticky ne

  labelframe $W(FrameExplicitSpecs) \
             -text "Explicit" \
             -bd 1 \
             -relief sunken
  grid $W(FrameExplicitSpecs) -row 0 -column 1 -padx 5 -pady 5 -sticky ew

  # Size
  grid [label $W(LabelSize) -text "Size \[ L W H \] "] \
    -row 0 -column 0 -sticky e -padx 5 -pady 5

  entry $W(EntrySize) \
        -textvariable args(Size) \
        -validate key \
        -validatecommand { validateSize %P; updateWidgets }
  grid $W(EntrySize) -row 0 -column 1 -sticky w -padx 5 -pady 5
  dict set ValidDict Size widget $W(EntrySize)
  dict set ValidDict Size valid 1

  # Origin
  grid [label $W(LabelOrigin) -text "Origin"] \
    -row 1 -column 0 -sticky e -padx 5 -pady 5

  entry $W(EntryOrigin) \
        -textvariable args(Origin) \
        -validate key \
        -validatecommand { validateOrigin %P; updateWidgets }
  grid $W(EntryOrigin) -row 1 -column 1 -sticky w -padx 5 -pady 5
  dict set ValidDict Origin widget $W(EntryOrigin)
  dict set ValidDict Origin valid 1

  # Interactive frame
  radiobutton $W(RadioSelectSpecs) \
              -variable args(SpecType) \
              -value "select" \
              -command { onSpecTypeChanged; updateWidgets }
  grid $W(RadioSelectSpecs) -row 1 -column 0 -sticky ne

  labelframe $W(FrameSelectSpecs) \
             -text "Interactive Mode" \
             -bd 1 \
             -relief sunken
  grid $W(FrameSelectSpecs) -row 1 -column 1 -padx 5 -pady 5 -sticky ew

  button $W(ButtonSelectSpecs) \
         -text "Select entities interactively" -state disabled \
	     -command { doPickEntities }
  grid $W(ButtonSelectSpecs) -row 0 -column 0 -pady 5

  label $W(FrameSelectSpecs).lt \
        -text "Selection uses canvas entities shown in red."
  grid $W(FrameSelectSpecs).lt -row 1 -column 0 -pady 5

  # Orientation frame
  labelframe $W(FrameOrient) \
             -text "Orientation/Portion" \
             -bd 2 \
             -relief sunken
  grid $W(FrameOrient) -row 3 -column 0 -padx 5 -pady 5 -sticky ew

  #### Canvas ####
  pack [canvas $W(Canvas) -bg "#110c3c"] -fill both -expand 1
  ${CurrentNS}::drawCanvas $W(Canvas)

  onShapeTypeChanged true

  #### Bindings ####
  bind $shapeMenu <<MenuSelect>> {
    onShapeTypeChanged false;
    update
  }
}

proc pwLogo {} {
  set logoData "
R0lGODlheAAYAIcAAAAAAAICAgUFBQkJCQwMDBERERUVFRkZGRwcHCEhISYmJisrKy0tLTIyMjQ0
NDk5OT09PUFBQUVFRUpKSk1NTVFRUVRUVFpaWlxcXGBgYGVlZWlpaW1tbXFxcXR0dHp6en5+fgBi
qQNkqQVkqQdnrApmpgpnqgpprA5prBFrrRNtrhZvsBhwrxdxsBlxsSJ2syJ3tCR2siZ5tSh6tix8
ti5+uTF+ujCAuDODvjaDvDuGujiFvT6Fuj2HvTyIvkGKvkWJu0yUv2mQrEOKwEWNwkaPxEiNwUqR
xk6Sw06SxU6Uxk+RyVKTxlCUwFKVxVWUwlWWxlKXyFOVzFWWyFaYyFmYx16bwlmZyVicyF2ayFyb
zF2cyV2cz2GaxGSex2GdymGezGOgzGSgyGWgzmihzWmkz22iymyizGmj0Gqk0m2l0HWqz3asznqn
ynuszXKp0XKq1nWp0Xaq1Hes0Xat1Hmt1Xyt0Huw1Xux2IGBgYWFhYqKio6Ojo6Xn5CQkJWVlZiY
mJycnKCgoKCioqKioqSkpKampqmpqaurq62trbGxsbKysrW1tbi4uLq6ur29vYCu0YixzYOw14G0
1oaz14e114K124O03YWz2Ie12oW13Im10o621Ii22oi23Iy32oq52Y252Y+73ZS51Ze81JC625G7
3JG825K83Je72pW93Zq92Zi/35G+4aC90qG+15bA3ZnA3Z7A2pjA4Z/E4qLA2KDF3qTA2qTE3avF
36zG3rLM3aPF4qfJ5KzJ4LPL5LLM5LTO4rbN5bLR6LTR6LXQ6r3T5L3V6cLCwsTExMbGxsvLy8/P
z9HR0dXV1dbW1tjY2Nra2tzc3N7e3sDW5sHV6cTY6MnZ79De7dTg6dTh69Xi7dbj7tni793m7tXj
8Nbk9tjl9N3m9N/p9eHh4eTk5Obm5ujo6Orq6u3t7e7u7uDp8efs8uXs+Ozv8+3z9vDw8PLy8vL0
9/b29vb5+/f6+/j4+Pn6+/r6+vr6/Pn8/fr8/Pv9/vz8/P7+/gAAACH5BAMAAP8ALAAAAAB4ABgA
AAj/AP8JHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNqZCioo0dC0Q7Sy2btlitisrjpK4io4yF/
yjzKRIZPIDSZOAUVmubxGUF88Aj2K+TxnKKOhfoJdOSxXEF1OXHCi5fnTx5oBgFo3QogwAalAv1V
yyUqFCtVZ2DZceOOIAKtB/pp4Mo1waN/gOjSJXBugFYJBBflIYhsq4F5DLQSmCcwwVZlBZvppQtt
D6M8gUBknQxA879+kXixwtauXbhheFph6dSmnsC3AOLO5TygWV7OAAj8u6A1QEiBEg4PnA2gw7/E
uRn3M7C1WWTcWqHlScahkJ7NkwnE80dqFiVw/Pz5/xMn7MsZLzUsvXoNVy50C7c56y6s1YPNAAAC
CYxXoLdP5IsJtMBWjDwHHTSJ/AENIHsYJMCDD+K31SPymEFLKNeM880xxXxCxhxoUKFJDNv8A5ts
W0EowFYFBFLAizDGmMA//iAnXAdaLaCUIVtFIBCAjP2Do1YNBCnQMwgkqeSSCEjzzyJ/BFJTQfNU
WSU6/Wk1yChjlJKJLcfEgsoaY0ARigxjgKEFJPec6J5WzFQJDwS9xdPQH1sR4k8DWzXijwRbHfKj
YkFO45dWFoCVUTqMMgrNoQD08ckPsaixBRxPKFEDEbEMAYYTSGQRxzpuEueTQBlshc5A6pjj6pQD
wf9DgFYP+MPHVhKQs2Js9gya3EB7cMWBPwL1A8+xyCYLD7EKQSfEF1uMEcsXTiThQhmszBCGC7G0
QAUT1JS61an/pKrVqsBttYxBxDGjzqxd8abVBwMBOZA/xHUmUDQB9OvvvwGYsxBuCNRSxidOwFCH
J5dMgcYJUKjQCwlahDHEL+JqRa65AKD7D6BarVsQM1tpgK9eAjjpa4D3esBVgdFAB4DAzXImiDY5
vCFHESko4cMKSJwAxhgzFLFDHEUYkzEAG6s6EMgAiFzQA4rBIxldExBkr1AcJzBPzNDRnFCKBpTd
gCD/cKKKDFuYQoQVNhhBBSY9TBHCFVW4UMkuSzf/fe7T6h4kyFZ/+BMBXYpoTahB8yiwlSFgdzXA
5JQPIDZCW1FgkDVxgGKCFCywEUQaKNitRA5UXHGFHN30PRDHHkMtNUHzMAcAA/4gwhUCsB63uEF+
bMVB5BVMtFXWBfljBhhgbCFCEyI4EcIRL4ChRgh36LBJPq6j6nS6ISPkslY0wQbAYIr/ahCeWg2f
ufFaIV8QNpeMMAkVlSyRiRNb0DFCFlu4wSlWYaL2mOp13/tY4A7CL63cRQ9aEYBT0seyfsQjHedg
xAG24ofITaBRIGTW2OJ3EH7o4gtfCIETRBAFEYRgC06YAw3CkIqVdK9cCZRdQgCVAKWYwy/FK4i9
3TYQIboE4BmR6wrABBCUmgFAfgXZRxfs4ARPPCEOZJjCHVxABFAA4R3sic2bmIbAv4EvaglJBACu
IxAMAKARBrFXvrhiAX8kEWVNHOETE+IPbzyBCD8oQRZwwIVOyAAXrgkjijRWxo4BLnwIwUcCJvgP
ZShAUfVa3Bz/EpQ70oWJC2mAKDmwEHYAIxhikAQPeOCLdRTEAhGIQKL0IMoGTGMgIBClA9QxkA3U
0hkKgcy9HHEQDcRyAr0ChAWWucwNMIJZ5KilNGvpADtt5JrYzKY2t8nNbnrzm+B8SEAAADs="

  return [image create photo -format GIF -data $logoData]
}

buildWidgets
::tk::PlaceWindow . widget
tkwait window .

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
