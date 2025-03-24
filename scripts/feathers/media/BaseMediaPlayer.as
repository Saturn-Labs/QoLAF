package feathers.media {
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.errors.AbstractClassError;
	import starling.events.Event;
	
	public class BaseMediaPlayer extends LayoutGroup implements IMediaPlayer {
		public function BaseMediaPlayer() {
			super();
			if(Object(this).constructor === BaseMediaPlayer) {
				throw new AbstractClassError();
			}
			this.addEventListener("added",mediaPlayer_addedHandler);
			this.addEventListener("removed",mediaPlayer_removedHandler);
		}
		
		override protected function initialize() : void {
			if(!this._layout) {
				this.layout = new AnchorLayout();
			}
			super.initialize();
		}
		
		protected function handleAddedChild(child:DisplayObject) : void {
			var _local2:DisplayObjectContainer = null;
			var _local4:int = 0;
			var _local3:int = 0;
			if(child is IMediaPlayerControl) {
				IMediaPlayerControl(child).mediaPlayer = this;
			}
			if(child is DisplayObjectContainer) {
				_local2 = DisplayObjectContainer(child);
				_local4 = _local2.numChildren;
				_local3 = 0;
				while(_local3 < _local4) {
					child = _local2.getChildAt(_local3);
					this.handleAddedChild(child);
					_local3++;
				}
			}
		}
		
		protected function handleRemovedChild(child:DisplayObject) : void {
			var _local2:DisplayObjectContainer = null;
			var _local4:int = 0;
			var _local3:int = 0;
			if(child is IMediaPlayerControl) {
				IMediaPlayerControl(child).mediaPlayer = null;
			}
			if(child is DisplayObjectContainer) {
				_local2 = DisplayObjectContainer(child);
				_local4 = _local2.numChildren;
				_local3 = 0;
				while(_local3 < _local4) {
					child = _local2.getChildAt(_local3);
					this.handleRemovedChild(child);
					_local3++;
				}
			}
		}
		
		protected function mediaPlayer_addedHandler(event:Event) : void {
			var _local2:DisplayObject = DisplayObject(event.target);
			this.handleAddedChild(_local2);
		}
		
		protected function mediaPlayer_removedHandler(event:Event) : void {
			var _local2:DisplayObject = DisplayObject(event.target);
			this.handleRemovedChild(_local2);
		}
	}
}

