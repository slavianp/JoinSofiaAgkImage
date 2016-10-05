package zoomify {
    import fl.controls.*;
    import flash.display.*;
    import fl.core.*;
    import flash.events.*;
    import fl.managers.*;
    import flash.utils.*;
    import zoomify.utils.*;
    import flash.text.*;
    import zoomify.toolbar.*;
    import flash.net.*;
    import flash.system.*;

    public class ZoomifyToolbar extends UIComponent implements IFocusManagerComponent {

        private static var defaultStyles:Object = {
            background:"ZoomifyToolbar_background",
            divider:"ZoomifyToolbar_divider",
            logo:"ZoomifyToolbar_logo",
            toolbarAlert:"ZoomifyToolbar_alert"
        };

        protected var panUp:Button;
        protected var background:DisplayObject;
        protected var _viewer:IZoomifyViewer;
        protected var panLeft:Button;
        protected var toolbarSkinCounter:uint = 0;
        protected var minZoomDecimal:Number;
        protected var moving:Boolean = false;
        protected var reset:Button;
        protected var alertOverlay:Sprite;
        protected var zoomIn:Button;
        protected var _showZoomifyButton:Boolean = true;
        protected var _toolbarSpacing:Number = 7;
        protected var toolbarSkinFolderPath:String = "";
        protected var content:Sprite;
        protected var zoomOut:Button;
        protected var panRight:Button;
        protected var toolbarSkinCounterMax:uint = 29;
        protected var skinError:String = "";
        protected var toolbarSkinArray:Array;
        protected var toolbarSkinLoadedArray:Array;
        protected var logo:Sprite;
        protected var _toolbarSkinXMLPath:String = "unset";
        protected var toolbarLogo:DisplayObject;
        protected var toolbarSkinLoader:Loader;
        protected var contentWidth:Number = 0;
        protected var _showSlider:Boolean = true;
        protected var panDown:Button;
        protected var slider:HighSlider;
        protected var logoDivider:DisplayObject;
        protected var _showToolbarTooltips:Boolean = true;
        protected var maxZoomDecimal:Number;
        protected var zoomPanDivider:DisplayObject;

        public function ZoomifyToolbar():void{
            toolbarSkinArray = [];
            toolbarSkinLoadedArray = [];
            toolbarSkinLoader = new Loader();
            super();
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }

        protected function panUpRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_PANUP, true);
            panUp.addEventListener(MouseEvent.ROLL_OUT, panUpRolloutHandler, false, 0, true);
        }
        protected function panRightMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.panRight();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function initializeStageMouseListeners(_arg1:Event=null):void{
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners, false, 0, true);
            } else {
                removeEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners);
            };
        }
        protected function drawLayoutContent():void{
            var _local1:Number = 0;
            drawLayoutButton(zoomOut, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            if (showSlider){
                _local1 = (_local1 + 3);
                slider.width = 116;
                slider.x = _local1;
                slider.y = Math.floor(((height - slider.height) / 2));
                _local1 = (_local1 + ((116 + _toolbarSpacing) + 3));
            };
            slider.visible = showSlider;
            drawLayoutButton(zoomIn, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            zoomPanDivider.height = height;
            zoomPanDivider.x = _local1;
            _local1 = (_local1 + (zoomPanDivider.width + _toolbarSpacing));
            drawLayoutButton(panLeft, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            drawLayoutButton(panUp, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            drawLayoutButton(panDown, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            drawLayoutButton(panRight, _local1);
            _local1 = (_local1 + (15 + _toolbarSpacing));
            drawLayoutButton(reset, _local1);
            contentWidth = (_local1 + 15);
        }
        protected function zoomOutMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.zoomOut();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function logoRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_LOGO, true);
            logo.addEventListener(MouseEvent.ROLL_OUT, logoRolloutHandler, false, 0, true);
        }
        public function get viewer():IZoomifyViewer{
            return (_viewer);
        }
        protected function configButton(_arg1:Button, _arg2:Function, _arg3:Function, _arg4:Number, _arg5:String):void{
            var _local6:Class = (ApplicationDomain.currentDomain.getDefinition(_arg5) as Class);
            _arg1.setStyle("disabledIcon", _local6);
            if (toolbarSkinLoadedArray[_arg4] == null){
                _arg1.setStyle("icon", _local6);
                _arg1.setStyle("overIcon", _local6);
                _arg1.setStyle("downIcon", _local6);
            } else {
                toolbarSkinLoadedArray[_arg4].scaleX = (toolbarSkinLoadedArray[_arg4].scaleY = 1);
                toolbarSkinLoadedArray[(_arg4 + 1)].scaleX = (toolbarSkinLoadedArray[(_arg4 + 1)].scaleY = 1);
                toolbarSkinLoadedArray[(_arg4 + 2)].scaleX = (toolbarSkinLoadedArray[(_arg4 + 2)].scaleY = 1);
                _arg1.setStyle("icon", toolbarSkinLoadedArray[_arg4]);
                _arg1.setStyle("overIcon", toolbarSkinLoadedArray[(_arg4 + 1)]);
                _arg1.setStyle("downIcon", toolbarSkinLoadedArray[(_arg4 + 2)]);
            };
            _arg1.label = "";
            _arg1.addEventListener(MouseEvent.MOUSE_OVER, _arg3, false, 0, true);
            _arg1.addEventListener(MouseEvent.MOUSE_DOWN, _arg2, false, 0, true);
        }
        protected function sliderChangeHandler(_arg1:Event):void{
            if (_viewer){
                _viewer.setExternalZoomingFlag(true);
                _viewer.setExternalZoomingFlag(false);
                _viewer.setZoomDecimal(getToolbarSliderZoomDecimal(), false);
                _viewer.invalidate(InvalidationType.STATE);
            };
        }
        protected function sliderRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_SLIDER, true);
            slider.addEventListener(MouseEvent.ROLL_OUT, sliderRolloutHandler, false, 0, true);
        }
        protected function validateSkins(){
            var _local1:Boolean = ((!((parent == null))) && ((getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent")));
            if (((((((_local1) && (!((_toolbarSkinXMLPath == null))))) && (!((_toolbarSkinXMLPath == ""))))) && (!((_toolbarSkinXMLPath == "/"))))){
                showAlert(Resources.ALERT_SKINSLIVEPREVIEW);
            };
            if (skinError != ""){
                showAlert(skinError);
            };
        }
        public function set viewer(_arg1:IZoomifyViewer):void{
            if (_viewer){
                _viewer.removeEventListener("gridChanged", gridChangedHandler);
            };
            _viewer = _arg1;
            if (_viewer){
                _viewer.addEventListener("gridChanged", gridChangedHandler, false, 0, true);
            };
        }
        protected function panDownRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            panDown.removeEventListener(MouseEvent.ROLL_OUT, panDownRolloutHandler);
        }
        public function get toolbarSkinXMLPath():String{
            return (_toolbarSkinXMLPath);
        }
        protected function loadToolbarSkinXMLCompleteHandler(_arg1:Event):void{
            if (_viewer){
                if (_viewer.eventsEnabled){
                    dispatchEvent(new Event("toolbarSkinXMLLoadingComplete"));
                };
            };
            var _local2:URLLoader = (_arg1.target as URLLoader);
            var _local3:XML = new XML(_local2.data);
            toolbarSkinArray[0] = (toolbarSkinFolderPath + _local3.@SKIN0);
            toolbarSkinArray[1] = (toolbarSkinFolderPath + _local3.@SKIN1);
            toolbarSkinArray[2] = (toolbarSkinFolderPath + _local3.@SKIN2);
            toolbarSkinArray[3] = (toolbarSkinFolderPath + _local3.@SKIN3);
            toolbarSkinArray[4] = (toolbarSkinFolderPath + _local3.@SKIN4);
            toolbarSkinArray[5] = (toolbarSkinFolderPath + _local3.@SKIN5);
            toolbarSkinArray[6] = (toolbarSkinFolderPath + _local3.@SKIN6);
            toolbarSkinArray[7] = (toolbarSkinFolderPath + _local3.@SKIN7);
            toolbarSkinArray[8] = (toolbarSkinFolderPath + _local3.@SKIN8);
            toolbarSkinArray[9] = (toolbarSkinFolderPath + _local3.@SKIN9);
            toolbarSkinArray[10] = (toolbarSkinFolderPath + _local3.@SKIN10);
            toolbarSkinArray[11] = (toolbarSkinFolderPath + _local3.@SKIN11);
            toolbarSkinArray[12] = (toolbarSkinFolderPath + _local3.@SKIN12);
            toolbarSkinArray[13] = (toolbarSkinFolderPath + _local3.@SKIN13);
            toolbarSkinArray[14] = (toolbarSkinFolderPath + _local3.@SKIN14);
            toolbarSkinArray[15] = (toolbarSkinFolderPath + _local3.@SKIN15);
            toolbarSkinArray[16] = (toolbarSkinFolderPath + _local3.@SKIN16);
            toolbarSkinArray[17] = (toolbarSkinFolderPath + _local3.@SKIN17);
            toolbarSkinArray[18] = (toolbarSkinFolderPath + _local3.@SKIN18);
            toolbarSkinArray[19] = (toolbarSkinFolderPath + _local3.@SKIN19);
            toolbarSkinArray[20] = (toolbarSkinFolderPath + _local3.@SKIN20);
            toolbarSkinArray[21] = (toolbarSkinFolderPath + _local3.@SKIN21);
            toolbarSkinArray[22] = (toolbarSkinFolderPath + _local3.@SKIN22);
            toolbarSkinArray[23] = (toolbarSkinFolderPath + _local3.@SKIN23);
            toolbarSkinArray[24] = (toolbarSkinFolderPath + _local3.@SKIN24);
            toolbarSkinArray[25] = (toolbarSkinFolderPath + _local3.@SKIN25);
            toolbarSkinArray[26] = (toolbarSkinFolderPath + _local3.@SKIN26);
            toolbarSkinArray[27] = (toolbarSkinFolderPath + _local3.@SKIN27);
            toolbarSkinArray[28] = (toolbarSkinFolderPath + _local3.@SKIN28);
            toolbarSkinArray[29] = (toolbarSkinFolderPath + _local3.@SKIN29);
            toolbarSkinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadToolbarSkinCompleteHandler);
            toolbarSkinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinIOErrorHandler);
            toolbarSkinLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinIOErrorHandler);
            toolbarSkinLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, loadToolbarSkinUnloadHandler);
            loadToolbarSkin(toolbarSkinCounter);
        }
        protected function stopZoomAndPanHandler(_arg1:MouseEvent):void{
            if (_viewer){
                _viewer.zoomStop();
                _viewer.panStop();
                _viewer.invalidate(InvalidationType.STATE);
                removeEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler);
            };
        }
        protected function logoMouseDownHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            logo.addEventListener(MouseEvent.MOUSE_UP, logoMouseUpHandler, false, 0, true);
        }
        protected function hideAlert():void{
            alertOverlay.visible = false;
        }
        public function get showSlider():Boolean{
            return (_showSlider);
        }
        protected function removeButtonEventListener(_arg1:Button, _arg2:Function):void{
            _arg1.removeEventListener(MouseEvent.MOUSE_OVER, _arg2);
        }
        protected function cleanupSkin():void{
            toolbarSkinArray = [];
            toolbarSkinLoadedArray = [];
        }
        protected function zoomOutRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_ZOOMOUT, true);
            zoomOut.addEventListener(MouseEvent.ROLL_OUT, zoomOutRolloutHandler, false, 0, true);
        }
        protected function removeToolbarTooltips(){
            logo.removeEventListener(MouseEvent.MOUSE_OVER, logoRolloverHandler);
            slider.removeEventListener(MouseEvent.MOUSE_OVER, sliderRolloverHandler);
            removeButtonEventListener(zoomOut, zoomOutRolloverHandler);
            removeButtonEventListener(zoomIn, zoomInRolloverHandler);
            removeButtonEventListener(panLeft, panLeftRolloverHandler);
            removeButtonEventListener(panUp, panUpRolloverHandler);
            removeButtonEventListener(panDown, panDownRolloverHandler);
            removeButtonEventListener(panRight, panRightRolloverHandler);
            removeButtonEventListener(reset, resetRolloverHandler);
        }
        public function get toolbarSpacing():Number{
            return (_toolbarSpacing);
        }
        protected function sliderMouseUpHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonUp"));
            };
            slider.removeEventListener(MouseEvent.MOUSE_UP, sliderMouseUpHandler);
        }
        override protected function draw():void{
            var _local1:DisplayObject;
            if (isInvalid(InvalidationType.STYLES)){
                _local1 = getDisplayObjectInstance(getStyleValue("background"));
                if (background != _local1){
                    swapDisplayObjects(background, _local1);
                    background = _local1;
                };
            };
            if (isInvalid(InvalidationType.SIZE)){
                drawLayout();
            };
            super.draw();
        }
        protected function panLeftRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_PANLEFT, true);
            panLeft.addEventListener(MouseEvent.ROLL_OUT, panLeftRolloutHandler, false, 0, true);
        }
        override protected function configUI():void{
            super.configUI();
            configBegin();
        }
        public function set toolbarSkinXMLPath(_arg1:String):void{
            _toolbarSkinXMLPath = _arg1;
            if (_toolbarSkinXMLPath == null){
                _toolbarSkinXMLPath = "";
            };
            if (_toolbarSkinXMLPath.slice(0, 1) == "/"){
                _toolbarSkinXMLPath = _toolbarSkinXMLPath.slice(1, _toolbarSkinXMLPath.length);
            };
            if (_toolbarSkinXMLPath.indexOf("/") != -1){
                toolbarSkinFolderPath = _toolbarSkinXMLPath.slice(0, (_toolbarSkinXMLPath.lastIndexOf("/") + 1));
            };
            configBegin();
        }
        protected function panDownRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_PANDOWN, true);
            panDown.addEventListener(MouseEvent.ROLL_OUT, panDownRolloutHandler, false, 0, true);
        }
        protected function drawLayoutButton(_arg1:Button, _arg2:Number):void{
            if (_arg1 == null){
                return;
            };
            _arg1.height = 15;
            _arg1.width = 15;
            _arg1.x = _arg2;
            _arg1.y = Math.floor(((height - 15) / 2));
        }
        public function set showToolbarTooltips(_arg1:Boolean):void{
            _showToolbarTooltips = _arg1;
        }
        protected function sliderMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            slider.addEventListener(MouseEvent.MOUSE_UP, sliderMouseUpHandler, false, 0, true);
        }
        protected function swapDisplayObjects(_arg1:DisplayObject, _arg2:DisplayObject):void{
            var idx:* = 0;
            var oldDO:* = _arg1;
            var newDO:* = _arg2;
            try {
                idx = getChildIndex(oldDO);
                removeChildAt(idx);
                addChildAt(newDO, idx);
                invalidate(InvalidationType.SIZE);
            } catch(e:Error) {
            };
        }
        protected function showAlert(_arg1:String):void{
            if (alertOverlay == null){
                alertOverlay = new Sprite();
            };
            while (alertOverlay.numChildren > 0) {
                alertOverlay.removeChildAt(0);
            };
            var _local2:DisplayObject = getDisplayObjectInstance(getStyleValue("toolbarAlert"));
            if (_local2){
                alertOverlay.addChild(_local2);
            };
            var _local3:TextField = new TextField();
            _local3.multiline = false;
            _local3.selectable = false;
            _local3.condenseWhite = true;
            _local3.defaultTextFormat = new TextFormat("_sans", 12, 0, null, null, null, null, null, TextFormatAlign.CENTER);
            _local3.htmlText = _arg1;
            _local3.width = (alertOverlay.width - 2);
            _local3.height = (alertOverlay.height - 2);
            _local3.x = 1;
            _local3.y = 1;
            alertOverlay.addChild(_local3);
            alertOverlay.x = ((width / 2) - (alertOverlay.width / 2));
            alertOverlay.y = 1;
            addChild(alertOverlay);
            alertOverlay.visible = true;
            alertOverlay.alpha = 1;
        }
        protected function panDownMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.panDown();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function indexOfContainingElement(_arg1:Array, _arg2:String):Number{
            var _local3:Number = -1;
            var _local4:Number = 0;
            var _local5:Number = _arg1.length;
            while (_local4 < _local5) {
                if (_arg1[_local4].toString().indexOf(_arg2) != -1){
                    _local3 = _local4;
                    _local4 = _local5;
                } else {
                    _local4++;
                };
            };
            return (_local3);
        }
        public function set viewerName(_arg1:String):void{
            var isLivePreview:* = false;
            var value:* = _arg1;
            try {
                viewer = (parent.getChildByName(value) as IZoomifyViewer);
                isLivePreview = ((!((parent == null))) && ((getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent")));
                if (((((!(isLivePreview)) && (!((value == ""))))) && (!((value == null))))){
                    if (viewer == null){
                        showAlert(Resources.ALERT_SETTINGTOOLBARVIEWER);
                    };
                };
            } catch(error:Error) {
                throw (new Error(Resources.ERROR_SETTINGVIEWER));
            };
        }
        public function set showSlider(_arg1:Boolean):void{
            if (_showSlider == _arg1){
                return;
            };
            _showSlider = _arg1;
            invalidate(InvalidationType.SIZE);
        }
        protected function configBegin(_arg1:Event=null):void{
            var _local2:Boolean;
            if (_toolbarSkinXMLPath != "unset"){
                _local2 = ((!((parent == null))) && ((getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent")));
                if (((((((_local2) || ((_toolbarSkinXMLPath == null)))) || ((_toolbarSkinXMLPath == "")))) || ((_toolbarSkinXMLPath == "/")))){
                    configSkin();
                } else {
                    loadToolbarSkinXML();
                };
            };
        }
        protected function loadToolbarSkinXMLIOErrorHandler(_arg1:Event):void{
            skinError = Resources.ALERT_SETTINGTOOLBARSKIN;
            if (_viewer){
                if (_viewer.eventsEnabled){
                    dispatchEvent(new Event("toolbarSkinXMLLoadingFailed"));
                };
            };
            cleanupSkin();
            configSkin();
        }
        public function set toolbarSpacing(_arg1:Number):void{
            _toolbarSpacing = _arg1;
        }
        protected function panUpRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            panUp.removeEventListener(MouseEvent.ROLL_OUT, panUpRolloutHandler);
        }
        protected function drawLayout():void{
            var _local1:Number;
            if (((((background) && (logo))) && (logoDivider))){
                background.width = width;
                background.height = height;
                logo.y = Math.ceil(((height - logo.height) / 2));
                logo.visible = showZoomifyButton;
                logoDivider.x = logo.width;
                logoDivider.height = height;
                logoDivider.visible = showZoomifyButton;
                drawLayoutContent();
                _local1 = ((showZoomifyButton) ? Math.ceil((logo.width + logoDivider.width)) : 0);
                content.x = (_local1 + Math.ceil((((width - _local1) - contentWidth) / 2)));
            };
        }
        protected function resetRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            reset.removeEventListener(MouseEvent.ROLL_OUT, resetRolloutHandler);
        }
        protected function loadToolbarSkinUnloadHandler(_arg1:Event):void{
            if (toolbarSkinCounter < toolbarSkinCounterMax){
                toolbarSkinCounter = (toolbarSkinCounter + 1);
                loadToolbarSkin(toolbarSkinCounter);
            } else {
                if (_viewer.eventsEnabled){
                    dispatchEvent(new Event("toolbarSkinLoadingComplete"));
                };
                toolbarSkinLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadToolbarSkinCompleteHandler);
                toolbarSkinLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinIOErrorHandler);
                toolbarSkinLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinIOErrorHandler);
                toolbarSkinLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, loadToolbarSkinUnloadHandler);
                configSkin();
            };
        }
        protected function configComplete(_arg1:Event=null):void{
            drawLayout();
            initializeStageMouseListeners();
            setToolbarSliderZoomDecimal();
            validateShowToolbarTooltips();
            validateSkins();
            if (_viewer){
                if (!_viewer.initialized){
                    _viewer.addEventListener("viewerInitializationCompleteInternal", configComplete, false, 0, true);
                } else {
                    _viewer.removeEventListener("viewerInitializationCompleteInternal", configComplete);
                };
            };
        }
        protected function loadToolbarSkinCompleteHandler(_arg1:Event):void{
            toolbarSkinLoadedArray[toolbarSkinCounter] = toolbarSkinLoader.content;
            toolbarSkinLoader.unload();
        }
        protected function panUpMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.panUp();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function setToolbarSliderZoomDecimal():void{
            var _local1:Number;
            if (_viewer){
                if (_viewer.initialized){
                    _local1 = _viewer.getZoomDecimal();
                    minZoomDecimal = _viewer.getMinimumZoomDecimal();
                    maxZoomDecimal = _viewer.getMaximumZoomDecimal();
                    if (((((slider) && (!(isNaN(minZoomDecimal))))) && (!(isNaN(maxZoomDecimal))))){
                        slider.value = ((20000 * (_local1 - minZoomDecimal)) / (maxZoomDecimal - minZoomDecimal));
                    };
                };
            };
        }
        protected function prepareForUserInteraction():void{
        }
        protected function getToolbarSliderZoomDecimal():Number{
            if (((slider) && (((isNaN(minZoomDecimal)) || (isNaN(maxZoomDecimal)))))){
                setToolbarSliderZoomDecimal();
            };
            return (((((maxZoomDecimal - minZoomDecimal) * slider.value) / 20000) + minZoomDecimal));
        }
        protected function configSkinContent():void{
            var _local1:Sprite;
            var _local2:Sprite;
            var _local3:Sprite;
            zoomOut = new Button();
            configButton(zoomOut, zoomOutMouseDownHandler, zoomOutRolloverHandler, 3, "iconMinus");
            content.addChild(zoomOut);
            slider = new HighSlider();
            slider.minimum = 0;
            slider.maximum = 20000;
            slider.snapInterval = 10;
            slider.tickInterval = 1000;
            slider.value = 0;
            if (toolbarSkinLoadedArray[6] != null){
                slider.setStyle("sliderTrackSkin", toolbarSkinLoadedArray[6]);
                slider.setStyle("tickSkin", toolbarSkinLoadedArray[(6 + 1)]);
                _local1 = new Sprite();
                _local1.addChild(toolbarSkinLoadedArray[(6 + 2)]);
                _local1.getChildAt(0).x = (_local1.getChildAt(0).x - (_local1.getChildAt(0).width / 2));
                slider.setStyle("thumbUpSkin", _local1);
                _local2 = new Sprite();
                _local2.addChild(toolbarSkinLoadedArray[(6 + 3)]);
                _local2.getChildAt(0).x = (_local2.getChildAt(0).x - (_local2.getChildAt(0).width / 2));
                slider.setStyle("thumbOverSkin", _local2);
                _local3 = new Sprite();
                _local3.addChild(toolbarSkinLoadedArray[(6 + 4)]);
                _local3.getChildAt(0).x = (_local3.getChildAt(0).x - (_local3.getChildAt(0).width / 2));
                slider.setStyle("thumbDownSkin", _local3);
            };
            slider.addEventListener("change", sliderChangeHandler);
            slider.addEventListener("thumbDrag", sliderDragHandler);
            slider.addEventListener(MouseEvent.MOUSE_OVER, sliderRolloverHandler, false, 0, true);
            slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDownHandler, false, 0, true);
            slider.visible = showSlider;
            content.addChild(slider);
            zoomIn = new Button();
            configButton(zoomIn, zoomInMouseDownHandler, zoomInRolloverHandler, 11, "iconPlus");
            content.addChild(zoomIn);
            if (toolbarSkinLoadedArray[14] == null){
                zoomPanDivider = getDisplayObjectInstance(getStyleValue("divider"));
            } else {
                zoomPanDivider = toolbarSkinLoadedArray[14];
            };
            content.addChild(zoomPanDivider);
            panLeft = new Button();
            configButton(panLeft, panLeftMouseDownHandler, panLeftRolloverHandler, 15, "iconArrowLeft");
            content.addChild(panLeft);
            panUp = new Button();
            configButton(panUp, panUpMouseDownHandler, panUpRolloverHandler, 18, "iconArrowUp");
            content.addChild(panUp);
            panDown = new Button();
            configButton(panDown, panDownMouseDownHandler, panDownRolloverHandler, 21, "iconArrowDown");
            content.addChild(panDown);
            panRight = new Button();
            configButton(panRight, panRightMouseDownHandler, panRightRolloverHandler, 24, "iconArrowRight");
            content.addChild(panRight);
            reset = new Button();
            configButton(reset, resetMouseDownHandler, resetRolloverHandler, 27, "iconReset");
            content.addChild(reset);
        }
        protected function stopZoomAndPan():void{
            if (_viewer){
                _viewer.zoomStop();
                _viewer.panStop();
                _viewer.invalidate(InvalidationType.STATE);
            };
        }
        protected function logoMouseUpHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonUp"));
            };
            logo.removeEventListener(MouseEvent.MOUSE_UP, logoMouseUpHandler);
            navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
        }
        public function get showToolbarTooltips():Boolean{
            return (_showToolbarTooltips);
        }
        protected function sliderRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            slider.removeEventListener(MouseEvent.ROLL_OUT, sliderRolloutHandler);
        }
        protected function zoomOutRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            zoomOut.removeEventListener(MouseEvent.ROLL_OUT, zoomOutRolloutHandler);
        }
        protected function validateShowToolbarTooltips(){
            if (_showToolbarTooltips == false){
                removeToolbarTooltips();
            };
        }
        public function set showZoomifyButton(_arg1:Boolean):void{
            if (_showZoomifyButton == _arg1){
                return;
            };
            _showZoomifyButton = _arg1;
            invalidate(InvalidationType.SIZE);
        }
        public function get viewerName():String{
            return (_viewer.name);
        }
        protected function panRightRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            panRight.removeEventListener(MouseEvent.ROLL_OUT, panRightRolloutHandler);
        }
        protected function loadToolbarSkinIOErrorHandler(_arg1:Event):void{
            if (_viewer){
                if (_viewer.eventsEnabled){
                    dispatchEvent(new Event("toolbarSkinLoadingFailed"));
                };
            };
            var _local2 = "Individual skin file not found";
            if (_arg1.toString().indexOf("/") != -1){
                _local2 = _arg1.toString().slice((_arg1.toString().lastIndexOf("/") + 1), (_arg1.toString().lastIndexOf("]") - 1));
            };
            showAlert(("Skin file not found: " + _local2));
            cleanupSkin();
        }
        protected function panLeftRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            panLeft.removeEventListener(MouseEvent.ROLL_OUT, panLeftRolloutHandler);
        }
        protected function panLeftMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.panLeft();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function zoomInRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_ZOOMIN, true);
            zoomIn.addEventListener(MouseEvent.ROLL_OUT, zoomInRolloutHandler, false, 0, true);
        }
        protected function panRightRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_PANRIGHT, true);
            panRight.addEventListener(MouseEvent.ROLL_OUT, panRightRolloutHandler, false, 0, true);
        }
        protected function zoomInRolloutHandler(_arg1:MouseEvent):void{
            Tooltip.hide();
            if (_arg1.buttonDown == true){
                stopZoomAndPan();
            };
            zoomIn.removeEventListener(MouseEvent.ROLL_OUT, zoomInRolloutHandler);
        }
        protected function loadToolbarSkin(_arg1):void{
            toolbarSkinLoader.load(new URLRequest(toolbarSkinArray[_arg1]));
        }
        protected function sliderDragHandler(_arg1:Event):void{
            if (_viewer){
                if (_viewer.eventsEnabled){
                    dispatchEvent(new Event("toolbarSliderDrag"));
                };
                _viewer.setExternalZoomingFlag(true);
                _viewer.setZoomDecimal(getToolbarSliderZoomDecimal(), false);
            };
        }
        protected function resetMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.zoomToInitialView();
            };
        }
        protected function zoomInMouseDownHandler(_arg1:MouseEvent):void{
            prepareForUserInteraction();
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("toolbarButtonDown"));
            };
            if (_viewer){
                _viewer.zoomIn();
                addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
            };
        }
        protected function gridChangedHandler(_arg1:Event):void{
            setToolbarSliderZoomDecimal();
        }
        protected function logoRolloutHandler(_arg1:MouseEvent):void{
            logo.removeEventListener(MouseEvent.ROLL_OUT, logoRolloutHandler);
            Tooltip.hide();
        }
        protected function loadToolbarSkinXML(){
            var _local1:URLLoader = new URLLoader();
            _local1.addEventListener(Event.COMPLETE, loadToolbarSkinXMLCompleteHandler);
            _local1.addEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinXMLIOErrorHandler);
            _local1.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinXMLIOErrorHandler);
            _local1.load(new URLRequest(_toolbarSkinXMLPath));
        }
        protected function configSkin():void{
            if (toolbarSkinArray.length == 0){
                background = getDisplayObjectInstance(getStyleValue("background"));
                toolbarLogo = getDisplayObjectInstance(getStyleValue("logo"));
                logoDivider = getDisplayObjectInstance(getStyleValue("divider"));
            } else {
                background = toolbarSkinLoadedArray[0];
                toolbarLogo = toolbarSkinLoadedArray[1];
                logoDivider = toolbarSkinLoadedArray[2];
            };
            logo = new Sprite();
            logo.buttonMode = true;
            logo.addEventListener(MouseEvent.MOUSE_OVER, logoRolloverHandler, false, 0, true);
            logo.addEventListener(MouseEvent.MOUSE_DOWN, logoMouseDownHandler, false, 0, true);
            logo.addChild(toolbarLogo);
            logo.visible = showZoomifyButton;
            logoDivider.visible = showZoomifyButton;
            addChild(background);
            addChild(logo);
            addChild(logoDivider);
            content = new Sprite();
            addChild(content);
            configSkinContent();
            configComplete();
        }
        protected function resetRolloverHandler(_arg1:MouseEvent):void{
            Tooltip.show(Resources.TOOLTIP_RESET, true);
            reset.addEventListener(MouseEvent.ROLL_OUT, resetRolloutHandler, false, 0, true);
        }
        public function get showZoomifyButton():Boolean{
            return (_showZoomifyButton);
        }

    }
}//package zoomify 
