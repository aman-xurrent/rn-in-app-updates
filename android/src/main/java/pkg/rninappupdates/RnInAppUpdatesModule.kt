package pkg.rninappupdates

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.Arguments
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability

class RnInAppUpdatesModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  private val appUpdateManager: AppUpdateManager = AppUpdateManagerFactory.create(reactContext)

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun checkForUpdate(promise: Promise) {
    val appUpdateInfoTask = appUpdateManager.appUpdateInfo

    appUpdateInfoTask.addOnSuccessListener { appUpdateInfo: AppUpdateInfo ->
      val result: WritableMap = Arguments.createMap()
      
      val isUpdateAvailable = appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
        appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
      
      result.putBoolean("isUpdateAvailable", isUpdateAvailable)
      promise.resolve(result)
    }.addOnFailureListener { exception: Exception ->
      promise.reject("UPDATE_CHECK_ERROR", "Failed to check for update: ${exception.message}", exception)
    }
  }

  @ReactMethod
  fun updateApp(promise: Promise) {
    val appUpdateInfoTask = appUpdateManager.appUpdateInfo

    appUpdateInfoTask.addOnSuccessListener { appUpdateInfo: AppUpdateInfo ->
      if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
          appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)) {
        
        val currentActivity = currentActivity
        if (currentActivity != null) {
          try {
            appUpdateManager.startUpdateFlowForResult(
              appUpdateInfo,
              currentActivity,
              AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
              UPDATE_REQUEST_CODE
            )
            promise.resolve(null)
          } catch (e: Exception) {
            promise.reject("UPDATE_START_ERROR", "Failed to start update: ${e.message}", e)
          }
        } else {
          promise.reject("NO_ACTIVITY", "No current activity available to start update flow", null as Throwable?)
        }
      } else {
        promise.reject("NO_UPDATE_AVAILABLE", "No update available or update type not supported", null as Throwable?)
      }
    }.addOnFailureListener { exception: Exception ->
      promise.reject("UPDATE_START_ERROR", "Failed to start update: ${exception.message}", exception)
    }
  }

  companion object {
    const val NAME = "RnInAppUpdates"
    const val UPDATE_REQUEST_CODE = 1001
  }
}