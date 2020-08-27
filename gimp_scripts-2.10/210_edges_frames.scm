; 210_edges_frames.scm
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
;===================================================
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
;  edge_sign.scm --- prepare photograph for publishing on Internet
;    originally frame.scm
;
;  Copyright (C) 2006 by Walter C. Pelissero
;
;  Author: Walter C. Pelissero <walter@pelissero.de>
;
; These scripts are suitable for publishing photographs on Internet.
; They resizes a picture, then add a border, (one of the commands
; drops a shadow as well) and add the author's name in the bottom
; right corner.
;
; There are three commands script-fu-frame-modern, -poster and
; -negative.  The former rounds the corners and drops a shadow on a
; white background.  The latter rounds the corners and adds a black
; border.  Both add a signature which has to be modified in the
; script as Script-Fu is very limited and doesn't allow for any
; default values that are not constant.
;==============================================================


(define (210-frame-hover image drawable width signature-text font-name)
  (gimp-display-new
   (210-frame-hover-batch image drawable width signature-text font-name))
  (gimp-displays-flush))

(define (210-frame-negative image drawable width signature-text font-name)
  (gimp-display-new
   (210-frame-negative-batch image drawable width signature-text font-name))
  (gimp-displays-flush))

(define (210-frame-poster image drawable width border-colour signature-text font-name)
  (gimp-display-new
   (210-frame-poster-batch image drawable width border-colour signature-text font-name))
  (gimp-displays-flush))

(define (%top-layer image)
  (aref (cadr (gimp-image-get-layers image)) 0))

(define (210-frame-hover-batch image drawable width signature-text font-name)
  (let* ((new-image (car (gimp-image-duplicate image)))
	 (drawable (car (gimp-image-get-active-drawable new-image)))
	 (height (* (car (gimp-image-height new-image))
		    (/ width (car (gimp-image-width new-image)))))
	 ;; just an index of dimension
	 (size (/ (sqrt (* width height)) 20))
	 (foreground (car (gimp-context-get-foreground)))
	 (background (car (gimp-context-get-background))))
    (gimp-image-undo-group-start new-image)
	
	(if (not (= RGB (car (gimp-image-base-type new-image))))
			 (gimp-image-convert-rgb new-image))	
	
	
    (script-fu-guides-remove new-image drawable)
    (gimp-image-scale new-image width height)
    (plug-in-unsharp-mask RUN-NONINTERACTIVE image drawable
			  (* size 0.15)	; radius (constant found empirically)
			  0.3		; amount
			  0		; threshold
			  )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    (script-fu-round-corners new-image
			     drawable
			     (trunc (/ size 2))	; edge radius
			     TRUE		; add drop shadow
			     (trunc (/ size 3)) ; shadow x offset
			     (trunc (/ size 3)) ; shadow y offset
			     (trunc (/ size 2))	; shadow blur radius
			     TRUE		; add background
			     ;; don't make another copy as we just made one
			     FALSE)
    (if (> size 20)
	(begin
	  (gimp-image-set-active-layer new-image (%top-layer new-image))
	  (let* ((text-layer (car (gimp-text-fontname new-image
						      -1 ; drawable, -1 = new layer
						      0
						      0
						      signature-text
						      (/ size 6) ; border
						      TRUE ; antialias
						      (max 10 (/ size 2)) ; text size
						      PIXELS ; size unit
						      font-name)))
		 (text-width (car (gimp-drawable-width text-layer)))
		 (text-height (car (gimp-drawable-height text-layer))))
	    (gimp-layer-set-offsets text-layer
				    (- (car (gimp-image-width new-image)) text-width (log size))
				    (- (car (gimp-image-height new-image)) text-height)))))
    (gimp-image-merge-visible-layers new-image 0)
    (gimp-context-set-foreground foreground)
    (gimp-context-set-background background)
    (gimp-image-undo-group-end new-image)
    ;; return the new image so that batch scripts can do something
    ;; with it
    new-image))

