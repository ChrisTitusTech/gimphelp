; 210_photo_film-grain.scm
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
; edited 10/15/2010 to eliminate errors from non-RGB images
; edited 02/14/2014 - added "Make image Black and White" option
; and convert to RGB if needed, leave more grain in colors option

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
; Copyright (C) 2008 Samuel Albrecht <samuel_albrecht@web.de>
;
; Version 0.1 - Adding Film Grain after: http://www.gimpguru.org/Tutorials/FilmGrain/
;==============================================================


(define (210-film-grain aimg adraw holdness grainsize strength colorgrain blackwhite)
	(gimp-image-undo-group-start aimg)
	(if (not (= RGB (car (gimp-image-base-type aimg))))
			 (gimp-image-convert-rgb aimg))

  (let* ((img (car (gimp-item-get-image adraw)))
         (owidth (car (gimp-image-width img)))
         (oheight (car (gimp-image-height img)))
         (grainlayer (car (gimp-layer-new img
                                          owidth 
                                          oheight
                                          1
                                          "Grain" 
                                          100 
                                          OVERLAY-MODE)))
         (grainlayermask (car (gimp-layer-create-mask grainlayer ADD-WHITE-MASK)))
         (floatingsel 0)
		 (orig-layer 0)
         )
  		   
    ; init
    (define (set-pt a index x y)
      (begin
        (aset a (* index 2) x)
        (aset a (+ (* index 2) 1) y)
        )
      )
    (define (splineValue)
      (let* ((a (cons-array 6 'byte)))
        (set-pt a 0 0 0)
        (set-pt a 1 128 strength)
        (set-pt a 2 255 0)
        a
        )
      )
	  
    (set! orig-layer (car (gimp-image-get-active-layer aimg)))

    
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    
	
    ;optional b/w
    (if(= blackwhite TRUE)
       (begin
         (gimp-desaturate-full orig-layer DESATURATE-LIGHTNESS)
         )
       )
	
    ;fill new layer with neutral gray
    (gimp-image-insert-layer img grainlayer 0 -1)
    (gimp-drawable-fill grainlayer TRANSPARENT-FILL)
    (gimp-context-set-foreground '(128 128 128))
    (gimp-selection-all img)
    (gimp-edit-bucket-fill grainlayer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    (gimp-selection-none img)
    
    ;add grain and blur it
	(plug-in-hsv-noise RUN-NONINTERACTIVE img grainlayer holdness 0 0 grainsize)
    (plug-in-gauss 1 img grainlayer 1 1 1)
    (gimp-layer-add-mask grainlayer grainlayermask)
    
    ;select the original image, copy and paste it as a layer mask into the grain layer
    (gimp-selection-all img)
    (gimp-edit-copy adraw)
    (set! floatingsel (car (gimp-edit-paste grainlayermask TRUE)))
    (gimp-floating-sel-anchor floatingsel)
	;give the grain a little extra strength
	(plug-in-unsharp-mask RUN-NONINTERACTIVE img grainlayer 5.0 1.0 0.0)
    ;set color curves of layer mask, so that only gray areas become grainy
    (if (= colorgrain FALSE)(gimp-curves-spline grainlayermask  HISTOGRAM-VALUE  6 (splineValue)))
    
    ; tidy up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    )
  )

(script-fu-register "210-film-grain"
	"Film Grain"
	"Simulating Film Grain.\nby Samuel Albrecht\n\nNewest version can be downloaded from http://registry.gimp.org/node/8108"
	"Samuel Albrecht <samuel_albrecht@web.de>"
	"Samuel Albrecht"
	"13/08/08"
	"*"
	SF-IMAGE       "Input image"          			0
	SF-DRAWABLE    "Input drawable"       			0
	SF-ADJUSTMENT  "Holdness" 						'(2 1 8 1 2 0 0)
	SF-ADJUSTMENT  "Value" 							'(100 0 255 1 10 0 0)
	SF-ADJUSTMENT  "Strength" 						'(128 0 255 1 10 0 0)
	SF-TOGGLE      "Include more grain in colors" 	FALSE
	SF-TOGGLE      "Make image all Black and White" FALSE
)
(script-fu-menu-register "210-film-grain" "<Image>/Script-Fu/Photo")
