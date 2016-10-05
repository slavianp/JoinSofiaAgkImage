package {
    import flash.display.*;
    import zoomify.*;
    import flash.events.*;
    import zoomify.utils.*;

    public class ZoomifyDesignViewer extends MovieClip {

        private var params:Parameters;
        private var paramsEnable:Boolean = false;
        public var imagePathParam:String;
        public var errFileNotFound;
        public var xmlPathParam:String;
        public var viewer:ZoomifyViewer;
        public var navigator:ZoomifyNavigator;
        public var toolbar:ZoomifyToolbar;

        public function ZoomifyDesignViewer():void{
            errFileNotFound = (Resources.ERROR_LOADINGFILE + "%s");
            super();
            addFrameScript(0, frame1);
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.BEST;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, onStageResizeHandler);
            paramsEnable = (Resources.DEFAULT_ENABLEPARAMETERS == "1");
            params = new Parameters();
            params.initialize(LoaderInfo(stage.loaderInfo).parameters);
            if (paramsEnable){
                loadXMLParameters();
            } else {
                initialize();
            };
        }
        protected function loadXMLParametersIOErrorHandler(_arg1:IOErrorEvent):void{
            dispatchEvent(new Event("XMLParametersLoadingFailed"));
            var _local2:String = xmlPathParam;
            if (xmlPathParam.slice(-1, xmlPathParam.length) == "/"){
                _local2 = xmlPathParam.slice(0, (xmlPathParam.length - 1));
            };
            imagePathParam = _local2;
            initialize();
        }
        protected function loadXMLParameters():void{
            xmlPathParam = params.getParameterAsString("zoomifyXMLPath", "");
            if (((xmlPathParam) && (!((xmlPathParam == ""))))){
                params.addEventListener(Event.COMPLETE, loadXMLParametersCompleteHandler);
                params.addEventListener(IOErrorEvent.IO_ERROR, loadXMLParametersIOErrorHandler);
                params.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadXMLParametersIOErrorHandler);
                params.load(xmlPathParam);
            } else {
                initialize();
            };
        }
        function frame1(){
        }
        protected function imagePropertiesLoadingFailureInternalHandler(_arg1:Event):void{
            if (toolbar != null){
                toolbar.visible = false;
            };
            if (navigator != null){
                navigator.alpha = 0;
            };
        }
        protected function loadXMLParametersCompleteHandler(_arg1:Event):void{
            dispatchEvent(new Event("XMLParametersLoadingComplete"));
            initialize();
        }
        private function onStageResizeHandler(_arg1:Event=null):void{
            var _local2:Number = stage.stageWidth;
            var _local3:Number = stage.stageHeight;
            viewer.move(0, 0);
            if (toolbar != null){
                viewer.setSize(_local2, (_local3 - 20));
                toolbar.move(0, (_local3 - 20));
                toolbar.setSize(_local2, 20);
            } else {
                viewer.setSize(_local2, _local3);
            };
        }
        protected function initialize():void{
            viewer = new ZoomifyViewer();
            if ((((imagePathParam == null)) || ((imagePathParam == "")))){
                imagePathParam = params.getParameterAsString("zoomifyImagePath", Resources.DEFAULT_IMAGEPATH);
            };
            viewer.imagePath = imagePathParam;
            var _local1:String = Resources.DEFAULT_INITIALX;
            var _local2:String = Resources.DEFAULT_INITIALY;
            var _local3:Number = ((isNaN(parseFloat(Resources.DEFAULT_INITIALZOOM))) ? -1 : parseFloat(Resources.DEFAULT_INITIALZOOM));
            var _local4:Number = ((isNaN(parseFloat(Resources.DEFAULT_MINZOOM))) ? -1 : parseFloat(Resources.DEFAULT_MINZOOM));
            var _local5:Number = ((isNaN(parseFloat(Resources.DEFAULT_MAXZOOM))) ? 100 : parseFloat(Resources.DEFAULT_MAXZOOM));
            var _local6:String = Resources.DEFAULT_SPLASHSCREEN;
            var _local7:String = Resources.DEFAULT_CLICKZOOM;
            var _local8:Number = ((isNaN(parseFloat(Resources.DEFAULT_ZOOMSPEED))) ? 5 : parseFloat(Resources.DEFAULT_ZOOMSPEED));
            var _local9:Number = ((isNaN(parseFloat(Resources.DEFAULT_FADEINSPEED))) ? 300 : parseFloat(Resources.DEFAULT_FADEINSPEED));
            var _local10:String = Resources.DEFAULT_PANCONSTRAIN;
            var _local11:String = Resources.DEFAULT_TOOLBAR;
            var _local12:Number = ((isNaN(parseFloat(Resources.DEFAULT_TOOLBARSPACING))) ? 7 : parseFloat(Resources.DEFAULT_TOOLBARSPACING));
            var _local13:String = Resources.DEFAULT_TOOLBARSKINXMLPATH;
            var _local14:String = Resources.DEFAULT_TOOLBARTOOLTIPS;
            var _local15:String = Resources.DEFAULT_TOOLBARSLIDER;
            var _local16:String = Resources.DEFAULT_TOOLBARLOGO;
            var _local17:String = Resources.DEFAULT_NAVIGATORVISIBLE;
            _local17 = params.getParameterAsString("zoomifyNavigatorVisible", _local17);
            var _local18:String = Resources.DEFAULT_NAVIGATORFIT;
            var _local19:Number = ((isNaN(parseFloat(Resources.DEFAULT_NAVIGATORWIDTH))) ? 130 : parseFloat(Resources.DEFAULT_NAVIGATORWIDTH));
            var _local20:Number = ((isNaN(parseFloat(Resources.DEFAULT_NAVIGATORHEIGHT))) ? 130 : parseFloat(Resources.DEFAULT_NAVIGATORHEIGHT));
            var _local21:Number = ((isNaN(parseFloat(Resources.DEFAULT_NAVIGATORX))) ? 0 : parseFloat(Resources.DEFAULT_NAVIGATORX));
            var _local22:Number = ((isNaN(parseFloat(Resources.DEFAULT_NAVIGATORY))) ? 0 : parseFloat(Resources.DEFAULT_NAVIGATORY));
            var _local23:String = Resources.DEFAULT_EVENTS;
            if (paramsEnable){
                _local1 = params.getParameterAsString("zoomifyInitialX", _local1);
                _local2 = params.getParameterAsString("zoomifyInitialY", _local2);
                _local3 = params.getParameterAsNumber("zoomifyInitialZoom", _local3);
                _local4 = params.getParameterAsNumber("zoomifyMinZoom", _local4);
                _local5 = params.getParameterAsNumber("zoomifyMaxZoom", _local5);
                _local6 = params.getParameterAsString("zoomifySplashScreen", _local6);
                _local7 = params.getParameterAsString("zoomifyClickZoom", _local7);
                _local8 = params.getParameterAsNumber("zoomifyZoomSpeed", _local8);
                _local9 = params.getParameterAsNumber("zoomifyFadeInSpeed", _local9);
                _local10 = params.getParameterAsString("zoomifyPanConstrain", _local10);
                _local11 = params.getParameterAsString("zoomifyToolbarVisible", _local11);
                _local12 = params.getParameterAsNumber("zoomifyToolbarSpacing", _local12);
                _local13 = params.getParameterAsString("zoomifyToolbarSkinXMLPath", _local13);
                _local14 = params.getParameterAsString("zoomifyToolbarTooltips", _local14);
                _local15 = params.getParameterAsString("zoomifySliderVisible", _local15);
                _local16 = params.getParameterAsString("zoomifyToolbarLogo", _local16);
                _local19 = params.getParameterAsNumber("zoomifyNavigatorWidth", _local19);
                _local20 = params.getParameterAsNumber("zoomifyNavigatorHeight", _local20);
                _local18 = params.getParameterAsString("zoomifyNavigatorFit", _local18);
                _local21 = params.getParameterAsNumber("zoomifyNavigatorX", _local21);
                _local22 = params.getParameterAsNumber("zoomifyNavigatorY", _local22);
                _local23 = params.getParameterAsString("zoomifyEvents", _local23);
            };
            viewer.initialX = _local1;
            viewer.initialY = _local2;
            viewer.minZoom = _local4;
            viewer.maxZoom = _local5;
            viewer.initialZoom = _local3;
            viewer.splashScreenVisibility = ((((!((_local6 == "0"))) && (!((_local6 == "hide"))))) && (!((_local6 == "false"))));
            viewer.clickZoom = ((!((_local7 == "0"))) && (!((_local7 == "false"))));
            viewer.zoomSpeed = _local8;
            viewer.fadeInSpeed = _local9;
            viewer.panConstrain = ((!((_local10 == "0"))) && (!((_local10 == "false"))));
            viewer.eventsEnabled = ((!((_local23 == "0"))) && (!((_local23 == "false"))));
            addChildAt(viewer, 0);
            viewer.addEventListener("imagePropertiesLoadingFailedInternal", imagePropertiesLoadingFailureInternalHandler, false, 0, true);
            if (((((!((_local11 == "0"))) && (!((_local11 == "hide"))))) && (!((_local11 == "false"))))){
                toolbar = new ZoomifyToolbar();
                toolbar.viewer = viewer;
                toolbar.showSlider = ((((!((_local15 == "0"))) && (!((_local15 == "hide"))))) && (!((_local15 == "false"))));
                toolbar.showZoomifyButton = ((((!((_local16 == "0"))) && (!((_local16 == "hide"))))) && (!((_local16 == "false"))));
                toolbar.showToolbarTooltips = ((((!((_local14 == "0"))) && (!((_local14 == "hide"))))) && (!((_local14 == "false"))));
                toolbar.toolbarSpacing = _local12;
                toolbar.toolbarSkinXMLPath = _local13;
                addChild(toolbar);
            };
            if (((((!((_local17 == "0"))) && (!((_local17 == "hide"))))) && (!((_local17 == "false"))))){
                navigator = new ZoomifyNavigator();
                navigator.move(_local21, _local22);
                navigator.setSize(_local19, _local20);
                navigator.sizeToFit = _local18;
                navigator.viewer = viewer;
                addChild(navigator);
            };
            onStageResizeHandler();
        }

    }
}//package 
