; 210_effects-selection_add-bevel.scm
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
; Made to work just on selection (found it not useful otherwise,
; and confusing.) Put in "smooth" option and changed menu location.
; Stopped from use if no selectioni present.
; Modified to allow non-rgb images... which will be converted autoatically.
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
; add-bevel.scm version 1.04
; Time-stamp: <2004-02-09 17:07:06 simon>
;
; Copyright (C) 1997 Andrew Donkin  (ard@cs.waikato.ac.nz)
; Contains code from add-shadow.scm by Sven Neumann
; (neumanns@uni-duesseldorf.de) (thanks Sven).
;
; Adds a bevel to an image.  See http://www.cs.waikato.ac.nz/~ard/gimp/
; (link above is dead)
;
; If there is a selection, it is bevelled.
; Otherwise if there is an alpha channel, the selection is taken from it
; and bevelled.
;
; The selection is set on exit, so Select->Invert then Edit->Clear will
; leave a cut-out.  Then use Sven's add-shadow for that
; floating-bumpmapped-texture cliche.
;==============================================================


(define (210-selection-add-bevel img
                             drawable
                             thickness
                             work-on-copy
                             keep-bump-layer
							 smoother)

(if (= (car (gimp-selection-is-empty img)) TRUE)
	(begin
	(gimp-message "No selection\nThis script is set to run only when an area is selected in the image."))
	(begin
	  (let* (
        	(index 1)
        	(bevelling-whole-image FALSE)
        	(greyness 0)
        	(thickness (abs thickness))
        	(type (car (gimp-drawable-type-with-alpha drawable)))
        	(image (if (= work-on-copy TRUE) (car (gimp-image-duplicate img)) img))
        	(pic-layer (car (gimp-image-get-active-drawable image)))
        	(offsets (gimp-drawable-offsets pic-layer))
        	(width (car (gimp-drawable-width pic-layer)))
        	(height (car (gimp-drawable-height pic-layer)))

        	; Bumpmap has a one pixel border on each side
        	(bump-layer (car (gimp-layer-new image
                                        	 (+ width 2)
                                        	 (+ height 2)
                                        	 GRAY
                                        	 "Bumpmap"
                                        	 100
                                        	 LAYER-MODE-NORMAL-LEGACY)))
        	(select)
        	)

    	(gimp-context-push)

    	; disable undo on copy, start group otherwise
    	(if (= work-on-copy TRUE)
    	  (gimp-image-undo-disable image)
    	  (gimp-image-undo-group-start image)
    	)

	    (if (not (= RGB (car (gimp-image-base-type image))))
		    	 (gimp-image-convert-rgb image))

    	(gimp-image-insert-layer image bump-layer 0 1)

    	; If the layer we're bevelling is offset from the image's origin, we
    	; have to do the same to the bumpmap
    	(gimp-layer-set-offsets bump-layer (- (car offsets) 1)
                                    	   (- (cadr offsets) 1))

    	;------------------------------------------------------------
    	;
    	; Set the selection to the area we want to bevel.
    	;
    	(if (eq? 0 (car (gimp-selection-bounds image)))
        	(begin
        	  (set! bevelling-whole-image TRUE) ; ...so we can restore things properly, and crop.
        	  (if (car (gimp-drawable-has-alpha pic-layer))
            	  (gimp-image-select-item image CHANNEL-OP-REPLACE pic-layer)
            	  (gimp-selection-all image)
        	  )
        	)
    	)

    	; Store it for later.
    	(set! select (car (gimp-selection-save image)))
    	; Try to lose the jaggies
    	(gimp-selection-feather image 2)

    	;------------------------------------------------------------
    	;
    	; Initialise our bumpmap
    	;
    	(gimp-context-set-background '(0 0 0))
    	(gimp-drawable-fill bump-layer BACKGROUND-FILL)

    	(while (< index thickness)
        	   (set! greyness (/ (* index 255) thickness))
        	   (gimp-context-set-background (list greyness greyness greyness))
        	   ;(gimp-selection-feather image 1) ;Stop the slopey jaggies?
        	   (gimp-edit-bucket-fill bump-layer BG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY
                                	  100 0 FALSE 0 0)
        	   (gimp-selection-shrink image 1)
        	   (set! index (+ index 1))
    	)
    	; Now the white interior
    	(gimp-context-set-background '(255 255 255))
    	(gimp-edit-bucket-fill bump-layer BG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY
                        	   100 0 FALSE 0 0)

    	;------------------------------------------------------------
    	;
    	; Do the bump.
    	;
    	(gimp-selection-none image)

    	; To further lessen jaggies?
    	(if (= smoother TRUE)
    		(plug-in-gauss-rle 1 image bump-layer thickness TRUE TRUE)
    	)
    	;
    	; BUMPMAP INVOCATION:
    	;
    	(plug-in-bump-map 1 image pic-layer bump-layer 125 45 3 0 0 0 0 TRUE FALSE 1)

    	;------------------------------------------------------------
    	;
    	; Restore things
    	;
    	(if (= bevelling-whole-image TRUE)
        	(gimp-selection-none image)        ; No selection to start with
        	(gimp-selection-load select)
    	)
    	; If they started with a selection, they can Select->Invert then
    	; Edit->Clear for a cutout.

    	; clean up
    	(gimp-image-remove-channel image select)
    	(if (= keep-bump-layer TRUE)
        	(gimp-item-set-visible bump-layer 0)
        	(gimp-image-remove-layer image bump-layer)
    	)
    	(gimp-image-set-active-layer image pic-layer)

    	; enable undo / end undo group
    	(if (= work-on-copy TRUE)
    	  (begin
        	(gimp-display-new image)
        	(gimp-image-undo-enable image)
    	  )
    	  (gimp-image-undo-group-end image)
    	)

    	(gimp-displays-flush)
    	(gimp-context-pop)
	  )
	))
)

(script-fu-register "210-selection-add-bevel"
	"Bevel Selection"
	"Add a beveled border to an image - runs only if there is a selection."
	"Andrew Donkin <ard@cs.waikato.ac.nz>"
	"Andrew Donkin"
	"1997/11/06"
	"*"
	SF-IMAGE       "Image"           		0
	SF-DRAWABLE    "Drawable"        		0
	SF-ADJUSTMENT  "Thickness"       		'(5 0 30 1 2 0 0)
	SF-TOGGLE      "Work on copy"    		TRUE
	SF-TOGGLE      "Keep bump layer" 		FALSE
	SF-TOGGLE      "Smooth Edges of bump" 	TRUE
)
(script-fu-menu-register "210-selection-add-bevel" "<Image>/Script-Fu/Effects Selection")
