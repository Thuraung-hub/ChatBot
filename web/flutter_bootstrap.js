{{flutter_js}}
{{flutter_build_config}}

// Intentionally disable Flutter service worker registration to avoid stale-cache white screens.
_flutter.buildConfig.useLocalCanvasKit = true;
_flutter.loader.load({
	config: {
		canvasKitBaseUrl: "canvaskit/"
	}
});