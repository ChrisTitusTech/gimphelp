;210_sharpness-sharper_wisest-sharpen.scm
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
; Smart Seperate Sharpening, V2.7
;
; Martin Egger (martin.egger@gmx.net), Michael Kolodny (m_kolodny@phreego.com) 
; added 'Texture Sharpening' and included Seperate Sharpen
; (C) 2010, Bern, Switzerland
;
; You can find more about Smart Sharpening at
; http://www.gimpguru.org/Tutorials/SmartSharpening2/
;
; This script was tested with Gimp 2.7
;
; New versions will be distributed from http://registry.gimp.org/ only
;==============================================================

; Define the function
;
(define (210-Eg-SmartSeparateSharpen 
			 InImage 
			 InLayer 
			 TInAmount
			 TInLightOpacity 
			 TInDarkOpacity 
			 EInAmount
			 EInLightOpacity 
			 EInDarkOpacity 
			 TInRadius 
			 TInThreshold 
			 EInRadius 
			 EInThreshold 
			 InEdge 
			 InBlur 
			 InFlatten)
;
; Save history			
;
	(gimp-image-undo-group-start InImage)
	(if (= (car (gimp-drawable-is-rgb InLayer)) FALSE ) (gimp-image-convert-rgb InImage))
;
	(let*	(
		(MaskImage (car (gimp-image-duplicate InImage)))
		(MaskLayer (cadr (gimp-image-get-layers MaskImage)))
;
		(OrigLayer (cadr (gimp-image-get-layers InImage)))

;
		(EdgeSharpenLayer (car (gimp-layer-copy InLayer TRUE)))
		(TextureSharpenLayer (car (gimp-layer-copy InLayer TRUE)))
		)
;
		(gimp-image-add-layer InImage EdgeSharpenLayer -1)
		(gimp-image-add-layer InImage TextureSharpenLayer -1)
;
;
; Find edges, Warpmode = Smear (1), Edgemode = Sobel (0)
;
		(plug-in-edge TRUE MaskImage (aref MaskLayer 0) InEdge 1 0)
		(gimp-levels-stretch (aref MaskLayer 0))
		(gimp-image-convert-grayscale MaskImage)
		(plug-in-gauss TRUE MaskImage (aref MaskLayer 0) InBlur InBlur TRUE)
;
		(let*	(
			(EdgeSharpenLayerMask (car (gimp-layer-create-mask EdgeSharpenLayer ADD-WHITE-MASK)))
			(TextureSharpenLayerMask (car (gimp-layer-create-mask TextureSharpenLayer ADD-WHITE-MASK)))
			)
			(gimp-layer-add-mask EdgeSharpenLayer EdgeSharpenLayerMask)
;

			(gimp-selection-all MaskImage)
			(gimp-edit-copy (aref MaskLayer 0))
			(gimp-floating-sel-anchor (car (gimp-edit-paste EdgeSharpenLayerMask FALSE)))
;
			(script-fu-Eg-SharpenLightAndDark InImage EdgeSharpenLayer EInRadius EInAmount EInLightOpacity EInDarkOpacity EInThreshold InFlatten "Edge")

;; do texture sharpening with an inverted edge mask
			(gimp-image-convert-rgb MaskImage)
			(plug-in-vinvert TRUE MaskImage (aref MaskLayer 0))
			(gimp-edit-copy (aref MaskLayer 0))

			(gimp-layer-add-mask TextureSharpenLayer TextureSharpenLayerMask)
			(gimp-floating-sel-anchor (car (gimp-edit-paste TextureSharpenLayerMask FALSE)))
			(gimp-image-delete MaskImage)
;

			(script-fu-Eg-SharpenLightAndDark InImage TextureSharpenLayer TInRadius TInAmount TInLightOpacity TInDarkOpacity TInThreshold InFlatten "Texture")

		)

		(cond
			((= InFlatten FALSE)
				(begin
					(gimp-layer-set-edit-mask EdgeSharpenLayer FALSE)
					(gimp-layer-set-edit-mask TextureSharpenLayer FALSE)
					(gimp-image-set-active-layer InImage InLayer)
				)
			)
		)
	)
;
; Finish work
;
	(gimp-image-undo-group-end InImage)
	(gimp-displays-flush)
;
)

