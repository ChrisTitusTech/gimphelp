; 210_sketch_sketch-drawing.scm
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
; 02/15/2014  - accommodated indexed images, 
; added option to flatten upon completion (and made flatten default)
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
; Drawing script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
;==============================================================


(define (210-drawing
		img
		drawable
		thickness
		inFlatten
	)

  (gimp-image-undo-group-start img)
  (define indexed (car (gimp-drawable-is-indexed drawable)))
	(if (= indexed TRUE)(gimp-image-convert-rgb img))
	
  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
         (thf (* height  0.005 thickness ))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-temp1 (car (gimp-layer-new img width height layer-type "temp1"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-temp2 (car (gimp-layer-new img width height layer-type "temp2"  100 LAYER-MODE-NORMAL-LEGACY)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection 2)) ; so Empty and All are the same.
    (gimp-selection-none img)
    (gimp-image-insert-layer img layer-temp1 0 -1)
    (gimp-image-insert-layer img layer-temp2 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp1 0)))

    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)      
        (gimp-desaturate layer-temp1))
    (gimp-edit-copy layer-temp1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-invert layer-temp2)
    (plug-in-gauss 1 img layer-temp2 thf thf 0)
    (gimp-layer-set-mode layer-temp2 16)
    (gimp-image-merge-down img layer-temp2 0)
    (set! layer-temp1 (car (gimp-image-get-active-layer img)))
    (gimp-levels layer-temp1 0 215 235 1.0 0 255) 

    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-temp1)
        ))

    (gimp-item-set-name layer-temp1 "Drawing")
    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-image-remove-channel img old-selection)

	(if (= inFlatten TRUE)(gimp-image-flatten img))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
	"210-drawing"
	"Drawing"
	"Creates a drawing.\n\nThis version lets you adjust the line thickness."
	"Eddy Verlinden <eddy_verlinden@hotmail.com>"
	"Eddy Verlinden"
	"2007, juli"
	"*"
	SF-IMAGE      "Image"	    					0
	SF-DRAWABLE   "Drawable"    					0
	SF-ADJUSTMENT "thickness"						'(2 1 5 1 1 0 0)
	SF-TOGGLE     "Flatten image when complete?" 	TRUE
)
(script-fu-menu-register "210-drawing" "<Image>/Script-Fu/Sketch")
