; 210_artist_water-paint-effect.scm
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
;   - Changelog -
; version 0.1  2001/04/15 iccii <iccii@hotmail.com>
;     - Initial relased
; version 0.1a 2001/07/20 iccii <iccii@hotmail.com>
;     - more simple
; Receved as completely broken, doing just gausian blur. Fixed to 
; do something that may have been the authors intent.
;==============================================================

(define (210-water-paint-effect
	inImage
	inDrawable
	inEffect
	inMerge
	)
			
	(define theNewlayer) 
	(define origlayer)
	(define nlayer)
  	(gimp-image-undo-group-start inImage)

	(define indexed (car (gimp-drawable-is-indexed inDrawable)))
	(if (= indexed TRUE)(gimp-image-convert-rgb inImage))
	
    (set! theNewlayer (car (gimp-layer-copy inDrawable 1)))
	(set! origlayer (car (gimp-layer-copy inDrawable 1)))
	
  	(plug-in-gauss-iir2 1 inImage inDrawable inEffect inEffect)
  	(gimp-image-insert-layer inImage theNewlayer 0 -1)
  	(plug-in-laplace 1 inImage theNewlayer)
  	(gimp-layer-set-mode theNewlayer SUBTRACT-MODE)
  	(gimp-image-merge-down inImage theNewlayer EXPAND-AS-NECESSARY)
	
	(set! nlayer (car (gimp-image-get-active-layer inImage)))
	(gimp-image-insert-layer inImage origlayer 0 -1)
	(gimp-image-lower-item-to-bottom inImage origlayer)
	(gimp-image-set-active-layer inImage nlayer)
	(gimp-item-set-name nlayer "Watercolor Layer")
  
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers inImage EXPAND-AS-NECESSARY))
  	(gimp-image-undo-group-end inImage)
  	(gimp-displays-flush)
)

(script-fu-register "210-water-paint-effect"
	"WaterColor"
	"draw with water paint effect"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Jul, 2001"
	"*"
	SF-IMAGE		"Image"							0
	SF-DRAWABLE		"Drawable"						0
	SF-ADJUSTMENT	"Effect Size (pixels)"			'(5 0 32 1 10 0 0)
	SF-TOGGLE     	"Merge layers when complete?" 	FALSE
)
(script-fu-menu-register "210-water-paint-effect" "<Image>/Script-Fu/Artist")
