package feathers.controls.text {
	public class MeasureTextResult {
		public var width:Number;
		
		public var height:Number;
		
		public var isTruncated:Boolean;
		
		public function MeasureTextResult(width:Number = 0, height:Number = 0, isTruncated:Boolean = false) {
			super();
			this.width = width;
			this.height = height;
			this.isTruncated = isTruncated;
		}
	}
}

