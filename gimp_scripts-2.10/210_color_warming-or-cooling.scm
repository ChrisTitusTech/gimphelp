; 210_color_warming-or-cooling.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 05/11/2019 on GIMP 2.10.10
;==================================================
;
; Installation:
; This script should be placed in the user or system-wide script folder.
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\scripts
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/scripts  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/scripts
;
;==================================================
;
; LICENSE
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;==============================================================
; Original information 
;
; tone-adjust
;
; Copyright (C) 2010 Howard Roberts(howardroberts@comcast.net)
;==============================================================


(define (210-tone-adjust 
		img 
		drawable 
		tone 
		method 
		density 
		inMerge
	)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))   
   
   (let* ( 
		(width (car (gimp-image-width img)))
		(height (car (gimp-image-height img)))
		(old-color (car (gimp-context-get-foreground)))
		(fill-color '(255 255 255))
		(overlay-layer (car (gimp-layer-new img width height RGB-IMAGE "Tone" 100 OVERLAY-MODE)))
		(myChannel 0)
		)
		(set! myChannel (car (gimp-channel-new-from-component img GRAY-CHANNEL "Value")))
		(gimp-image-add-channel img myChannel 0)
		(gimp-image-add-layer img overlay-layer 0)
		(gimp-image-raise-layer-to-top img overlay-layer)
		(if (or (= tone 6)(= method 1))
			(gimp-selection-combine myChannel CHANNEL-OP-REPLACE)
		)
		(cond ((= tone 0)
			 (set! fill-color '(0 109 255))
			)
			((= tone 1)
			  (set! fill-color '(0 181 255))
			)
		((= tone 2)
			  (set! fill-color '(235 177 19))
			)
		((= tone 3)
			  (set! fill-color '(237 138 0))
			)
		((= tone 4)
			  (gimp-image-remove-layer img overlay-layer)
			  (gimp-color-balance drawable 1 TRUE 0 -5 -20)

			)
		((= tone 5)
			  (gimp-image-remove-layer img overlay-layer)
			  (let* (
					(warmed-layer (car (gimp-layer-copy drawable FALSE)))
					)
			(gimp-image-add-layer img warmed-layer -1)
			(gimp-colorize warmed-layer 40 50 0)
			(gimp-layer-set-opacity warmed-layer density)
			  )
			)
		((= tone 6)
			  (set! fill-color '(255 255 255))
			)
		)
		(unless (or (= tone 4)(= tone 5))
		(if (= tone 6)
			(gimp-layer-set-opacity overlay-layer 100)
			(gimp-layer-set-opacity overlay-layer density)
		))
		(cond ((or (< tone 4)(= tone 6))
			(gimp-context-set-background fill-color)
			(gimp-edit-bucket-fill-full overlay-layer BG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 255 FALSE FALSE SELECT-CRITERION-COMPOSITE 0 0)
			(gimp-context-set-background old-color)
		))
		) ; end LET
		(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
		(gimp-selection-none img)
		(gimp-displays-flush)
		(gimp-image-undo-group-end img)
)

(script-fu-register "210-tone-adjust"
	"Warming or Cooling"
	"Warm or cool an image using one of several methods"
	"Howard Roberts <howardroberts@comcast.net>"
	"(c) 2010 Howard D. Roberts"
	"May 24,2010"
	"*"
	SF-IMAGE    	"Image"         										0
	SF-DRAWABLE 	"Layer"													0
	SF-OPTION      	"Tone"    												'("Cooling - Wratten 80"
																			"Cooling - Wratten 82" 
																			"Warming - Wratten 81" 
																			"Warming - Wratten 85"
																			"Roy's Warm"
																			"Brauer's Warm"
																			"Pasty Cadaveric Look")
	SF-OPTION	  	"Overlay Fill Method\nApplies only to Wratten filters" 	'("Fill Entire layer" "Fill Red Channel")
	SF-ADJUSTMENT 	"Opacity\nPasty Cadaveric defaults to 100%"				'(25 1 100 0 1 0 0 0)
	SF-TOGGLE     	"Merge layers when complete?" 							FALSE
)
(script-fu-menu-register "210-tone-adjust" "<Image>/Script-Fu/Color")
