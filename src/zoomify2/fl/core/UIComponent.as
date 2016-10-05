package fl.core {
    import flash.display.*;
    import flash.events.*;
    import fl.managers.*;
    import flash.utils.*;
    import fl.events.*;
    import flash.text.*;
    import flash.system.*;

    public class UIComponent extends Sprite {

        public static var inCallLaterPhase:Boolean = false;
        private static var defaultStyles:Object = {
            focusRectSkin:"focusRectSkin",
            focusRectPadding:2,
            textFormat:new TextFormat("_sans", 11, 0, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            disabledTextFormat:new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            defaultTextFormat:new TextFormat("_sans", 11, 0, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            defaultDisabledTextFormat:new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0)
        };
        public static var createAccessibilityImplementation:Function;
        private static var focusManagers:Dictionary = new Dictionary(false);

        protected var _x:Number;
        protected var _enabled:Boolean = true;
        protected var callLaterMethods:Dictionary;
        private var _mouseFocusEnabled:Boolean = true;
        private var tempText:TextField;
        private var _focusEnabled:Boolean = true;
        protected var startHeight:Number;
        protected var _height:Number;
        protected var invalidateFlag:Boolean = false;
        protected var _oldIMEMode:String = null;
        protected var _inspector:Boolean = false;
        protected var startWidth:Number;
        public var focusTarget:IFocusManagerComponent;
        protected var errorCaught:Boolean = false;
        protected var invalidHash:Object;
        protected var sharedStyles:Object;
        protected var uiFocusRect:DisplayObject;
        protected var isLivePreview:Boolean = false;
        protected var _imeMode:String = null;
        protected var _width:Number;
        protected var instanceStyles:Object;
        public var version:String = "3.0.0.16";
        protected var isFocused:Boolean = false;
        protected var _y:Number;

        public function UIComponent(){
            instanceStyles = {};
            sharedStyles = {};
            invalidHash = {};
            callLaterMethods = new Dictionary();
            StyleManager.registerInstance(this);
            configUI();
            invalidate(InvalidationType.ALL);
            tabEnabled = (this is IFocusManagerComponent);
            focusRect = false;
            if (tabEnabled){
                addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
                addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
                addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
                addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            };
            initializeFocusManager();
            addEventListener(Event.ENTER_FRAME, hookAccessibility, false, 0, true);
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }
        public static function mergeStyles(... _args):Object{
            var _local5:Object;
            var _local6:String;
            var _local2:Object = {};
            var _local3:uint = _args.length;
            var _local4:uint;
            while (_local4 < _local3) {
                _local5 = _args[_local4];
                for (_local6 in _local5) {
                    if (_local2[_local6] != null){
                    } else {
                        _local2[_local6] = _args[_local4][_local6];
                    };
                };
                _local4++;
            };
            return (_local2);
        }

        public function getStyle(_arg1:String):Object{
            return (instanceStyles[_arg1]);
        }
        protected function checkLivePreview():Boolean{
            var className:* = null;
            if (parent == null){
                return (false);
            };
            try {
                className = getQualifiedClassName(parent);
            } catch(e:Error) {
            };
            return ((className == "fl.livepreview::LivePreviewParent"));
        }
        private function callLaterDispatcher(_arg1:Event):void{
            var _local3:Object;
            if (_arg1.type == Event.ADDED_TO_STAGE){
                removeEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher);
                stage.addEventListener(Event.RENDER, callLaterDispatcher, false, 0, true);
                stage.invalidate();
                return;
            };
            _arg1.target.removeEventListener(Event.RENDER, callLaterDispatcher);
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher, false, 0, true);
                return;
            };
            inCallLaterPhase = true;
            var _local2:Dictionary = callLaterMethods;
            for (_local3 in _local2) {
                _local3();
                delete _local2[_local3];
            };
            inCallLaterPhase = false;
        }
        protected function validate():void{
            invalidHash = {};
        }
        protected function focusOutHandler(_arg1:FocusEvent):void{
            if (isOurFocus((_arg1.target as DisplayObject))){
                drawFocus(false);
                isFocused = false;
            };
        }
        public function set mouseFocusEnabled(_arg1:Boolean):void{
            _mouseFocusEnabled = _arg1;
        }
        public function getFocus():InteractiveObject{
            if (stage){
                return (stage.focus);
            };
            return (null);
        }
        override public function get height():Number{
            return (_height);
        }
        private function addedHandler(_arg1:Event):void{
            removeEventListener("addedToStage", addedHandler);
            initializeFocusManager();
        }
        protected function getStyleValue(_arg1:String):Object{
            return (((instanceStyles[_arg1])==null) ? sharedStyles[_arg1] : instanceStyles[_arg1]);
        }
        public function invalidate(_arg1:String="all", _arg2:Boolean=true):void{
            invalidHash[_arg1] = true;
            if (_arg2){
                this.callLater(draw);
            };
        }
        protected function isOurFocus(_arg1:DisplayObject):Boolean{
            return ((_arg1 == this));
        }
        public function get enabled():Boolean{
            return (_enabled);
        }
        protected function getScaleX():Number{
            return (super.scaleX);
        }
        protected function getScaleY():Number{
            return (super.scaleY);
        }
        public function get focusEnabled():Boolean{
            return (_focusEnabled);
        }
        protected function afterComponentParameters():void{
        }
        override public function get scaleY():Number{
            return ((height / startHeight));
        }
        protected function setIMEMode(_arg1:Boolean){
            var enabled:* = _arg1;
            if (_imeMode != null){
                if (enabled){
                    IME.enabled = true;
                    _oldIMEMode = IME.conversionMode;
                    try {
                        if (((!(errorCaught)) && (!((IME.conversionMode == IMEConversionMode.UNKNOWN))))){
                            IME.conversionMode = _imeMode;
                        };
                        errorCaught = false;
                    } catch(e:Error) {
                        errorCaught = true;
                        throw (new Error(("IME mode not supported: " + _imeMode)));
                    };
                } else {
                    if (((!((IME.conversionMode == IMEConversionMode.UNKNOWN))) && (!((_oldIMEMode == IMEConversionMode.UNKNOWN))))){
                        IME.conversionMode = _oldIMEMode;
                    };
                    IME.enabled = false;
                };
            };
        }
        protected function draw():void{
            if (isInvalid(InvalidationType.SIZE, InvalidationType.STYLES)){
                if (((isFocused) && (focusManager.showFocusIndicator))){
                    drawFocus(true);
                };
            };
            validate();
        }
        override public function set height(_arg1:Number):void{
            if (_height == _arg1){
                return;
            };
            setSize(width, _arg1);
        }
        protected function configUI():void{
            isLivePreview = checkLivePreview();
            var _local1:Number = rotation;
            rotation = 0;
            var _local2:Number = super.width;
            var _local3:Number = super.height;
            var _local4 = 1;
            super.scaleY = _local4;
            super.scaleX = _local4;
            setSize(_local2, _local3);
            move(super.x, super.y);
            rotation = _local1;
            startWidth = _local2;
            startHeight = _local3;
            if (numChildren > 0){
                removeChildAt(0);
            };
        }
        protected function setScaleY(_arg1:Number):void{
            super.scaleY = _arg1;
        }
        override public function get scaleX():Number{
            return ((width / startWidth));
        }
        protected function setScaleX(_arg1:Number):void{
            super.scaleX = _arg1;
        }
        private function initializeFocusManager():void{
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, addedHandler, false, 0, true);
            } else {
                createFocusManager();
            };
        }
        protected function keyDownHandler(_arg1:KeyboardEvent):void{
        }
        public function set focusManager(_arg1:IFocusManager):void{
            UIComponent.focusManagers[this] = _arg1;
        }
        public function clearStyle(_arg1:String):void{
            setStyle(_arg1, null);
        }
        protected function isInvalid(_arg1:String, ... _args):Boolean{
            if (((invalidHash[_arg1]) || (invalidHash[InvalidationType.ALL]))){
                return (true);
            };
            while (_args.length > 0) {
                if (invalidHash[_args.pop()]){
                    return (true);
                };
            };
            return (false);
        }
        public function setStyle(_arg1:String, _arg2:Object):void{
            if ((((instanceStyles[_arg1] === _arg2)) && (!((_arg2 is TextFormat))))){
                return;
            };
            instanceStyles[_arg1] = _arg2;
            invalidate(InvalidationType.STYLES);
        }
        override public function get visible():Boolean{
            return (super.visible);
        }
        protected function focusInHandler(_arg1:FocusEvent):void{
            var _local2:IFocusManager;
            if (isOurFocus((_arg1.target as DisplayObject))){
                _local2 = focusManager;
                if (((_local2) && (_local2.showFocusIndicator))){
                    drawFocus(true);
                    isFocused = true;
                };
            };
        }
        public function get componentInspectorSetting():Boolean{
            return (_inspector);
        }
        override public function get x():Number{
            return (((isNaN(_x)) ? super.x : _x));
        }
        override public function get y():Number{
            return (((isNaN(_y)) ? super.y : _y));
        }
        public function set enabled(_arg1:Boolean):void{
            if (_arg1 == _enabled){
                return;
            };
            _enabled = _arg1;
            invalidate(InvalidationType.STATE);
        }
        public function setSize(_arg1:Number, _arg2:Number):void{
            _width = _arg1;
            _height = _arg2;
            invalidate(InvalidationType.SIZE);
            dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE, false));
        }
        protected function keyUpHandler(_arg1:KeyboardEvent):void{
        }
        public function setSharedStyle(_arg1:String, _arg2:Object):void{
            if ((((sharedStyles[_arg1] === _arg2)) && (!((_arg2 is TextFormat))))){
                return;
            };
            sharedStyles[_arg1] = _arg2;
            if (instanceStyles[_arg1] == null){
                invalidate(InvalidationType.STYLES);
            };
        }
        public function set focusEnabled(_arg1:Boolean):void{
            _focusEnabled = _arg1;
        }
        override public function set width(_arg1:Number):void{
            if (_width == _arg1){
                return;
            };
            setSize(_arg1, height);
        }
        public function setFocus():void{
            if (stage){
                stage.focus = this;
            };
        }
        override public function set scaleX(_arg1:Number):void{
            setSize((startWidth * _arg1), height);
        }
        public function get mouseFocusEnabled():Boolean{
            return (_mouseFocusEnabled);
        }
        override public function set scaleY(_arg1:Number):void{
            setSize(width, (startHeight * _arg1));
        }
        protected function getDisplayObjectInstance(_arg1:Object):DisplayObject{
            var skin:* = _arg1;
            var classDef:* = null;
            if ((skin is Class)){
                return ((new (skin)() as DisplayObject));
            };
            if ((skin is DisplayObject)){
                (skin as DisplayObject).x = 0;
                (skin as DisplayObject).y = 0;
                return ((skin as DisplayObject));
            };
            try {
                classDef = getDefinitionByName(skin.toString());
            } catch(e:Error) {
                try {
                    classDef = (loaderInfo.applicationDomain.getDefinition(skin.toString()) as Object);
                } catch(e:Error) {
                };
            };
            if (classDef == null){
                return (null);
            };
            return ((new (classDef)() as DisplayObject));
        }
        protected function copyStylesToChild(_arg1:UIComponent, _arg2:Object):void{
            var _local3:String;
            for (_local3 in _arg2) {
                _arg1.setStyle(_local3, getStyleValue(_arg2[_local3]));
            };
        }
        protected function initializeAccessibility():void{
            if (UIComponent.createAccessibilityImplementation != null){
                UIComponent.createAccessibilityImplementation(this);
            };
        }
        public function get focusManager():IFocusManager{
            var _local1:DisplayObject = this;
            while (_local1) {
                if (UIComponent.focusManagers[_local1] != null){
                    return (IFocusManager(UIComponent.focusManagers[_local1]));
                };
                _local1 = _local1.parent;
            };
            return (null);
        }
        override public function get width():Number{
            return (_width);
        }
        protected function beforeComponentParameters():void{
        }
        protected function callLater(_arg1:Function):void{
            if (inCallLaterPhase){
                return;
            };
            callLaterMethods[_arg1] = true;
            if (stage != null){
                stage.addEventListener(Event.RENDER, callLaterDispatcher, false, 0, true);
                stage.invalidate();
            } else {
                addEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher, false, 0, true);
            };
        }
        public function move(_arg1:Number, _arg2:Number):void{
            _x = _arg1;
            _y = _arg2;
            super.x = Math.round(_arg1);
            super.y = Math.round(_arg2);
            dispatchEvent(new ComponentEvent(ComponentEvent.MOVE));
        }
        public function validateNow():void{
            invalidate(InvalidationType.ALL, false);
            draw();
        }
        override public function set visible(_arg1:Boolean):void{
            if (super.visible == _arg1){
                return;
            };
            super.visible = _arg1;
            var _local2:String = ((_arg1) ? ComponentEvent.SHOW : ComponentEvent.HIDE);
            dispatchEvent(new ComponentEvent(_local2, true));
        }
        protected function createFocusManager():void{
            if (focusManagers[stage] == null){
                focusManagers[stage] = new FocusManager(stage);
            };
        }
        protected function hookAccessibility(_arg1:Event):void{
            removeEventListener(Event.ENTER_FRAME, hookAccessibility);
            initializeAccessibility();
        }
        public function set componentInspectorSetting(_arg1:Boolean):void{
            _inspector = _arg1;
            if (_inspector){
                beforeComponentParameters();
            } else {
                afterComponentParameters();
            };
        }
        override public function set y(_arg1:Number):void{
            move(_x, _arg1);
        }
        public function drawFocus(_arg1:Boolean):void{
            var _local2:Number;
            isFocused = _arg1;
            if (((!((uiFocusRect == null))) && (contains(uiFocusRect)))){
                removeChild(uiFocusRect);
                uiFocusRect = null;
            };
            if (_arg1){
                uiFocusRect = (getDisplayObjectInstance(getStyleValue("focusRectSkin")) as Sprite);
                if (uiFocusRect == null){
                    return;
                };
                _local2 = Number(getStyleValue("focusRectPadding"));
                uiFocusRect.x = -(_local2);
                uiFocusRect.y = -(_local2);
                uiFocusRect.width = (width + (_local2 * 2));
                uiFocusRect.height = (height + (_local2 * 2));
                addChildAt(uiFocusRect, 0);
            };
        }
        override public function set x(_arg1:Number):void{
            move(_arg1, _y);
        }
        public function drawNow():void{
            draw();
        }

    }
}//package fl.core 
