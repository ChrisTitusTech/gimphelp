; 210_effects_water-reflection.scm
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
; Copyright (C) 2005-2007 Otavio Correa Cordeiro (otavio gmail com)
; Create a reflection effect like Apple iWeb does..
;
;  02/11/2014 - re-worked by Paul Sherman from reflection to water-reflection,
;  incorporates the script to build displacement map v.1.2.1
;  Written by Andrey Lebedenko (Lucidlook) 2009
;  plus a lot of other changes...
;
; modified by Paul Sherman to work in GIMP 2.4.2 on 11/30/2007
;
; modified by David Cummins and Paul Sherman Dec 2007, tested on GIMP-2.4.3
; * added user settings to control the height of the generated reflection,
;   the gradient mask starting point (presented as Fade Rate %), and options
;   to keep the generated reflection as a separate layer, or on a single layer
;   either transparent or flattened.
; * added code to "play nice" with the current GIMP environment: colors and
;   gradient prior selections are preserved, as well as the original layer
;   name (handled using careful stack order).
;   generated layers are constrained around the original layer.
; * simplified some of the internal logic so repeated calculations are done
;   only once, reformatted, organised the code, added comments, etc.
; * flattened on start (to avoid errors)
; * undo ability functional
;
; Wed Oct  1 22:14:40 EDT 2008
; Modified to remove deprecated procedures as listed:
;     gimp-flip  ==>  gimp-drawable-transform-flip-simple
; added extra parameters
; also flushed before undo-end
;==============================================================
(define (draw-line layer x-from y-from x-to y-to) 
  (let* (
          (points (cons-array 4 'double))
        )
        (aset points 0 x-from)
        (aset points 1 y-from)
        (aset points 2 x-to  )
        (aset points 3 y-to  )

        (gimp-pencil layer 4 points)
  )
)

(define (210-water-reflection
         theImage
         theLayer
         userFade
		 rateBlue
		 wavy
        )
  (let* (
    (work-image 0)
    (new-layer 0)
	(map-layer 0)
	(mirrored-layer 0)
	(image)
	(i 0)
	(RGBImage)
	(num_layers 0)
	(layer_ids)
	(current_layer)
	(ripple-layer 0)
	(theDisplay)
	(mask)
	(red-component 0)
	(green-component 1)
	(blue-component 2)
	(alpha-component 5)
    )
	
    (define originalWidth (car (gimp-image-width theImage)))
    (define originalHeight (car (gimp-image-height theImage)))
	
    (gimp-image-undo-group-start theImage)
	(if (not (= RGB (car (gimp-image-base-type theImage))))
			 (gimp-image-convert-rgb theImage))
;      (gimp-selection-all theImage)
    (gimp-selection-none theImage)
    (set! theLayer (car(gimp-image-merge-visible-layers theImage 0)))

	(gimp-context-set-background '(255 255 255))
	(gimp-context-set-foreground '(0 0 0))
	
    ;preserve original settings
    (define old-bg   (car (gimp-context-get-background)))
    (define old-fg   (car (gimp-context-get-foreground)))
    (define old-grad (car (gimp-context-get-gradient)))
	
    ;calculate color for start of gradient fade
    (define fadeStart (* (- 100 userFade) 2.55))
    (define fadeColor (list fadeStart fadeStart fadeStart))

    (define reflectionScale 1)
    (define stackPos (car(gimp-image-get-item-position theImage theLayer)))
    (define newWidth originalWidth)
    (define newHeight (* originalHeight (+ reflectionScale 1)))
    (define gradX (/ originalWidth 2))
    (define gradY1 (* originalHeight reflectionScale))
    (define gradY2 (* originalHeight reflectionScale -1))
	
    (gimp-image-resize theImage originalWidth newHeight 0 0)
    (define new-layer (car (gimp-layer-copy theLayer 1)))
    (gimp-image-insert-layer theImage new-layer 0 (+ stackPos 0))
    (gimp-item-set-name new-layer "Reflection")
    (gimp-layer-set-offsets new-layer 0 originalHeight)
    (gimp-item-transform-flip-simple new-layer ORIENTATION-VERTICAL TRUE 0.0)
	
    (define new-mask (car (gimp-layer-create-mask new-layer 0)))
    (gimp-layer-add-mask new-layer new-mask)
    (gimp-context-set-foreground fadeColor)
    (gimp-edit-blend new-mask FG-TRANSPARENT-MODE LAYER-MODE-NORMAL-LEGACY
		   GRADIENT-LINEAR 100 0 REPEAT-NONE
		   FALSE
		   FALSE 0 0 TRUE
		   gradX originalHeight gradX gradY2)

	(gimp-layer-remove-mask new-layer MASK-APPLY)
	(gimp-image-set-active-layer theImage new-layer)
	
;	(plug-in-ripple RUN-NONINTERACTIVE theImage new-layer 32 2 1 0 0 TRUE TRUE)	
	
	(if (= wavy TRUE) (plug-in-ripple RUN-NONINTERACTIVE theImage new-layer 40 3 0 0 0 TRUE TRUE))
	
	(define mirrored-layer (car (gimp-image-merge-visible-layers theImage EXPAND-AS-NECESSARY)))
	(plug-in-autocrop RUN-NONINTERACTIVE theImage mirrored-layer)


;============ Now we work on the water layer...======================	
	
	(define image (car(gimp-image-new originalWidth originalHeight RGB)))
;	(set! image (car (gimp-image-new orig-width orig-height RGB)))
	(set! map-layer (car (gimp-layer-new  
						 image 
						 originalWidth
						 originalHeight
						 RGB-IMAGE
						 "Displacement map"
						 100
						 LAYER-MODE-NORMAL-LEGACY
						 )))	
	
	
; Add new layer
	(gimp-image-add-layer image map-layer 0)
	(set! theDisplay (car (gimp-display-new image)))
   
	(gimp-context-set-background '(255 255 255))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-fill map-layer BACKGROUND-FILL)
	(gimp-layer-set-lock-alpha map-layer TRUE)
	
	(while (< i 6)
		(plug-in-rgb-noise RUN-NONINTERACTIVE image map-layer 0 1 0.2 0.2 0.2 0)
		(set! i (+ i 1))
	)
	
	(plug-in-gauss-iir 1 image map-layer 5 TRUE TRUE)	
	
	(gimp-image-set-component-active image green-component FALSE)
	(gimp-image-set-component-active image blue-component FALSE)
	(plug-in-emboss 1 image map-layer 0 50.0 10 -5) ; horizontal
	
	(gimp-image-set-component-active image red-component FALSE)
	(gimp-image-set-component-active image green-component TRUE)
	(plug-in-emboss 1 image map-layer 90 50.0 10 -5) ; vertical

	(gimp-image-set-component-active image red-component FALSE)
	(gimp-image-set-component-active image green-component FALSE)
	(gimp-image-set-component-active image blue-component TRUE)
	(gimp-edit-bucket-fill-full map-layer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 255 FALSE TRUE SELECT-CRITERION-COMPOSITE 0 0)

	(gimp-image-set-component-active image red-component TRUE)
	(gimp-image-set-component-visible image red-component TRUE)
	(gimp-image-set-component-active image green-component TRUE)
	(gimp-image-set-component-visible image green-component TRUE)

	(set! i 1)		
	
	(while (<= i 2)
		(gimp-perspective map-layer TRUE 0 0 originalWidth 0 (- 0 originalWidth) (* originalHeight 4) (* originalWidth 2) (* originalHeight 4))
		(gimp-layer-scale map-layer (* originalWidth 3) originalHeight FALSE)
		
		(gimp-layer-scale map-layer (* originalWidth 3) (+ originalHeight 10) FALSE)
		(gimp-image-crop (car(gimp-drawable-get-image map-layer)) originalWidth originalHeight 0 0)
		
		(set! i (+ i 1))
	)	
	
	(gimp-drawable-transform-scale-default map-layer (- 0 originalWidth) 0 (* originalHeight 4) originalHeight TRUE TRUE)
	(gimp-image-crop (car(gimp-drawable-get-image map-layer)) originalWidth originalHeight 0 0)


	(set! mask (car (gimp-layer-create-mask map-layer ADD-WHITE-MASK)))
	(gimp-layer-add-mask map-layer mask)

	(gimp-edit-blend mask FG-BG-RGB-MODE LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE TRUE FALSE 1 0 TRUE 0 0 0 originalHeight)
	
	; mask to selection ( mask-to-selection ) :
	(gimp-selection-load mask)

	(gimp-image-set-component-active image red-component TRUE)
	(gimp-image-set-component-active image green-component FALSE)
	(gimp-image-set-component-active image blue-component FALSE)

	; fill with grey
	(gimp-context-set-foreground '(128 128 128))
	(gimp-edit-bucket-fill-full map-layer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 255 FALSE TRUE SELECT-CRITERION-COMPOSITE 0 0)

	(gimp-selection-none image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(gimp-edit-blend mask FG-BG-RGB-MODE LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE TRUE FALSE 1 0 TRUE 
		0 0 0 (round(* originalHeight 0.2)) )	

	; mask to selection ( mask-to-selection ) :
	(gimp-selection-load mask)

	(gimp-image-set-component-active image red-component FALSE)
	(gimp-image-set-component-active image green-component TRUE)
	(gimp-image-set-component-active image blue-component FALSE)

	; fill with grey
	(gimp-context-set-foreground '(128 128 128))
	(gimp-edit-bucket-fill-full map-layer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 255 FALSE TRUE SELECT-CRITERION-COMPOSITE 0 0)
	
	(gimp-layer-remove-mask map-layer MASK-DISCARD)
	(gimp-selection-none image)	

	(set! RGBImage (car (plug-in-decompose RUN-NONINTERACTIVE image map-layer "RGB" TRUE)))
	
	; since we decompose, we no loner need original map
	(gimp-display-delete theDisplay)
	
	; delete blue channel/layer
	(set! num_layers (car (gimp-image-get-layers RGBImage)))
	(set! layer_ids (cadr (gimp-image-get-layers RGBImage)))
	(set! i 0)

	(while (< i num_layers)
		(set! current_layer (vector-ref layer_ids i))
			(if (= i 0) ; red
;				(gimp-drawable-set-name current_layer "X")
				(gimp-image-remove-layer RGBImage current_layer)
				
		)
		(if (= i 1) ; green
			(gimp-drawable-set-name current_layer "Y")
		)
		(if (= i 2) ; blue
				(gimp-image-remove-layer RGBImage current_layer)
		)
		(set! i (+ i 1))
	)

	(gimp-edit-copy-visible RGBImage)
	(gimp-image-delete RGBImage)
	(gimp-edit-paste mirrored-layer FALSE)
	(gimp-floating-sel-to-layer (car (gimp-image-get-floating-sel theImage)))	
	(set! ripple-layer (car (gimp-image-get-layer-by-name theImage "Pasted Layer")))
	(gimp-layer-set-opacity ripple-layer 30)
	(gimp-layer-set-mode ripple-layer HARDLIGHT-MODE)
	(gimp-layer-translate ripple-layer 0 (/ originalHeight 2))

	(cond ((= rateBlue 1)
		 (gimp-context-set-background '(70 70 30))
		)
	((= rateBlue 2)
		  (gimp-context-set-background '(60 70 90))
		)
	((= rateBlue 3)
		  (gimp-context-set-background '(50 70 110))
		)
	((= rateBlue 4)
		  (gimp-context-set-background '(40 50 150))
		)
	((= rateBlue 5)
		  (gimp-context-set-background '(30 50 200))
		)
	)
	
	(gimp-image-flatten theImage)
	(define final-layer (car (gimp-image-get-active-layer theImage)))

	(gimp-image-select-rectangle theImage CHANNEL-OP-ADD 0 (- originalHeight 2) originalWidth 4)
	(plug-in-waves RUN-NONINTERACTIVE theImage final-layer 0.4 0.0 40 0 0)
	(gimp-selection-none theImage)

    ;restore original settings
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-context-set-gradient old-grad)
	
    (gimp-displays-flush)
    (gimp-image-undo-group-end theImage)
))

(script-fu-register "210-water-reflection"
	"Water Reflection"
	"Reflection -- extends lower section of an image as a reflection of the original image."
	"Original author Otavio Cordeiro, later edited by David Cummins and Paul Sherman"
	"Paul Sherman <psherman2001@gmail.com>"
	"Last updated Tuesday, 02/11/2014"
	"*"
	SF-IMAGE    "Image"    0
	SF-DRAWABLE "Drawable" 0
	SF-ADJUSTMENT "Reflection Fade Rate (%)" '(70 0 100 10 20 0 0)
	SF-ADJUSTMENT "Blue Amount on Water" '(2 1 5 1 1 0 0)
	SF-TOGGLE "Wavier Reflection"  FALSE
)
(script-fu-menu-register "210-water-reflection" "<Image>/Script-Fu/Effects")
