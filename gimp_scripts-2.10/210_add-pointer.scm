; 210_add-pointer.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 05/12/2019 on GIMP-2.10.10
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

;==============================================================
; Original information 
; 
; Konstantin Beliakov <Konstantin.Belyakov@devexpress.com>
; Developer Express Inc.
; 2010/07/22
;==============================================================

(define (210-add-pointer image
                               drawable
                               drop-shadow
			       pointer-type
                               shadow-distance
                               shadow-angle
                               shadow-blur
                               shadow-color
                               shadow-opacity
			       motion
			       motion-separate-layers
			       motion-length
			       motion-angle	
			       reflections
				click
	)
  (let* (
        (shadow-blur (max shadow-blur 0))
        (shadow-opacity (min shadow-opacity 100))
        (shadow-opacity (max shadow-opacity 0))
;        (type (car (gimp-drawable-type-with-alpha drawable)))script-fu-dx-pointerv2
        (image-width (car (gimp-image-width image)))
        (image-height (car (gimp-image-height image)))
	(offset-x (/ image-width 2))
	(offset-y (/ image-height 2))
	(opacity 100)
	(opacity-decrement (/ opacity reflections))
	(motion-step (/ motion-length (- reflections 1)))
	(reflections-counter reflections)
	(layer (gimp-image-get-active-layer image))
	(shadow-transl-y (* shadow-distance (sin (/ (- 180 shadow-angle) 57.32))))
	(shadow-transl-x (* shadow-distance (cos (/ (- 180 shadow-angle) 57.32))))
        )

	(gimp-context-push)
	(gimp-image-set-active-layer image drawable)
	(gimp-image-undo-group-start image)

	(if (= motion FALSE) (set! motion-length 0))

	(if (= click TRUE)
		(begin
		(set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-click-effect.png"))))
		(gimp-layer-set-offsets layer (- (+ offset-x (* (/ motion-length 2) (sin (/ (- motion-angle 90) 57.2958)))) 7) (- (+ offset-y (* (/ motion-length 2) (cos (/ (- motion-angle 90) 57.2958)))) 7))
 		(gimp-image-insert-layer image layer 0 -1)
                (gimp-item-set-name (car (gimp-image-get-active-drawable image)) "Pointer")
		)
	)

	(if (= motion TRUE)
		(begin	
			(set! offset-x (- offset-x (* (/ motion-length 2) (sin (/ (- motion-angle 90) 57.2958)))))
			(set! offset-y (- offset-y (* (/ motion-length 2) (cos (/ (- motion-angle 90) 57.2958)))))
		)
	)

	

	(while (> reflections-counter 0)
		(if (= pointer-type 0)
		        (set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-normal-select.png"))))
		)
		(if (= pointer-type 1)
		        (set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-drag-and-drop.png"))))
		)
		(if (= pointer-type 2)
		        (set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-drag-and-drop-move.png"))))
		)
		(if (= pointer-type 3)
		        (set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-link-select.png"))))
		)

		(if (= pointer-type 4)
		        (set! layer (car (gimp-file-load-layer 0 image (string-append gimp-data-directory "/scripts/images/pointer-editor.png"))))
		)

	        (gimp-layer-set-offsets layer offset-x offset-y)
		(gimp-image-insert-layer image layer 0 -1)
		;(gimp-image-resize-to-layers image)
		(if (= drop-shadow TRUE)
		(begin
			(script-fu-drop-shadow image 
					;(car (gimp-image-get-active-layer image))
					layer
					shadow-transl-x
					shadow-transl-y
					shadow-blur
					shadow-color
					shadow-opacity
					TRUE)
				
			(gimp-image-merge-down image 
				;(car (gimp-image-get-active-layer image))
				layer
				 0)
		)
		)
		(gimp-layer-set-opacity (car (gimp-image-get-active-layer image)) opacity)
		(gimp-item-set-name (car (gimp-image-get-active-drawable image)) "Pointer")
 		(set! reflections-counter (- reflections-counter 1))
		(set! offset-x (+ offset-x (* motion-step (sin (/ (- motion-angle 90) 57.2958)))))
		(set! offset-y (+ offset-y (* motion-step (cos (/ (- motion-angle 90) 57.2958)))))
		(set! opacity (- opacity opacity-decrement))
		(if (= motion FALSE) (set! reflections-counter 0))

		
	 )
	(if (and (= motion TRUE) (= motion-separate-layers FALSE))
		(while (< reflections-counter (- reflections 1))
			(begin
				(gimp-image-merge-down image (car (gimp-image-get-active-layer image)) 0)
		 		(set! reflections-counter (+ reflections-counter 1))
			)
		)
	)

	(if (= click TRUE) (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) 0))

	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)
)
(script-fu-register "210-add-pointer"
	"Add-Pointer"
	"Adds pointer to image and applies effects to it."
	"Konstantin Beliakov <Konstantin.Belyakov@devexpress.com>"
	"Developer Express Inc."
	"2010/07/22"
	"RGB* GRAY*"
	SF-IMAGE      "Image"                                0
	SF-DRAWABLE   "Drawable"                             0
	SF-TOGGLE     "Add pointer shadow"  	             TRUE
	SF-OPTION     "Pointer type"      					'("Normal pointer" "Drag&Drop" "Drag&Drop/Move" "Link select" "Editor")
	SF-ADJUSTMENT "Shadow distance (0-20 pixels)"       '(3 0 10 1 10 0 )
	SF-ADJUSTMENT "Shadow angle (0-360 degrees)"        '(120 0 360 1 10 0 0)
	SF-ADJUSTMENT "Shadow blur radius (0-40 pixels)"    '(3 0 20 1 10 0 0)
	SF-COLOR      "Shadow color"                        "black"
	SF-ADJUSTMENT "Shadow opacity (0-100%)"             '(45 0 100 1 10 0 0)
	SF-TOGGLE     "Motion effect" 	                     FALSE
	SF-TOGGLE     "Create separate layers with motion reflections" FALSE
	SF-ADJUSTMENT "Motion length (0-600 pixels)"       	'(200 0 600 1 10 0 )
	SF-ADJUSTMENT "Motion angle (-180-+180 degrees)"    '(15 -180 180 1 10 0 0)
	SF-ADJUSTMENT "Number of reflections (2-10)"      	'(4 0 10 1 10 0 )
	SF-TOGGLE     "Click effect" 	                     FALSE
)
(script-fu-menu-register "210-add-pointer" "<Image>/Script-Fu")
