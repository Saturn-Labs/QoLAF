package feathers.controls {
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.skins.IStyleProvider;
	import feathers.utils.math.roundDownToNearest;
	import feathers.utils.math.roundUpToNearest;
	import flash.globalization.DateTimeFormatter;
	import starling.events.Event;
	
	public class DateTimeSpinner extends FeathersControl {
		public static const DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-date-time-spinner-list";
		
		public static const EDITING_MODE_DATE_AND_TIME:String = "dateAndTime";
		
		public static const EDITING_MODE_TIME:String = "time";
		
		public static const EDITING_MODE_DATE:String = "date";
		
		private static const MS_PER_DAY:int = 86400000;
		
		private static const MIN_MONTH_VALUE:int = 0;
		
		private static const MAX_MONTH_VALUE:int = 11;
		
		private static const MIN_DATE_VALUE:int = 1;
		
		private static const MAX_DATE_VALUE:int = 31;
		
		private static const MIN_HOURS_VALUE:int = 0;
		
		private static const MAX_HOURS_VALUE_12HOURS:int = 11;
		
		private static const MAX_HOURS_VALUE_24HOURS:int = 23;
		
		private static const MIN_MINUTES_VALUE:int = 0;
		
		private static const MAX_MINUTES_VALUE:int = 59;
		
		protected static const INVALIDATION_FLAG_LOCALE:String = "locale";
		
		protected static const INVALIDATION_FLAG_EDITING_MODE:String = "editingMode";
		
		protected static const INVALIDATION_FLAG_PENDING_SCROLL:String = "pendingScroll";
		
		protected static const INVALIDATION_FLAG_SPINNER_LIST_FACTORY:String = "spinnerListFactory";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_DATE:Date = new Date();
		
		private static const DAYS_IN_MONTH:Vector.<int> = new Vector.<int>(0);
		
		protected var listStyleName:String = "feathers-date-time-spinner-list";
		
		protected var monthsList:SpinnerList;
		
		protected var datesList:SpinnerList;
		
		protected var yearsList:SpinnerList;
		
		protected var dateAndTimeDatesList:SpinnerList;
		
		protected var hoursList:SpinnerList;
		
		protected var minutesList:SpinnerList;
		
		protected var meridiemList:SpinnerList;
		
		protected var listGroup:LayoutGroup;
		
		protected var _locale:String = "i-default";
		
		protected var _value:Date;
		
		protected var _minimum:Date;
		
		protected var _maximum:Date;
		
		protected var _minuteStep:int = 1;
		
		protected var _editingMode:String = "dateAndTime";
		
		protected var _formatter:DateTimeFormatter;
		
		protected var _longestMonthNameIndex:int;
		
		protected var _localeMonthNames:Vector.<String>;
		
		protected var _localeWeekdayNames:Vector.<String>;
		
		protected var _ignoreListChanges:Boolean = false;
		
		protected var _monthFirst:Boolean = true;
		
		protected var _showMeridiem:Boolean = true;
		
		protected var _lastMeridiemValue:int = 0;
		
		protected var _listMinYear:int;
		
		protected var _listMaxYear:int;
		
		protected var _minYear:int;
		
		protected var _maxYear:int;
		
		protected var _minMonth:int;
		
		protected var _maxMonth:int;
		
		protected var _minDate:int;
		
		protected var _maxDate:int;
		
		protected var _minHours:int;
		
		protected var _maxHours:int;
		
		protected var _minMinute:int;
		
		protected var _maxMinute:int;
		
		protected var _scrollDuration:Number = 0.5;
		
		protected var _itemRendererFactory:Function;
		
		protected var _listFactory:Function;
		
		protected var _customListStyleName:String;
		
		protected var _lastValidate:Date;
		
		protected var _todayLabel:String = null;
		
		protected var _amString:String;
		
		protected var _pmString:String;
		
		protected var pendingScrollToDate:Date;
		
		protected var pendingScrollDuration:Number;
		
		public function DateTimeSpinner() {
			var _local1:int = 0;
			super();
			if(DAYS_IN_MONTH.length === 0) {
				HELPER_DATE.setFullYear(2015);
				_local1 = 0;
				while(_local1 <= 11) {
					HELPER_DATE.setMonth(_local1 + 1,-1);
					DAYS_IN_MONTH[_local1] = HELPER_DATE.date + 1;
					_local1++;
				}
				DAYS_IN_MONTH.fixed = true;
			}
		}
		
		protected static function defaultListFactory() : SpinnerList {
			return new SpinnerList();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return DateTimeSpinner.globalStyleProvider;
		}
		
		public function get locale() : String {
			return this._locale;
		}
		
		public function set locale(value:String) : void {
			if(this._locale == value) {
				return;
			}
			this._locale = value;
			this._formatter = null;
			this.invalidate("locale");
		}
		
		public function get value() : Date {
			return this._value;
		}
		
		public function set value(value:Date) : void {
			var _local2:Number = value.time;
			if(this._minimum && this._minimum.time > _local2) {
				_local2 = this._minimum.time;
			}
			if(this._maximum && this._maximum.time < _local2) {
				_local2 = this._maximum.time;
			}
			if(this._value && this._value.time === _local2) {
				return;
			}
			this._value = new Date(_local2);
			this.invalidate("data");
		}
		
		public function get minimum() : Date {
			return this._minimum;
		}
		
		public function set minimum(value:Date) : void {
			if(this._minimum == value) {
				return;
			}
			this._minimum = value;
			this.invalidate("data");
		}
		
		public function get maximum() : Date {
			return this._maximum;
		}
		
		public function set maximum(value:Date) : void {
			if(this._maximum == value) {
				return;
			}
			this._maximum = value;
			this.invalidate("data");
		}
		
		public function get minuteStep() : int {
			return this._minuteStep;
		}
		
		public function set minuteStep(value:int) : void {
			if(60 % value !== 0) {
				throw new ArgumentError("minuteStep must evenly divide into 60.");
			}
			if(this._minuteStep == value) {
				return;
			}
			this._minuteStep = value;
			this.invalidate("data");
		}
		
		public function get editingMode() : String {
			return this._editingMode;
		}
		
		public function set editingMode(value:String) : void {
			if(this._editingMode == value) {
				return;
			}
			this._editingMode = value;
			this.invalidate("editingMode");
		}
		
		public function get scrollDuration() : Number {
			return this._scrollDuration;
		}
		
		public function set scrollDuration(value:Number) : void {
			this._scrollDuration = value;
		}
		
		public function get itemRendererFactory() : Function {
			return this._itemRendererFactory;
		}
		
		public function set itemRendererFactory(value:Function) : void {
			if(this._itemRendererFactory === value) {
				return;
			}
			this._itemRendererFactory = value;
			this.invalidate("spinnerListFactory");
		}
		
		public function get listFactory() : Function {
			return this._listFactory;
		}
		
		public function set listFactory(value:Function) : void {
			if(this._listFactory == value) {
				return;
			}
			this._listFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customListStyleName() : String {
			return this._customListStyleName;
		}
		
		public function set customListStyleName(value:String) : void {
			if(this._customListStyleName == value) {
				return;
			}
			this._customListStyleName = value;
			this.invalidate("spinnerListFactory");
		}
		
		public function get todayLabel() : String {
			return this._todayLabel;
		}
		
		public function set todayLabel(value:String) : void {
			if(this._todayLabel == value) {
				return;
			}
			this._todayLabel = value;
			this.invalidate("data");
		}
		
		public function scrollToDate(date:Date, animationDuration:Number = NaN) : void {
			if(this.pendingScrollToDate && this.pendingScrollToDate.time === date.time && this.pendingScrollDuration === animationDuration) {
				return;
			}
			this.pendingScrollToDate = date;
			this.pendingScrollDuration = animationDuration;
			this.invalidate("pendingScroll");
		}
		
		override protected function initialize() : void {
			var _local1:HorizontalLayout = null;
			if(!this.listGroup) {
				_local1 = new HorizontalLayout();
				_local1.horizontalAlign = "center";
				_local1.verticalAlign = "justify";
				this.listGroup = new LayoutGroup();
				this.listGroup.layout = _local1;
				this.addChild(this.listGroup);
			}
		}
		
		override protected function draw() : void {
			var _local4:Boolean = this.isInvalid("editingMode");
			var _local3:Boolean = this.isInvalid("locale");
			var _local2:Boolean = this.isInvalid("data");
			var _local5:Boolean = this.isInvalid("pendingScroll");
			var _local1:Boolean = this.isInvalid("spinnerListFactory");
			if(this._todayLabel) {
				this._lastValidate = new Date();
			}
			if(_local3 || _local4) {
				this.refreshLocale();
			}
			if(_local3 || _local4 || _local1) {
				this.refreshLists(_local4 || _local1,_local3);
			}
			if(_local3 || _local4 || _local2 || _local1) {
				this.useDefaultsIfNeeded();
				this.refreshValidRanges();
				this.refreshSelection();
			}
			this.autoSizeIfNeeded();
			this.layoutChildren();
			if(_local5) {
				this.handlePendingScroll();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local1:* = this._explicitWidth !== this._explicitWidth;
			var _local3:* = this._explicitHeight !== this._explicitHeight;
			var _local2:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local4:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local1 && !_local3 && !_local2 && !_local4) {
				return false;
			}
			this.listGroup.width = this._explicitWidth;
			this.listGroup.height = this._explicitHeight;
			this.listGroup.minWidth = this._explicitMinWidth;
			this.listGroup.minHeight = this._explicitMinHeight;
			this.listGroup.validate();
			return this.saveMeasurements(this.listGroup.width,this.listGroup.height,this.listGroup.minWidth,this.listGroup.minHeight);
		}
		
		protected function refreshLists(createNewLists:Boolean, localeChanged:Boolean) : void {
			var _local3:ListCollection = null;
			var _local4:ListCollection = null;
			if(createNewLists) {
				this.createYearList();
				this.createMonthList();
				this.createDateList();
				this.createHourList();
				this.createMinuteList();
				this.createMeridiemList();
				this.createDateAndTimeDateList();
			} else if(this._showMeridiem && !this.meridiemList || !this._showMeridiem && this.meridiemList) {
				this.createMeridiemList();
			}
			if(this._editingMode == "date") {
				if(this._monthFirst) {
					this.listGroup.setChildIndex(this.monthsList,0);
				} else {
					this.listGroup.setChildIndex(this.datesList,0);
				}
			}
			if(localeChanged) {
				if(this.monthsList) {
					_local3 = this.monthsList.dataProvider;
					if(_local3) {
						_local3.updateAll();
					}
				}
				if(this.dateAndTimeDatesList) {
					_local4 = this.dateAndTimeDatesList.dataProvider;
					if(_local4) {
						_local4.updateAll();
					}
				}
			}
		}
		
		protected function createYearList() : void {
			if(this.yearsList) {
				this.listGroup.removeChild(this.yearsList,true);
				this.yearsList = null;
			}
			if(this._editingMode !== "date") {
				return;
			}
			var _local1:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.yearsList = SpinnerList(_local1());
			var _local2:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.yearsList.styleNameList.add(_local2);
			this.yearsList.itemRendererFactory = this.yearsListItemRendererFactory;
			this.yearsList.addEventListener("change",yearsList_changeHandler);
			this.listGroup.addChild(this.yearsList);
		}
		
		protected function createMonthList() : void {
			if(this.monthsList) {
				this.listGroup.removeChild(this.monthsList,true);
				this.monthsList = null;
			}
			if(this._editingMode !== "date") {
				return;
			}
			var _local2:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.monthsList = SpinnerList(_local2());
			var _local4:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.monthsList.styleNameList.add(_local4);
			var _local1:IntegerRange = new IntegerRange(0,11,1);
			var _local3:ListCollection = new ListCollection(_local1);
			_local3.dataDescriptor = new IntegerRangeDataDescriptor();
			this.monthsList.dataProvider = _local3;
			this.monthsList.typicalItem = this._longestMonthNameIndex;
			this.monthsList.itemRendererFactory = this.monthsListItemRendererFactory;
			this.monthsList.addEventListener("change",monthsList_changeHandler);
			this.listGroup.addChildAt(this.monthsList,0);
		}
		
		protected function createDateList() : void {
			if(this.datesList) {
				this.listGroup.removeChild(this.datesList,true);
				this.datesList = null;
			}
			if(this._editingMode !== "date") {
				return;
			}
			var _local3:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.datesList = SpinnerList(_local3());
			var _local4:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.datesList.styleNameList.add(_local4);
			var _local1:IntegerRange = new IntegerRange(1,31,1);
			var _local2:ListCollection = new ListCollection(_local1);
			_local2.dataDescriptor = new IntegerRangeDataDescriptor();
			this.datesList.dataProvider = _local2;
			this.datesList.itemRendererFactory = this.datesListItemRendererFactory;
			this.datesList.addEventListener("change",datesList_changeHandler);
			this.listGroup.addChildAt(this.datesList,0);
		}
		
		protected function createHourList() : void {
			if(this.hoursList) {
				this.listGroup.removeChild(this.hoursList,true);
				this.hoursList = null;
			}
			if(this._editingMode === "date") {
				return;
			}
			var _local1:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.hoursList = SpinnerList(_local1());
			var _local2:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.hoursList.styleNameList.add(_local2);
			this.hoursList.itemRendererFactory = this.hoursListItemRendererFactory;
			this.hoursList.addEventListener("change",hoursList_changeHandler);
			this.listGroup.addChild(this.hoursList);
		}
		
		protected function createMinuteList() : void {
			if(this.minutesList) {
				this.listGroup.removeChild(this.minutesList,true);
				this.minutesList = null;
			}
			if(this._editingMode === "date") {
				return;
			}
			var _local1:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.minutesList = SpinnerList(_local1());
			var _local4:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.minutesList.styleNameList.add(_local4);
			var _local3:IntegerRange = new IntegerRange(0,59,this._minuteStep);
			var _local2:ListCollection = new ListCollection(_local3);
			_local2.dataDescriptor = new IntegerRangeDataDescriptor();
			this.minutesList.dataProvider = _local2;
			this.minutesList.itemRendererFactory = this.minutesListItemRendererFactory;
			this.minutesList.addEventListener("change",minutesList_changeHandler);
			this.listGroup.addChild(this.minutesList);
		}
		
		protected function createMeridiemList() : void {
			if(this.meridiemList) {
				this.listGroup.removeChild(this.meridiemList,true);
				this.meridiemList = null;
			}
			if(!this._showMeridiem) {
				return;
			}
			var _local1:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.meridiemList = SpinnerList(_local1());
			var _local2:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.meridiemList.styleNameList.add(_local2);
			this.meridiemList.itemRendererFactory = this.meridiemListItemRendererFactory;
			this.meridiemList.addEventListener("change",meridiemList_changeHandler);
			this.listGroup.addChild(this.meridiemList);
		}
		
		protected function createDateAndTimeDateList() : void {
			if(this.dateAndTimeDatesList) {
				this.listGroup.removeChild(this.dateAndTimeDatesList,true);
				this.dateAndTimeDatesList = null;
			}
			if(this._editingMode !== "dateAndTime") {
				return;
			}
			var _local1:Function = this._listFactory !== null ? this._listFactory : defaultListFactory;
			this.dateAndTimeDatesList = SpinnerList(_local1());
			var _local2:String = this._customListStyleName !== null ? this._customListStyleName : this.listStyleName;
			this.dateAndTimeDatesList.styleNameList.add(_local2);
			this.dateAndTimeDatesList.itemRendererFactory = this.dateAndTimeDatesListItemRendererFactory;
			this.dateAndTimeDatesList.addEventListener("change",dateAndTimeDatesList_changeHandler);
			this.dateAndTimeDatesList.typicalItem = {};
			this.listGroup.addChildAt(this.dateAndTimeDatesList,0);
		}
		
		protected function refreshLocale() : void {
			var _local5:String = null;
			var _local3:int = 0;
			var _local2:int = 0;
			var _local7:* = null;
			var _local6:int = 0;
			var _local4:int = 0;
			var _local1:String = null;
			if(!this._formatter || this._formatter.requestedLocaleIDName != this._locale) {
				this._formatter = new DateTimeFormatter(this._locale,"short","short");
				_local5 = this._formatter.getDateTimePattern();
				_local3 = int(_local5.indexOf("M"));
				_local2 = int(_local5.indexOf("d"));
				this._monthFirst = _local3 < _local2;
				this._showMeridiem = this._editingMode !== "date" && _local5.indexOf("a") >= 0;
				if(this._showMeridiem) {
					this._formatter.setDateTimePattern("a");
					HELPER_DATE.setHours(1);
					this._amString = this._formatter.format(HELPER_DATE);
					HELPER_DATE.setHours(13);
					this._pmString = this._formatter.format(HELPER_DATE);
					this._formatter.setDateTimePattern(_local5);
				}
			}
			if(this._editingMode === "date") {
				this._localeMonthNames = this._formatter.getMonthNames("full");
				this._localeWeekdayNames = null;
			} else if(this._editingMode === "dateAndTime") {
				this._localeMonthNames = this._formatter.getMonthNames("shortAbbreviation");
				this._localeWeekdayNames = this._formatter.getWeekdayNames("longAbbreviation");
			} else {
				this._localeMonthNames = null;
				this._localeWeekdayNames = null;
			}
			if(this._localeMonthNames !== null) {
				this._longestMonthNameIndex = 0;
				_local7 = this._localeMonthNames[0];
				_local6 = int(this._localeMonthNames.length);
				_local4 = 1;
				while(_local4 < _local6) {
					_local1 = this._localeMonthNames[_local4];
					if(_local1.length > _local7.length) {
						_local7 = _local1;
						this._longestMonthNameIndex = _local4;
					}
					_local4++;
				}
			}
		}
		
		protected function refreshSelection() : void {
			var _local11:ListCollection = null;
			var _local5:IntegerRange = null;
			var _local9:IntegerRangeDataDescriptor = null;
			var _local6:Number = NaN;
			var _local3:int = 0;
			var _local7:ListCollection = null;
			var _local1:IntegerRange = null;
			var _local10:Number = NaN;
			var _local8:Number = NaN;
			var _local2:ListCollection = null;
			var _local12:IntegerRange = null;
			var _local4:Boolean = this._ignoreListChanges;
			this._ignoreListChanges = true;
			if(this._editingMode === "date") {
				_local11 = this.yearsList.dataProvider;
				if(_local11) {
					_local5 = IntegerRange(_local11.data);
					if(_local5.minimum !== this._listMinYear || _local5.maximum !== this._listMaxYear) {
						_local5.minimum = this._listMinYear;
						_local5.maximum = this._listMaxYear;
						_local9 = IntegerRangeDataDescriptor(_local11.dataDescriptor);
						_local11.data = null;
						_local11.data = _local5;
						_local11.dataDescriptor = _local9;
					}
				} else {
					_local5 = new IntegerRange(this._listMinYear,this._listMaxYear,1);
					_local11 = new ListCollection(_local5);
					_local11.dataDescriptor = new IntegerRangeDataDescriptor();
					this.yearsList.dataProvider = _local11;
				}
			} else {
				_local6 = this._maximum.time - this._minimum.time;
				_local3 = _local6 / (24 * 60 * 60 * 1000);
				if(this._editingMode === "dateAndTime") {
					_local7 = this.dateAndTimeDatesList.dataProvider;
					if(_local7) {
						_local1 = IntegerRange(_local7.data);
						if(_local1.maximum !== _local3) {
							_local1.maximum = _local3;
							_local9 = IntegerRangeDataDescriptor(_local7.dataDescriptor);
							_local7.data = null;
							_local7.data = _local1;
							_local7.dataDescriptor = _local9;
						}
					} else {
						_local1 = new IntegerRange(0,_local3,1);
						_local7 = new ListCollection(_local1);
						_local7.dataDescriptor = new IntegerRangeDataDescriptor();
						this.dateAndTimeDatesList.dataProvider = _local7;
					}
				}
				_local10 = 0;
				_local8 = this._showMeridiem ? 11 : 23;
				_local2 = this.hoursList.dataProvider;
				if(_local2) {
					_local12 = IntegerRange(_local2.data);
					if(_local12.minimum !== _local10 || _local12.maximum !== _local8) {
						_local12.minimum = _local10;
						_local12.maximum = _local8;
						_local9 = IntegerRangeDataDescriptor(_local2.dataDescriptor);
						_local2.data = null;
						_local2.data = _local12;
						_local2.dataDescriptor = _local9;
					}
				} else {
					_local12 = new IntegerRange(_local10,_local8,1);
					_local2 = new ListCollection(_local12);
					_local2.dataDescriptor = new IntegerRangeDataDescriptor();
					this.hoursList.dataProvider = _local2;
				}
				if(this._showMeridiem && !this.meridiemList.dataProvider) {
					this.meridiemList.dataProvider = new ListCollection(new <String>[this._amString,this._pmString]);
				}
			}
			if(this.monthsList && !this.monthsList.isScrolling) {
				this.monthsList.selectedItem = this._value.month;
			}
			if(this.datesList && !this.datesList.isScrolling) {
				this.datesList.selectedItem = this._value.date;
			}
			if(this.yearsList && !this.yearsList.isScrolling) {
				this.yearsList.selectedItem = this._value.fullYear;
			}
			if(this.dateAndTimeDatesList) {
				this.dateAndTimeDatesList.selectedIndex = (this._value.time - this._minimum.time) / (24 * 60 * 60 * 1000);
			}
			if(this.hoursList) {
				if(this._showMeridiem) {
					this.hoursList.selectedIndex = this._value.hours % 12;
				} else {
					this.hoursList.selectedIndex = this._value.hours;
				}
			}
			if(this.minutesList) {
				this.minutesList.selectedItem = this._value.minutes;
			}
			if(this.meridiemList) {
				this.meridiemList.selectedIndex = this._value.hours <= 11 ? 0 : 1;
			}
			this._ignoreListChanges = _local4;
		}
		
		protected function refreshValidRanges() : void {
			var _local17:int = this._minYear;
			var _local8:int = this._maxYear;
			var _local19:int = this._minMonth;
			var _local9:int = this._maxMonth;
			var _local20:int = this._minDate;
			var _local2:int = this._maxDate;
			var _local10:int = this._minHours;
			var _local15:int = this._maxHours;
			var _local3:int = this._minMinute;
			var _local18:int = this._maxMinute;
			var _local11:int = this._value.fullYear;
			var _local7:int = this._value.month;
			var _local6:int = this._value.date;
			var _local13:int = this._value.hours;
			this._minYear = this._minimum.fullYear;
			this._maxYear = this._maximum.fullYear;
			if(_local11 === this._minYear) {
				this._minMonth = this._minimum.month;
			} else {
				this._minMonth = 0;
			}
			if(_local11 === this._maxYear) {
				this._maxMonth = this._maximum.month;
			} else {
				this._maxMonth = 11;
			}
			if(_local11 === this._minYear && _local7 === this._minimum.month) {
				this._minDate = this._minimum.date;
			} else {
				this._minDate = 1;
			}
			if(_local11 === this._maxYear && _local7 === this._maximum.month) {
				this._maxDate = this._maximum.date;
			} else if(_local7 === 1) {
				HELPER_DATE.setFullYear(_local11,_local7 + 1,-1);
				this._maxDate = HELPER_DATE.date + 1;
			} else {
				this._maxDate = DAYS_IN_MONTH[_local7];
			}
			if(this._editingMode === "dateAndTime") {
				if(_local11 === this._minYear && _local7 === this._minimum.month && _local6 === this._minimum.date) {
					this._minHours = this._minimum.hours;
				} else {
					this._minHours = 0;
				}
				if(_local11 === this._maxYear && _local7 === this._maximum.month && _local6 === this._maximum.date) {
					this._maxHours = this._maximum.hours;
				} else {
					this._maxHours = 23;
				}
				if(_local11 === this._minYear && _local7 === this._minimum.month && _local6 === this._minimum.date && _local13 === this._minimum.hours) {
					this._minMinute = this._minimum.minutes;
				} else {
					this._minMinute = 0;
				}
				if(_local11 === this._maxYear && _local7 === this._maximum.month && _local6 === this._maximum.date && _local13 === this._maximum.hours) {
					this._maxMinute = this._maximum.minutes;
				} else {
					this._maxMinute = 59;
				}
			} else {
				this._minHours = this._minimum.hours;
				this._maxHours = this._maximum.hours;
				if(_local13 === this._minHours) {
					this._minMinute = this._minimum.minutes;
				} else {
					this._minMinute = 0;
				}
				if(_local13 === this._maxHours) {
					this._maxMinute = this._maximum.minutes;
				} else {
					this._maxMinute = 59;
				}
			}
			var _local12:ListCollection = !!this.yearsList ? this.yearsList.dataProvider : null;
			if(_local12 && (_local17 !== this._minYear || _local8 !== this._maxYear)) {
				_local12.updateAll();
			}
			var _local4:ListCollection = !!this.monthsList ? this.monthsList.dataProvider : null;
			if(_local4 && (_local19 !== this._minMonth || _local9 !== this._maxMonth)) {
				_local4.updateAll();
			}
			var _local14:ListCollection = !!this.datesList ? this.datesList.dataProvider : null;
			if(_local14 && (_local20 !== this._minDate || _local2 !== this._maxDate)) {
				_local14.updateAll();
			}
			var _local5:ListCollection = !!this.dateAndTimeDatesList ? this.dateAndTimeDatesList.dataProvider : null;
			if(_local5 && (_local17 !== this._minYear || _local8 !== this._maxYear || _local19 !== this._minMonth || _local9 !== this._maxMonth || _local20 !== this._minDate || _local2 !== this._maxDate)) {
				_local5.updateAll();
			}
			var _local1:ListCollection = !!this.hoursList ? this.hoursList.dataProvider : null;
			if(_local1 && (_local10 !== this._minHours || _local15 !== this._maxHours || this._showMeridiem && this._lastMeridiemValue !== this.meridiemList.selectedIndex)) {
				_local1.updateAll();
			}
			var _local16:ListCollection = !!this.minutesList ? this.minutesList.dataProvider : null;
			if(_local16 && (_local3 !== this._minMinute || _local18 !== this._maxMinute)) {
				_local16.updateAll();
			}
			if(this._showMeridiem) {
				this._lastMeridiemValue = this._value.hours <= 11 ? 0 : 1;
			}
		}
		
		protected function useDefaultsIfNeeded() : void {
			if(!this._value) {
				this._value = new Date();
				if(this._minimum && this._value.time < this._minimum.time) {
					this._value.time = this._minimum.time;
				} else if(this._maximum && this._value.time > this._maximum.time) {
					this._value.time = this._maximum.time;
				}
			}
			if(this._minimum) {
				if(this._editingMode === "dateAndTime") {
					this._listMinYear = this._minimum.fullYear - 1;
				} else {
					this._listMinYear = this._minimum.fullYear - 10;
				}
			} else if(this._editingMode === "dateAndTime") {
				HELPER_DATE.time = this._value.time;
				this._listMinYear = HELPER_DATE.fullYear - 1;
				this._minimum = new Date(this._listMinYear,0,1,0,0);
			} else {
				HELPER_DATE.time = this._value.time;
				this._listMinYear = roundDownToNearest(HELPER_DATE.fullYear - 100,50);
				this._minimum = new Date(this._listMinYear,0,1,0,0);
			}
			if(this._maximum) {
				if(this._editingMode === "dateAndTime") {
					this._listMaxYear = this._maximum.fullYear + 1;
				} else {
					this._listMaxYear = this._maximum.fullYear + 10;
				}
			} else if(this._editingMode === "dateAndTime") {
				HELPER_DATE.time = this._minimum.time;
				this._listMaxYear = HELPER_DATE.fullYear + 1;
				this._maximum = new Date(this._listMaxYear,11,DAYS_IN_MONTH[11],23,59);
			} else {
				HELPER_DATE.time = this._value.time;
				this._listMaxYear = roundUpToNearest(HELPER_DATE.fullYear + 100,50);
				this._maximum = new Date(this._listMaxYear,11,DAYS_IN_MONTH[11],23,59);
			}
		}
		
		protected function layoutChildren() : void {
			this.listGroup.width = this.actualWidth;
			this.listGroup.height = this.actualHeight;
			this.listGroup.validate();
		}
		
		protected function handlePendingScroll() : void {
			var _local5:int = 0;
			var _local6:IntegerRange = null;
			var _local4:int = 0;
			var _local2:int = 0;
			var _local7:int = 0;
			var _local3:int = 0;
			var _local8:int = 0;
			var _local9:int = 0;
			if(!this.pendingScrollToDate) {
				return;
			}
			var _local1:Number = this.pendingScrollDuration;
			if(_local1 !== _local1) {
				_local1 = this._scrollDuration;
			}
			if(this.yearsList) {
				_local5 = this.pendingScrollToDate.fullYear;
				if(this.yearsList.selectedItem !== _local5) {
					_local6 = IntegerRange(this.yearsList.dataProvider.data);
					this.yearsList.scrollToDisplayIndex(_local5 - _local6.minimum,_local1);
				}
			}
			if(this.monthsList) {
				_local4 = this.pendingScrollToDate.month;
				if(this.monthsList.selectedItem !== _local4) {
					this.monthsList.scrollToDisplayIndex(_local4,_local1);
				}
			}
			if(this.datesList) {
				_local2 = this.pendingScrollToDate.date;
				if(this.datesList.selectedItem !== _local2) {
					this.datesList.scrollToDisplayIndex(_local2 - 1,_local1);
				}
			}
			if(this.dateAndTimeDatesList) {
				_local7 = (this.pendingScrollToDate.time - this._minimum.time) / (24 * 60 * 60 * 1000);
				if(this.dateAndTimeDatesList.selectedIndex !== _local7) {
					this.dateAndTimeDatesList.scrollToDisplayIndex(_local7,_local1);
				}
			}
			if(this.hoursList) {
				_local3 = this.pendingScrollToDate.hours;
				if(this._showMeridiem) {
					_local3 %= 12;
				}
				if(this.hoursList.selectedItem !== _local3) {
					this.hoursList.scrollToDisplayIndex(_local3,_local1);
				}
			}
			if(this.minutesList) {
				_local8 = this.pendingScrollToDate.minutes;
				if(this.minutesList.selectedItem !== _local8) {
					this.minutesList.scrollToDisplayIndex(_local8,_local1);
				}
			}
			if(this.meridiemList) {
				_local9 = this.pendingScrollToDate.hours < 11 ? 0 : 1;
				if(this.meridiemList.selectedIndex !== _local9) {
					this.meridiemList.scrollToDisplayIndex(_local9,_local1);
				}
			}
		}
		
		protected function meridiemListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			return _local1;
		}
		
		protected function minutesListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.labelFunction = formatMinutes;
			_local1.enabledFunction = isMinuteEnabled;
			_local1.itemHasEnabled = true;
			return _local1;
		}
		
		protected function hoursListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.labelFunction = formatHours;
			_local1.enabledFunction = isHourEnabled;
			_local1.itemHasEnabled = true;
			return _local1;
		}
		
		protected function dateAndTimeDatesListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.labelFunction = formatDateAndTimeDate;
			_local1.accessoryLabelFunction = formatDateAndTimeWeekday;
			return _local1;
		}
		
		protected function monthsListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.labelFunction = formatMonthName;
			_local1.enabledFunction = isMonthEnabled;
			_local1.itemHasEnabled = true;
			return _local1;
		}
		
		protected function datesListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.enabledFunction = isDateEnabled;
			_local1.itemHasEnabled = true;
			return _local1;
		}
		
		protected function yearsListItemRendererFactory() : DefaultListItemRenderer {
			var _local1:DefaultListItemRenderer = null;
			if(this._itemRendererFactory !== null) {
				_local1 = DefaultListItemRenderer(this._itemRendererFactory());
			} else {
				_local1 = new DefaultListItemRenderer();
			}
			_local1.enabledFunction = isYearEnabled;
			_local1.itemHasEnabled = true;
			return _local1;
		}
		
		protected function isMonthEnabled(month:int) : Boolean {
			return month >= this._minMonth && month <= this._maxMonth;
		}
		
		protected function isYearEnabled(year:int) : Boolean {
			return year >= this._minYear && year <= this._maxYear;
		}
		
		protected function isDateEnabled(date:int) : Boolean {
			return date >= this._minDate && date <= this._maxDate;
		}
		
		protected function isHourEnabled(hour:int) : Boolean {
			if(this._showMeridiem && this.meridiemList.selectedIndex !== 0) {
				hour += 12;
			}
			return hour >= this._minHours && hour <= this._maxHours;
		}
		
		protected function isMinuteEnabled(minute:int) : Boolean {
			return minute >= this._minMinute && minute <= this._maxMinute;
		}
		
		protected function formatHours(item:int) : String {
			if(this._showMeridiem) {
				if(item === 0) {
					item = 12;
				}
				return item.toString();
			}
			var _local2:String = item.toString();
			if(_local2.length < 2) {
				_local2 = "0" + _local2;
			}
			return _local2;
		}
		
		protected function formatMinutes(item:int) : String {
			var _local2:String = item.toString();
			if(_local2.length < 2) {
				_local2 = "0" + _local2;
			}
			return _local2;
		}
		
		protected function formatDateAndTimeWeekday(item:Object) : String {
			if(item is int) {
				HELPER_DATE.setTime(this._minimum.time);
				HELPER_DATE.setDate(HELPER_DATE.date + item);
				if(this._todayLabel) {
					if(HELPER_DATE.fullYear === this._lastValidate.fullYear && HELPER_DATE.month === this._lastValidate.month && HELPER_DATE.date === this._lastValidate.date) {
						return "";
					}
				}
				return this._localeWeekdayNames[HELPER_DATE.day] as String;
			}
			return "Wom";
		}
		
		protected function formatDateAndTimeDate(item:Object) : String {
			var _local2:String = null;
			if(item is int) {
				HELPER_DATE.setTime(this._minimum.time);
				HELPER_DATE.setDate(HELPER_DATE.date + item);
				if(this._todayLabel) {
					if(HELPER_DATE.fullYear === this._lastValidate.fullYear && HELPER_DATE.month === this._lastValidate.month && HELPER_DATE.date === this._lastValidate.date) {
						return this._todayLabel;
					}
				}
				_local2 = this._localeMonthNames[HELPER_DATE.month] as String;
				if(this._monthFirst) {
					return _local2 + " " + HELPER_DATE.date;
				}
				return HELPER_DATE.date + " " + _local2;
			}
			return "Wom 30";
		}
		
		protected function formatMonthName(item:int) : String {
			return this._localeMonthNames[item] as String;
		}
		
		protected function validateNewValue() : void {
			var _local1:Number = this._value.time;
			var _local2:Number = this._minimum.time;
			var _local3:Number = this._maximum.time;
			var _local4:Boolean = false;
			if(_local1 < _local2) {
				_local4 = true;
				this._value.setTime(_local2);
			} else if(_local1 > _local3) {
				_local4 = true;
				this._value.setTime(_local3);
			}
			if(_local4) {
				this.scrollToDate(this._value);
			}
		}
		
		protected function updateHoursFromLists() : void {
			var _local1:int = this.hoursList.selectedItem as int;
			if(this.meridiemList && this.meridiemList.selectedIndex === 1) {
				_local1 += 12;
			}
			this._value.setHours(_local1);
		}
		
		protected function monthsList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			var _local2:int = this.monthsList.selectedItem as int;
			this._value.setMonth(_local2);
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function datesList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			var _local2:int = this.datesList.selectedItem as int;
			this._value.setDate(_local2);
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function yearsList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			var _local2:int = this.yearsList.selectedItem as int;
			this._value.setFullYear(_local2);
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function dateAndTimeDatesList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			this._value.setFullYear(this._minimum.fullYear,this._minimum.month,this._minimum.date + this.dateAndTimeDatesList.selectedIndex);
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function hoursList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			this.updateHoursFromLists();
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function minutesList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			var _local2:int = this.minutesList.selectedItem as int;
			this._value.setMinutes(_local2);
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
		
		protected function meridiemList_changeHandler(event:Event) : void {
			if(this._ignoreListChanges) {
				return;
			}
			this.updateHoursFromLists();
			this.validateNewValue();
			this.refreshValidRanges();
			this.dispatchEventWith("change");
		}
	}
}