(define (script-fu-Eg-SharpenLightAndDark InImage InSharpenDarkLayer InRadius InAmount InLightOpacity InDarkOpacity InThreshold InFlatten InLabel)

   		(gimp-layer-set-mode InSharpenDarkLayer DARKEN-ONLY-MODE)
   		(gimp-layer-set-opacity InSharpenDarkLayer  InDarkOpacity)
			(plug-in-unsharp-mask TRUE InImage InSharpenDarkLayer InRadius InAmount InThreshold)
;
		(let*	(
		(SharpenLightLayer (car (gimp-layer-copy InSharpenDarkLayer TRUE)))
		
			)
			(gimp-image-add-layer InImage SharpenLightLayer -1)
			(gimp-layer-set-mode SharpenLightLayer LIGHTEN-ONLY-MODE)
			(gimp-layer-set-opacity SharpenLightLayer InLightOpacity)
		
;
; Flatten the image, if we need to
;
			(cond
				((= InFlatten TRUE)
					(begin
						(let*	(
							(InSharpenDarkLayer (car (gimp-image-merge-down InImage InSharpenDarkLayer CLIP-TO-IMAGE)))
							)
							(gimp-image-merge-down InImage SharpenLightLayer CLIP-TO-IMAGE)
						)
					)
				)
				((= InFlatten FALSE)
					(begin
						(gimp-drawable-set-name SharpenLightLayer (string-append InLabel " Sharpened Lighten"))
						(gimp-drawable-set-name InSharpenDarkLayer (string-append InLabel " Sharpened Darken"))
						(gimp-image-set-active-layer InImage InSharpenDarkLayer)
					)
				)
			)
		)
)


(script-fu-register 
	"210-Eg-SmartSeparateSharpen"
	"Wisest Sharpen"
	"Smart Sharpening, Redux version"
	"Martin Egger (martin.egger@gmx.net) and Michael Kolodny (m_kolodny@phreego.com)"
	"2010, Martin Egger, Bern, Switzerland"
	"21.11.2010"
	"*"
	SF-IMAGE		"The Image"									0
	SF-DRAWABLE		"The Layer"									0
	SF-ADJUSTMENT	"Texture Sharpen USM: Amount"				'(1.2 0.0 10.0 0.5 0 2 0)
	SF-ADJUSTMENT	"Texture Sharpen Lighten USM: Opacity"		'(50 0.0 100 0.5 0 2 0)
	SF-ADJUSTMENT	"Texture Sharpen Darken USM: Opacity"		'(100 0.0 100 0.5 0 2 0)
	SF-ADJUSTMENT	"Edge Sharpen USM: Amount"					'(1.2 0.0 5.0 0.5 0 2 0)
	SF-ADJUSTMENT	"Edge Sharpen Lighten USM: Opacity"			'(50 0.0 100 0.5 0 2 0)
	SF-ADJUSTMENT	"Edge Sharpen Darken USM: Opacity"			'(100 0.0 100 0.5 0 2 0)
	SF-ADJUSTMENT	"Texture Sharpen USM: Radius"				'(0.3 0.0 120.0 1 0 2 0)
	SF-ADJUSTMENT	"Texture Sharpen USM: Threshold"			'(0.0 0.0 255.0 1.0 0 2 0)
	SF-ADJUSTMENT	"Edge Sharpen USM: Radius"					'(0.3 0.0 50.0 1 0 2 0)
	SF-ADJUSTMENT	"Edge Sharpen USM: Threshold"				'(0.0 0.0 50.0 1.0 0 2 0)
	SF-ADJUSTMENT	"Edges: Detect Amount"						'(6.0 1.0 10.0 1.0 0 2 0)
	SF-ADJUSTMENT	"Edges: Blur Pixels"						'(6.0 1.0 10.0 1.0 0 2 0)
	SF-TOGGLE		"Flatten Image"								FALSE
)
(script-fu-menu-register "210-Eg-SmartSeparateSharpen" "<Image>/Script-Fu/Sharpness/Sharper")
;