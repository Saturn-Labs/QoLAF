package qolaf.ui.debuff {
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	import qolaf.debuff.DebuffEffect;
	import qolaf.utils.ObjectPool;
	import qolaf.utils.StringUtils;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	
	/**
	 * @author rydev
	 */
	public class DebuffDisplay extends LayoutGroup {
		private var _pool:ObjectPool;
		
		public function DebuffDisplay() {
			_pool = new ObjectPool(createTextField, resetTextField);
			
			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			verticalLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout = verticalLayout;
		}
		
		private function createTextField():TextField {
			var field:TextField = new TextField(0, 15, "", new TextFormat("DAIDRR", 12, 0xffffff));
			field.autoSize = TextFieldAutoSize.HORIZONTAL;
			return field;
		}
		
		private function resetTextField(field:TextField):void {
			field.text = "";
		}
		
		public function updateDebuffs(debuffs:Vector.<DebuffEffect>):void {
			for (var i:int = 0; i < numChildren; i++) {
				var child:DisplayObject = getChildAt(i);
				if (child is TextField) {
					_pool.recycleOne(child);
				}
			}
			removeChildren();
			
			for each (var debuff:DebuffEffect in debuffs) {
				var textField:TextField = _pool.getOne() as TextField;
				textField.text = StringUtils.substitute("Debuff: [id], [time], x[stacks]", {
					"[id]": debuff.debuff,
					"[time]": debuff.currentDuration,
					"[stacks]": debuff.stacks
				});
				addChild(textField);
			}
		}
	}
}