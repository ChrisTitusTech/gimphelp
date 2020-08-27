; 210_edges_photoframe.scm
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
; Edited on 12/01/2007 by Paul Sherman to fix UNDO functionality 
; when NOT working on a copy. Menu location also changed.
; tested on GIMP-2.4.1
; udated again for gimp-2.6 by Paul - 11/20/2008
; 12/15/2008 - 
; pulled use with alpha layer until I get it to behave - PS
; 10/15/2010 - fixed undo glitch that left stray "select all" if undone.

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
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; Photo Frame script  for GIMP 2.4
; Original author: Alexios Chouchoulas
;
; Author statement:
; This is a rather simple script to produce a photographic frame
; around an image. This resembles a simplistic full-frame print: a
; thin black frame outlines the photograph itself, with thicker white
; borders around frame and picture. The colours and thicknesses are,
; of course, customisable.
;
; Written on top of Chris Gutteridge's (cjg@ecs.soton.ac.uk) Fuzzy
; Border script (which was only used as a template, but there you go).
;
; --------------------------------------------------------------------

;


(define (alexios-draw-frame inImage inFrameWidth inColour inLayerName)
  (let* (
          (theWidth 0)
          (theHeight 0)
          (theLayer 0)
        )
  (set! theWidth (car (gimp-image-width inImage)))
  (set! theHeight (car (gimp-image-height inImage)))
  
  (gimp-image-resize inImage
		     (+ theWidth (* inFrameWidth 2))
		     (+ theHeight (* inFrameWidth 2))
		     inFrameWidth
		     inFrameWidth)

  (gimp-selection-all inImage)
  (set! theWidth (car (gimp-image-width inImage)))
  (set! theHeight (car (gimp-image-height inImage)))
  
  (set! theLayer (car (gimp-layer-new 	inImage
					theWidth
					theHeight
					RGBA-IMAGE
					inLayerName
					100
					LAYER-MODE-NORMAL-LEGACY)))

  (gimp-image-insert-layer inImage theLayer 0 0)
  (gimp-context-set-background inColour)
  (gimp-edit-clear theLayer)
  (gimp-edit-fill theLayer FILL-BACKGROUND)
  (gimp-image-lower-item-to-bottom inImage theLayer) 
  )
)


(define (210-photo-frame
				inImage
				inLayer
				inFrameColour
				inFrameWidth
				inPaddingColour
				inPaddingWidth
				inCopy
        		inFlatten
	)
  (let* (
          (theImage 0)
          (theWidth 0)
          (theHeight 0)
          (mode 0)
        )
		
		(gimp-image-undo-group-start inImage)
		
    	(gimp-selection-all inImage)
    	(set! theImage (if (= inCopy TRUE)
    		       (car (gimp-image-duplicate inImage))
                           inImage)
            )

    	(if (< 0 (car (gimp-image-base-type theImage))) (gimp-image-convert-rgb theImage))
    	(set! mode 'RGBA-IMAGE)
        (set! theWidth (car (gimp-image-width theImage)))
    	(set! theHeight (car (gimp-image-height theImage)))
    
    	; Add an alpha channel to the bottom layer.
    	(let* (
    	       (layers (gimp-image-get-layers theImage))
    	       (num-layers (car layers))
    	       (layer-array (cadr layers)))
    	  (gimp-layer-add-alpha (aref layer-array (- num-layers 1))))
    
    	; Draw the frame.
    	(alexios-draw-frame theImage inFrameWidth inFrameColour "Frame" mode)
    
    	; Draw the padding.
    	(alexios-draw-frame theImage inPaddingWidth inPaddingColour "Padding" mode)
    
    	; Flatten the image, if we need to.
    	(if (= inFlatten TRUE) (gimp-image-flatten theImage) ())
    
    	; Have we been working on a copy? If so display the new image.
    	(if (= inCopy TRUE)
    	    (begin
    	      (gimp-image-clean-all theImage)
    	      (gimp-display-new theImage)
    	      )
    	    ()
    	)
    
        (gimp-image-undo-group-end inImage)
    	(gimp-displays-flush)
	)
)

; Register the function with the GIMP:

(script-fu-register "210-photo-frame"
	"Photo Frame"
	"Frame a photograph"
	"Alexios Chouchoulas"
	"2003, Alexios Chouchoulas"
	"20th September 2003"
	"RGB GRAY INDEXED"
	SF-IMAGE       "The Image"      0
	SF-DRAWABLE    "The Layer"      0
	SF-COLOR       "Frame color"   '(0 0 0)
	SF-ADJUSTMENT  "Frame width"   '(3 1 300 1 10 0 1)
	SF-COLOR       "Padding color" '(255 255 255)
	SF-ADJUSTMENT  "Padding width" '(10 1 300 1 10 0 1)
	SF-TOGGLE      "Work on Copy"  TRUE
	SF-TOGGLE      "Flatten Image" TRUE
)
(script-fu-menu-register "210-photo-frame" "<Image>/Script-Fu/Edges")
