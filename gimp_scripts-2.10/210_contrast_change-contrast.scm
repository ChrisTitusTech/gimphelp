; 210_contrast_change-contrast.scm
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
; Original was "Vivid saturation" script  for GIMP 2.4
; by Dennis Bond with thanks to Jozef Trawinski
; Modified for use in GMP-2.4 by Paul Sherman 
; This is modification 2 made on 11/15/2007
; distributed by gimphelp.org
;
(define (210-change-contrast image drawable shadows highlights)

	;Start an undo group so the process can be undone with one undo
	(gimp-image-undo-group-start image)

	; create a highlights layer
	(let ((highlights-layer (car (gimp-layer-copy drawable 1))))
	(gimp-item-set-name highlights-layer "fix highlights (adjust opacity)")
	(gimp-image-insert-layer image highlights-layer 0 -1)

	;process shadows/highlights layer
	(gimp-desaturate highlights-layer)
	(gimp-invert highlights-layer)
	(gimp-layer-set-mode highlights-layer 5)
	(plug-in-gauss-iir2 1 image highlights-layer 25 25)

	;copy highlights layer to create shadows layer
	(define shadows-layer (car (gimp-layer-copy highlights-layer 1)))
	(gimp-item-set-name shadows-layer "fix shadows (adjust opacity)")
	(gimp-image-insert-layer image shadows-layer 0 -1)

	;process highlights layer
	(plug-in-colortoalpha 1 image highlights-layer '(255 255 255))
	(gimp-layer-set-opacity highlights-layer highlights)

	;process shadows layer
	(plug-in-colortoalpha 1 image shadows-layer '(0 0 0))
	(gimp-layer-set-opacity shadows-layer shadows)

	;Finish the undo group for the process
	(gimp-image-undo-group-end image)

	;update image window
	(gimp-displays-flush)))


(script-fu-register "210-change-contrast"
		"Change Contrast"
		"Removes shadows and highlights from a photograph, makes image feel more saturated"
		"Dennis Bond - thanks to Jozef Trawinski"
		"Dennis Bond - thanks to Jozef Trawinski"
		"October 26, 2006"
		"RGB*"
		SF-IMAGE "Image" 0
		SF-DRAWABLE "Drawable" 0
		SF-ADJUSTMENT "Shadows"    '(50 0  100   1   1   0   0)
		SF-ADJUSTMENT "Highlights" '(0  0  100   1   1   0   0)
)
(script-fu-menu-register "210-change-contrast" "<Image>/Script-Fu/Contrast")