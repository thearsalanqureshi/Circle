package com.company.circle

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlin.math.min
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private var pendingImageResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            POST_IMAGE_PICKER_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                PICK_COMPRESSED_IMAGE_METHOD -> pickCompressedImage(result)
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated by Android, but still supported by FlutterActivity.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_IMAGE_REQUEST_CODE) {
            return
        }

        val result = pendingImageResult ?: return
        pendingImageResult = null

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }

        try {
            val bytes = compressImage(uri)
            if (bytes == null || bytes.size > MAX_IMAGE_BYTES) {
                result.error("image-too-large", "Image exceeds the upload limit.", null)
                return
            }
            result.success(
                mapOf(
                    "bytes" to bytes,
                    "fileName" to displayNameFor(uri),
                    "contentType" to "image/jpeg"
                )
            )
        } catch (error: Exception) {
            result.error("image-pick-failed", error.message, null)
        }
    }

    private fun pickCompressedImage(result: MethodChannel.Result) {
        if (pendingImageResult != null) {
            result.error("image-picker-busy", "Image picker is already open.", null)
            return
        }

        pendingImageResult = result
        val intent = Intent(Intent.ACTION_PICK).apply {
            type = "image/*"
        }
        startActivityForResult(intent, PICK_IMAGE_REQUEST_CODE)
    }

    private fun compressImage(uri: Uri): ByteArray? {
        val bitmap = contentResolver.openInputStream(uri)?.use { stream ->
            BitmapFactory.decodeStream(stream)
        } ?: return null

        val scaled = scaledBitmap(bitmap)
        val output = ByteArrayOutputStream()
        var quality = IMAGE_QUALITY
        var bytes: ByteArray

        do {
            output.reset()
            scaled.compress(Bitmap.CompressFormat.JPEG, quality, output)
            bytes = output.toByteArray()
            quality -= QUALITY_STEP
        } while (bytes.size > MAX_IMAGE_BYTES && quality >= MIN_IMAGE_QUALITY)

        if (scaled != bitmap) {
            scaled.recycle()
        }
        bitmap.recycle()

        return bytes
    }

    private fun scaledBitmap(bitmap: Bitmap): Bitmap {
        val scale = min(
            1.0,
            min(
                MAX_IMAGE_WIDTH / bitmap.width.toDouble(),
                MAX_IMAGE_HEIGHT / bitmap.height.toDouble()
            )
        )
        if (scale >= 1.0) {
            return bitmap
        }

        return Bitmap.createScaledBitmap(
            bitmap,
            (bitmap.width * scale).roundToInt(),
            (bitmap.height * scale).roundToInt(),
            true
        )
    }

    private fun displayNameFor(uri: Uri): String {
        var name = "post.jpg"
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                name = cursor.getString(index) ?: name
            }
        }
        return name.substringBeforeLast('.', name) + ".jpg"
    }

    companion object {
        private const val POST_IMAGE_PICKER_CHANNEL = "circle/post_image_picker"
        private const val PICK_COMPRESSED_IMAGE_METHOD = "pickCompressedImage"
        private const val PICK_IMAGE_REQUEST_CODE = 4203
        private const val MAX_IMAGE_BYTES = 300 * 1024
        private const val MAX_IMAGE_WIDTH = 960.0
        private const val MAX_IMAGE_HEIGHT = 960.0
        private const val IMAGE_QUALITY = 60
        private const val MIN_IMAGE_QUALITY = 24
        private const val QUALITY_STEP = 6
    }
}
