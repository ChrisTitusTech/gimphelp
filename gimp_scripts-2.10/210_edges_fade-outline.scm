; 210_edges_fade-outline.scm
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
; This GIMP script_fu operates on a single Layer
; It blends the outline boarder from one to another transparency level
; by adding a layer_mask that follows the shape of the selection.
; usually from 100% (white is full opaque) to 0% (black is full transparent)
;
; The user can specify the thickness of the fading border
; that is used to blend from transparent to opaque
; and the Fading direction (shrink or grow).
;
; The outline is taken from the current selection
; or from the layers alpha channel if no selection is active.
;
; Optional you may keep the generated layermask or apply
; it to the layer 
;
; Tue 10/14/2008 - Modified by Paul Sherman
;     Eliminated undefined variable errors.
;     Simplified by flattening image upon completion.
;     Added option to leave fade transparent, or flaten onto the image.
;==============================================================

(define (210-fade-outline
			inImage
			inLayer
			inBorderSize
			inFadeFrom
			inFadeTo
			inLeaveTransparent
	)
	(let* ((l-idx 0)
		(l-old-bg-color (car (gimp-context-get-background)))
		(l-has-selection TRUE)
	)
	; check Fade from and To Values (and force values from 0% to 100%)
	(if (> inFadeFrom 100) (begin (set! inFadeFrom 100 )) )
	(if (< inFadeFrom 0)   (begin (set! inFadeFrom 0 )) )
	(if (> inFadeTo 100) (begin (set! inFadeTo 100 )) )
	(if (< inFadeTo 0)   (begin (set! inFadeTo 0 )) )
         
	(define l-from-gray (* inFadeFrom 255))
	(define l-to-gray (* inFadeTo 255))
    (define l-step (/  (- l-from-gray l-to-gray) (+ inBorderSize 1)))
    (define l-gray l-to-gray)
	(define old-selection)
	; do nothing if the layer is a layer mask
	(if (= (car (gimp-item-is-layer-mask inLayer)) 0)
		(begin
			(gimp-image-undo-group-start inImage)
			
			(if (not (= RGB (car (gimp-image-base-type inImage))))
					 (gimp-image-convert-rgb inImage))			
			; if the layer has no alpha add alpha channel
			(if (= (car (gimp-drawable-has-alpha inLayer)) FALSE)
				(begin
					(gimp-layer-add-alpha inLayer)))
			; if the layer is the floating selection convert to normal layer
			; because floating selection cant have a layer mask
			(if (> (car (gimp-layer-is-floating-sel inLayer)) 0)
				(begin
					(gimp-floating-sel-to-layer inLayer)))
			; if there is no selection we use the layers alpha channel
			(if (= (car (gimp-selection-is-empty inImage)) TRUE)
				(begin
					(set! l-has-selection FALSE)
					(gimp-image-select-item inImage CHANNEL-OP-REPLACE inLayer)))
			(gimp-selection-sharpen inImage)
			(define l-mask (car (gimp-layer-create-mask inLayer ADD-MASK-WHITE)))
			(gimp-layer-add-mask inLayer l-mask)
              (while (<= l-idx inBorderSize)
                 (if (= l-idx inBorderSize)
                     (begin
                        (set! l-gray l-from-gray)
                      )
                  )
                  (gimp-context-set-background (list (/ l-gray 100) (/ l-gray 100) (/ l-gray 100)))
                  (gimp-edit-fill l-mask FILL-BACKGROUND)
                  (set! l-idx (+ l-idx 1))
                  (set! l-gray (+ l-gray l-step))
                  (gimp-selection-shrink inImage 1)
                  ; check if selection has shrinked to none
                  (if (= (car (gimp-selection-is-empty inImage)) TRUE)
                      (begin
                         (set! l-idx (+ inBorderSize 100))     ; break the while loop
                      )
                   )
              )
              (if (= l-has-selection FALSE)
                  (gimp-selection-none inImage)
              )
              (gimp-context-set-background l-old-bg-color)
	     (gimp-selection-none inImage)
              (if (=  inLeaveTransparent FALSE)
                  (begin
                    (gimp-image-flatten inImage)
                  )
               )	     
             (gimp-image-undo-group-end inImage)
             (gimp-displays-flush)
             )
        ))
)
(script-fu-register
    "210-fade-outline"
    "Fade Outline"
    "Blend the Layers outline border from one alpha value (opaque) to another (transparent) by generating a Layermask"
    "Wolfgang Hofer <hof@hotbot.com>"
    "Wolfgang Hofer"
    "10 Nov 1999"
    "*"
    SF-IMAGE 		"The Image" 					0
    SF-DRAWABLE 	"The Layer" 					0
    SF-ADJUSTMENT 	"Border Size" 					'(10 1 300 1 10 0 1)
    SF-ADJUSTMENT 	"Fade From %" 					'(100 0 100 1 10 0 0)
    SF-ADJUSTMENT 	"Fade To   %" 					'(0 0 100 1 10 0 0)
    SF-TOGGLE 		"Leave faded area transparent" 	FALSE
)
(script-fu-menu-register "210-fade-outline" "<Image>/Script-Fu/Edges")
