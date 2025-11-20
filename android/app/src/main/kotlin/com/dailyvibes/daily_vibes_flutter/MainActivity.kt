package com.dailyvibes.daily_vibes_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.dailyvibes/notifications"
    private val CHANNEL_ID = "daily_vibes_notifications"
    private var notificationId = 1000

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        createNotificationChannel()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotification" -> {
                    val title = call.argument<String>("title") ?: "Daily Vibes"
                    val body = call.argument<String>("body") ?: ""
                    showNotification(title, body)
                    result.success(null)
                }
                "scheduleNotification" -> {
                    // TODO: Implement scheduling logic
                    result.success(null)
                }
                "cancelAll" -> {
                    cancelAllNotifications()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Daily Vibes"
            val descriptionText = "Benachrichtigungen für Daily Vibes"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(title: String, body: String) {
        try {
            val builder = NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true)

            with(NotificationManagerCompat.from(this)) {
                try {
                    notify(notificationId++, builder.build())
                    println("✅ Notification shown: $title")
                } catch (e: SecurityException) {
                    println("❌ SecurityException: Missing notification permission - $e")
                }
            }
        } catch (e: Exception) {
            println("❌ Notification error: $e")
        }
    }

    private fun cancelAllNotifications() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }
}
