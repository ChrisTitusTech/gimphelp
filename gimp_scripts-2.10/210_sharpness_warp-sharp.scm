; 210_sharpness_warp-sharp.scm
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
; warp-sharp.scm
; Date: <1999/11/11 16:50 simon@gimp.org>
; Author: Simon Budig <simon@gimp.org>
; Version 1.4

; Version 1.4 updated for Gimp 1.3 and 2.0.
;
; This implements a method to sharpen images described by Joern Loviscach
; in the german computer magazine c't, 22/1999.
;
; Basically it "squeezes" unsharp edges. This method is a simplified
; Version of an algorithm by Nur Arad and Craig Gotsman:
; "Enhancement by Image-Dependent Warping", IEEE Transactions on
; Image Processing, 1999, Vol. 8, No. 8, S. 1063
;==============================================================


(define (210-warp-sharp 
		img 
		drw 
		edge-strength 
		blur-strength 
		bump-depth 
		displace-amount
	)
	
  (gimp-image-undo-group-start img)
  (define indexed (car (gimp-drawable-is-indexed drw)))
	(if (= indexed TRUE)(gimp-image-convert-rgb img))

  (let* ((drawable-width (car (gimp-drawable-width drw)))
		 (drawable-height (car (gimp-drawable-height drw)))
		 (drawable-type (car (gimp-drawable-type drw)))
			 (old-selection 0)
		 ; layer for detecting edges
			 (edge-layer (car (gimp-layer-copy drw 0)))
		 ; layer for x-displace information
			 (x-displace-layer (car (gimp-layer-new img drawable-width
							  drawable-height drawable-type "Displace X" 100 0)))
		 ; layer for x-displace information
			 (y-displace-layer (car (gimp-layer-new img drawable-width
							  drawable-height drawable-type "Displace Y" 100 0)))
			 (selection-info (gimp-selection-bounds img))
			 (has-selection (car selection-info))
			 (bump-xoff 0)
			 (bump-yoff 0)
			)
		
		(if has-selection (begin
			; If there is a selection don't render too much.
			(set! old-selection
					(car (gimp-channel-copy (car (gimp-image-get-selection img)))))
			(gimp-selection-grow img (+ blur-strength bump-depth displace-amount))
			(set! selection-info (gimp-selection-bounds img))
			(set! bump-xoff (cadr selection-info))
			(set! bump-yoff (caddr selection-info))
		))
		; set up the layers
		(gimp-drawable-fill x-displace-layer 2)
		(gimp-drawable-fill y-displace-layer 2)
		(gimp-image-insert-layer img edge-layer 0 -1)
		(gimp-image-insert-layer img y-displace-layer 0 -1)
		(gimp-image-insert-layer img x-displace-layer 0 -1)

		; detect the edges and blur the layer a little bit
		(plug-in-edge 1 img edge-layer edge-strength 1 0)
		(if (>= blur-strength 1)
			(plug-in-gauss-iir 1 img edge-layer blur-strength 1 1))

		; create the displacement-maps by bump-mapping the edges.
		; elevation=30: areas without edges will get a 50 % gray.
		(plug-in-bump-map 1 img x-displace-layer edge-layer 0 30
						  bump-depth bump-xoff bump-yoff 0 0 0 0 0)
		(plug-in-bump-map 1 img y-displace-layer edge-layer 270 30
						  bump-depth bump-xoff bump-yoff 0 0 0 0 0)
		; restore the old selection
		(if has-selection (begin
			(gimp-item-delete old-selection)
		))
		; finally displace the image.
		(plug-in-displace 1 img drw displace-amount displace-amount 1 1
						  x-displace-layer y-displace-layer 1)

		; clean up...
		(gimp-image-remove-layer img edge-layer)
		(gimp-image-remove-layer img x-displace-layer)
		(gimp-image-remove-layer img y-displace-layer)
	)
	(gimp-image-undo-group-end img)
	(gimp-displays-flush)
)

(script-fu-register "210-warp-sharp"
    "Warp Sharp"
    "Sharpen the current drawable by squeezing unsharp edges. Algorithm described by Joern Loviscach in c't 22/1999, p 236."
    "Simon Budig <simon@gimp.org>"
    "Simon Budig"
    "30. 10. 1999"
    "*"
    SF-IMAGE 		"Image" 				0
    SF-DRAWABLE 	"Drawable" 				0
    SF-ADJUSTMENT 	"Edge detection" 		'(7 1 10 0.1 1 1 0)
    SF-ADJUSTMENT 	"Blur radius" 			'(3 0 10 0.1 1 1 0)
    SF-ADJUSTMENT 	"Bump depth" 			'(2 1 10 1 1 0 0)
    SF-ADJUSTMENT 	"Displace intensity" 	'(2.5 0.1 10 0.1 0.5 1 0)
)
(script-fu-menu-register "210-warp-sharp" "<Image>/Script-Fu/Sharpness")
