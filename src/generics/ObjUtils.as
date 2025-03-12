package generics
{
	
	public class ObjUtils
	{
		public function ObjUtils()
		{
			super();
		}
		
		public static function ToVector(param1:Object, param2:Boolean = false, param3:String = "name"):Vector.<Object>
		{
			var key:String;
			var input:Object = param1;
			var sort:Boolean = param2;
			var sortBy:String = param3;
			var output:Vector.<Object> = new Vector.<Object>();
			for (key in input)
			{
				output.push(input[key]);
			}
			if (sort)
			{
				output.sort(function(param1:Object, param2:Object):int
				{
					if (param1[sortBy] > param2[sortBy])
					{
						return 1;
					}
					return -1;
				});
			}
			return output;
		}
	}
}
