; 210_texture_texturizer.scm
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
; I*****  IN ADDITION: *****************************************

; Put the Gimpressionist presets (ev_angledstrokes.txt and 21 others...)  in :
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\gimpressionist\presets
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\gimpressionist\presets
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/gimpressionist\presets  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/gimpressionist\presets 
;==============================================================
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
; Texturizer script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; I would appreciate any comments/suggestions that you have about this
; script. I need new texture, how to create it.
;==============================================================


(define (210-texturizer
			img
			drawable
			pattern
			bg-type
			angle
			elevation
			direction
			invert?
			show?
	)
	
	(gimp-image-undo-group-start img)
	(define indexed (car (gimp-drawable-is-indexed drawable)))
	(if (= indexed TRUE)(gimp-image-convert-rgb img))
	
  (let* (
		 (width (car (gimp-drawable-width drawable)))
		 (height (car (gimp-drawable-height drawable)))
		 (old-fg (car (gimp-context-get-foreground)))
		 (old-pattern (car (gimp-context-get-pattern)))
		 (tmp-image (car (gimp-image-new width height GRAY)))
		 (tmp-layer (car (gimp-layer-new tmp-image width height 2 "Texture" 100 0)))
		)
    (gimp-image-undo-disable tmp-image)
    (gimp-drawable-fill tmp-layer 2)
    (gimp-image-insert-layer tmp-image tmp-layer 0 0)

    (cond
      ((eqv? bg-type 0)
         (gimp-context-set-pattern pattern)
         (gimp-edit-bucket-fill tmp-layer PATTERN-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0))
      ((eqv? bg-type 1)
         (plug-in-noisify 1 img tmp-layer FALSE 1.0 1.0 1.0 0)
         (gimp-brightness-contrast tmp-layer 0 63))
      ((eqv? bg-type 2)
         (plug-in-solid-noise 1 img tmp-layer FALSE FALSE (rand 65535) 15 16 16)
; last parameter added by EV (for GIMP 2)
         (plug-in-edge 1 img tmp-layer 4 1 5)
         (gimp-brightness-contrast tmp-layer 0 -63))
      ((eqv? bg-type 3)
         (plug-in-plasma 1 img tmp-layer (rand 65535) 4.0)
         (plug-in-gauss-iir2 1 img tmp-layer 1 1)
         (gimp-brightness-contrast tmp-layer 0 63))
      ) ; end of cond
    (plug-in-bump-map 1 img drawable tmp-layer angle (+ 35 elevation)
                      1 0 0 0 0 TRUE invert? 0)

    (gimp-context-set-foreground old-fg)
    (gimp-context-set-pattern old-pattern)
    (gimp-image-clean-all tmp-image)
    (gimp-image-undo-enable tmp-image)
    (if (eqv? show? TRUE)
        (gimp-display-new tmp-image)
        (gimp-image-delete tmp-image))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
	"210-texturizer"
	"Texturizer"
	"Creates textured canvas image. Be sure presets are installed into the gimpressionist/presets folder."
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Oct"
	"*"
	SF-IMAGE      "Image"	           	0
	SF-DRAWABLE   "Drawable"         	0
	SF-PATTERN    "Use Pattern"      	"Pine?"
	SF-OPTION     "Texture Type"     	'("Pattern" "Sand" "Paper" "Cloud")
	SF-ADJUSTMENT "Angle"            	'(135 0 360 1 10 0 0)
	SF-ADJUSTMENT "Depth"            	'(0 -5 5 1 1 0 1)
	SF-OPTION     "Stretch Direction" 	'("None" "Horizontal" "Vertical")
	SF-TOGGLE     "Invert"           	FALSE
	SF-TOGGLE     "Show Texture"     	FALSE
)
(script-fu-menu-register "210-texturizer" "<Image>/Script-Fu/Texture")
