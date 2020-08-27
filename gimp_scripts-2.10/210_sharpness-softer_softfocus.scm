; 210_sharpness-sharper_softfocus.scm
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
; copyright 2006, Y.Morikaku
; August 15, 2006
;==============================================================


(define (210-soft-focus 
		theImage 
		theLayer
		edge 
		mode 
		opacity
		inMerge
	)

	(gimp-image-undo-group-start theImage)
    (if (not (= RGB (car (gimp-image-base-type theImage))))
			 (gimp-image-convert-rgb theImage))	
	
    (define addString (cond     ((= mode 0) "_super-softfocus_h.jpg" )
                                ((= mode 1) "_super-softfocus_a.jpg" )
                                ((= mode 2) "_super-softfocus_s.jpg" )
                                ((= mode 3) "_super-softfocus_dv.jpg" )
                                ('else "_super-softfocus_ds.jpg" ) ))
    
    (define theLayer2 (car(gimp-layer-copy theLayer 1)))
    (gimp-image-insert-layer theImage theLayer2 0 0)
    (plug-in-gauss-iir2 1 theImage theLayer2 10 10)

    (define theLayer3 (car(gimp-layer-copy theLayer2 1)))
    (gimp-image-insert-layer theImage theLayer3 0 0)
    (define mask (car (gimp-layer-create-mask theLayer3 ADD-COPY-MASK)))
    (gimp-layer-add-mask theLayer3 mask)

    (define theLayer4 (car(gimp-layer-copy theLayer3 1)))
    (gimp-image-insert-layer theImage theLayer4 0 0)

    (gimp-layer-set-mode theLayer2 LAYER-MODE-SCREEN-LEGACY)
    (gimp-layer-set-mode theLayer3 LAYER-MODE-MULTIPLY-LEGACY)
    (gimp-layer-set-mode theLayer4 LAYER-MODE-OVERLAY-LEGACY)

    (define theLayer5 (car(gimp-layer-copy theLayer 1)))
    (gimp-image-insert-layer theImage theLayer5 0 0)
    (define mask5 (car (gimp-layer-create-mask theLayer5 ADD-COPY-MASK)))
    (gimp-layer-add-mask theLayer5 mask5)
    (plug-in-edge 1 theImage mask5 1 1 0)
    (plug-in-blur 1 theImage mask5)
    (gimp-levels-stretch mask5)
    (gimp-layer-set-opacity theLayer5 edge)
    (gimp-edit-copy-visible theImage)
    (define theLayer6 (car (gimp-edit-paste theLayer FALSE)))

    (define pastedLayer (car (gimp-image-get-active-layer theImage)))
    (define pastedLayerMode (cond ((= mode 0) LAYER-MODE-HARDLIGHT-LEGACY )
                                ((= mode 1) LAYER-MODE-ADDITION-LEGACY )
                                ((= mode 2) LAYER-MODE-SCREEN-LEGACY )
                                ((= mode 3) LAYER-MODE-DIVIDE-LEGACY )
                                ('else LAYER-MODE-NORMAL-LEGACY ) ))
    (gimp-layer-set-mode pastedLayer pastedLayerMode )
    (if (>= mode 4)
        (begin 
            (gimp-desaturate pastedLayer)
            (define maskPasted (car (gimp-layer-create-mask pastedLayer ADD-COPY-MASK)))
            (gimp-layer-add-mask pastedLayer maskPasted )
        );end of begin
    );end of if 
    (gimp-layer-set-opacity pastedLayer opacity )    
    
	(if (= inMerge TRUE)(gimp-image-merge-visible-layers theImage EXPAND-AS-NECESSARY))
	(gimp-image-undo-group-end theImage)
	(gimp-displays-flush)

    
     
);end of define

(script-fu-register "210-soft-focus"
    "Soft Focus"
    "Super Softfocus 1.1 / Layer mode select version.\n\nFlattens image if needed before doing its work."
    "Y Morikaku"
    "copyright 2006, Y.Morikaku"
    "August 15, 2006"
    "*"
    SF-IMAGE      "Image"     						0
    SF-DRAWABLE   "Drawable"  						0
    SF-ADJUSTMENT "Edge Strength"   				'(50 0 100 1 10 0 0)
    SF-OPTION     "Top Layer Mode" 					'( "HARDLIGHT-MODE" "ADDITION" "SCREEN" "DIVIDE" "Desaturation" )
    SF-ADJUSTMENT "Top Layer Opacity"   			'(30 0 100 1 10 0 0)
	SF-TOGGLE     "Merge layers when complete?" 	TRUE
)
(script-fu-menu-register "210-soft-focus" "<Image>/Script-Fu/Sharpness/Softer")
