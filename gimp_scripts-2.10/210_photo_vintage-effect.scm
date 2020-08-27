; 210_photo_vintage-effect.scm
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
; 04/27/2008 - Edited by Paul Sherman
; added faded border option
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
; Vintage Film Effect script for GIMP 2.4
; Original author: Alexia Death
; Tags: photo, vintage
; Author statement:
;
; Based on paint net tutorial by fallout75.
; (http://www.flickr.com/photos/fallout75/)
; This represents my first attempt at gimp scripting and my first 
; ever contact with Scheme language. If you feel its not as good 
; as it can be, feel free to improve it.
;==============================================================


(define (210-vintage-effect     
		inImage
		inLayer
		inCopy
		inFlatten
		inBorder
        )

  (let (

       (theWidth (car (gimp-image-width inImage)))
       (theHeight (car (gimp-image-height inImage)))
       (theImage 0)
       (base 0)
       (sepia 0)
       (magenta 0)
       (floating-sel 0)
       (control_pts_r (cons-array 10 'byte))
       (control_pts_g (cons-array 8 'byte))
       (control_pts_b (cons-array 4 'byte))

       )

    (set! theImage (if (= inCopy TRUE)
                     (car (gimp-image-duplicate inImage))
                     inImage
                   )
    )

    (if (= inCopy FALSE)
      (begin
        (gimp-image-undo-group-start theImage)
      )
    )
    (if (> (car (gimp-drawable-type inLayer)) 1)(gimp-image-convert-rgb theImage))

; flattening the image at hand into a copy
    (gimp-edit-copy-visible theImage)

; Making base layer
    (set! base (car (gimp-layer-new theImage
                                        theWidth
                                        theHeight
                                        RGBA-IMAGE
                                        "base"
                                        100
                                        LAYER-MODE-NORMAL-LEGACY)))

    (gimp-image-insert-layer theImage base 0 -1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste base TRUE)))
    (gimp-hue-saturation base ALL-HUES 0 0 15)
    (gimp-brightness-contrast base 0 20)
    (set! control_pts_r #(0 0 88 47 170 188 221 249 255 255))
    (set! control_pts_g #(0 0 65 57 184 208 255 255))
    (set! control_pts_b #(0 29 255 226))
    (gimp-curves-spline base HISTOGRAM-RED 10 control_pts_r)
    (gimp-curves-spline base HISTOGRAM-GREEN 8 control_pts_g)
    (gimp-curves-spline base HISTOGRAM-BLUE 4 control_pts_b)

; making sepia layer

     (set! sepia (car (gimp-layer-new theImage
                                        theWidth
                                        theHeight
                                        RGBA-IMAGE
                                        "sepia"
                                        100
                                        LAYER-MODE-NORMAL-LEGACY)))

    (gimp-image-insert-layer theImage sepia 0 -1)
    (gimp-floating-sel-anchor (car (gimp-edit-paste sepia TRUE)))
    (gimp-colorize sepia 25 25 30)
    (gimp-brightness-contrast sepia 40 30)
    (gimp-layer-set-opacity sepia 50)
    ; making magenta layer
    (set! magenta (car (gimp-layer-new theImage
                                        theWidth
                                        theHeight
                                        RGBA-IMAGE
                                        "magenta"
                                        100
                                        LAYER-MODE-SCREEN-LEGACY)))
					
    (gimp-image-insert-layer theImage magenta 0 -1)
    (gimp-context-push)
    (gimp-context-set-foreground '(255 0 220))
    (gimp-drawable-fill magenta FOREGROUND-FILL)
    (gimp-layer-set-opacity magenta 6)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (if (= inBorder TRUE)
    (begin
    	(gimp-selection-all theImage)
    	(gimp-selection-shrink theImage 4)
    	(gimp-selection-invert theImage)
    	(gimp-selection-feather theImage 24)
    	(gimp-context-set-foreground '(166 129 71))
    	(gimp-edit-fill base FOREGROUND-FILL)
    	(gimp-selection-none theImage)
    ))
    
    (gimp-context-pop)
    (if (= inFlatten TRUE)(gimp-image-flatten theImage))
    
    (if (= inCopy TRUE)
      (begin
        (gimp-image-clean-all theImage)
        (gimp-display-new theImage)
      )
    )
    (if (= inCopy FALSE)
      (begin
        (gimp-image-undo-group-end theImage)
      )
    )
    (gimp-displays-flush)
  )
)

(script-fu-register "210-vintage-effect"
	"Vintage Photo"
	"Make image look like an old photograph."
	"Alexia Death"
	"2007, Alexia Death."
	"3rd October 2007"
	"*"
	SF-IMAGE      "The image"		0
	SF-DRAWABLE   "The layer"		0
	SF-TOGGLE     "Work on copy" 	FALSE
	SF-TOGGLE     "Flatten image" 	FALSE
	SF-TOGGLE     "Faded Border"  	TRUE
)
(script-fu-menu-register "210-vintage-effect" "<Image>/Script-Fu/Photo")
