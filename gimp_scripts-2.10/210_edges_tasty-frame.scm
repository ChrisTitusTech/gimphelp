; 210_edges_tasty-frame.scm
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
; NOT AVAILABLE
;==============================================================

(define (210-tasty-frame 
			img
        	drawable
        	radius
        	blur
        	color
        	border
        	colorborder
        	colorbackground
        	title
        	colorletters
        	tit
			titf
			signat
        	sig
			sigf
        	font)

    (gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (let* ((blur (abs blur))
         (radius (abs radius))
         (diam (* 2 radius))
         (width (car (gimp-image-width img)))
         (height (car (gimp-image-height img)))
         (type (car (gimp-drawable-type-with-alpha drawable)))
         (image img)
         (main-layer (car (gimp-image-get-active-drawable image)))
        )

    ; Add an alpha channel to the image
    (gimp-layer-add-alpha main-layer)

    (gimp-selection-none image)
    (gimp-image-select-rectangle image CHANNEL-OP-ADD 0 0 radius radius)
    (gimp-image-select-ellipse image CHANNEL-OP-SUBTRACT 0 0 diam diam)
    (gimp-image-select-rectangle image CHANNEL-OP-ADD (- width radius) 0 radius radius)
    (gimp-image-select-ellipse image CHANNEL-OP-SUBTRACT (- width diam) 0 diam diam)
    (gimp-image-select-rectangle image CHANNEL-OP-ADD 0 (- height radius) radius radius)
    (gimp-image-select-ellipse image CHANNEL-OP-SUBTRACT 0 (- height diam) diam diam)
    (gimp-image-select-rectangle image CHANNEL-OP-ADD (- width radius) (- height radius) radius radius)
    (gimp-image-select-ellipse image CHANNEL-OP-SUBTRACT (- width diam) (- height diam) diam diam)
    (gimp-edit-clear main-layer)
    (gimp-selection-none image)

    (gimp-context-set-background color)
    (set!  width (+ (car (gimp-image-width  image)) blur blur))
    (set! height (+ (car (gimp-image-height image)) blur blur))
    (gimp-image-resize image width height blur blur)
    (let*
      ((shadow-layer (car (gimp-layer-new image width height type "Shadow" 100 LAYER-MODE-NORMAL-LEGACY))))
      (gimp-image-insert-layer image shadow-layer 0 -1)
      (gimp-edit-clear shadow-layer)
      (gimp-image-select-item image CHANNEL-OP-REPLACE main-layer)
      (gimp-edit-fill shadow-layer BACKGROUND-FILL)
      (gimp-selection-none image)
      (plug-in-gauss-rle2 1 image shadow-layer blur blur)
      ; This mask is to change the color of the shadow afterwards
      (gimp-layer-add-mask shadow-layer (car (gimp-layer-create-mask shadow-layer ADD-ALPHA-TRANSFER-MASK)))
    )

    (if (and (= signat TRUE)(> (string-length sig) 0)) (set! height (+ height 18)))
    
    (if (and (= title TRUE)(> (string-length tit) 0)) (set! height (+ height 32)))
    

    (gimp-image-resize image width height 0 0)
    (gimp-context-set-background colorbackground)

    (let*
      ((bg-layer (car (gimp-layer-new image width height type "Background" 100 LAYER-MODE-NORMAL-LEGACY))))
      (gimp-drawable-fill bg-layer BACKGROUND-FILL)
      (gimp-image-insert-layer image bg-layer 0 -1)
      (gimp-image-raise-item image main-layer)
      (gimp-image-lower-item image bg-layer)
      (gimp-image-lower-item image bg-layer)
    )

    (gimp-context-set-foreground colorletters)
    
    (if (and (= title TRUE) (> (string-length tit) 0))
      (let* (
          ; Title
          (title-layer (car (gimp-text-fontname image -1 0 0 tit 0 TRUE titf PIXELS font)))
          (tw (car (gimp-drawable-width title-layer)))
          (th (car (gimp-drawable-height title-layer)))
        )
        (gimp-layer-set-offsets title-layer (+ border blur) (- height (+ th border)))
        (gimp-context-set-foreground '(255 255 255))
      )
    )

    (if (and (= signat TRUE) (> (string-length sig) 0))
      (let* (
          ; Signature
	  ;(if (> (string-length sig) 0)
          (signature-layer (car (gimp-text-fontname image -1 0 0 sig 0 TRUE sigf PIXELS font)))
          (tw1 (car (gimp-drawable-width signature-layer)))
          (th1 (car (gimp-drawable-height signature-layer)))
	  ;)
        )
	;(if (defined? 'title-layer)(gimp-layer-set-offsets title-layer (+ border blur) (- height (+ th border))))
        (gimp-layer-set-offsets signature-layer (- width (+ tw1 border blur)) (- height (+ th1 border)))
        (gimp-context-set-foreground '(255 255 255))
      )
    )
    
    (set! height (+ height (* 2 border)))
    (set! width (+ width (* 2 border)))
    (gimp-image-resize image width height border border)
    (gimp-context-set-background colorborder)

    (let*
      ((bg-layer1 (car (gimp-layer-new image width height type "Border" 100 LAYER-MODE-NORMAL-LEGACY))))
      (gimp-drawable-fill bg-layer1 BACKGROUND-FILL)
      (gimp-image-insert-layer image bg-layer1 0 -1)
      (gimp-image-lower-item-to-bottom image bg-layer1)
    )

    (gimp-context-set-background '(0 0 0))
    (gimp-context-set-foreground '(255 255 255))
    (gimp-image-flatten image)
    (gimp-image-undo-group-end image)
    (gimp-displays-flush)
  )
)


(script-fu-register "210-tasty-frame"
	"Tasty Frame - optional Title"
	"Add a tasty frame to the image, including Title and name if desired."
	"Luis A. Florit <luis@impa.br>"
	"Luis A. Florit"
	"2007/06/03"
	"*"
	SF-IMAGE      "Image"              0
	SF-DRAWABLE   "Drawable"           0
	SF-ADJUSTMENT _"Round edge radius" '(5 0 300 1 5 0 1)
	SF-ADJUSTMENT _"Light radius"      '(13 0 300 1 5 0 1)
	SF-COLOR      _"Light color"       '(255 255 0)
	SF-ADJUSTMENT _"Border radius"     '(3 0 300 1 1 0 1)
	SF-COLOR      _"Border color"      '(200 200 0)
	SF-COLOR      _"Background color"  '(0 0 0)
	SF-TOGGLE     _"Add title"          TRUE
	SF-COLOR      _"Letter color"      '(140 140 140)
	SF-STRING     _"Title"             "(Picture Title here)"
	SF-ADJUSTMENT _"Title Font"        '(32 8 48 1 1 0 0)
	SF-TOGGLE     _"Add signature"      TRUE
	SF-STRING     _"Signature"         "(Your Name Here)"
	SF-ADJUSTMENT _"Signature Font"    '(16 8 32 1 1 0 0)
	SF-FONT       _"Font"              "sans"
)
(script-fu-menu-register "210-tasty-frame" "<Image>/Script-Fu/Edges")
