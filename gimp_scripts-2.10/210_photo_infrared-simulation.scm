; 210_photo_infrared-simulation.scm
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
; Infrared, V2.1 for GIMP 2.4
; Original author: Martin Egger (martin.egger@gmx.net)
; (C) 2005, Bern, Switzerland
;
; You can find more about simulating IR at
; http://www.gimpguru.org/Tutorials/SimulatedInfrared/
; http://epaperpress.com/psphoto/
;==============================================================


(define (210-Infrared InImage InLayer InOpacity InContrast InNoise InBlur InFlatten)

	; Save history			
	(gimp-image-undo-group-start InImage)
	(if (not (= RGB (car (gimp-image-base-type InImage))))
			 (gimp-image-convert-rgb InImage))
	
	(let*	(
		(CopyLayer (car (gimp-layer-copy InLayer TRUE)))
		(IRLayer (car (gimp-layer-copy InLayer TRUE)))
		(IRLayer2 (car (gimp-layer-copy InLayer TRUE)))
		(IRLayer3 (car (gimp-layer-copy InLayer TRUE)))
		)
		(gimp-image-insert-layer InImage CopyLayer 0 -1)

		(gimp-image-insert-layer InImage IRLayer3 0 -1)
		(gimp-layer-set-mode IRLayer3 SCREEN-MODE)
		(gimp-layer-set-opacity IRLayer3 InContrast)
		(gimp-image-insert-layer InImage IRLayer2 0 -1)
		(gimp-layer-set-mode IRLayer2 BURN-MODE)
		(gimp-layer-set-opacity IRLayer2 InContrast)
		(gimp-image-insert-layer InImage IRLayer 0 -1)
		(gimp-layer-set-mode IRLayer SCREEN-MODE)
		(gimp-layer-set-opacity IRLayer InOpacity)

		; Dreamy IR
		(gimp-desaturate CopyLayer)
		(gimp-desaturate IRLayer3)
		(plug-in-colors-channel-mixer TRUE InImage IRLayer2 TRUE 1.0 1.0 -1.0 0 0 0 0 0 0)
		(plug-in-colors-channel-mixer TRUE InImage IRLayer TRUE -.3 2.0 -.7 0 0 0 0 0 0)
		(gimp-brightness-contrast IRLayer -25 70)

		; Add noise to the image, if we need to
		(if (and (= InNoise TRUE) (defined? 'plug-in-scatter-rgb) ) (plug-in-scatter-rgb TRUE InImage IRLayer FALSE FALSE 0.1 0.1 0.1 0))

		; Blur the IR layer, if we need to
		(if (= InBlur TRUE) (plug-in-gauss TRUE InImage IRLayer 4.0 4.0 0))

		; Flatten the image, if we need to
		(cond
			((= InFlatten TRUE) 
				(begin
					(gimp-image-merge-down InImage CopyLayer CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage IRLayer3 CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage IRLayer2 CLIP-TO-IMAGE)
					(gimp-image-merge-down InImage IRLayer CLIP-TO-IMAGE)
				)
			)

			((= InFlatten FALSE) 
				(begin
					(gimp-item-set-name IRLayer "Infrared (Green)")
					(gimp-item-set-name IRLayer2 "Infrared (Sky Contrast)")
					(gimp-item-set-name IRLayer3 "Infrared (Green Glow)")
					(gimp-item-set-name CopyLayer "BW-Copy")
				)
			)
		)
	)

	; Finish work
	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
)

(script-fu-register
	"210-Infrared"
	"Infrared Simulation"
	"Simulate digital Infrared"
	"Martin Egger (martin.egger@gmx.net)"
	"2005, Martin Egger, Bern, Switzerland"
	"12.07.2005"
	"*"
	SF-IMAGE		"The Image"												0
	SF-DRAWABLE		"The Layer"												0
	SF-ADJUSTMENT	"IR Layer Opacity" 										'(80.0 1.0 100.0 1.0 0 2 0)
	SF-ADJUSTMENT	"Contrast/Glow Layer Opacity" 							'(50.0 1.0 100.0 1.0 0 2 0)
	SF-TOGGLE		"Film grain simulation(requires RGB scater plug-in)" 	FALSE
	SF-TOGGLE		"Blur Image"											FALSE
	SF-TOGGLE		"Flatten Image"											FALSE
	)
(script-fu-menu-register "210-Infrared" "<Image>/Script-Fu/Photo")
