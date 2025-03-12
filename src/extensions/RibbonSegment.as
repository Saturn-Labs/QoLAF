package extensions
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import starling.utils.MatrixUtil;
	
	public class RibbonSegment
	{
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sHelperPoint:Point = new Point();
		public var ribbonTrail:RibbonTrail;
		
		public var x0:Number = 0;
		public var y0:Number = 0;
		public var x1:Number = 0;
		public var y1:Number = 0;
		public var alpha:Number = 1;
		public function RibbonSegment()
		{
			super();
		}
		
		public function tweenTo(param1:RibbonSegment):void
		{
			var _loc2_:Number = ribbonTrail.movingRatio;
			x0 += (param1.x0 - x0) * _loc2_;
			y0 += (param1.y0 - y0) * _loc2_;
			x1 += (param1.x1 - x1) * _loc2_;
			y1 += (param1.y1 - y1) * _loc2_;
			alpha = param1.alpha * ribbonTrail.alphaRatio;
		}
		
		public function setTo(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 1):void
		{
			this.x0 = param1;
			this.y0 = param2;
			this.x1 = param3;
			this.y1 = param4;
			this.alpha = param5;
		}
		
		public function setTo2(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 1):void
		{
			if (param4 == 0)
			{
				this.x0 = param1;
				this.y0 = param2 - param3;
				this.x1 = param1;
				this.y1 = param2 + param3;
			}
			else
			{
				sHelperMatrix.identity();
				sHelperMatrix.rotate(param4);
				MatrixUtil.transformCoords(sHelperMatrix, 0, -param3, sHelperPoint);
				this.x0 = param1 + sHelperPoint.x;
				this.y0 = param2 + sHelperPoint.y;
				MatrixUtil.transformCoords(sHelperMatrix, 0, param3, sHelperPoint);
				this.x1 = param1 + sHelperPoint.x;
				this.y1 = param2 + sHelperPoint.y;
			}
			this.alpha = param5;
		}
		
		public function copyFrom(param1:RibbonSegment):void
		{
			x0 = param1.x0;
			y0 = param1.y0;
			x1 = param1.x1;
			y1 = param1.y1;
			alpha = param1.alpha;
		}
		
		public function toString():String
		{
			return "[TrailSegment \nx0= " + x0 + ", " + "y0= " + y0 + ", " + "x1= " + x1 + ", " + "y1= " + y1 + ", " + "alpha= " + alpha + "]";
		}
	}
}
