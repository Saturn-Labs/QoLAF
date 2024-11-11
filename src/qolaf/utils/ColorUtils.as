package qolaf.utils
{

	/**
	 * @author rydev
	 */
	public class ColorUtils
	{
		public static function rgb2hex(r:Number, g:Number, b:Number):uint
		{
			var nR:uint = uint(Math.round(255 * Math.max(0, Math.min(1, r))));
			var nG:uint = uint(Math.round(255 * Math.max(0, Math.min(1, g))));
			var nB:uint = uint(Math.round(255 * Math.max(0, Math.min(1, b))));
			return (nR << 16) | (nG << 8) | nB;
		}
	}
}