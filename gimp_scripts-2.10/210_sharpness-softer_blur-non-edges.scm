; 210_sharpness-softer_blur-non-edges.scm
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
; Original information
;
; Blur Non-Edges version 0.9.1
;
; Blurs those areas of a picture which are considered not edges, that
; is are more or less uniform color areas. This is somewhat like the
; standard Selective Gaussian Blur plugin, but gives better results in
; some situations. Also try running this script first, and then
; Selective Gaussian Blur on the resulting image.
;
; Technically, the script works as following.
;
;  - find edges
;  - make a selection that doesn't include the edges
;  - shrink and feather the selection in proportion to blur radius
;  - perform gaussian blur
;
; End original information ------------------------------------------


(define (210-blur-non-edges image layer select-threshold blur-strength show-used-selection)
    (gimp-image-undo-group-start image)
    (let* ((saved-selection (car (gimp-selection-save image)))
           (saved-selection-empty (car (gimp-selection-is-empty image))))
          (let* ((dup-layer (car (gimp-layer-copy layer 1))))
                (gimp-image-insert-layer image dup-layer 0 -1)
                (plug-in-edge 1 image dup-layer 2 2 0)
                (gimp-image-select-color image CHANNEL-OP-REPLACE dup-layer '(0 0 0))
                (if (= TRUE saved-selection-empty)
                    '()
                    (gimp-selection-combine saved-selection CHANNEL-OP-INTERSECT))
                (gimp-image-remove-layer image dup-layer)
          )
          (gimp-selection-shrink image (/ blur-strength 2))
          (gimp-selection-feather image blur-strength)
          (gimp-image-set-active-layer image layer)
          (plug-in-gauss-iir2 1 image layer blur-strength blur-strength)

          (if (= TRUE show-used-selection)
              '()
			  (gimp-image-select-item image CHANNEL-OP-REPLACE saved-selection))
          (gimp-image-remove-channel image saved-selection)
          (gimp-displays-flush)
          (gimp-image-undo-group-end image))
)

(script-fu-register "210-blur-non-edges"
	"Blur Non-Edges"
	"Gaussian blur smooth, non-edge areas of the image"
	"Samuli Kärkkäinen"
	"Samuli Kärkkäinen"
	"2005-01-08"
	"RGB* GRAY*"
	SF-IMAGE      "Font" 0
	SF-DRAWABLE   "Font Size" 0
	SF-ADJUSTMENT "Non-edge selection threshold" '(60 0 255 1 10 0 0)
	SF-ADJUSTMENT "Blur radius" '(5 0.1 999 0.1 1 1 1)
	SF-TOGGLE     "Show used selection" FALSE
)
(script-fu-menu-register "210-blur-non-edges" "<Image>/Script-Fu/Sharpness/Softer")
