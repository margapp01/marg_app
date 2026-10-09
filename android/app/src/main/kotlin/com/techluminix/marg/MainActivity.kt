package `in`.margapp.marg_app

import android.app.Activity
import android.content.Intent
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.Priority
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingServiceResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestLocationService" -> requestLocationService(result)
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Shows Google Play services' in-app "Turn on location" dialog when device
     * location is off. Resolves true once location is on, false if the user
     * declines; errors when the dialog can't be shown (the caller then falls
     * back to the system location settings).
     */
    private fun requestLocationService(result: MethodChannel.Result) {
        if (pendingServiceResult != null) {
            result.error("busy", "A location request is already showing", null)
            return
        }
        val settings = LocationSettingsRequest.Builder()
            .addLocationRequest(LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, LOCATION_INTERVAL_MS).build())
            .setAlwaysShow(true)
            .build()
        LocationServices.getSettingsClient(this).checkLocationSettings(settings)
            .addOnSuccessListener { result.success(true) }
            .addOnFailureListener { error ->
                if (error is ResolvableApiException) {
                    try {
                        pendingServiceResult = result
                        error.startResolutionForResult(this, REQUEST_LOCATION_SERVICE)
                    } catch (e: Exception) {
                        pendingServiceResult = null
                        result.error("unavailable", e.message, null)
                    }
                } else {
                    result.error("unavailable", error.message, null)
                }
            }
    }

    @Deprecated("Needed for Play services' resolution dialog")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_LOCATION_SERVICE) {
            pendingServiceResult?.success(resultCode == Activity.RESULT_OK)
            pendingServiceResult = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private companion object {
        const val LOCATION_CHANNEL = "in.margapp.marg_app/location"
        const val REQUEST_LOCATION_SERVICE = 7301
        const val LOCATION_INTERVAL_MS = 10_000L
    }
}
