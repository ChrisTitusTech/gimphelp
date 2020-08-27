; 210_color_funky-color.scm
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
; Funky color script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/03
;     - Initial relase
; version 0.1a by Iccii 2001/12/08
;     - Now only affects to selection area
;==============================================================

(define (apply-easy-glowing-effect
			img
			img-layer
			blur)

  (let* (
         (img-width (car (gimp-drawable-width img-layer)))
         (img-height (car (gimp-drawable-height img-layer)))
         (layer (car (gimp-layer-new img img-width img-height RGBA-IMAGE
                                           "Base Layer" 100 LAYER-MODE-NORMAL-LEGACY)))
    	 (layer-copy (car (gimp-layer-copy layer TRUE)))
        )

    (gimp-image-resize img img-width img-height 0 0)
    (if (equal? (car (gimp-drawable-has-alpha img-layer)) FALSE)
        (gimp-layer-add-alpha img-layer))
    (gimp-image-insert-layer img layer 0 -1)
    (gimp-image-lower-item img layer)
    (gimp-drawable-fill layer 2)
    (set! layer (car (gimp-image-merge-down img img-layer EXPAND-AS-NECESSARY)))
    (set! layer-copy (car (gimp-layer-copy layer TRUE)))
    (gimp-image-insert-layer img layer-copy 0 -1)
    (gimp-layer-set-mode layer-copy OVERLAY-MODE)
    (plug-in-gauss-iir2 1 img layer blur blur)
    (plug-in-gauss-iir2 1 img layer-copy (+ (/ blur 2) 1) (+ (/ blur 2) 1))
    (let* ((point-num 3)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 127)
       (aset control_pts 3 255)
       (aset control_pts 4 255)
       (aset control_pts 5 0)
       (gimp-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))
    (plug-in-gauss-iir2 1 img layer (+ (* blur 2) 1) (+ (* blur 2) 1))
    (let* ((point-num 4)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 63)
       (aset control_pts 3 255)
       (aset control_pts 4 191)
       (aset control_pts 5 0)
       (aset control_pts 6 255)
       (aset control_pts 7 255)
       (gimp-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))

    (list layer layer-copy)
  )
)

(define (210-funky-color
		img
		layer
		blur
	)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img)) 
  
  (let* (
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (old-layer-name (car (gimp-item-get-name layer)))
         (layer-list (apply-easy-glowing-effect img layer blur))
	)

    (gimp-item-set-name (car layer-list) old-layer-name)
    (gimp-item-set-name (cadr layer-list) "Change layer mode")
    (if (equal? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear (cadr layer-list))
          (gimp-selection-invert img)))
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)))

(script-fu-register
	"210-funky-color"
	"Funky Color"
	"Create funky color logo image. \n\nBe sure to check out the MODE in the layers dialog after running the script. Different modes can yield much different appearances..."
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Dec"
	"*"
	SF-IMAGE     	"Image"			0
	SF-DRAWABLE  	"Drawable"		0
	SF-ADJUSTMENT	"Blur Amount"	'(10 1 100 1 1 0 1)
)
(script-fu-menu-register "210-funky-color" "<Image>/Script-Fu/Color")
