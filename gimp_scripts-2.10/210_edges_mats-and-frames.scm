; 210_edges_mats-and-frames.scm
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
; Copyright (C) 2003 Eric Jeschke (eric@redskiesatnight.com)
; Based on code by
; Copyright (C) 1997 Andy Thomas (alt@picnic.demon.co.uk)
; and
; Copyright (C) 1997 Andrew Donkin  (ard@cs.waikato.ac.nz)
;
;==============================================================

; gimp-scheme should add this...it's a scheme "standard"
(define (cadddr l) (caddr (cdr l)))

; ditto
; non-functional mapper (discards values, used for effect).
(define (for-each proc l)
  (if (not (null? l))
      (begin
        (proc (car l))
        (for-each proc (cdr l)))))

; Create an array from a list.
(define (list-to-array contents)
  (let* ((alen (length contents))
         (n_array (cons-array alen 'double))
         (count 0))
    (for-each (lambda (val)
                (aset n_array count val)
                (set! count (+ count 1)))
              contents)
    n_array))

; Takes a color (represented as a list of numbers: (R G B)) and a delta
; value and returns four new colors representing the left, top, right and
; bottom shades.  Used for coloring the mat bevel.
;
; returns (LC TC RC BC)
(define (getcolors color delta)
  (letrec ((deltacolor (lambda (v d) (max (min (+ v d) 255) 0)))
           (adjcolor (lambda (cl d)
                       (mapcar (lambda (v) (deltacolor v d)) cl)))
           )
    (list
     (adjcolor color (- 0 (/ delta 2)))   ; left color
     (adjcolor color (- 0 delta))         ; top color
     (adjcolor color (/ delta 2))         ; right color
     (adjcolor color delta)               ; bottom color
     )
    ))

; utility routine to decipher color choice option and return the
; appropriate fill: from dialog color picker, current fg, or current bg.
(define (get-color fillchoice colorchoice)
    (cond
     ((= fillchoice 0) colorchoice)
     ((= fillchoice 1) (car (gimp-context-get-foreground)))
     (TRUE (car (gimp-context-get-background))) ))

; Draw a border around an image.
;
; This is the workhorse function.  Draws a constant width border around
; an image with optional padding on each of the 4 sides.  If 'delta' > 0
; then each side will be colored so that it resembles a bevel (unless
; the fillchoice is a pattern).
(define (draw-border drawable
		 borderwidth
		 lpad tpad rpad bpad   ; # pixels to pad on L, T, R, B
		 fillchoice            ; type of fill
		 fillcolor delta       ; fill parameters
		 bumppattern           ; "texture" pattern
		 leavebumpmap          ; flag: TRUE-->preserve bumpmap
		 ibumpp                ; flag: TRUE-->bump interactively
		 layername             ; border is drawn on a new layer
		 leaveselectionp       ; if true, border becomes selection
		 )
  (let* ((img (car (gimp-item-get-image drawable)))
         (imgtype (car (gimp-drawable-type-with-alpha drawable)))
         (owidth (car (gimp-image-width img)))      ; current image w & h
         (oheight (car (gimp-image-height img)))
         (old-fg (car (gimp-context-get-foreground)))
         (old-bg (car (gimp-context-get-background)))
         ; calculate new dimensions
         (width (+ owidth (* 2 borderwidth) lpad rpad))
         (height (+ oheight (* 2 borderwidth) tpad bpad))
         ; calculate coordinates for filling
         (ulimage_x (+ borderwidth lpad))
         (ulimage_y (+ borderwidth tpad))
         (llimage_x ulimage_x)
         (llimage_y (+ ulimage_y oheight))
         (lrimage_x (+ llimage_x owidth))
         (lrimage_y llimage_y)
         (urimage_x lrimage_x)
         (urimage_y ulimage_y)
         (ulborder_x lpad)
         (ulborder_y tpad)
         (llborder_x ulborder_x)
         (llborder_y (+ llimage_y borderwidth))
         (lrborder_x (+ lrimage_x borderwidth))
         (lrborder_y (+ lrimage_y borderwidth))
         (urborder_x lrborder_x)
         (urborder_y ulborder_y)
         ; get colors for each side (returns LC TC RC BC)
         (filltype BG-BUCKET-FILL)
         (color (get-color fillchoice fillcolor))
         (colors (getcolors color delta))
         ; create a new layer above current one
         (layer (car (gimp-layer-new img width height imgtype layername
                                     100 LAYER-MODE-NORMAL-LEGACY)))
         (ibumpflag (if (= ibumpp TRUE) 0 1))
         )

    ; fill with transparent pixels and resize to new dimensions
    (gimp-drawable-fill layer 3)
    (gimp-image-resize img width height ulimage_x ulimage_y)

    ; add the layer
    (gimp-image-insert-layer img layer 0 0)

    ; set up for pattern fill if that was requested
    (if (> fillchoice 2)
        (set! filltype PATTERN-BUCKET-FILL))
    
    ; color the left polygon
    (gimp-context-set-background (car colors))
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE
		      10
              (list-to-array (list ulborder_x ulborder_y ulimage_x ulimage_y
                               llimage_x llimage_y llborder_x llborder_y
                               ulborder_x ulborder_y)))
							   
    (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

    ; color the left pad
    (if (> lpad 0)
        (begin
          (gimp-context-set-background color)
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list 0 ulborder_y ulborder_x ulborder_y llborder_x
                               llborder_y 0 llborder_y 0 ulborder_y)))
							   
          (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
          ))

    ; color the top polygon
    (gimp-context-set-background (cadr colors))
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list ulborder_x ulborder_y ulimage_x ulimage_y
                               urimage_x urimage_y urborder_x urborder_y
                               ulborder_x ulborder_y)))
							   
    (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

    ; color the top pad
    (if (> tpad 0)
        (begin
          (gimp-context-set-background color)
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list 0 0 0 ulborder_y width urborder_y width 0 0 0)))
			  
          (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
          ))

    ; color the right polygon
    (gimp-context-set-background (caddr colors))
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list urborder_x urborder_y urimage_x urimage_y
                               lrimage_x lrimage_y lrborder_x lrborder_y
                               urborder_x urborder_y)))
							   
    (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

    ; color the right pad
    (if (> rpad 0)
        (begin
          (gimp-context-set-background color)
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list width urborder_y urborder_x urborder_y
                               lrborder_x lrborder_y width lrborder_y
                               width urborder_y)))
							   
          (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
          ))

    ; color the bottom polygon
    (gimp-context-set-background (cadddr colors))
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list llborder_x llborder_y llimage_x llimage_y
                               lrimage_x lrimage_y lrborder_x lrborder_y
                               llborder_x llborder_y)))
							   
    (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

    ; color the bottom pad
    (if (> bpad 0)
        (begin
          (gimp-context-set-background color)
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list 0 height 0 llborder_y width lrborder_y
                               width height 0 height)))
							   
          (gimp-edit-bucket-fill layer filltype LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
          ))

    ; if user wanted to texture the border, do a bump map
    (if (not (null? bumppattern))
        (let* ((old-pattern (car (gimp-patterns-get-pattern)))
               (bumpmap (car (gimp-layer-new img width height imgtype
                                             "Texture Bump Map" 100 LAYER-MODE-NORMAL-LEGACY)))
               )
          (gimp-image-insert-layer img bumpmap 0 0)
          (gimp-patterns-set-pattern bumppattern)
          ; NOTE: if we try to do a bump map on only the selection we get
          ; wierd artifacts around the edges; as a kludge, we turn on
          ; "preserve transparency" and bump map the entire thing.  It might
          ; also be possible to just grow the selection, but I haven't tried
          ; that yet.
          (gimp-layer-set-preserve-trans layer 1)
          (gimp-selection-all img)
          (gimp-edit-bucket-fill bumpmap PATTERN-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100
                            0 FALSE 0 0)
          (gimp-patterns-set-pattern old-pattern)
          (plug-in-bump-map ibumpflag img layer bumpmap 125 45 3 0 0 0 0
                            TRUE FALSE 1)
          (if (= leavebumpmap TRUE)
              (gimp-item-set-visible bumpmap 0)
              (gimp-image-remove-layer img bumpmap)
              )
          (gimp-layer-set-preserve-trans layer 0)
      ))

    ; clear selection
    (gimp-selection-none img)

    ; set selection to border if desired
    (if (= leaveselectionp TRUE)
        (begin
    (gimp-image-select-polygon img CHANNEL-OP-REPLACE 10
              (list-to-array (list ulimage_x ulimage_y urimage_x urimage_y
                               lrimage_x lrimage_y llimage_x llimage_y
                               ulimage_x ulimage_y)))
							   
          (gimp-selection-invert img)
          ))

    ; clean-up
    (gimp-context-set-background old-bg)

    ; return value
    (list layer)
  );end let*
)

