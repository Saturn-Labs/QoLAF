package feathers.controls.popups {
	import feathers.controls.Callout;
	import flash.errors.IllegalOperationError;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class CalloutPopUpContentManager extends EventDispatcher implements IPopUpContentManager {
		public var calloutFactory:Function;
		
		public var direction:String = "any";
		
		public var isModal:Boolean = true;
		
		protected var _overlayFactory:Function = null;
		
		protected var content:DisplayObject;
		
		protected var callout:Callout;
		
		public function CalloutPopUpContentManager() {
			super();
		}
		
		public function get overlayFactory() : Function {
			return this._overlayFactory;
		}
		
		public function set overlayFactory(value:Function) : void {
			this._overlayFactory = value;
		}
		
		public function get isOpen() : Boolean {
			return this.content !== null;
		}
		
		public function open(content:DisplayObject, source:DisplayObject) : void {
			if(this.isOpen) {
				throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
			}
			this.content = content;
			this.callout = Callout.show(content,source,this.direction,this.isModal,this.calloutFactory,this._overlayFactory);
			this.callout.addEventListener("removedFromStage",callout_removedFromStageHandler);
			this.dispatchEventWith("open");
		}
		
		public function close() : void {
			if(!this.isOpen) {
				return;
			}
			this.callout.close();
		}
		
		public function dispose() : void {
			this.close();
		}
		
		protected function cleanup() : void {
			this.content = null;
			this.callout.content = null;
			this.callout.removeEventListener("removedFromStage",callout_removedFromStageHandler);
			this.callout = null;
		}
		
		protected function callout_removedFromStageHandler(event:Event) : void {
			this.cleanup();
			this.dispatchEventWith("close");
		}
	}
}

