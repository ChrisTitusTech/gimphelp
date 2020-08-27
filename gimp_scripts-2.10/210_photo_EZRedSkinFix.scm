; 210_photo_EZRedSkinFix.scm
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             lyle's EZ Red Skin Fix           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A GIMP script-fu to perform a quick red skin fix
; technique created by lylejk of dpreview.com
;
; Creates a top layer set to Value mode and
; a second layer set to Screen mode.
;
; If you leave the "Merge Layers" box unchecked,
; the two layers will remain on the stack and you can
; adjust the opacity of the Screen layer to suit,
; then merge down if desired.
;
; With the "Merge Layers" box checked, the layers will
; automatically merge down, and the resulting layer name
; will be "Fixed with EZ Red Skin Fix".  If you have several
; similar images to adjust, you may wish to determine the
; desired opacity manually on the first image, then check
; the "Merge Layers" box to speed things up on the rest of
; the layers.  The script-fu input parameters are retained
; from one run to the next, so you won't have to change the
; opacity slider once you get it set the way you want it.
;==============================================================

 
(define (210-EZRedSkinFix  img drawable opacity merge-flag )
 
	; Start an undo group.  Everything between the start and the end
	; will be carried out if an undo command is issued.
	(gimp-image-undo-group-start img)
	
	; convert to RGB if not....
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
	;CREATE THE SCREEN LAYER
	(define screen-layer (car (gimp-layer-copy drawable 0)))

	; Give it a name
	(gimp-item-set-name screen-layer "Adjust opacity, then merge this layer down first")

	; Add the new layer to the image
	(gimp-image-insert-layer img screen-layer 0 0)

	; Set opacity
	(gimp-layer-set-opacity screen-layer opacity)

	; Set the layer mode to Screen
	(gimp-layer-set-mode screen-layer SCREEN-MODE )

	;CREATE THE VALUE LAYER 
	(define value-layer (car (gimp-layer-copy drawable 0)))

	; Give it a name
	(gimp-item-set-name value-layer "Merge this layer down second")

	; Add the new layer to the image
	(gimp-image-insert-layer img value-layer 0 0)

	; Set opacity to 100%
	(gimp-layer-set-opacity value-layer 100 )

	; Set the layer mode to Value
	(gimp-layer-set-mode value-layer VALUE-MODE )

	; NOW MERGE EVERYTHING DOWN IF DESIRED
	(if (equal? merge-flag TRUE)
	  (gimp-image-merge-down img screen-layer 1 )
	  ()
	)

	(if (equal? merge-flag TRUE)
	   (define second-merge (car(gimp-image-merge-down img value-layer 1 )))
	   ()
	)

	(if (equal? merge-flag TRUE)
	   (gimp-item-set-name second-merge "Fixed with EZ Red Skin Fix")
	   ()
	)

	; Complete the undo group
	(gimp-image-undo-group-end img)

	; Flush the display 
	(gimp-displays-flush)   
)
 
 
(script-fu-register "210-EZRedSkinFix"
	"EZ Red Skin Fix"
	"Add screen layer and a value layer"
	"Script by Mark Lowry"
	"Technique by lylejk of dpreview.com"
	"2006"
	"*"
	SF-IMAGE "Image" 									0
	SF-DRAWABLE "Current Layer" 						0
	SF-ADJUSTMENT "Strength? (Screen Layer Opacity)"  	'(35 0 100 1 10 0 0)
	SF-TOGGLE     "Merge layers when complete?" 		FALSE
 )
(script-fu-menu-register "210-EZRedSkinFix" "<Image>/Script-Fu/Photo")
