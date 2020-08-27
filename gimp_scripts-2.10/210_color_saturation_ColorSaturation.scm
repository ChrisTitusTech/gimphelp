; 210_color-saturation_ColorSaturation.scm
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
; Color Saturation, V2.02
;
; Martin Egger (martin.egger@gmx.net)
; (C) 2005, Bern, Switzerland
;==============================================================


(define (210-ColorSaturation 
		InImage 
		InLayer 
		InIntensity 
		InFlatten
	)

	(gimp-image-undo-group-start InImage)
	(if (not (= RGB (car (gimp-image-base-type InImage))))
			 (gimp-image-convert-rgb InImage))	
	
	(let*	(
		(factor (* InIntensity .025))
		(plus (+ 1 (* 2 factor)))
		(minus (* -1 factor))
		(ColorLayer (car (gimp-layer-copy InLayer TRUE)))
		)
		(gimp-image-insert-layer InImage ColorLayer 0 -1)
;
; Apply new color mappings to image
;
		(plug-in-colors-channel-mixer TRUE InImage ColorLayer FALSE plus minus minus minus plus minus minus minus plus)
;
; Flatten the image, if we need to
;
		(cond
			((= InFlatten TRUE) (gimp-image-merge-down InImage ColorLayer CLIP-TO-IMAGE))
			((= InFlatten FALSE) (gimp-item-set-name ColorLayer "Saturated"))
		)
	)
;
; Finish work
;
	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
;
)
;
; Register the function with the GIMP
;
(script-fu-register
	"210-ColorSaturation"
	"Color Saturation"
	"Saturate or desaturate color images"
	"Martin Egger (martin.egger@gmx.net)"
	"2005, Martin Egger, Bern, Switzerland"
	"15.05.2005"
	"*"
	SF-IMAGE		"The Image"						0
	SF-DRAWABLE		"The Layer"						0
	SF-ADJUSTMENT	"Intensity"						'(1 -7 7 0.5 0 2 0)
	SF-TOGGLE		"Merge Layers when complete?"	FALSE
)
(script-fu-menu-register "210-ColorSaturation" "<Image>/Script-Fu/Color/Saturation")
