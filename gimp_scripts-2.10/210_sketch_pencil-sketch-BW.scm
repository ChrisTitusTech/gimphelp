; 210_sketch_pencil-sketch-BW.scm
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
; ALSO PUT:
; Pencil-Sketch.pat
;
;	Windows Vista/7
;	C:\Program Files\GIMP 2\share\gimp\2.0\patterns
;	or
;	C:\Users\YOUR-NAME\.gimp-2.8\patterns
;	
;	Windows XP
;	C:\Program Files\GIMP 2\share\gimp\2.0\patterns
;	or
;	C:\Documents and Settings\yourname\.gimp-2.8\patterns  
;    
;	Linux
;	/home/yourname/.gimp-2.8/patterns
;	or
;	Linux - system-wide
;	/usr/share/gimp/2.0/patterns
;==============================================================
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
; based on....
; pencil-sketch.scm
; Jeff Trefftzs <trefftzs@tcsn.net>
;
; but with a custom pattern and very specific, altered settings
;==============================================================


(define (210-pencil-sketch-BW 
		inImage 
		inLayer
		inMerge
	)
	
	(gimp-image-undo-group-start inImage)
	(define indexed (car (gimp-drawable-is-indexed inLayer)))
	(if (= indexed TRUE)(gimp-image-convert-rgb inImage))	
	
  (let*
      (
       (WhiteLayer (car (gimp-layer-copy inLayer TRUE)))
       (MaskedLayer (car (gimp-layer-copy inLayer TRUE)))
       (EdgeLayer (car (gimp-layer-copy inLayer TRUE)))
       (LayerMask (car (gimp-layer-create-mask MaskedLayer 0)))
       )
    
    (gimp-image-insert-layer inImage WhiteLayer 0 -1)
    (gimp-image-insert-layer inImage MaskedLayer 0 -1)
    (gimp-image-insert-layer inImage EdgeLayer 0 -1)

    (gimp-item-set-name WhiteLayer "Paper Layer")
    (gimp-item-set-name MaskedLayer "Copy with layer mask")
    (gimp-item-set-name EdgeLayer "Edges from original image")

    ; Real work goes in here
    (gimp-drawable-fill WhiteLayer WHITE-FILL) ; Fill the white layer
	
    ; Create the layer mask and put the paper pattern in it.
    (gimp-layer-add-mask MaskedLayer LayerMask)
    (gimp-context-set-pattern "Pencil-Sketch")
    (gimp-edit-bucket-fill LayerMask PATTERN-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY
		      100		; opacity
		      0			; threshold
		      FALSE		; no sample-merged
		      0 0)		; X, Y coords
    (gimp-image-unset-active-channel inImage) ; finished with it
    
    ; Now find the edges
    (gimp-image-set-active-layer inImage EdgeLayer)

   (define tmplayer (car (gimp-layer-copy EdgeLayer TRUE)))
   (gimp-image-insert-layer inImage tmplayer 0 -1)
   (gimp-layer-set-mode tmplayer DIVIDE-MODE)
   (plug-in-gauss-iir TRUE inImage tmplayer 14 TRUE TRUE)
   (set! EdgeLayer 
	 (car (gimp-image-merge-down inImage tmplayer
					 EXPAND-AS-NECESSARY)))
   (gimp-levels EdgeLayer HISTOGRAM-VALUE
		210 ; low input
		255	; high input
		1.6	; gamma
		30 255)
	   
    (gimp-layer-set-mode EdgeLayer DARKEN-ONLY-MODE) ; in case white bg
	
	;(gimp-desaturate-full EdgeLayer DESATURATE-LUMINOSITY)
    (gimp-image-set-active-layer inImage inLayer)
    ); end let
	;(gimp-desaturate-full inLayer DESATURATE-LUMINOSITY)
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers inImage EXPAND-AS-NECESSARY))
	(if (not (= GRAY (car (gimp-image-base-type inImage))))
		 (gimp-image-convert-grayscale inImage))
    (gimp-image-undo-group-end inImage)
    (gimp-displays-flush)
  )

(script-fu-register "210-pencil-sketch-BW"
	"Pencil Sketch BW"
	"Creates an black and white pencil sketch of an image."
	"Paul Sherman"
	"psherman2001@gmail.com"
	"Tuesday, 02/18/2014"
	"*"
	SF-IMAGE 		"The Image" 								0
	SF-DRAWABLE 	"The Layer" 								0
	SF-TOGGLE     	"Merge layers when complete?" 				TRUE
)
(script-fu-menu-register "210-pencil-sketch-BW" "<Image>/Script-Fu/Sketch")
