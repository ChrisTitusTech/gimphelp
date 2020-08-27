; 210_contrast_high-pass.scm
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
;high-pass.scm
; by Rob Antonishen
; http://ffaat.pointclark.net

; Version 1.2 (20120427)

; Description
;
; This implements a highpass filter using the blur and invert method
; parameters are blur radius, a preserve colour toggle, and whether to keep the original layer
;
; Changes:
; v1.1 fixes "bug" created by bug fix for gimp 2.6.9 in gimp-histogram
; v1.2 changed to a different layer blend mode (thanks Blacklemon67) that
;      has less histogram banding, by eliminating the need for the contrast boost.
;
;==============================================================


(define (210-highpass-image 
		img 
		inLayer 
		inRadius 
		inMode 
		flatten 
		overlay
	)

  (let*
    (
	  (blur-layer 0)
	  (blur-layer2 0)
	  (working-layer 0)
	  (colours-layer 0)
	  (colours-layer2 0)
	  (orig-name (car (gimp-drawable-get-name inLayer)))
    )

    (gimp-context-push)
    (gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))	

	(set! working-layer (car (gimp-layer-copy inLayer FALSE)))
	(gimp-image-add-layer img working-layer -1)
	(gimp-drawable-set-name working-layer "working")
	(gimp-image-set-active-layer img working-layer)


	(set! colours-layer (car (gimp-layer-copy inLayer FALSE)))
	(gimp-image-add-layer img colours-layer -1)
	(gimp-image-lower-layer img colours-layer)	
	(gimp-drawable-set-name colours-layer "colours")
	(gimp-image-set-active-layer img working-layer)
 
    ;if Greyscale, desaturate
	(if (or (= inMode 2) (= inMode 3))
	  (gimp-desaturate working-layer) 	
	)
	
	;Duplicate on top and blur
    (set! blur-layer (car (gimp-layer-copy working-layer FALSE)))
    (gimp-image-add-layer img blur-layer -1)
	(gimp-drawable-set-name blur-layer "blur")

	;blur
    (plug-in-gauss 1 img blur-layer inRadius inRadius 1) 	
	
	(if (<= inMode 3)
	  (begin
        ;v1.2 using grain extract...
        (gimp-layer-set-mode blur-layer GRAIN-EXTRACT-MODE)
	    (set! working-layer (car (gimp-image-merge-down img blur-layer 0)))
		
	    ; if preserve chroma, change set the mode to value and merge down with the layer we kept earlier.
	    (if (= inMode 3)
          (begin
            (gimp-layer-set-mode working-layer VALUE-MODE)
		    (set! working-layer (car (gimp-image-merge-down img working-layer 0)))
	      )
	    )   

	    ; if preserve DC, change set the mode to overlay and merge down with the average colour of the layer we kept earlier.
	    (if (= inMode 1)
          (begin	
	        (gimp-context-set-foreground (list 
                (car (gimp-histogram colours-layer HISTOGRAM-RED 0 255)) 
                (car (gimp-histogram colours-layer HISTOGRAM-GREEN 0 255)) 
                (car (gimp-histogram colours-layer HISTOGRAM-BLUE 0 255)))
            )
		    (gimp-drawable-fill colours-layer FOREGROUND-FILL)
            (gimp-layer-set-mode working-layer OVERLAY-MODE)
		    (set! working-layer (car (gimp-image-merge-down img working-layer 0)))
	      )
	    )   
	  )
	  (begin  ;else 4=redrobes method
	  
	    (gimp-image-set-active-layer img blur-layer)  ;top layer
		
		;get the average colour of the input layer
	    (set! colours-layer (car (gimp-layer-copy inLayer FALSE)))
	    (gimp-image-add-layer img colours-layer -1)
		(gimp-drawable-set-name colours-layer "colours")

	    (gimp-context-set-foreground (list 
            (car (gimp-histogram colours-layer HISTOGRAM-RED 0 255)) 
            (car (gimp-histogram colours-layer HISTOGRAM-GREEN 0 255)) 
            (car (gimp-histogram colours-layer HISTOGRAM-BLUE 0 255)))
        )
		(gimp-drawable-fill colours-layer FOREGROUND-FILL)
	    (gimp-image-set-active-layer img colours-layer)

        ;copy the solid colour layer
		(set! colours-layer2 (car (gimp-layer-copy colours-layer FALSE)))
        (gimp-image-add-layer img colours-layer2 -1)		
        (gimp-layer-set-mode colours-layer SUBTRACT-MODE)
	    (gimp-image-set-active-layer img colours-layer2)

		;copy the blurred layer
		(set! blur-layer2 (car (gimp-layer-copy blur-layer FALSE)))
        (gimp-image-add-layer img blur-layer2 -1)		
        (gimp-layer-set-mode blur-layer2 SUBTRACT-MODE)
		
		(set! blur-layer (car (gimp-image-merge-down img colours-layer 0)))
		(set! blur-layer2 (car (gimp-image-merge-down img blur-layer2 0)))
		
        (gimp-layer-set-mode blur-layer SUBTRACT-MODE)
        (gimp-layer-set-mode blur-layer2 ADDITION-MODE)
		
	    (set! working-layer (car (gimp-image-merge-down img blur-layer 0)))
	    (set! working-layer (car (gimp-image-merge-down img blur-layer2 0)))
	
	  )
	)
    (if (= overlay TRUE)
        (gimp-layer-set-mode working-layer OVERLAY-MODE)
    )
	(gimp-layer-set-opacity working-layer 96)
	(gimp-drawable-set-name working-layer "high pass")
	
	(if (= inMode 0)(gimp-image-remove-layer img (car (gimp-image-get-layer-by-name img "colours"))))
	(if (= inMode 2)(gimp-image-remove-layer img (car (gimp-image-get-layer-by-name img "colours"))))
	(if (= inMode 4)(gimp-image-remove-layer img (car (gimp-image-get-layer-by-name img "colours"))))
	
	
    (if (= flatten TRUE)
        (gimp-image-flatten img)
    )
	;done
	(gimp-progress-end)
	(gimp-image-undo-group-end img)
	(gimp-displays-flush)
	(gimp-context-pop)
  )
)

(script-fu-register 
	"210-highpass-image"
	"High Pass"
	"Basic High Pass Filter."
	"Rob Antonishen"
	"Rob Antonishen"
	"April 2012"
	"*"
	SF-IMAGE      "image"      			0
	SF-DRAWABLE   "drawable"   			0
	SF-ADJUSTMENT "Filter Radius" 		'(10 2 200 1 10 0 0)
	SF-OPTION     "Mode" 				'("Colour" "Preserve DC" "Greyscale" "Greyscale, Apply Chroma" "Redrobes")
	SF-TOGGLE     "Flatten image"    	TRUE
	SF-TOGGLE     "Overlay (sharpen)"   TRUE
)
(script-fu-menu-register "210-highpass-image" "<Image>/Script-Fu/Contrast")
