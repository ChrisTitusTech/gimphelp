; 210_sketch_pen-sketch.scm
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
; 11/23/2007: adapted to GIMP-2.4 by Paul Sherman
; 10/02/2008: Updated again for v2.6, needed another define...
; 12/15/2008 - accepts RGB* only, to prevent errors
;
; Original information -----------------------------------------------
; script by Karl Ward
; End original information -----------------------------------------

(define (210-pen inimage indraw blur)
	(define theImage inimage)
	(define theDraw indraw)
	(gimp-image-undo-group-start theImage)
	(define flush (car(gimp-image-flatten theImage)))
	(define flush-copy (car(gimp-layer-copy flush 1)))
	(gimp-image-insert-layer theImage flush-copy 0 -1)
	(define second-copy (car(gimp-layer-copy flush 1)))
	(gimp-image-insert-layer theImage second-copy 0 -1)
	(gimp-layer-set-mode second-copy 20)
	(plug-in-gauss 1 theImage second-copy blur blur 0)
	(define width (car (gimp-drawable-width flush)))
	(define height (car (gimp-drawable-height flush)))
	(define white-layer (car (gimp-layer-new theImage width height 1 "white" 100 13)))
	(gimp-drawable-fill white-layer 2)
	(gimp-image-insert-layer theImage white-layer 0 -1)
	(gimp-item-set-visible flush 0)
	(define flat-grey (car(gimp-image-merge-visible-layers theImage 0)))
	(define (plug-in-color-map 1 theImage flat-grey '(0 0 0) '(128 128 128) '(00 00 00) '(256 256 256) 0))
	(define outline-copy (car(gimp-layer-copy flat-grey 1)))
	(gimp-image-insert-layer theImage outline-copy 0 -1)
	(plug-in-colortoalpha 1 theImage outline-copy '(256 256 256))
	(gimp-layer-set-mode outline-copy 17)
	(define final-outline (car(gimp-image-merge-visible-layers theImage 0)))
	(define copy-count 1)
	(while (<= copy-count 4 )
	(define copy (car(gimp-layer-copy final-outline 1)))
	(gimp-image-insert-layer theImage copy 0 -1)
	(gimp-layer-set-mode copy 17)
	(set! copy-count (+ copy-count 1)))
	(gimp-layer-set-mode final-outline 17)

	(gimp-item-set-visible flush 1)
	(gimp-layer-add-alpha flush)
	(gimp-layer-set-opacity flush 70)
	(set! white-layer (car (gimp-layer-new theImage width height 1 "white" 100 0)))
	(gimp-drawable-fill white-layer 2)
	(gimp-image-insert-layer theImage white-layer 0 -1)
	(gimp-image-lower-item-to-bottom theImage white-layer)
	(gimp-image-flatten theImage)
	(gimp-image-undo-group-end theImage)
	(gimp-displays-flush)
)
(script-fu-register "210-pen"
	"Pen Drawn"
	"This filter changes any image into a image that appears to have been drawn woth ink"
	"Karl Ward"
	"Karl Ward"
	"OCT 2006"
	"RGB*"
	SF-IMAGE      "SF-IMAGE" 0
	SF-DRAWABLE   "SF-DRAWABLE" 0
	SF-ADJUSTMENT "Line thickess" '(25 1 100 1 5 0 0)
)
(script-fu-menu-register "210-pen" "<Image>/Script-Fu/Sketch")

