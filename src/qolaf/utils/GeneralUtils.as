package qolaf.utils 
{
	/**
	 * @author pancake
	 */
	public class GeneralUtils 
	{
		public static function clamp(value:Number, min:Number, max:Number) : Number
		{
			return Math.max(min, Math.min(value, max));
		}
	}

}