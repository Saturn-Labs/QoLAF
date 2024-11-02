package qolaf.ui.elements {
	import core.scene.Game;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import feathers.controls.LayoutGroup;
	import starling.text.TextField;
	import starling.utils.Align;
	
	/**
	 * @author rydev
	 */
	public class DebuffInfoTooltip extends LayoutGroup {
		public static const MAX_WIDTH:int = 260;
		public static const MAX_HEIGHT:int = 210;
		public static const DEBUFF_NAME_TEMPLATE:String = "[name] x[stacks]";
		
		private var _title:TextField;
		private var _time:TextField;
		private var _description:TextField;
		
		public function DebuffInfoTooltip() {
			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			verticalLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			verticalLayout.gap = 3;
			verticalLayout.padding = 1;
			layout = verticalLayout;
			backgroundSkin = new Quad(1, 1, 0x0);
			createComponents();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function createComponents():void {
			var titleAndTimeGroup:LayoutGroup = new LayoutGroup();
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			titleAndTimeGroup.layout = hLayout;
			
			
			_title = new TextField(MAX_WIDTH * 0.75, 15, "Unknown Debuff x1", new TextFormat("DAIDRR", 12, 0xffffff, Align.LEFT, Align.TOP));
			titleAndTimeGroup.addChild(_title);
			_time = new TextField(MAX_WIDTH * 0.25, 15, "0h 0m 0s", new TextFormat("DAIDRR", 12, 0xffffff, Align.RIGHT, Align.TOP));
			titleAndTimeGroup.addChild(_time);
			addChild(titleAndTimeGroup);
			_description = new TextField(MAX_WIDTH, MAX_HEIGHT - _time.x, "", new TextFormat("DAIDRR", 12, 0xffffff, Align.LEFT, Align.TOP));
			_description.wordWrap = true;
			_description.isHtmlText = true;
			_description.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_description);
		}
		
		private function onEnterFrame(e:EnterFrameEvent):void {
			x = Starling.current.nativeOverlay.mouseX + 5;
			y = Starling.current.nativeOverlay.mouseY + 5;
		}
		
		public function get title():TextField {
			return _title;
		}
		
		public function get time():TextField {
			return _time;
		}
		
		public function get description():TextField {
			return _description;
		}
	}
}