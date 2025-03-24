package com.google.analytics.debug {
	import flash.display.Graphics;
	
	public class Background {
		public function Background() {
			super();
		}
		
		public static function drawRounded(target:*, g:Graphics, width:uint = 0, height:uint = 0) : void {
			var _local5:uint = 0;
			var _local6:uint = 0;
			var _local7:uint = uint(Style.roundedCorner);
			if(width > 0 && height > 0) {
				_local5 = width;
				_local6 = height;
			} else {
				_local5 = uint(target.width);
				_local6 = uint(target.height);
			}
			if(Boolean(target.stickToEdge) && target.alignement != Align.none) {
				switch(target.alignement) {
					case Align.top:
						g.drawRoundRectComplex(0,0,_local5,_local6,0,0,_local7,_local7);
						break;
					case Align.topLeft:
						g.drawRoundRectComplex(0,0,_local5,_local6,0,0,0,_local7);
						break;
					case Align.topRight:
						g.drawRoundRectComplex(0,0,_local5,_local6,0,0,_local7,0);
						break;
					case Align.bottom:
						g.drawRoundRectComplex(0,0,_local5,_local6,_local7,_local7,0,0);
						break;
					case Align.bottomLeft:
						g.drawRoundRectComplex(0,0,_local5,_local6,0,_local7,0,0);
						break;
					case Align.bottomRight:
						g.drawRoundRectComplex(0,0,_local5,_local6,_local7,0,0,0);
						break;
					case Align.left:
						g.drawRoundRectComplex(0,0,_local5,_local6,0,_local7,0,_local7);
						break;
					case Align.right:
						g.drawRoundRectComplex(0,0,_local5,_local6,_local7,0,_local7,0);
						break;
					case Align.center:
						g.drawRoundRect(0,0,_local5,_local6,_local7,_local7);
				}
			} else {
				g.drawRoundRect(0,0,_local5,_local6,_local7,_local7);
			}
		}
	}
}

