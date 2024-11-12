package qolaf.data
{
	import core.scene.SceneBase;
	import core.scene.Game;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.geom.Point;
	import flash.net.SharedObject;

	/**
	 * @author rydev
	 */
	public class SharedSettings implements ISharedSettings
	{
		private var _sceneBase:SceneBase;
		private var _handler:IDataHandler;
		public var sharedObject:SharedObject;
		
		public function SharedSettings(sceneBase:SceneBase)
		{
			this._sceneBase = sceneBase;
			sharedObject = SharedObject.getLocal("QoLAFSettings");
			this._handler = new DataHandler(this);
		}
		
		public function getValue(fn:Function):Object {
			return fn(_handler);
		}
		
		public function modify(fn:Function):void {
			fn(_handler);
			sharedObject.flush();
		}
	}
}