; Script to add a mat around an image.
;
(define (210-add-mat image drawable
         bevelwidth           ; mat bevel width in pixels
         bevelfillchoice      ; {0 (Choose) | 1 (FG color) | 2 (BG color)}
         bevelcolorchoice     ; (Choose) color from color selection dialog
         delta                ; amount to vary fill to create bevel effect
         matwidth
         matfillchoice        ; as above, but for the mat
         matcolorchoice
         texturep             ; flag: TRUE-->bump map the mat
         mattexture           ; pattern for bump mapping mat
         leavebumpmapp        ; flag: TRUE-->preserve bump map
         ibumpp               ; flag: TRUE-->bump interactively
         lpad                 ; amount to pad the mat on the left
         tpad                 ; top
         rpad                 ; right
         bpad                 ; bottom
         layersp              ; flag: TRUE-->preserve new layers
         leaveselectionp      ; flag: TRUE-->mat is selected on exit
         )
		 
    (gimp-image-undo-group-start image)
	(if (not (= RGB (car (gimp-image-base-type image))))
			 (gimp-image-convert-rgb image))	
	
  (let* ((img (car (gimp-item-get-image drawable)))
         (pattern (if (= texturep TRUE) mattexture '()))
         )

    ; draw bevel
    (if (> bevelwidth 0)
        (draw-border drawable bevelwidth 0 0 0 0 bevelfillchoice
                    bevelcolorchoice delta '() FALSE FALSE "Mat Bevel" FALSE)
        )

    ; draw mat
    (if (> matwidth 0)
        (draw-border drawable matwidth lpad tpad rpad bpad
                    matfillchoice matcolorchoice 0 pattern leavebumpmapp
                    ibumpp "Mat" leaveselectionp)
        )

    ; merge layers if user did not want them
    (if (= layersp FALSE)
        (begin
          (if (> matwidth 0)
              (let ((layer (car (gimp-image-get-active-layer img))))
                (gimp-image-merge-down img layer EXPAND-AS-NECESSARY) ))
          (if (> bevelwidth 0)
              (let ((layer (car (gimp-image-get-active-layer img))))
                (gimp-image-merge-down img layer EXPAND-AS-NECESSARY) ))
          ))

    ; th-th-th-that's all folks!
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    )
)


; Script to add a frame around an image.
;
(define (210-add-frame image drawable
         framewidth
         framefillchoice      ; as above, but for the mat
         framecolorchoice
         texturep             ; flag: TRUE-->bump map the mat
         frametexture         ; pattern for bump mapping mat
         leavebumpmapp        ; flag: TRUE-->preserve texture bump map
         ibumpp               ; flag: TRUE-->bump interactively
         bevelindex           ; "depth" of 3D effect
         ds-width             ; inner shadow width
         ds-opacity           ; inner shadow opacity
         layersp              ; flag: TRUE-->preserve new layers
         leaveselectionp      ; flag: TRUE-->mat is selected on exit
         leavebevelbumpmapp   ; flag: TRUE-->preserve bevel bump map
         )
		 
    (gimp-image-undo-group-start image)
	(if (not (= RGB (car (gimp-image-base-type image))))
			 (gimp-image-convert-rgb image))	
			 
  (let* ((img (car (gimp-item-get-image drawable)))
         (imgtype (car (gimp-drawable-type-with-alpha drawable)))
         (pattern (if (= texturep TRUE) frametexture '()))
         )

    ; parameter sanity checks
    (if (<= framewidth 0)
        (set! framewidth 10))
    (if (> bevelindex (/ framewidth 2))
        (set! bevelindex (/ framewidth 2)))

    ; draw border
    (let* ((frame (car (draw-border drawable framewidth 0 0 0 0
                                    framefillchoice framecolorchoice 0
                                    pattern leavebumpmapp ibumpp "Frame"
                                    TRUE)))
           (selection (car (gimp-selection-save img)))
           (width (car (gimp-image-width img)))      ; current image w & h
           (height (car (gimp-image-height img)))
           (old-bg (car (gimp-context-get-background)))
           (bumpmap (car (gimp-layer-new img width height imgtype
                                         "Frame Bevel Bump Map" 100 LAYER-MODE-NORMAL-LEGACY)))
           (index 1)
           )
      
      ; Initialise our bumpmap
      (gimp-image-insert-layer img bumpmap 0 0)
      (gimp-item-set-visible bumpmap 0)
      (gimp-context-set-background '(0 0 0))
      (gimp-drawable-fill bumpmap FILL-BACKGROUND)
      (gimp-image-select-item img CHANNEL-OP-REPLACE selection)

      ; Fill with a gradient of sorts
      ; TODO: there has got to be a more efficient way to do this
      ; (gradient fills?)
      (while (< index bevelindex)
             (let ((gv (/ (* index 255) bevelindex)))
               (begin
                 (gimp-context-set-background (list gv gv gv))
                 (gimp-edit-bucket-fill bumpmap BUCKET-FILL-BG LAYER-MODE-NORMAL-LEGACY 100 0
                                   FALSE 0 0)
                 (gimp-selection-shrink img 1)
                 (set! index (+ index 1))
                 )))
      
      ; Now the white interior of the bumpmap
      (gimp-context-set-background '(255 255 255))
      (gimp-edit-bucket-fill bumpmap BUCKET-FILL-BG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)

      ; Do the bump map.
      (gimp-selection-none img)
      (plug-in-bump-map 1 img frame bumpmap 125 45 3 0 0 0 0 TRUE FALSE 1)

      ; remove bump map if user did not want it
      (if (= leavebevelbumpmapp FALSE)
          (gimp-image-remove-layer img bumpmap)
          )

      ; Now for the inner shadow
      (if (> ds-width 0)
          (let* ((ds-color '(0 0 0))
                 ; create the shadow layer
                 (shadow (car (gimp-layer-new img width height imgtype
                                              "Shadow" ds-opacity LAYER-MODE-NORMAL-LEGACY)))
                 )
            (gimp-image-insert-layer img shadow 0 0)
            (gimp-selection-none img)
            (gimp-edit-clear shadow)
            (gimp-context-set-background ds-color)
            (gimp-image-select-item img CHANNEL-OP-REPLACE selection)
            (gimp-selection-feather img ds-width)
            (gimp-edit-fill shadow FILL-BACKGROUND)
            (gimp-image-select-item img CHANNEL-OP-REPLACE selection)
            (gimp-edit-clear shadow)
            ))

      ; merge layers if user did not want them
      (if (= layersp FALSE)
          (begin
            ;(gimp-image-set-active-layer img frame)
            ;(gimp-image-merge-down img frame EXPAND-AS-NECESSARY)
            (gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY)
            ))

      ; leave the selection if the user requested it
      (if (= leaveselectionp TRUE)
          (gimp-image-select-item img CHANNEL-OP-REPLACE selection)
          (gimp-selection-none img)
          )

      ; clean up
      (gimp-image-remove-channel img selection)
      (gimp-context-set-background old-bg)

     );end let*

    ; th-th-th-that's all folks!
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    )
)

; Obligatory script registrations...

(script-fu-register "210-add-mat"
		    "Add Matte"
		    "Add a single mat around an image"
		    "Eric Jeschke <eric@redskiesatnight.com>"
		    "Eric Jeschke"
		    "5/27/03"
		    "*"
		    SF-IMAGE 		"Input Image" 					0
		    SF-DRAWABLE 	"Input Drawable" 				0
		    SF-ADJUSTMENT 	"Bevel Width" 					'(5 0 250 1 10 0 1)
            SF-OPTION 		"Bevel Fill" 					'("Color" "FG color" "BG color" "Pattern")
            SF-COLOR 		"Bevel Fill Color" 				'(221 221 221)
		    SF-ADJUSTMENT 	"Delta Value on Bevel Color" 	'(25 1 255 1 10 0 1)
		    SF-ADJUSTMENT 	"Mat Width" 					'(35 0 1000 1 10 0 1)
            SF-OPTION 		"Mat Fill" 						'(_"Color" "FG color" "BG color" "Pattern")
            SF-COLOR 		"Mat Fill Color" 				'(128 128 128)
            SF-TOGGLE  		"Texture Mat" 					FALSE
            SF-PATTERN 		"Texture Pattern" 				"Wood"
            SF-TOGGLE  		"Leave Texture Bump Map" 		FALSE
            SF-TOGGLE  		"Bump Interactively" 			FALSE
		    SF-ADJUSTMENT 	"Left Pad" 						'(0 0 1000 1 10 0 1)
		    SF-ADJUSTMENT 	"Top Pad" 						'(0 0 1000 1 10 0 1)
		    SF-ADJUSTMENT 	"Right Pad" 					'(0 0 1000 1 10 0 1)
		    SF-ADJUSTMENT 	"Bottom Pad" 					'(0 0 1000 1 10 0 1)
            SF-TOGGLE  		"Use Layers" 					FALSE
            SF-TOGGLE  		"Leave Selection" 				FALSE
		)
(script-fu-menu-register "210-add-mat" "<Image>/Script-Fu/Edges")

(script-fu-register "210-add-frame"
		    "Frame with Bevel"
		    "Add a frame around an image, ability to adjust bevel and shadow"
		    "Eric Jeschke <eric@redskiesatnight.com>"
		    "Eric Jeschke"
		    "5/27/03"
		    "*"
		    SF-IMAGE 		"Input Image" 					0
		    SF-DRAWABLE 	"Input Drawable" 				0
		    SF-ADJUSTMENT 	"Frame Width" 					'(35 0 1000 1 10 0 1)
            SF-OPTION 		"Frame Fill" 					'("Color" "FG color" "BG color" "Pattern")
            SF-COLOR 		"Frame Fill Color" 				'(128 128 128)
            SF-TOGGLE  		"Texture Frame" 				FALSE
            SF-PATTERN 		"Texture Pattern" 				"Wood"
            SF-TOGGLE  		"Leave Texture Bump Map" 		FALSE
            SF-TOGGLE  		"Bump Interactively" 			FALSE
		    SF-ADJUSTMENT 	"Beveling Index" 				'(10 0 250 1 10 0 1)
		    SF-ADJUSTMENT 	"Inner Shadow Width" 			'(8 0 100 1 10 0 1)
		    SF-ADJUSTMENT 	"Inner Shadow Opacity" 			'(50 0 100 1 10 0 1)
            SF-TOGGLE  		"Use Layers" 					FALSE
            SF-TOGGLE  		"Leave Selection" 				FALSE
            SF-TOGGLE  		"Leave Bevel Bump Map" 			FALSE
		)
(script-fu-menu-register "210-add-frame" "<Image>/Script-Fu/Edges")