import feathers.data.IListCollectionDataDescriptor;

class IntegerRange {
	public var minimum:int;
	
	public var maximum:int;
	
	public var step:int;
	
	public function IntegerRange(minimum:int, maximum:int, step:int = 1) {
		super();
		this.minimum = minimum;
		this.maximum = maximum;
		this.step = step;
	}
}

class IntegerRangeDataDescriptor implements IListCollectionDataDescriptor {
	public function IntegerRangeDataDescriptor() {
		super();
	}
	
	public function getLength(data:Object) : int {
		var _local2:IntegerRange = IntegerRange(data);
		return 1 + int((_local2.maximum - _local2.minimum) / _local2.step);
	}
	
	public function getItemAt(data:Object, index:int) : Object {
		var _local4:IntegerRange = IntegerRange(data);
		var _local5:int = _local4.maximum;
		var _local3:* = _local4.minimum + index * _local4.step;
		if(_local3 > _local5) {
			_local3 = _local5;
		}
		return _local3;
	}
	
	public function setItemAt(data:Object, item:Object, index:int) : void {
		throw "Not implemented";
	}
	
	public function addItemAt(data:Object, item:Object, index:int) : void {
		throw "Not implemented";
	}
	
	public function removeItemAt(data:Object, index:int) : Object {
		throw "Not implemented";
	}
	
	public function getItemIndex(data:Object, item:Object) : int {
		if(!(item is int)) {
			return -1;
		}
		var _local4:int = item as int;
		var _local3:IntegerRange = IntegerRange(data);
		return Math.ceil((_local4 - _local3.minimum) / _local3.step);
	}
	
	public function removeAll(data:Object) : void {
		throw "Not implemented";
	}
}
