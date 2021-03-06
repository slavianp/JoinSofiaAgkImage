﻿package zoomify {
    import flash.display.*;
    import fl.core.*;
    import flash.events.*;
    import flash.geom.*;
    import zoomify.viewer.*;
    import zoomify.events.*;
    import fl.managers.*;
    import flash.utils.*;
    import zoomify.utils.*;
    import flash.ui.*;
    import flash.net.*;

    public class ZoomifyViewer extends UIComponent implements IFocusManagerComponent, IZoomifyViewer {

        private static var defaultStyles:Object = {
            splashScreen:"zoomify.viewer.SplashScreen",
            messageScreen:"zoomify.viewer.MessageScreen",
            tooltipBackground:"ZoomifyViewer_tooltipBackground"
        };

        protected var _minZoom:Number = -1;
        protected var toolbarHorizontalFlag:Number = 0;
        public var errFileNotFound;
        protected var changeXSpan:Number;
        protected var _maxZoom:Number = 100;
        protected var tmpX:Number = 0;
        protected var tmpY:Number = 0;
        protected var cachedView2:BitmapData;
        protected var cachedView1:BitmapData;
        protected var _splashScreenVisibility:Boolean = true;
        protected var _fadeInSpeed:Number = 200;
        protected var _imageTileSize:Number;
        protected var minZoomDecimal:Number = 0.1;
        public var tierWidthsInTilesArray:Array;
        protected var viewPanning:Boolean = false;
        protected var content:MovieClip;
        protected var toolbarZoomFlag:Number = 0;
        protected var externalPanning:Boolean = false;
        protected var targetPanY:Number = 0;
        public var tierHeightsArray:Array;
        protected var targetPanX:Number = 0;
        protected var changeXStart:Number;
        protected var _imagePath:String;
        protected var _imageHeight:Number;
        protected var _zoomSpeed:Number = 10;
        protected var scaleCalc:Number;
        protected var changeCurrentTierScaleStart:Number;
        protected var changeCurrentTierScaleSpan:Number;
        protected var _imageWidth:Number;
        protected var viewZooming:Boolean = false;
        protected var externalZooming:Boolean = false;
        protected var numTiers:uint = 0;
        protected var tmpXParam:String = "center";
        protected var changingImage = false;
        protected var _initialX:Number = 0;
        protected var _initialY:Number = 0;
        protected var logoSplashScreen:Sprite;
        protected var zoomFactor:Number;
        public var currentTier:int = 0;
        protected var currentTierScale:Number = 1;
        protected var _initialized:Boolean = false;
        protected var _keyboardEnabled:Boolean = true;
        protected var toolbarVerticalFlag:Number = 0;
        protected var textMessageScreen:Sprite;
        protected var _panConstrain:Boolean = true;
        protected var changeYStart:Number;
        protected var grid:ZoomGrid;
        protected var _tierScaleUpThreshold:Number = 1.15;
        protected var spaceZooming:Boolean = false;
        protected var _viewY:Number;
        protected var _tierScaleDownThreshold:Number;
        protected var _viewX:Number;
        protected var _viewZoom:Number;
        protected var _initialZoom:Number = -1;
        protected var zoomPoint:Point;
        protected var _messageScreenVisibility:Boolean = false;
        protected var tmpZoom:Number = -1;
        protected var tmpYParam:String = "center";
        protected var hit:Point;
        protected var dragged:Boolean = false;
        protected var changeYSpan:Number;
        protected var zoomToViewTimer:Timer;
        protected var contentScrollRect:Rectangle;
        protected var targetZoomDecimal:Number = 0;
        protected var lastMouse:Point;
        public var tierWidthsArray:Array;
        protected var updateTierTimer:Timer;
        protected var currentCacheView:BitmapData;
        protected var zoomSpeedAdj:Number;
        protected var _eventsEnabled:Boolean = false;
        public var tierHeightsInTilesArray:Array;
        protected var ignoreMouseUp:Boolean = true;
        protected var _tileCache:TileCache;
        protected var mouseIsDown:Boolean = false;
        protected var maxZoomDecimal:Number;
        protected var _clickZoom:Boolean = true;

        public function ZoomifyViewer():void{
            _tierScaleDownThreshold = (_tierScaleUpThreshold / 2);
            zoomSpeedAdj = (_zoomSpeed * 1.25);
            zoomFactor = (1 / (1000 / (zoomSpeedAdj * zoomSpeedAdj)));
            maxZoomDecimal = (_maxZoom / 100);
            tierWidthsArray = [];
            tierHeightsArray = [];
            tierWidthsInTilesArray = [];
            tierHeightsInTilesArray = [];
            zoomToViewTimer = new Timer(0, 0);
            errFileNotFound = (Resources.ERROR_LOADINGFILE + "%s");
            super();
            tabEnabled = false;
            _tileCache = new TileCache();
            _tileCache.addEventListener(TileProgressEvent.TILE_PROGRESS, tileProgressHandler);
            updateTierTimer = new Timer(300, 1);
            updateTierTimer.addEventListener("timer", updateTierTimerHandler, false, 0, true);
            if ((((_tierScaleUpThreshold <= 1)) || ((_tierScaleUpThreshold > 2)))){
                _tierScaleUpThreshold = 1.15;
                _tierScaleDownThreshold = (1 / _tierScaleUpThreshold);
            };
            lastMouse = new Point(mouseX, mouseY);
            addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
            initializeStageKeyboardListeners();
            initializeStageMouseListeners();
            initializeTooltip();
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }

        private function initializeStageMouseListeners(_arg1:Event=null):void{
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners, false, 0, true);
            } else {
                removeEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners);
                if (((enabled) && (mouseEnabled))){
                    stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
                    stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
                    stage.addEventListener(MouseEvent.MOUSE_WHEEL, stageMouseWheelHandler, false, 0, true);
                    addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
                    addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
                } else {
                    stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
                    stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
                    stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stageMouseWheelHandler);
                    removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
                    removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
                };
            };
        }
        public function get fadeInSpeed():Number{
            return (_fadeInSpeed);
        }
        protected function configTextMessageScreen():void{
            var _local1:DisplayObject = getDisplayObjectInstance(getStyleValue("messageScreen"));
            textMessageScreen = new Sprite();
            textMessageScreen.visible = false;
            _messageScreenVisibility = textMessageScreen.visible;
            textMessageScreen.buttonMode = true;
            textMessageScreen.addChild(_local1);
            textMessageScreen.addEventListener(MouseEvent.CLICK, messageScreenClickHandler, false, 0, true);
            addChild(textMessageScreen);
        }
        protected function clearAll(){
            clearCachedViews();
            clearImage();
        }
        protected function splashScreenClickHandler(_arg1:MouseEvent):void{
            navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
        }
        public function set fadeInSpeed(_arg1:Number):void{
            if (_arg1 < 1){
                _arg1 = 1;
            };
            _fadeInSpeed = _arg1;
            if (grid != null){
                grid.setFadeInSpeed(_fadeInSpeed);
            };
        }
        protected function enterFrameHandler(_arg1:Event):void{
            var _local2:int;
            if (((((((((((((!((toolbarZoomFlag == 0))) || (!((targetZoomDecimal == 0))))) || (!((targetPanX == 0))))) || (!((targetPanY == 0))))) || (!((toolbarHorizontalFlag == 0))))) || (!((toolbarVerticalFlag == 0))))) && (zoomToViewTimer.running))){
                zoomToViewStop();
            };
            if (((!(grid)) || (zoomToViewTimer.running))){
                return;
            };
            if (toolbarZoomFlag == -1){
                dispatchEvent(new Event("viewZoomingOutInternal"));
                if (_eventsEnabled){
                    viewZooming = true;
                    dispatchEvent(new Event("viewZoomingOut"));
                };
                setZoomDecimal(Math.max(minZoomDecimal, (getZoomDecimal() * (1 - zoomFactor))), true);
                targetZoomDecimal = 0;
            } else {
                if (toolbarZoomFlag == 1){
                    dispatchEvent(new Event("viewZoomingInInternal"));
                    if (_eventsEnabled){
                        viewZooming = true;
                        dispatchEvent(new Event("viewZoomingIn"));
                    };
                    setZoomDecimal(Math.min(maxZoomDecimal, (getZoomDecimal() * (1 + zoomFactor))), true);
                    targetZoomDecimal = 0;
                } else {
                    if (targetZoomDecimal != 0){
                        if (_eventsEnabled){
                            viewZooming = true;
                        };
                        if (targetZoomDecimal < currentTierScale){
                            dispatchEvent(new Event("viewZoomingOutInternal"));
                            if (_eventsEnabled){
                                dispatchEvent(new Event("viewZoomingOut"));
                            };
                        } else {
                            if (targetZoomDecimal > currentTierScale){
                                dispatchEvent(new Event("viewZoomingInInternal"));
                                if (_eventsEnabled){
                                    dispatchEvent(new Event("viewZoomingIn"));
                                };
                            };
                        };
                        if (Math.abs((targetZoomDecimal - currentTierScale)) < 0.001){
                            modifyCurrentTierScaleRelatively((targetZoomDecimal - currentTierScale), zoomPoint);
                            targetZoomDecimal = 0;
                            invalidate(InvalidationType.STATE);
                        } else {
                            modifyCurrentTierScaleRelatively(((targetZoomDecimal - currentTierScale) / 2), zoomPoint);
                        };
                        if (getZoomDecimal() < minZoomDecimal){
                            setZoomDecimal(minZoomDecimal, false);
                            targetZoomDecimal = 0;
                            invalidate(InvalidationType.STATE);
                        } else {
                            if (getZoomDecimal() > maxZoomDecimal){
                                setZoomDecimal(maxZoomDecimal, false);
                                targetZoomDecimal = 0;
                                invalidate(InvalidationType.STATE);
                            };
                        };
                        dispatchEvent(new Event("gridChanged"));
                        dispatchEvent(new Event("areaChanged"));
                    };
                };
            };
            if (((!((targetPanX == 0))) || (!((targetPanY == 0))))){
                targetPanX = (targetPanX / 2);
                targetPanY = (targetPanY / 2);
                _local2 = moveCanvas(targetPanX, targetPanY);
                if ((((_local2 & 1)) || ((Math.abs(targetPanX) < 1)))){
                    targetPanX = 0;
                };
                if ((((_local2 & 2)) || ((Math.abs(targetPanY) < 1)))){
                    targetPanY = 0;
                };
                if ((((targetPanX == 0)) && ((targetPanY == 0)))){
                    invalidate(InvalidationType.STATE);
                };
            } else {
                if (((!((toolbarHorizontalFlag == 0))) || (!((toolbarVerticalFlag == 0))))){
                    moveCanvas((toolbarHorizontalFlag * 6), (toolbarVerticalFlag * 6));
                } else {
                    if (((((viewPanning) || (viewZooming))) && (((((!(mouseIsDown)) && (!(externalPanning)))) && (!(externalZooming)))))){
                        if (viewPanning){
                            viewPanning = false;
                            if (_eventsEnabled){
                                dispatchEvent(new Event("viewPanComplete"));
                            };
                        };
                        if (((((viewZooming) && ((toolbarZoomFlag == 0)))) && ((targetZoomDecimal == 0)))){
                            viewZooming = false;
                            if (_eventsEnabled){
                                dispatchEvent(new Event("viewZoomComplete"));
                            };
                            if (getZoomDecimal() == maxZoomDecimal){
                                dispatchEvent(new Event("zoomConstrainedToMax"));
                            };
                            if (getZoomDecimal() == minZoomDecimal){
                                dispatchEvent(new Event("zoomConstrainedToMin"));
                            };
                        };
                    };
                };
            };
        }
        public function get viewZoom():Number{
            if (grid){
                return ((getZoomDecimal() * 100));
            };
            return (0);
        }
        public function get imagePath():String{
            return (_imagePath);
        }
        protected function modifyCurrentTierScaleRelatively(_arg1:Number, _arg2:Point):void{
            currentTierScale = (currentTierScale + _arg1);
            var _local3:Point = new Point((width / 2), (height / 2));
            _local3 = localToGlobal(_local3);
            grid.scaleCurrentTierRelatively(currentTierScale, _arg2.x, _arg2.y, _local3);
        }
        public function zoomToViewStop():void{
            if (zoomToViewTimer.running){
                zoomToViewTimer.repeatCount = zoomToViewTimer.currentCount;
            };
        }
        public function get zoomSpeed():Number{
            return (_zoomSpeed);
        }
        public function set viewZoom(_arg1:Number):void{
            var _local2:Number;
            if (grid){
                if (_arg1 != -1){
                    _local2 = convertZoomPercentToDecimal(_arg1);
                } else {
                    _local2 = calcZoomDecimalToFitDisplay();
                };
                if (_local2 < minZoomDecimal){
                    _local2 = minZoomDecimal;
                };
                if (_local2 > maxZoomDecimal){
                    _local2 = maxZoomDecimal;
                };
                _viewZoom = _local2;
                setZoomDecimal(_viewZoom);
                invalidate(InvalidationType.STATE);
            } else {
                tmpZoom = _arg1;
            };
        }
        public function setImageOffset(_arg1:Point):void{
            if (_eventsEnabled){
                viewPanning = true;
                dispatchEvent(new Event("viewPanning"));
            };
            grid.setImageOffset(_arg1);
        }
        public function setZoomDecimal(_arg1:Number, _arg2:Boolean=true):void{
            _arg1 = (_arg1 * (1 << (numTiers - 1)));
            modifyCurrentTierScale(((_arg1 / (1 << grid.getCurrentTier())) - currentTierScale), new Point((width / 2), (height / 2)), _arg2);
        }
        public function set imagePath(_arg1:String):void{
            if (_imagePath == _arg1){
                return;
            };
            if (_imagePath != null){
                hideMessage();
                if (grid != null){
                    clearAll();
                };
                changingImage = true;
                addEventListener("imageChangedInternal", viewerImageChangedInternalHandler, false, 0, true);
            };
            _imagePath = _arg1;
            loadImageProperties();
        }
        public function panStop():void{
            toolbarVerticalFlag = 0;
            toolbarHorizontalFlag = 0;
        }
        protected function updateTierTimerHandler(_arg1:TimerEvent):void{
            invalidate(InvalidationType.STATE);
        }
        protected function viewerImageChangedInternalHandler(_arg1:Event):void{
            setInitialView();
        }
        public function set splashScreenVisibility(_arg1:Boolean):void{
            logoSplashScreen.visible = _arg1;
            _splashScreenVisibility = logoSplashScreen.visible;
        }
        public function getViewYImageSpan():Number{
            if (grid){
                return (grid.yImageSpan);
            };
            return (0);
        }
        public function updateTier():void{
            var _local2:BitmapData;
            var _local3:Point;
            var _local1:int = currentTier;
            if ((((((currentTierScale > _tierScaleUpThreshold)) && (((currentTier + 1) < numTiers)))) || ((((currentTierScale <= _tierScaleDownThreshold)) && (((currentTier - 1) >= 0)))))){
                _local2 = swapBuffer();
                _local2.lock();
                _local2.fillRect(new Rectangle(0, 0, _local2.width, _local2.height), 0xFFFFFF);
                _local2.draw(this, null, null, null, null, true);
                _local2.unlock();
                _local1 = selectTier();
                grid.active(false);
                _local3 = grid.getOffset();
                grid.updateCanvas(imageTileSize, imageWidth, imageHeight, _local1, tierWidthsInTilesArray, tierHeightsInTilesArray);
                grid.setPriorBitmap(_local2);
                grid.active(true);
                grid.resetScale(currentTierScale);
                grid.setOffset(_local3, tierWidthsArray[_local1]);
            };
            grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), _local1, tierWidthsArray[_local1], tierHeightsArray[_local1], tierWidthsInTilesArray[_local1], tierHeightsInTilesArray[_local1], true);
            currentTier = _local1;
        }
        protected function firstFullViewDrawViewerInternalHandler(_arg1:Event):void{
            removeEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawViewerInternalHandler);
            content.visible = true;
            invalidate(InvalidationType.SIZE);
            _initialized = true;
            if (changingImage == false){
                dispatchEvent(new Event("imageChangedInternal"));
                dispatchEvent(new Event("viewerInitializationCompleteInternal"));
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewerInitializationComplete"));
                };
            } else {
                dispatchEvent(new Event("imageChangedInternal"));
                dispatchEvent(new Event("imageChanged"));
            };
            dispatchEvent(new Event("areaChanged"));
        }
        public function zoomIn():void{
            toolbarZoomFlag = 1;
        }
        public function get imageTileSize():Number{
            return (_imageTileSize);
        }
        private function initializeTooltip(_arg1:Event=null):void{
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, initializeTooltip, false, 0, true);
            } else {
                removeEventListener(Event.ADDED_TO_STAGE, initializeTooltip);
                Tooltip.initialize(this);
            };
        }
        public function get viewY():Number{
            if (grid){
                return (grid.y);
            };
            return (0);
        }
        public function getTierWidth(_arg1:uint):Number{
            var _local2:Number = imageWidth;
            var _local3:uint = numTiers;
            while (_local3 > (_arg1 + 1)) {
                _local2 = (_local2 / 2);
                _local3--;
            };
            return (_local2);
        }
        public function panUp():void{
            toolbarVerticalFlag = 1;
        }
        protected function configLogoSplashScreen():void{
            var _local1:DisplayObject = getDisplayObjectInstance(getStyleValue("splashScreen"));
            logoSplashScreen = new Sprite();
            logoSplashScreen.visible = false;
            _splashScreenVisibility = logoSplashScreen.visible;
            logoSplashScreen.buttonMode = true;
            logoSplashScreen.addChild(_local1);
            logoSplashScreen.addEventListener(MouseEvent.CLICK, splashScreenClickHandler, false, 0, true);
            addChild(logoSplashScreen);
        }
        public function get viewX():Number{
            if (grid){
                return (grid.x);
            };
            return (0);
        }
        public function hideMessage():void{
            textMessageScreen.visible = false;
        }
        public function get scaleUpThreshold():Number{
            return (_tierScaleUpThreshold);
        }
        public function get imageHeight():Number{
            return (_imageHeight);
        }
        private function initializeStageKeyboardListeners(_arg1:Event=null):void{
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, initializeStageKeyboardListeners, false, 0, true);
            } else {
                removeEventListener(Event.ADDED_TO_STAGE, initializeStageKeyboardListeners);
                if (((enabled) && (_keyboardEnabled))){
                    stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler, false, 0, true);
                    stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, false, 0, true);
                } else {
                    stage.removeEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler);
                    stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
                };
            };
        }
        public function setView(_arg1:Number, _arg2:Number, _arg3:Number):void{
            viewX = _arg1;
            viewY = _arg2;
            viewZoom = _arg3;
        }
        public function set initialZoom(_arg1:Number):void{
            _initialZoom = _arg1;
            if (grid == null){
                tmpZoom = _initialZoom;
            };
        }
        public function set zoomSpeed(_arg1:Number):void{
            _zoomSpeed = Math.max(1, Math.min(50, _arg1));
            zoomSpeedAdj = (_zoomSpeed * 1.25);
            zoomFactor = (1 / (1000 / (zoomSpeedAdj * zoomSpeedAdj)));
        }
        protected function convertCurrentTierScaleToZoom(_arg1:Number, _arg2:int):Number{
            var _local3:Number = (_arg1 * (getTierWidth(_arg2) / imageWidth));
            return (_local3);
        }
        public function setInitialView():void{
            setView(_initialX, _initialY, initialZoom);
        }
        public function setViewYImageSpan(_arg1:Number):void{
            if (grid){
                grid.yImageSpan = _arg1;
                invalidate(InvalidationType.STATE);
            } else {
                tmpY = _arg1;
            };
        }
        public function zoomOut():void{
            toolbarZoomFlag = -1;
        }
        public function zoomStop():void{
            toolbarZoomFlag = 0;
        }
        override public function set enabled(_arg1:Boolean):void{
            super.enabled = _arg1;
            if (grid){
                grid.enabled = _arg1;
            };
            initializeStageKeyboardListeners();
            initializeStageMouseListeners();
        }
        public function showMessage(_arg1:String=null):void{
            var _local3:MessageScreen;
            textMessageScreen.visible = true;
            var _local2:uint;
            while (_local2 < textMessageScreen.numChildren) {
                _local3 = (textMessageScreen.getChildAt(_local2) as MessageScreen);
                if (_local3 != null){
                    _local3.setMessage(((_arg1)==null) ? "" : _arg1);
                    break;
                };
                _local2++;
            };
        }
        protected function mouseDownHandler(_arg1:MouseEvent):void{
            if (_eventsEnabled){
                dispatchEvent(new Event("viewerMouseDown"));
            };
            dragged = false;
            if (!grid){
                return;
            };
            if (content.contains(DisplayObject(_arg1.target))){
                ignoreMouseUp = false;
                dispatchEvent(new Event("prepareForUserInteraction"));
            };
            if (mouseY < height){
                mouseIsDown = true;
            };
            lastMouse = new Point(mouseX, mouseY);
            hit = new Point(mouseX, mouseY);
            zoomPoint = grid.getMousePosition();
            scaleCalc = grid.getCurrentTierScale();
            currentTierScale = scaleCalc;
        }
        protected function moveCanvas(_arg1:Number, _arg2:Number):int{
            if ((((_arg1 == 0)) && ((_arg2 == 0)))){
                return (0);
            };
            var _local3:int = grid.offsetCanvas(_arg1, _arg2);
            grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
            if (_eventsEnabled){
                viewPanning = true;
                dispatchEvent(new Event("viewPanning"));
            };
            dispatchEvent(new Event("areaChanged"));
            return (_local3);
        }
        public function set minZoom(_arg1:Number):void{
            _minZoom = _arg1;
            if (grid){
                minZoomDecimal = convertZoomPercentToDecimal(_minZoom);
            };
        }
        public function getTierPowerOf2():Number{
            return (((1 << grid.getCurrentTier()) * currentTierScale));
        }
        public function getImageOffset():Point{
            return (grid.getImageOffset());
        }
        protected function firstTileDrawViewerInternalHandler(_arg1:Event):void{
            grid.removeEventListener("viewerFirstTileDrawInternal", firstTileDrawViewerInternalHandler);
            this.splashScreenVisibility = false;
            cacheView();
        }
        protected function convertZoomToCurrentTierScale(_arg1:Number, _arg2:int):Number{
            var _local3:Number = (_arg1 / (getTierWidth(_arg2) / imageWidth));
            return (_local3);
        }
        public function set viewX(_arg1:Number):void{
            if (grid){
                _viewX = _arg1;
                grid.x = _viewX;
                invalidate(InvalidationType.STATE);
            } else {
                tmpX = _arg1;
            };
        }
        public function set maxZoom(_arg1:Number):void{
            _maxZoom = _arg1;
            if (grid){
                maxZoomDecimal = convertZoomPercentToDecimal(_maxZoom);
            };
        }
        protected function positionMessageScreen():void{
            textMessageScreen.x = ((width - textMessageScreen.width) / 2);
            textMessageScreen.y = ((height - textMessageScreen.height) / 2);
        }
        public function set panConstrain(_arg1:Boolean):void{
            _panConstrain = _arg1;
            if (grid != null){
                grid.setPanConstrain(_panConstrain);
            };
        }
        public function set viewY(_arg1:Number):void{
            if (grid){
                _viewY = _arg1;
                grid.y = _viewY;
                invalidate(InvalidationType.STATE);
            } else {
                tmpY = _arg1;
            };
        }
        protected function drawScrollRect():void{
            contentScrollRect = content.scrollRect;
            contentScrollRect.width = width;
            contentScrollRect.height = height;
            content.scrollRect = contentScrollRect;
        }
        public function get messageScreenVisibility():Boolean{
            return (_messageScreenVisibility);
        }
        public function setExternalZoomingFlag(_arg1:Boolean):void{
            externalZooming = _arg1;
        }
        public function getZoomDecimal():Number{
            return ((currentTierScale * (getTierWidth(grid.getCurrentTier()) / imageWidth)));
        }
        public function changeEaseInOut(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number):Number{
            _arg1 = (_arg1 / (_arg4 / 2));
            if (_arg1 < 1){
                return ((((((((_arg3 / 2) * _arg1) * _arg1) * _arg1) * _arg1) * _arg1) + _arg2));
            };
            _arg1 = (_arg1 - 2);
            return ((((_arg3 / 2) * (((((_arg1 * _arg1) * _arg1) * _arg1) * _arg1) + 2)) + _arg2));
        }
        public function set keyboardEnabled(_arg1:Boolean):void{
            _keyboardEnabled = _arg1;
            initializeStageKeyboardListeners();
        }
        public function get scaleDownThreshold():Number{
            return (_tierScaleDownThreshold);
        }
        public function set scaleUpThreshold(_arg1:Number):void{
            _tierScaleUpThreshold = _arg1;
        }
        public function panLeft():void{
            toolbarHorizontalFlag = 1;
        }
        override public function get mouseEnabled():Boolean{
            return (super.mouseEnabled);
        }
        public function panDown():void{
            toolbarVerticalFlag = -1;
        }
        public function getTooltipBackground():DisplayObject{
            return (getDisplayObjectInstance(getStyleValue("tooltipBackground")));
        }
        public function get initialized():Boolean{
            return (_initialized);
        }
        public function set clickZoom(_arg1:Boolean):void{
            _clickZoom = _arg1;
        }
        protected function selectTier():int{
            var _local1:int = numTiers;
            var _local2:Number = (1 * _tierScaleUpThreshold);
            var _local3:Number = convertCurrentTierScaleToZoom(currentTierScale, grid.getCurrentTier());
            while ((_local2 / 2) >= _local3) {
                _local1--;
                _local2 = (_local2 / 2);
            };
            if (_local1 > 0){
                _local1--;
            };
            if (_local1 < 0){
                _local1 = 0;
            };
            currentTierScale = convertZoomToCurrentTierScale(_local3, _local1);
            scaleCalc = currentTierScale;
            return (_local1);
        }
        public function getMinimumZoomDecimal():Number{
            return (convertZoomPercentToDecimal(_minZoom));
        }
        protected function stageKeyDownHandler(_arg1:KeyboardEvent):void{
            switch (_arg1.charCode){
                case 97:
                    toolbarZoomFlag = 1;
                    targetZoomDecimal = 0;
                    break;
                case 122:
                    toolbarZoomFlag = -1;
                    targetZoomDecimal = 0;
                    break;
            };
            switch (_arg1.keyCode){
                case Keyboard.SPACE:
                    spaceZooming = true;
                    break;
                case Keyboard.SHIFT:
                    toolbarZoomFlag = 1;
                    targetZoomDecimal = 0;
                    break;
                case Keyboard.CONTROL:
                    toolbarZoomFlag = -1;
                    targetZoomDecimal = 0;
                    break;
                case Keyboard.LEFT:
                    toolbarHorizontalFlag = 1;
                    break;
                case Keyboard.RIGHT:
                    toolbarHorizontalFlag = -1;
                    break;
                case Keyboard.UP:
                    toolbarVerticalFlag = 1;
                    break;
                case Keyboard.DOWN:
                    toolbarVerticalFlag = -1;
                    break;
            };
            if (((((!((toolbarZoomFlag == 0))) || (!((toolbarHorizontalFlag == 0))))) || (!((toolbarVerticalFlag == 0))))){
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewerKeyDown"));
                };
                dispatchEvent(new Event("prepareForUserInteraction"));
            };
        }
        public function convertImageSpanToPixelCoord(_arg1:Number, _arg2:ZoomifyViewer, _arg3:String):Number{
            if (_arg3 == "width"){
                return (((_arg1 + 0.5) * _arg2.imageWidth));
            };
            return (((_arg1 + 0.5) * _arg2.imageHeight));
        }
        protected function clearImage(){
            grid.clearTiles();
            grid = null;
            content.removeChildAt(0);
            currentTier = 0;
        }
        protected function mouseUpHandler(_arg1:MouseEvent):void{
            var _local2:Number;
            if (_eventsEnabled){
                dispatchEvent(new Event("viewerMouseUp"));
            };
            if (((!(dragged)) && (!(ignoreMouseUp)))){
                if (((!(_clickZoom)) || (((((_arg1.altKey) && ((getZoomDecimal() == minZoomDecimal)))) || (((!(_arg1.altKey)) && ((getZoomDecimal() == maxZoomDecimal)))))))){
                    targetPanX = ((width / 2) - mouseX);
                    targetPanY = ((height / 2) - mouseY);
                    dispatchEvent(new Event("viewPanning"));
                    if (_eventsEnabled){
                        dispatchEvent(new Event("viewPanning"));
                    };
                    return;
                };
                _local2 = ((_arg1.altKey) ? (1 << (grid.getCurrentTier() - 1)) : (1 << Math.min((grid.getCurrentTier() + 1), (numTiers - 1))));
                zoomPoint = grid.getMousePosition();
                targetZoomDecimal = (_local2 / (1 << grid.getCurrentTier()));
            };
            ignoreMouseUp = true;
        }
        protected function stageKeyUpHandler(_arg1:KeyboardEvent):void{
            switch (_arg1.charCode){
                case 97:
                    if (toolbarZoomFlag == 1){
                        toolbarZoomFlag = 0;
                        invalidate(InvalidationType.STATE);
                    };
                    break;
                case 122:
                    if (toolbarZoomFlag == -1){
                        toolbarZoomFlag = 0;
                        invalidate(InvalidationType.STATE);
                    };
                    break;
            };
            switch (_arg1.keyCode){
                case Keyboard.SHIFT:
                    if (toolbarZoomFlag == 1){
                        toolbarZoomFlag = 0;
                        invalidate(InvalidationType.STATE);
                    };
                case Keyboard.CONTROL:
                    if (toolbarZoomFlag == -1){
                        toolbarZoomFlag = 0;
                        invalidate(InvalidationType.STATE);
                    };
                    break;
                case Keyboard.SPACE:
                    spaceZooming = false;
                    break;
                case Keyboard.LEFT:
                    toolbarHorizontalFlag = 0;
                    break;
                case Keyboard.RIGHT:
                    toolbarHorizontalFlag = 0;
                    break;
                case Keyboard.UP:
                    toolbarVerticalFlag = 0;
                    break;
                case Keyboard.DOWN:
                    toolbarVerticalFlag = 0;
                    break;
                case Keyboard.ESCAPE:
                    dispatchEvent(new Event("prepareForUserInteraction"));
                    setInitialView();
                    break;
            };
            if ((((((((toolbarZoomFlag == 0)) && ((toolbarHorizontalFlag == 0)))) && ((toolbarVerticalFlag == 0)))) || ((_arg1.keyCode == Keyboard.ESCAPE)))){
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewerKeyUp"));
                };
            };
        }
        public function get splashScreenVisibility():Boolean{
            return (_splashScreenVisibility);
        }
        protected function loadImageProperties():void{
            if ((((_imagePath == null)) || ((_imagePath == "")))){
                return;
            };
            var _local1:URLLoader = new URLLoader();
            _local1.addEventListener(Event.COMPLETE, loadImagePropertiesCompleteHandler);
            _local1.addEventListener(IOErrorEvent.IO_ERROR, loadImagePropertiesIOErrorHandler);
            _local1.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadImagePropertiesIOErrorHandler);
            tileCache.setPath(_imagePath);
            _local1.load(new URLRequest(((_imagePath + "/") + "ImageProperties.xml")));
        }
        public function set initialY(_arg1:String):void{
            _initialY = ((isNaN(parseFloat(_arg1))) ? 0 : parseFloat(_arg1));
            if (grid){
                if (_arg1 == "center"){
                    _initialY = (imageHeight / 2);
                };
            } else {
                tmpYParam = _arg1;
            };
        }
        public function getViewXImageSpan():Number{
            if (grid){
                return (grid.xImageSpan);
            };
            return (0);
        }
        public function get imageWidth():Number{
            return (_imageWidth);
        }
        protected function configScrollRect():void{
            contentScrollRect = new Rectangle(0, 0, 100, 100);
            content = new MovieClip();
            content.visible = false;
            content.scrollRect = contentScrollRect;
            addChild(content);
        }
        public function set initialX(_arg1:String):void{
            _initialX = ((isNaN(parseFloat(_arg1))) ? 0 : parseFloat(_arg1));
            if (grid){
                if (_arg1 == "center"){
                    _initialX = (imageWidth / 2);
                };
            } else {
                tmpXParam = _arg1;
            };
        }
        public function get initialZoom():Number{
            return (_initialZoom);
        }
        override public function get enabled():Boolean{
            return (super.enabled);
        }
        public function setViewXImageSpan(_arg1:Number):void{
            if (grid){
                grid.xImageSpan = _arg1;
                invalidate(InvalidationType.STATE);
            } else {
                tmpX = _arg1;
            };
        }
        override protected function draw():void{
            if (isInvalid(InvalidationType.SIZE)){
                drawLayout();
            };
            if (((isInvalid(InvalidationType.STATE)) && (!((grid == null))))){
                updateTier();
                dispatchEvent(new Event("gridChanged"));
                dispatchEvent(new Event("areaChanged"));
            };
            super.draw();
        }
        public function get minZoom():Number{
            return (_minZoom);
        }
        protected function cacheView():void{
            var _local1:BitmapData = swapBuffer();
            _local1.lock();
            _local1.fillRect(new Rectangle(0, 0, _local1.width, _local1.height), 0xFFFFFF);
            _local1.draw(this, null, null, null, null, true);
            _local1.unlock();
            grid.setPriorBitmap(_local1);
            var _local2:Point = grid.getOffset();
            grid.setOffset(_local2, tierWidthsArray[currentTier]);
            grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
        }
        override protected function configUI():void{
            super.configUI();
            configLogoSplashScreen();
            configScrollRect();
            configTextMessageScreen();
        }
        public function get maxZoom():Number{
            return (_maxZoom);
        }
        private function zoomToViewTimerHandler(_arg1:TimerEvent):void{
            var _local2:Number = (_arg1.target.currentCount * _arg1.target.delay);
            var _local3:Number = (_arg1.target.repeatCount * _arg1.target.delay);
            if (changeCurrentTierScaleSpan != 0){
                if (_eventsEnabled){
                    viewZooming = true;
                };
                if (changeCurrentTierScaleSpan > 0){
                    dispatchEvent(new Event("viewZoomingInInternal"));
                    if (_eventsEnabled){
                        dispatchEvent(new Event("viewZoomingIn"));
                    };
                } else {
                    if (changeCurrentTierScaleSpan < 0){
                        dispatchEvent(new Event("viewZoomingOutInternal"));
                        if (_eventsEnabled){
                            dispatchEvent(new Event("viewZoomingOut"));
                        };
                    };
                };
                currentTierScale = (grid.scaleX = (grid.scaleY = changeEaseInOut(_local2, changeCurrentTierScaleStart, changeCurrentTierScaleSpan, _local3)));
                dispatchEvent(new Event("gridChanged"));
            };
            grid.x = changeEaseInOut(_local2, changeXStart, changeXSpan, _local3);
            grid.y = changeEaseInOut(_local2, changeYStart, changeYSpan, _local3);
            grid.constrainPan();
            dispatchEvent(new Event("areaChanged"));
            if (_arg1.target.currentCount == _arg1.target.repeatCount){
                _arg1.target.stop();
                _arg1.target.reset();
                _arg1.target.removeEventListener("timer", zoomToViewTimerHandler);
                targetPanX = 0;
                targetPanY = 0;
                targetZoomDecimal = 0;
                invalidate(InvalidationType.STATE);
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewPanComplete"));
                };
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewZoomComplete"));
                };
            };
        }
        public function calcZoomDecimalToFitDisplay():Number{
            return ((((imageWidth / imageHeight))>(width / height)) ? (width / imageWidth) : (height / imageHeight));
        }
        protected function stageMouseWheelHandler(_arg1:MouseEvent):void{
            if (_eventsEnabled){
                dispatchEvent(new Event("stageMouseWheel"));
            };
            var _local2:Number = (_arg1.delta * 3.5);
            var _local3:Number = (1 / (1000 / (_local2 * _local2)));
            var _local4:Number = ((_arg1.delta)>1) ? (1 + _local3) : (1 - _local3);
            var _local5:Number = (getZoomDecimal() * _local4);
            if (_local5 < minZoomDecimal){
                _local5 = minZoomDecimal;
            };
            if (_local5 > maxZoomDecimal){
                _local5 = maxZoomDecimal;
            };
            setZoomDecimal(_local5, true);
            if (updateTierTimer.running){
                updateTierTimer.reset();
            } else {
                dispatchEvent(new Event("prepareForUserInteraction"));
            };
            updateTierTimer.start();
        }
        public function setExternalPanningFlag(_arg1:Boolean):void{
            externalPanning = _arg1;
        }
        public function get panConstrain():Boolean{
            return (_panConstrain);
        }
        protected function calcZoomConstraints():void{
            minZoomDecimal = getMinimumZoomDecimal();
            maxZoomDecimal = getMaximumZoomDecimal();
        }
        public function get keyboardEnabled():Boolean{
            return (_keyboardEnabled);
        }
        public function zoomToView(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number):void{
            if (grid){
                zoomToViewStop();
                if (_arg1 < 0){
                    _arg1 = 0;
                };
                if (_arg1 > imageWidth){
                    _arg1 = imageWidth;
                };
                changeXStart = grid.x;
                changeXSpan = (_arg1 - grid.x);
                if (_arg2 < 0){
                    _arg2 = 0;
                };
                if (_arg2 > imageHeight){
                    _arg2 = imageHeight;
                };
                changeYStart = grid.y;
                changeYSpan = (_arg2 - grid.y);
                if (_arg3 == -1){
                    _arg3 = (calcZoomDecimalToFitDisplay() * 100);
                };
                if ((_arg3 / 100) < minZoomDecimal){
                    _arg3 = (minZoomDecimal * 100);
                };
                if ((_arg3 / 100) > maxZoomDecimal){
                    _arg3 = (maxZoomDecimal * 100);
                };
                changeCurrentTierScaleStart = currentTierScale;
                changeCurrentTierScaleSpan = ((convertZoomToCurrentTierScale(_arg3, grid.getCurrentTier()) / 100) - currentTierScale);
                zoomToViewTimer = new Timer(_arg5, (_arg4 / _arg5));
                zoomToViewTimer.addEventListener("timer", zoomToViewTimerHandler, false, 0, true);
                zoomToViewTimer.start();
            };
        }
        protected function stageMouseMoveHandler(_arg1:MouseEvent):void{
            var _local2:Number;
            var _local3:Number;
            if (_eventsEnabled){
                dispatchEvent(new Event("stageMouseMove"));
            };
            if (!grid){
                return;
            };
            if (mouseIsDown){
                if (spaceZooming){
                    _local2 = currentTierScale;
                    modifyCurrentTierScaleRelatively(((lastMouse.y - mouseY) / 100), zoomPoint);
                    _local3 = (currentTierScale / _local2);
                    hit.x = (hit.x / _local3);
                    hit.y = (hit.y * _local3);
                } else {
                    grid.offsetCanvas((mouseX - hit.x), (mouseY - hit.y));
                    hit = new Point(mouseX, mouseY);
                };
                viewPanning = true;
                dispatchEvent(new Event("viewPanning"));
                dispatchEvent(new Event("areaChanged"));
                dragged = true;
            };
            lastMouse.x = mouseX;
            lastMouse.y = mouseY;
        }
        public function get clickZoom():Boolean{
            return (_clickZoom);
        }
        protected function positionSplashScreen():void{
            logoSplashScreen.x = ((width - logoSplashScreen.width) / 2);
            logoSplashScreen.y = ((height - logoSplashScreen.height) / 2);
        }
        public function panRight():void{
            toolbarHorizontalFlag = -1;
        }
        public function set scaleDownThreshold(_arg1:Number):void{
            _tierScaleDownThreshold = _arg1;
        }
        public function convertPixelCoordToImageSpan(_arg1:Number, _arg2:ZoomifyViewer, _arg3:String):Number{
            if (_arg3 == "width"){
                return ((_arg1 * ((((_arg2.imageWidth / 2) + 1) / _arg2.imageWidth) - 0.5)));
            };
            return ((_arg1 * ((((_arg2.imageHeight / 2) + 1) / _arg2.imageHeight) - 0.5)));
        }
        protected function loadImagePropertiesCompleteHandler(_arg1:Event):void{
            if (_eventsEnabled){
                dispatchEvent(new Event("imagePropertiesLoadingComplete"));
            };
            var _local2:URLLoader = (_arg1.target as URLLoader);
            var _local3:XML = new XML(_local2.data);
            _imageWidth = uint(_local3.@WIDTH);
            _imageHeight = uint(_local3.@HEIGHT);
            _imageTileSize = int(_local3.@TILESIZE);
            calculateTierValues();
            cachedView1 = new BitmapData(Math.ceil(width), Math.ceil(height), true, 0);
            cachedView2 = new BitmapData(Math.ceil(width), Math.ceil(height), true, 0);
            currentCacheView = cachedView1;
            tileCache.calculatePathLimits(imageTileSize, imageWidth, imageHeight);
            var _local4:Sprite = new Sprite();
            content.addChild(_local4);
            grid = new ZoomGrid(_local4, tileCache);
            grid.active(false);
            grid.viewer = this;
            grid.setMaxTier((numTiers - 1));
            grid.addEventListener("viewerFirstTileDrawInternal", firstTileDrawViewerInternalHandler, false, 0, true);
            grid.addEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawViewerInternalHandler, false, 0, true);
            grid.configureCanvas(imageTileSize, width, height, imageWidth, imageHeight, 0, _tierScaleDownThreshold, tierWidthsInTilesArray, tierHeightsInTilesArray);
            calcZoomConstraints();
            grid.setFadeInSpeed(_fadeInSpeed);
            grid.setPanConstrain(_panConstrain);
            _initialX = (tmpX = ((isNaN(parseFloat(tmpXParam))) ? (imageWidth / 2) : parseFloat(tmpXParam)));
            _initialY = (tmpY = ((isNaN(parseFloat(tmpYParam))) ? (imageHeight / 2) : parseFloat(tmpYParam)));
            setView(tmpX, tmpY, tmpZoom);
            grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
            grid.active(true);
            invalidate(InvalidationType.SIZE);
            invalidate(InvalidationType.STATE);
        }
        public function get tileCache():TileCache{
            return (_tileCache);
        }
        protected function drawLayout():void{
            drawScrollRect();
            positionSplashScreen();
            positionMessageScreen();
        }
        protected function loadImagePropertiesIOErrorHandler(_arg1:Event):void{
            var _local2:Boolean = ((!((parent == null))) && ((getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent")));
            if (((((_local2) && (!((_imagePath == null))))) && (!((_imagePath == ""))))){
                showMessage((Resources.ALERT_IMAGELIVEPREVIEW + _imagePath));
                return;
            };
            dispatchEvent(new Event("imagePropertiesLoadingFailedInternal"));
            if (_eventsEnabled){
                dispatchEvent(new Event("imagePropertiesLoadingFailed"));
            };
            var _local3:String = _imagePath;
            if (_local3.slice(0, 1) == "/"){
                _local3 = _local3.slice(1, _local3.length);
            };
            showMessage(errFileNotFound.split("%s").join(_local3));
        }
        public function set messageScreenVisibility(_arg1:Boolean):void{
            textMessageScreen.visible = _arg1;
            _messageScreenVisibility = textMessageScreen.visible;
        }
        public function get initialY():String{
            return (_initialY.toString());
        }
        public function zoomToInitialView():void{
            zoomToView(_initialX, _initialY, initialZoom, 250, 10);
        }
        public function getTierHeight(_arg1:uint):Number{
            var _local2:Number = imageHeight;
            var _local3:uint = numTiers;
            while (_local3 > (_arg1 + 1)) {
                _local2 = (_local2 / 2);
                _local3--;
            };
            return (_local2);
        }
        public function get initialX():String{
            return (_initialX.toString());
        }
        override public function setSize(_arg1:Number, _arg2:Number):void{
            var _local3:Number;
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            var _local7:Number;
            var _local8:Point;
            var _local9:Number;
            var _local10:Number;
            var _local11:Point;
            this.enabled = false;
            if (grid){
                _local3 = this.width;
                _local4 = this.height;
            };
            super.setSize(_arg1, _arg2);
            if (grid){
                _local5 = getZoomDecimal();
                _local6 = (_local3 - _arg1);
                _local7 = (_local4 - _arg2);
                _local8 = getImageOffset();
                _local9 = (_local8.x - (_local6 / 2));
                _local10 = (_local8.y - (_local7 / 2));
                _local11 = new Point(_local9, _local10);
                cacheView();
                grid.configureCanvas(imageTileSize, _arg1, _arg2, imageWidth, imageHeight, currentTier, _tierScaleDownThreshold, tierWidthsInTilesArray, tierHeightsInTilesArray);
                setZoomDecimal(_local5);
                setImageOffset(_local11);
                currentTierScale = grid.getCurrentTierScale();
                invalidate(InvalidationType.SIZE);
                invalidate(InvalidationType.STATE);
                drawNow();
                dispatchEvent(new Event("gridChanged"));
                dispatchEvent(new Event("areaChanged"));
            };
            this.enabled = true;
        }
        public function set initialized(_arg1:Boolean):void{
            _initialized = _arg1;
        }
        protected function swapBuffer():BitmapData{
            currentCacheView = ((currentCacheView)==cachedView1) ? cachedView2 : cachedView1;
            return (currentCacheView);
        }
        public function getMaximumZoomDecimal():Number{
            return (convertZoomPercentToDecimal(_maxZoom));
        }
        protected function stageMouseUpHandler(_arg1:MouseEvent):void{
            if (!grid){
                return;
            };
            if (spaceZooming){
                invalidate(InvalidationType.STATE);
            } else {
                if (mouseIsDown){
                    grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], true);
                };
            };
            spaceZooming = false;
            mouseIsDown = false;
        }
        override public function set mouseEnabled(_arg1:Boolean):void{
            super.mouseEnabled = _arg1;
            if (grid){
                grid.enabled = _arg1;
            };
            initializeStageMouseListeners();
        }
        private function calculateTierValues():void{
            tierWidthsArray = [];
            tierHeightsArray = [];
            tierWidthsInTilesArray = [];
            tierHeightsInTilesArray = [];
            var _local1:Number = (Math.max(imageWidth, imageHeight) / Number(imageTileSize));
            var _local2:uint;
            while ((1 << _local2) <= _local1) {
                numTiers = (_local2 + 1);
                if (_local1 > (1 << _local2)){
                    numTiers = (numTiers + 1);
                };
                _local2++;
            };
            var _local3:Number = imageWidth;
            var _local4:Number = imageHeight;
            var _local5:int = (numTiers - 1);
            while (_local5 >= 0) {
                tierWidthsArray[_local5] = _local3;
                tierHeightsArray[_local5] = _local4;
                tierWidthsInTilesArray[_local5] = (((_local3 % imageTileSize)) ? (Math.floor((_local3 / imageTileSize)) + 1) : Math.floor((_local3 / imageTileSize)));
                tierHeightsInTilesArray[_local5] = (((_local4 % imageTileSize)) ? (Math.floor((_local4 / imageTileSize)) + 1) : Math.floor((_local4 / imageTileSize)));
                _local3 = Math.floor((_local3 / 2));
                _local4 = Math.floor((_local4 / 2));
                _local5--;
            };
        }
        public function zoomToFitDisplay():void{
            setZoomDecimal(calcZoomDecimalToFitDisplay(), false);
            invalidate(InvalidationType.STATE);
        }
        public function get zoomGrid():ZoomGrid{
            return (grid);
        }
        protected function messageScreenClickHandler(_arg1:MouseEvent):void{
            navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
        }
        protected function tileProgressHandler(_arg1:TileProgressEvent):void{
            dispatchEvent(_arg1.clone());
        }
        public function set eventsEnabled(_arg1:Boolean):void{
            _eventsEnabled = _arg1;
            if (grid != null){
                grid.setEventsEnabled(_eventsEnabled);
            };
        }
        protected function convertZoomPercentToDecimal(_arg1:Number):Number{
            if (_arg1 == -1){
                return (calcZoomDecimalToFitDisplay());
            };
            return ((_arg1 / 100));
        }
        public function clearCachedViews():void{
            tileCache.purge(0);
            if (cachedView1){
                cachedView1.dispose();
            };
            if (cachedView1){
                cachedView2.dispose();
            };
            if (currentCacheView){
                currentCacheView.dispose();
            };
        }
        public function get eventsEnabled():Boolean{
            return (_eventsEnabled);
        }
        protected function modifyCurrentTierScale(_arg1:Number, _arg2:Point, _arg3:Boolean=true):void{
            currentTierScale = (currentTierScale + _arg1);
            var _local4:Point = new Point(_arg2.x, _arg2.y);
            _local4 = localToGlobal(_local4);
            grid.scaleCurrentTier(currentTierScale, _local4.x, _local4.y);
            if (_eventsEnabled){
                viewZooming = true;
            };
            if (_arg1 > 0){
                dispatchEvent(new Event("viewZoomingInInternal"));
                if (_eventsEnabled){
                    dispatchEvent(new Event("viewZoomingIn"));
                };
            } else {
                if (_arg1 < 0){
                    dispatchEvent(new Event("viewZoomingOutInternal"));
                    if (_eventsEnabled){
                        dispatchEvent(new Event("viewZoomingOut"));
                    };
                };
            };
            if (_arg3){
                dispatchEvent(new Event("gridChanged"));
            } else {
                dispatchEvent(new Event("gridChangedBySlider"));
            };
            dispatchEvent(new Event("areaChanged"));
        }

    }
}//package zoomify 
