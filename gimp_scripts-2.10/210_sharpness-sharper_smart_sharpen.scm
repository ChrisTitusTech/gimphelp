; 210_sharpness-sharper_smart-sharpen.scm
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
; Smart sharpening script  for GIMP 2.4
; Original author: Olli Salonen <olli@cabbala.net>
;
; Author statement:
;
; script-fu-smart-sharpening - Smart sharpening of image. This script finds
; the edges of images and only sharpens those.
;
; You can find more about smart sharpening at
; http://www.gimpguru.org/Tutorials/SmartSharpening/
;
;   - Changelog -
; Changelog:
; 1.00 - Jan 07, 2004 initial release
;==============================================================


(define (210-smart-sharpening 
		inImg 
		inDrw 
		inAmount 
		inRadius 
		inEdge
	)

    (gimp-image-undo-group-start inImg)
    (if (not (= RGB (car (gimp-image-base-type inImg))))
			 (gimp-image-convert-rgb inImg))
			 
  (let* (
	 (original inImg)
	 (template (car (gimp-image-duplicate original)))
	 (original-layers (cadr (gimp-image-get-layers inImg)))
	 (template-layers (cadr (gimp-image-get-layers template)))
	 (template-bg-copy (car (gimp-layer-copy (aref template-layers 0) TRUE)))
	 (width (car (gimp-image-width original)))
	 (height (car (gimp-image-height original)))
	 (sharpen-mask)
	 (lab-image)
	 (lab-layers)
	 (final-mask)
	 (result-image)
	 (result-layers)
	 )

    (define (spline)
      (let* ((a (make-vector 8 'byte)))
		(set-pt a 0 0 0)
		(set-pt a 1 166 0)
		(set-pt a 2 246 255)
		(set-pt a 3 255 255)
	a))

    (define (set-pt a index x y)
		(prog1
		(aset a (* index 2) x)
		(aset a (+ (* index 2) 1) y)))

    (gimp-image-insert-layer template template-bg-copy 0 -1)
    (gimp-image-set-active-layer template template-bg-copy)
    (gimp-selection-all template)
    (gimp-edit-copy template-bg-copy)
    (set! sharpen-mask (car (gimp-channel-new template width height "SharpenMask" 50 '(255 0 0))))
    (gimp-image-insert-channel template sharpen-mask -1 0)
    (gimp-floating-sel-anchor (car (gimp-edit-paste sharpen-mask FALSE)))
    (plug-in-edge TRUE template sharpen-mask inEdge 1 0)
    (gimp-invert sharpen-mask)    
    (gimp-curves-spline sharpen-mask 0 8 (spline))
    (plug-in-gauss-iir TRUE template sharpen-mask 1 TRUE TRUE)
    (gimp-edit-copy sharpen-mask)

    ; split to L*a*b* and sharpen only L-channel
    (set! lab-image (car (plug-in-decompose TRUE original (aref original-layers 0) "LAB" TRUE)))
    (set! lab-layers (cadr (gimp-image-get-layers lab-image)))
    (set! final-mask (car (gimp-channel-new lab-image width height "FinalMask" 50 '(255 0 0))))
	(gimp-image-insert-channel lab-image final-mask -1 0)
    (gimp-floating-sel-anchor (car (gimp-edit-paste final-mask FALSE)))
    (gimp-image-delete template)
	(gimp-image-select-item lab-image CHANNEL-OP-REPLACE final-mask)
    (gimp-selection-invert lab-image)
    (gimp-selection-shrink lab-image 1)
    (gimp-image-remove-channel lab-image final-mask)
    (plug-in-unsharp-mask TRUE lab-image (aref lab-layers 0) inRadius inAmount 0)
    (gimp-selection-none lab-image)

    ; compose image from Lab-channels
    (set! result-image (car (plug-in-drawable-compose TRUE 0 (aref lab-layers 0) (aref lab-layers 1) (aref lab-layers 2) 0 "LAB")))
    (set! result-layers (cadr (gimp-image-get-layers result-image)))
    (gimp-edit-copy (aref result-layers 0))
    (gimp-image-delete lab-image)
    (gimp-image-delete result-image)
    (gimp-floating-sel-anchor (car (gimp-edit-paste (aref original-layers 0) FALSE)))

    (gimp-image-undo-group-end inImg)
    (gimp-displays-flush)
    )
)

(script-fu-register "210-smart-sharpening"
	"Smart Sharpening"
	"Sharpen images intelligently. Smart sharpen only sharpens images on the edges, where sharpening counts. Even areas are not sharpened, so noise levels are kept down when compared to normal unsharp mask. You may need to tweak the parameters for best result."
	"Olli Salonen <olli@cabbala.net>"
	"Olli Salonen"
	"Jan 07, 2004"
	"*"
	SF-IMAGE              "Image"                0
	SF-DRAWABLE           "Drawable"             0
	SF-ADJUSTMENT         "Amount of USM"        '(0.5 0 10 0.01 0.01 2 0)
	SF-ADJUSTMENT         "Radius of USM"        '(0.5 0 10 0.01 0.01 2 0)
	SF-ADJUSTMENT         "FindEdge amount"      '(2.0 0 10 0.01 0.01 2 0)
)
(script-fu-menu-register "210-smart-sharpening" "<Image>/Script-Fu/Sharpness/Sharper")
