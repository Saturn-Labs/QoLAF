package starling.core {
	import flash.system.System;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.rendering.Painter;
	import starling.styles.MeshStyle;
	import starling.text.TextField;
	
	internal class StatsDisplay extends Sprite {
		private static const UPDATE_INTERVAL:Number = 0.5;
		
		private static const B_TO_MB:Number = 9.5367431640625e-7;
		
		private var _background:Quad;
		
		private var _labels:TextField;
		
		private var _values:TextField;
		
		private var _frameCount:int = 0;
		
		private var _totalTime:Number = 0;
		
		private var _fps:Number = 0;
		
		private var _memory:Number = 0;
		
		private var _gpuMemory:Number = 0;
		
		private var _drawCount:int = 0;
		
		private var _skipCount:int = 0;
		
		public function StatsDisplay() {
			var _local1:String = null;
			_local1 = "mini";
			var _local3:Number = NaN;
			_local3 = -1;
			var _local4:* = 0;
			_local4 = 16777215;
			var _local2:Number = NaN;
			_local2 = 90;
			super();
			var _local6:Number = supportsGpuMem ? 35 : 27;
			var _local5:String = supportsGpuMem ? "\ngpu memory:" : "";
			var _local7:String = "frames/sec:\nstd memory:" + _local5 + "\ndraw calls:";
			_labels = new TextField(90,_local6,_local7);
			_labels.format.setTo("mini",-1,16777215,"left");
			_labels.batchable = true;
			_labels.x = 2;
			_values = new TextField(90 - 1,_local6,"");
			_values.format.setTo("mini",-1,16777215,"right");
			_values.batchable = true;
			_background = new Quad(90,_local6,0);
			if(_background.style.type != MeshStyle) {
				_background.style = new MeshStyle();
			}
			if(_labels.style.type != MeshStyle) {
				_labels.style = new MeshStyle();
			}
			if(_values.style.type != MeshStyle) {
				_values.style = new MeshStyle();
			}
			addChild(_background);
			addChild(_labels);
			addChild(_values);
			addEventListener("addedToStage",onAddedToStage);
			addEventListener("removedFromStage",onRemovedFromStage);
		}
		
		private function onAddedToStage() : void {
			addEventListener("enterFrame",onEnterFrame);
			_totalTime = _frameCount = _skipCount = 0;
			update();
		}
		
		private function onRemovedFromStage() : void {
			removeEventListener("enterFrame",onEnterFrame);
		}
		
		private function onEnterFrame(event:EnterFrameEvent) : void {
			_totalTime += event.passedTime;
			_frameCount++;
			if(_totalTime > 0.5) {
				update();
				_frameCount = _skipCount = _totalTime = 0;
			}
		}
		
		public function update() : void {
			_background.color = _skipCount > _frameCount / 2 ? 0x3f00 : 0;
			_fps = _totalTime > 0 ? _frameCount / _totalTime : 0;
			_memory = System.totalMemory * 9.5367431640625e-7;
			_gpuMemory = supportsGpuMem ? Starling.context["totalGPUMemory"] * 9.5367431640625e-7 : -1;
			var _local1:String = _fps.toFixed(_fps < 100 ? 1 : 0);
			var _local3:String = _memory.toFixed(_memory < 100 ? 1 : 0);
			var _local2:String = _gpuMemory.toFixed(_gpuMemory < 100 ? 1 : 0);
			var _local4:String = (_totalTime > 0 ? _drawCount - 2 : _drawCount).toString();
			_values.text = _local1 + "\n" + _local3 + "\n" + (_gpuMemory >= 0 ? _local2 + "\n" : "") + _local4;
		}
		
		public function markFrameAsSkipped() : void {
			_skipCount += 1;
		}
		
		override public function render(painter:Painter) : void {
			painter.excludeFromCache(this);
			painter.finishMeshBatch();
			super.render(painter);
		}
		
		private function get supportsGpuMem() : Boolean {
			return "totalGPUMemory" in Starling.context;
		}
		
		public function get drawCount() : int {
			return _drawCount;
		}
		
		public function set drawCount(value:int) : void {
			_drawCount = value;
		}
		
		public function get fps() : Number {
			return _fps;
		}
		
		public function set fps(value:Number) : void {
			_fps = value;
		}
		
		public function get memory() : Number {
			return _memory;
		}
		
		public function set memory(value:Number) : void {
			_memory = value;
		}
		
		public function get gpuMemory() : Number {
			return _gpuMemory;
		}
		
		public function set gpuMemory(value:Number) : void {
			_gpuMemory = value;
		}
	}
}

