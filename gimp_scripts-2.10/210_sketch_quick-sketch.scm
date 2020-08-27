; 210_sketch_quick-sketch.scm
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
;  10/14/2008
;		  Modified by Paul Sherman 
;		  in accordence with post by char101 on
;		  http://registry.gimp.org/node/5921
;		  Also changed menu location.
; 10/15/2010 - bumped INDEXED* to prevent errors
; 02/15/2014 - accommodated indexed images properly
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
; Quick sketch is a script for The GIMP
; Quick sketch turns a photo into what looks like a artists sketch
; The script is located in "<Image> / Script-Fu / Artistic / Quick sketch..."
; Last changed: 14 June 2008
; Copyright (C) 2007 Harry Phillips <script-fu@tux.com.au>
;==============================================================


(define (210-quick-sketch 	
		theImage
		theLayer
		blurAmount
	)
	
	(gimp-image-undo-group-start theImage)
	(define indexed (car (gimp-drawable-is-indexed theLayer)))
	(if (= indexed TRUE)(gimp-image-convert-rgb theImage))

    ;Initiate some variables
	(let* (
	(layerCopy 0)
	(layerGrey (car (gimp-drawable-is-gray theLayer)))
	)

	;Rename the layer
	(gimp-item-set-name theLayer "Original")

	;Select none
	(gimp-selection-none theImage)

	;Change the layer Greyscale if it isn't already
	(if (= layerGrey 0) (gimp-desaturate theLayer))

	(set! layerCopy (car (gimp-layer-copy theLayer 1)))

	;Copy the layer
	(gimp-image-insert-layer theImage layerCopy 0 0)

	;Rename the layer
	(gimp-item-set-name layerCopy "Dodge layer")

	;Invert the layer
	(gimp-invert layerCopy)

	;Change the layers mode
	(gimp-layer-set-mode layerCopy 16)

	;Blur the dodge layer
	(plug-in-gauss 1 theImage layerCopy blurAmount blurAmount 0)

    )

	(gimp-image-undo-group-end theImage)
	(gimp-displays-flush)
)

(script-fu-register "210-quick-sketch"
	"Quick sketch"
	"Create a sketch from a photo"
	"Harry Phillips"
	"Harry Phillips"
	"Sep. 9 2007"
	"*"
	SF-IMAGE		"Image"     		0
	SF-DRAWABLE		"Drawable"  		0
	SF-ADJUSTMENT	"Blur factor"      '(30 5 200 1 1 0 1)
)

(script-fu-menu-register "210-quick-sketch" "<Image>/Script-Fu/Sketch")
