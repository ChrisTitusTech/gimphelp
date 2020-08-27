; 210_effects_blackboard-effect.scm
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
; Copyright (c) 2007 Pucelo for www.gimp.org.es
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Neither the name of copyright holders nor the names of its
;    contributors may be used to endorse or promote products derived
;    from this software without specific prior written permission.
; *
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL COPYRIGHT HOLDERS OR CONTRIBUTORS
; BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;==============================================================

(define (210-blackboard 
		img 
		drawable 
		copy 
		aplanar
		)
  (define image (if
    (= copy TRUE)
    (car (gimp-image-duplicate img))
    img
  ))
  (gimp-image-undo-group-start image)
  (if (not (= RGB (car (gimp-image-base-type image))))
			 (gimp-image-convert-rgb image))  
  (set! drawable (car (gimp-image-flatten image)))
  (define shadow-layer (car (gimp-layer-copy drawable 1)))
  (gimp-image-insert-layer image shadow-layer 0 -1)
  (gimp-item-set-name shadow-layer "Sat")
  (gimp-layer-set-mode shadow-layer 12)
  ; Create new layer and add to the image
  (define shadow-layer2 (car (gimp-layer-copy drawable 1)))
  (gimp-image-insert-layer image shadow-layer2 0 -1)
  (gimp-item-set-name shadow-layer2 "Hue / Tono")
  (gimp-layer-set-mode shadow-layer2 11)
  (plug-in-sobel 1 image drawable 1 1 0)
  (gimp-equalize drawable 0)
  (if 
    (= aplanar TRUE)
    (set! drawable (car (gimp-image-flatten image)))
    ()
  )
  (gimp-image-set-active-layer image drawable)
  (if
    (= copy TRUE)
    (gimp-display-new image)
    ()
  )
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
)

(script-fu-register "210-blackboard"
   "Blackboard Effect"
   "Simulates drawn on a blackboard with chalk colors. Works best on simple colors."
   "Is based in this script http://gimp.org/docs/scheme_plugin/scheme-sample.html by Simon Budig <simon@gimp.org> / Esta basado en ese guion de Simon Budig."
   "Pucelo (based on a Simon Budig sample script) for www.gimp.org.es"
   "2007/4/21"
   "*"
   SF-IMAGE "Image" 0
   SF-DRAWABLE "Drawable" 0
   SF-TOGGLE "Work on copy" TRUE
   SF-TOGGLE "Flatten image at finish" TRUE
)
(script-fu-menu-register "210-blackboard" "<Image>/Script-Fu/Effects")
