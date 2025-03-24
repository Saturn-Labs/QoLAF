package generics {
	public class ObjUtils {
		public function ObjUtils() {
			super();
		}
		
		public static function ToVector(input:Object, sort:Boolean = false, sortBy:String = "name") : Vector.<Object> {
			var key:String;
			var output:Vector.<Object> = new Vector.<Object>();
			for(key in input) {
				output.push(input[key]);
			}
			if(sort) {
				output.sort(function(param1:Object, param2:Object):int {
					if(param1[sortBy] > param2[sortBy]) {
						return 1;
					}
					return -1;
				});
			}
			return output;
		}
	}
}

