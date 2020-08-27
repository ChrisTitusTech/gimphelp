; 210_edges_art-border.scm
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
; Last update reintroduced a modified drop-shadow effect 
; to give slight "dark glow" to inner border. This is optional. 
; Also pulled the flatten image on start, so you can retain an 
; alpha layer image if present.
; Dropped remnant selection when finished,
; changed menu location, added version for reference.
; convert to RGB if needed.
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
; Do a cool fade to a given colour at the border of an image (optional shadow)
; Will make image RGB if it isn't already.
;
; Chris Gutteridge (cjg@ecs.soton.ac.uk)
; At ECS Dept, University of Southampton, England.
;
; Modified for use in GIMP-2.4+ by Paul Sherman
; distributed by gimphelp.org
; improved UNDO while testing for GIMP-2.6
; last modified 10/02/2008
;==============================================================


(define (210-art-border
				inImage
				inLayer
				inSize
				inCopy
				inDesaturate
				inShadow
				inInvert
				inBlur
	)
	 (if (= inCopy FALSE) 
           (begin
			(gimp-image-undo-group-start inImage)
			(if (not (= RGB (car (gimp-image-base-type inImage))))
				(gimp-image-convert-rgb inImage))		 
		 ))

	(define theImage (if (= inCopy TRUE)
		       (car (gimp-image-duplicate inImage))
                       inImage))
	(define theWidth (car (gimp-image-width inImage)))
	(define theHeight (car (gimp-image-height inImage)))
	(define theLayer (car (gimp-image-get-active-layer theImage)))

	(if (not (= RGB (car (gimp-image-base-type theImage))))
		(gimp-image-convert-rgb theImage))
	(gimp-selection-all theImage)
	(gimp-selection-shrink theImage inSize)
	(gimp-selection-invert theImage)
	
	(if 	(= inDesaturate TRUE)
		(gimp-desaturate theLayer)
	)
	
	(if 	(= inInvert TRUE)
		(gimp-invert theLayer)
	)
	
	(if 	(= inBlur TRUE)
		(plug-in-blur 1 theImage theLayer)
	)

	(gimp-selection-invert theImage)
	(gimp-selection-border theImage 1)
	(gimp-edit-fill theLayer 0)

	(if 	(= inShadow TRUE)
			(script-fu-drop-shadow theImage theLayer 0 0 8 '(0 0 0) 70 TRUE)
	)

	(if 	(= inCopy TRUE)
		(begin 	(gimp-image-clean-all theImage)
			(gimp-selection-none theImage)
			(gimp-display-new theImage)
		)
		()
	)
	(gimp-displays-flush)
	 (if (= inCopy FALSE) 
           (begin
		 		(gimp-selection-none inImage)
	     		(gimp-image-undo-group-end inImage))
				)
)

(script-fu-register "210-art-border"
	"Art Border"
	"Add art border to the image"
	"Antony Dovgal"
	"2006, Antony Dovgal. This script is based on 'fuzzy border' by Chris Gutteridge"
	"21 April 2006"
	"*"
	SF-IMAGE       "The image"              		0
	SF-DRAWABLE    "The layer"              		0
	SF-ADJUSTMENT  "Border size"            		'(12 1 300 1 10 0 1)
	SF-TOGGLE      "Work on copy"           		TRUE
	SF-TOGGLE      "Desaturate border"      		TRUE
	SF-TOGGLE      "Lightly Shadow Inner Border"    TRUE
	SF-TOGGLE      "Invert border colors"   		FALSE
	SF-TOGGLE      "Blur border"            		FALSE
)
(script-fu-menu-register "210-art-border" "<Image>/Script-Fu/Edges")
