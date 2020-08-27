; 210_sharpness-sharper_midtone-sharp.scm
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
; Installation:
; This script should be placed in the user or system-wide script folder.
;
;	Windows Vista/7/8)
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;	or
;	C:\Users\YOUR-NAME\.gimp-2.8\scripts
;	
;	Windows XP
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;	or
;	C:\Documents and Settings\yourname\.gimp-2.8\scripts   
;    
;	Linux
;	/home/yourname/.gimp-2.8/scripts  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/scripts
;
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
; version 2.0
;
; Midtone Sharp script  for GIMP 2.4
; Original author: Tim Jacobs <twjacobs@gmail.com>
; Author statement: Sharpens the midtones of an image
;==============================================================


(define (210-midtone-sharp 
		image 
		drawable 
		inStrength 
		merger
	)

	(gimp-image-undo-group-start image)
	(define indexed (car (gimp-drawable-is-indexed drawable)))
	(if (= indexed TRUE)(gimp-image-convert-rgb image))		 
		 
	(gimp-selection-all image)
	(define (floor x)
	 (- x (fmod x 1))
	)

	(define (interpolate run rise x)
	 (max (min (floor (* (/ rise run) x)) 255) 0)
	)

	; Initialize variables
	(let* 
	 (
	   (i 0)
	   (mask_opacity 50)
	   (num_bytes 256)
	   (thresh_1 85)
	   (thresh_2 116)
	   (thresh_3 140)
	   (thresh_4 171)
	   (thresh_5 256)
	   (value-curve (make-vector num_bytes 'byte))
	   (sharp-layer)
	   (sharp-mask)
	 )

	; create TRC for sharp layer mask
	 (while (< i thresh_1)
	   (aset value-curve i 0)
	   (set! i (+ i 1))
	 )

	 (while (< i thresh_2)
	   (aset value-curve i (interpolate (- thresh_2 thresh_1) 255 (- i thresh_1)))
	   (set! i (+ i 1))
	 )

	 (while (< i thresh_3)
	   (aset value-curve i 255)
	   (set! i (+ i 1))
	 )

	 (while (< i thresh_4)
	   (aset value-curve i (interpolate (- thresh_4 thresh_3) -255 (- i thresh_3)))
	   (set! i (+ i 1))
	 )

	 (while (< i thresh_5)
	   (aset value-curve i 0)
	   (set! i (+ i 1))
	 )

	; Create new layer and add to the image
	 (set! sharp-layer (car (gimp-layer-copy drawable 1)))
	 (gimp-image-insert-layer image sharp-layer 0 -1)
	 (gimp-item-set-name sharp-layer "Sharp Mask")

	; create mask layer
	 (set! sharp-mask (car (gimp-layer-create-mask sharp-layer ADD-COPY-MASK)))
	 (gimp-layer-add-mask sharp-layer sharp-mask)
	 (gimp-layer-set-opacity sharp-layer mask_opacity)
	 (gimp-layer-set-mode sharp-layer LAYER-MODE-NORMAL-LEGACY)

	; apply TRC to mask layer
	 (gimp-curves-explicit sharp-mask HISTOGRAM-VALUE num_bytes value-curve)

	(plug-in-unsharp-mask 1 image sharp-layer 5.5 1.50 0)
	(gimp-layer-remove-mask sharp-layer 0)

	; Merge down with the drawable, if selection box was checked.
	(if (= merger TRUE)
		(gimp-image-merge-down image sharp-layer 1)
		()
	)
	; Cleanup
	 (gimp-image-undo-group-end image)
	 (gimp-displays-flush)
	)
)

(script-fu-register "210-midtone-sharp"
    "Midtone-Sharp"
    "Sharpen the midtones of an image"
    "twjacobs@gmail.com"
    "Tim Jacobs"
    "March 19, 2005"
    "*"
    SF-IMAGE 		"Image" 					0
    SF-DRAWABLE 	"Drawable" 					0
	SF-ADJUSTMENT	"Strength of Sharpening"	'(1.0 0.5 10.0 0.1 0.1 2 0)
	SF-TOGGLE 		"Merge Layers?"  			FALSE
)
(script-fu-menu-register "210-midtone-sharp" "<Image>/Script-Fu/Sharpness/Sharper")
