package qolaf.data {
	
	/**
	 * @author rydev
	 */
	
	public interface ISharedSettings {
		function getValue(fn:Function):Object;
		function modify(fn:Function):void;
	}
}