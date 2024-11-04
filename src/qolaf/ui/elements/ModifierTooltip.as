package qolaf.ui.elements {
	import core.scene.Game;
	import core.weapon.Debuff;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import qolaf.data.ModifierInfo;
	import qolaf.modifiers.IModifierTarget;
	import qolaf.modifiers.Modifier;
	import qolaf.utils.StringUtils;
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
	public class ModifierTooltip extends LayoutGroup {
		public static const MAX_WIDTH:int = 260;
		public static const MAX_HEIGHT:int = 210;
		public static const MODIFIER_NAME_TEMPLATE:String = "[name] [stacks]";
		
		private var _target:IModifierTarget;
		private var _modifier:Modifier;
		private var _title:TextField;
		private var _time:TextField;
		private var _description:TextField;
		
		public function ModifierTooltip() {
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
			
			
			_title = new TextField(MAX_WIDTH * 0.75, 15, "Unknown Debuff", new TextFormat("DAIDRR", 12, 0xffffff, Align.LEFT, Align.TOP));
			titleAndTimeGroup.addChild(_title);
			_time = new TextField(MAX_WIDTH * 0.25, 15, "0h 0m 0s", new TextFormat("DAIDRR", 12, 0xffffff, Align.RIGHT, Align.TOP));
			titleAndTimeGroup.addChild(_time);
			addChild(titleAndTimeGroup);
			_description = new TextField(MAX_WIDTH, 0, "", new TextFormat("DAIDRR", 12, 0xffffff, Align.LEFT, Align.TOP));
			_description.isHtmlText = true;
			_description.autoSize = TextFieldAutoSize.VERTICAL;
			addChild(_description);
		}
		
		private function onEnterFrame(e:EnterFrameEvent):void {
			x = Starling.current.nativeOverlay.mouseX + 5;
			y = Starling.current.nativeOverlay.mouseY + 5;
			
			if (_modifier != null && _target != null) {
				_time.text = modifier.indeterminate ? "Ind.." : StringUtils.formatTime(modifier.currentDuration);
				_time.format.color = modifier.indeterminate ? 0xffffff : modifier.currentDuration <= 10000 ? 0xff0000 : 0xffffff;
			}
		}
		
		public function get modifier():Modifier {
			return _modifier;
		}
		
		public function get target():IModifierTarget {
			return _target;
		}
		
		public function setModifier(target:IModifierTarget, modifier:Modifier):void {
			_modifier = modifier;
			_target = target;
			
			if (modifier != null && target != null) {
				var debuffInfo:Object = ModifierInfo.getModifier(modifier.id);
				var name:String = debuffInfo != null ? debuffInfo.name : "Unknown Debuff";
				var description:String = debuffInfo != null ? (target.isLocalPlayer() ? debuffInfo["self_description"] : debuffInfo["enemy_description"]) : "Unknown Debuff Description";
				
				_title.text = StringUtils.substitute(ModifierTooltip.MODIFIER_NAME_TEMPLATE, {
					"[name]": name,
					"[stacks]": Debuff.canStack(modifier.id) ? ("x" + modifier.stacks) : ""
				});
				
				_time.text = modifier.indeterminate ? "Ind.." : StringUtils.formatTime(modifier.currentDuration);
				_time.format.color = modifier.indeterminate ? 0xffffff : modifier.currentDuration <= 10000 ? 0xff0000 : 0xffffff;
				
				_description.text = StringUtils.substitute(description, {
					"[enemy]": _target.getTrueName()
				});
				readjustLayout();
			}
			visible = modifier != null;
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
		
		public function set descriptionText(text:String):void {
			_description.text = text;
			readjustLayout();
		}
	}
}