(define (210-frame-negative-batch image drawable width signature-text font-name)
  (let* ((new-image (car (gimp-image-duplicate image)))
	 (drawable (car (gimp-image-get-active-drawable new-image)))
	 (height (* (car (gimp-image-height new-image))
		    (/ width (car (gimp-image-width new-image)))))
	 (size (/ (sqrt (* width height)) 20))
	 (foreground (car (gimp-context-get-foreground)))
	 (background (car (gimp-context-get-background))))
    (gimp-image-undo-group-start new-image)
	
	(if (not (= RGB (car (gimp-image-base-type new-image))))
			 (gimp-image-convert-rgb new-image))	
			 
			 
    (script-fu-guides-remove new-image drawable)
    (gimp-image-scale new-image width height)
    (plug-in-unsharp-mask RUN-NONINTERACTIVE image drawable
			  (* size 0.15)	; radius
			  0.3		; amount
			  0		; threshold
			  )
    (gimp-context-set-foreground '(200 200 200))
    (gimp-context-set-background '(0 0 0))
    (script-fu-round-corners new-image
			     drawable
			     (trunc (/ size 3))	; edge radius
			     FALSE		; no shadow
			     0			; shadow x offset
			     0			; shadow y offset
			     0			; shadow blur radius
			     TRUE		; add background
			     ;; don't make another copy as we just made one
			     FALSE)
    (gimp-image-merge-visible-layers new-image 0)
    (let ((background-layer (%top-layer new-image)))
      (if (> size 20)
	  (begin
	    (let* ((text-layer (car (gimp-text-fontname new-image
							-1 ; drawable, -1 = new layer
							0
							0
							signature-text
							1    ; border
							TRUE ; antialias
							(max 10 (/ size 2)) ; text size
							PIXELS ; size unit
							font-name)))
		   (text-width (car (gimp-drawable-width text-layer)))
		   (text-height (car (gimp-drawable-height text-layer))))
	      (script-fu-addborder new-image background-layer
				   text-height text-height '(0 0 0) 0)
	      (gimp-layer-set-offsets text-layer
				      (- (car (gimp-image-width new-image)) text-width (log size))
				      (- (car (gimp-image-height new-image)) text-height))
	      (gimp-image-raise-item-to-top new-image text-layer))
	    (gimp-image-merge-visible-layers new-image 0))
	  (script-fu-addborder new-image background-layer
			       (/ size 5) (/ size 5) '(0 0 0) 0)))
    (gimp-context-set-foreground foreground)
    (gimp-context-set-background background)
    (gimp-image-undo-group-end new-image)
    ;; return the new image so that batch scripts can do something
    ;; with it
    new-image))

(define (210-frame-poster-batch image drawable width border-colour signature-text font-name)
  (let* ((new-image (car (gimp-image-duplicate image)))
	 (drawable (car (gimp-image-get-active-drawable new-image)))
	 (height (* (car (gimp-image-height new-image))
		    (/ width (car (gimp-image-width new-image)))))
	 (size (/ (sqrt (* width height)) 20))
	 (inverted-border-colour (mapcar (lambda (value)
					   (- 255 value))
					 border-colour))
	 (foreground (car (gimp-context-get-foreground)))
	 (background (car (gimp-context-get-background))))
    (gimp-image-undo-group-start new-image)
	
	(if (not (= RGB (car (gimp-image-base-type new-image))))
			 (gimp-image-convert-rgb new-image))		
	
    (script-fu-guides-remove new-image drawable)
    (gimp-image-scale new-image width height)
    (plug-in-unsharp-mask RUN-NONINTERACTIVE image drawable
			  (* size 0.15)	; radius
			  0.3		; amount
			  0		; threshold
			  )
    (gimp-context-set-foreground inverted-border-colour)
    (gimp-context-set-background border-colour)
    (let ((thickness (max 1 (trunc (/ (log size) 2)))))
      (script-fu-addborder new-image (%top-layer new-image)
			   thickness thickness
			   inverted-border-colour
			   0))
    (gimp-image-merge-visible-layers new-image 0)
    (let ((background-layer (%top-layer new-image)))
      (if (> size 20)
	  (begin
	    (let* ((text-layer (car (gimp-text-fontname new-image
							-1 ; drawable, -1 = new layer
							0
							0
							signature-text
							1    ; border
							TRUE ; antialias
							;; text size (cursive fonts need more space)
							(max 10 (/ size 1.5))
							PIXELS ; size unit
							font-name)))
		   (text-width (car (gimp-drawable-width text-layer)))
		   (text-height (car (gimp-drawable-height text-layer))))
	      (script-fu-addborder new-image background-layer
				   text-height text-height border-colour 0)
	      (gimp-layer-set-offsets text-layer
				      (- (car (gimp-image-width new-image)) text-width (log size))
				      (- (car (gimp-image-height new-image)) text-height))
	      (gimp-image-raise-item-to-top new-image text-layer)))
	  (script-fu-addborder new-image background-layer
			       size size border-colour 0)))
    (gimp-image-merge-visible-layers new-image 0)
    (gimp-context-set-foreground foreground)
    (gimp-context-set-background background)
    (gimp-image-undo-group-end new-image)
    ;; return the new image so that batch scripts can do something
    ;; with it
    new-image))


(script-fu-register "210-frame-hover"
		    "Frame with hover effect and round corners..."
		    "Resize, frame and sign a photograph for publishing on Internet (\"hover\" style)"
		    "Walter Pelissero <walter@pelissero.de>"
		    "Walter Pelissero"
		    "2006/07/13"
		    "*"
		    SF-IMAGE       "Image" 			0
		    SF-DRAWABLE    "Drawable"		0
		    SF-ADJUSTMENT  "Image width" 	'(640 128 4096 128 10 0 1)
		    SF-STRING      "Signature" 		"Your Name"
		    SF-FONT        "Font" 			"sans")

(script-fu-register "210-frame-negative"
		    "Frame like slide with round corners..."
		    "Resize, frame and sign a photograph for publishing on Internet (\"slide\" style)"
		    "Walter Pelissero <walter@pelissero.de>"
		    "Walter Pelissero"
		    "2006/07/13"
		    "*"
		    SF-IMAGE       "Image" 			0
		    SF-DRAWABLE    "Drawable" 		0
		    SF-ADJUSTMENT  "Image width" 	'(640 128 4096 128 10 0 1)
		    SF-STRING      "Signature" 		"Your Name"
		    SF-FONT        "Font" 			"sans")

(script-fu-register "210-frame-poster"
		    "Frame like poster with straight corners..."
		    "Resize, frame and sign a photograph for publishing on Internet (\"poster\" style)"
		    "Walter Pelissero <walter@pelissero.de>"
		    "Walter Pelissero"
		    "2006/09/06"
		    "*"
		    SF-IMAGE       "Image"			0
		    SF-DRAWABLE    "Drawable"		0
		    SF-ADJUSTMENT  "Image width" 	'(640 128 4096 128 10 0 1)
		    SF-COLOR       "Border colour"	'(0 0 0)
		    SF-STRING      "Signature" 		"Your Name"
		    SF-FONT        "Font" 			"sans")

(script-fu-menu-register "210-frame-hover"
			 "<Image>/Script-Fu/Edges")

(script-fu-menu-register "210-frame-negative"
			 "<Image>/Script-Fu/Edges")

(script-fu-menu-register "210-frame-poster"
			 "<Image>/Script-Fu/Edges")
