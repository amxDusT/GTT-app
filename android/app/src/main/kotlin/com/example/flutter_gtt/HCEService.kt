// import android.annotation.TargetApi
// import android.content.Intent
// import android.nfc.cardemulation.HostApduService
// import android.os.Build
// import android.os.Bundle
// import com.example.flutter_gtt.MainActivity

// @TargetApi(Build.VERSION_CODES.KITKAT)
// class HCEService : HostApduService() {
//     private val RESULT_SUCCESS : String = "RESULT_SUCCESS"
//     private val RESULT_FAILURE : String = "RESULT_FAILURE"
//     private val RESULT_EMPTY : String = "RESULT_EMPTY"
//     override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
//     if (commandApdu != null) {
//         val success: Boolean = processCommand(commandApdu)
//         forwardTheResult(success)
//         return if (success) RESULT_SUCCESS.toByteArray() else RESULT_FAILURE.toByteArray()
//     }
//     return RESULT_EMPTY.toByteArray()
//     }

//     override fun onDeactivated(p0: Int) {

//         // deactivated
//     }
//     private fun processCommand(commandApdu: ByteArray?) : Boolean {
//         return true
//     }
//     private fun forwardTheResult(success: Boolean) {
//         startActivity(
//             Intent(this, MainActivity::class.java)
//                 .apply {
//                     addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                     putExtra("success", true)
//             }
//         )
//     }
// }
