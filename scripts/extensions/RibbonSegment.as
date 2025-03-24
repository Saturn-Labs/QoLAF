package extensions {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.utils.MatrixUtil;
	
	public class RibbonSegment {
		private static var sHelperMatrix:Matrix = new Matrix();
		
		private static var sHelperPoint:Point = new Point();
		
		public var ribbonTrail:RibbonTrail;
		
		public var x0:Number = 0;
		
		public var y0:Number = 0;
		
		public var x1:Number = 0;
		
		public var y1:Number = 0;
		
		public var alpha:Number = 1;
		
		public function RibbonSegment() {
			super();
		}
		
		public function tweenTo(preTrailSegment:RibbonSegment) : void {
			var _local2:Number = ribbonTrail.movingRatio;
			x0 += (preTrailSegment.x0 - x0) * _local2;
			y0 += (preTrailSegment.y0 - y0) * _local2;
			x1 += (preTrailSegment.x1 - x1) * _local2;
			y1 += (preTrailSegment.y1 - y1) * _local2;
			alpha = preTrailSegment.alpha * ribbonTrail.alphaRatio;
		}
		
		public function setTo(x0:Number, y0:Number, x1:Number, y1:Number, alpha:Number = 1) : void {
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
			this.alpha = alpha;
		}
		
		public function setTo2(centerX:Number, centerY:Number, radius:Number, rotation:Number, alpha:Number = 1) : void {
			if(rotation == 0) {
				this.x0 = centerX;
				this.y0 = centerY - radius;
				this.x1 = centerX;
				this.y1 = centerY + radius;
			} else {
				sHelperMatrix.identity();
				sHelperMatrix.rotate(rotation);
				MatrixUtil.transformCoords(sHelperMatrix,0,-radius,sHelperPoint);
				this.x0 = centerX + sHelperPoint.x;
				this.y0 = centerY + sHelperPoint.y;
				MatrixUtil.transformCoords(sHelperMatrix,0,radius,sHelperPoint);
				this.x1 = centerX + sHelperPoint.x;
				this.y1 = centerY + sHelperPoint.y;
			}
			this.alpha = alpha;
		}
		
		public function copyFrom(trailSegment:RibbonSegment) : void {
			x0 = trailSegment.x0;
			y0 = trailSegment.y0;
			x1 = trailSegment.x1;
			y1 = trailSegment.y1;
			alpha = trailSegment.alpha;
		}
		
		public function toString() : String {
			return "[TrailSegment \nx0= " + x0 + ", " + "y0= " + y0 + ", " + "x1= " + x1 + ", " + "y1= " + y1 + ", " + "alpha= " + alpha + "]";
		}
	}
}

