package zoomify {
    import flash.display.*;
    import fl.core.*;
    import flash.events.*;
    import flash.geom.*;
    import zoomify.viewer.*;
    import fl.managers.*;
    import flash.utils.*;
    import zoomify.utils.*;

    public class ZoomifyNavigator extends UIComponent implements IFocusManagerComponent {

        private static var defaultStyles:Object = {
            background:"ZoomifyNavigator_background",
            thumbRect:"ZoomifyNavigator_thumbRect"
        };

        protected var navInitTimer:Timer;
        protected var bg:Bitmap;
        protected var hit:Point;
        protected var _sizeToFit:String;
        protected var rect:Sprite;
        protected var contentScrollRect:Rectangle;
        protected var background:DisplayObject;
        protected var bitmap:Sprite;
        protected var _tileCache:TileCache;
        protected var _viewer:IZoomifyViewer;
        protected var content:Sprite;

        public function ZoomifyNavigator():void{
            navInitTimer = new Timer(0, 0);
            super();
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }

        public function set sizeToFit(_arg1:String):void{
            switch (_arg1){
                case "-0":
                    _sizeToFit = "-0";
                    break;
                case "-1":
                    _sizeToFit = "-1";
                    break;
                case "sizeToFitViewer":
                    _sizeToFit = "-0";
                    break;
                case "sizeToFitImage":
                    _sizeToFit = "-1";
                    break;
                default:
                    _sizeToFit = "";
            };
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
        protected function renderNavigatorThumbnail():void{
            var _local1:Number = (width - 2);
            var _local2:Number = (height - 2);
            var _local3:Number = (_local1 / bitmap.width);
            var _local4:Number = (_local2 / bitmap.height);
            if (_sizeToFit == "-1"){
                bitmap.width = (width - 2);
                bitmap.height = (height - 2);
                bitmap.x = 0;
                bitmap.y = 0;
            } else {
                if (_local3 == _local4){
                    bitmap.scaleX = (bitmap.scaleY = _local3);
                } else {
                    if (_local3 < _local4){
                        bitmap.scaleX = (bitmap.scaleY = _local3);
                        bitmap.y = ((_local2 - (bitmap.height * (_local1 / bitmap.width))) / 2);
                    } else {
                        if (_local3 > _local4){
                            bitmap.scaleX = (bitmap.scaleY = _local4);
                            bitmap.x = ((_local1 - (bitmap.width * (_local2 / bitmap.height))) / 2);
                        };
                    };
                };
            };
        }
        public function get viewerName():String{
            return (_viewer.name);
        }
        protected function viewerImageChangedInternalHandler(_arg1:Event):void{
            var _local2:Bitmap = _viewer.tileCache.convertTileDataToBitmap(0, 0, 0);
            if (_local2 != null){
                bg = _local2;
                bitmap.x = (bitmap.y = 0);
                bitmap.scaleX = (bitmap.scaleY = 1);
                bitmap.graphics.clear();
                bitmap.graphics.beginBitmapFill(_local2.bitmapData, null, false, true);
                bitmap.graphics.drawRect(0, 0, _local2.bitmapData.width, _local2.bitmapData.height);
                bitmap.graphics.endFill();
                if (_sizeToFit == "-1"){
                    sizeNavigatorToFitImage();
                } else {
                    if (_sizeToFit == "-0"){
                        sizeNavigatorToFitViewer();
                    };
                };
                renderNavigatorThumbnail();
            };
        }
        protected function drawLayout():void{
            background.width = (width - 1);
            background.height = (height - 1);
            contentScrollRect = content.scrollRect;
            contentScrollRect.width = (width - 2);
            contentScrollRect.height = (height - 2);
            content.scrollRect = contentScrollRect;
            visible = true;
        }
        protected function adjustPosition():void{
            _viewer.setExternalPanningFlag(true);
            rect.x = Math.min(Math.max(-1, (mouseX - hit.x)), (content.width - rect.width));
            rect.y = Math.min(Math.max(-1, (mouseY - hit.y)), (content.height - rect.height));
            var _local1:Number = _viewer.getZoomDecimal();
            var _local2:Point = new Point();
            _local2.x = -((((((rect.x + 1) - bitmap.x) * _viewer.imageWidth) * _local1) / bitmap.width));
            _local2.y = -((((((rect.y + 1) - bitmap.y) * _viewer.imageHeight) * _local1) / bitmap.height));
            _viewer.setImageOffset(_local2);
        }
        public function get viewer():IZoomifyViewer{
            return (_viewer);
        }
        public function sizeNavigatorToFitImage():void{
            height = width;
            var _local1:Number = (bitmap.width / bitmap.height);
            if (_local1 > 1){
                height = (height / _local1);
            } else {
                if (_local1 < 1){
                    width = (width * _local1);
                };
            };
        }
        public function sizeNavigatorToFitViewer():void{
            height = width;
            var _local1:Number = (_viewer.width / _viewer.height);
            if (_local1 > 1){
                height = (height / _local1);
            } else {
                if (_local1 < 1){
                    width = (width * _local1);
                };
            };
        }
        protected function mouseDownHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("navigatorMouseDown"));
            };
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
            if (rect.hitTestPoint(stage.mouseX, stage.mouseY)){
                hit = new Point((mouseX - rect.x), (mouseY - rect.y));
            } else {
                hit = new Point((rect.width / 2), (rect.height / 2));
                adjustPosition();
            };
        }
        override protected function configUI():void{
            super.configUI();
            background = getDisplayObjectInstance(getStyleValue("background"));
            addChild(background);
            contentScrollRect = new Rectangle(0, 0, 100, 100);
            content = new Sprite();
            content.visible = false;
            content.x = 1;
            content.y = 1;
            content.scrollRect = contentScrollRect;
            addChild(content);
            bitmap = new Sprite();
            content.addChild(bitmap);
            var _local1:DisplayObject = getDisplayObjectInstance(getStyleValue("thumbRect"));
            rect = new Sprite();
            rect.visible = false;
            rect.buttonMode = true;
            rect.useHandCursor = true;
            rect.addChild(_local1);
            content.addChild(rect);
            visible = false;
        }
        public function set viewerName(_arg1:String):void{
            var value:* = _arg1;
            try {
                viewer = (parent.getChildByName(value) as IZoomifyViewer);
            } catch(error:Error) {
                throw (new Error(Resources.ERROR_SETTINGVIEWER));
            };
        }
        protected function viewerInitializationCompleteInternalHandler(_arg1:Event=null):void{
            rect.visible = true;
            content.visible = true;
            var _local2:Bitmap = _viewer.tileCache.convertTileDataToBitmap(0, 0, 0);
            if (_local2 != null){
                bg = _local2;
                bitmap.x = (bitmap.y = 0);
                bitmap.scaleX = (bitmap.scaleY = 1);
                bitmap.graphics.clear();
                bitmap.graphics.beginBitmapFill(_local2.bitmapData, null, false, true);
                bitmap.graphics.drawRect(0, 0, _local2.bitmapData.width, _local2.bitmapData.height);
                bitmap.graphics.endFill();
                if (_sizeToFit == "-1"){
                    sizeNavigatorToFitImage();
                } else {
                    if (_sizeToFit == "-0"){
                        sizeNavigatorToFitViewer();
                    };
                };
                renderNavigatorThumbnail();
            } else {
                navInitTimer = new Timer(500, 1);
                navInitTimer.addEventListener("timer", navInitTimerHandler, false, 0, true);
                navInitTimer.start();
            };
        }
        public function get sizeToFit():String{
            return (_sizeToFit);
        }
        protected function mouseMoveHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("navigatorMouseMove"));
            };
            adjustPosition();
        }
        protected function mouseUpHandler(_arg1:MouseEvent):void{
            if (_viewer.eventsEnabled){
                dispatchEvent(new Event("navigatorMouseUp"));
            };
            _viewer.setExternalPanningFlag(false);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            _viewer.invalidate(InvalidationType.STATE);
        }
        public function set viewer(_arg1:IZoomifyViewer):void{
            if (_viewer != null){
                _viewer.removeEventListener("viewerInitializationCompleteInternal", viewerInitializationCompleteInternalHandler);
                _viewer.removeEventListener("areaChanged", viewerAreaChangedHandler);
            };
            _viewer = _arg1;
            if (_viewer != null){
                _viewer.addEventListener("viewerInitializationCompleteInternal", viewerInitializationCompleteInternalHandler, false, 0, true);
                _viewer.addEventListener("areaChanged", viewerAreaChangedHandler, false, 0, true);
                _viewer.addEventListener("imageChangedInternal", viewerImageChangedInternalHandler, false, 0, true);
            };
        }
        protected function viewerAreaChangedHandler(_arg1:Event):void{
            var _local2:Number = _viewer.width;
            var _local3:Number = _viewer.height;
            var _local4:Number = _viewer.getZoomDecimal();
            var _local5:Point = _viewer.getImageOffset();
            rect.x = ((((-(_local5.x) * bitmap.width) / (_viewer.imageWidth * _local4)) + bitmap.x) - 1);
            rect.y = ((((-(_local5.y) * bitmap.height) / (_viewer.imageHeight * _local4)) + bitmap.y) - 1);
            rect.width = (((_local2 * bitmap.width) / (_viewer.imageWidth * _local4)) + 1);
            rect.height = (((_local3 * bitmap.height) / (_viewer.imageHeight * _local4)) + 1);
        }
        protected function navInitTimerHandler(_arg1:TimerEvent):void{
            if (navInitTimer.running){
                navInitTimer.stop();
                navInitTimer.removeEventListener("timer", navInitTimerHandler);
            };
            viewerInitializationCompleteInternalHandler();
        }

    }
}//package zoomify 
