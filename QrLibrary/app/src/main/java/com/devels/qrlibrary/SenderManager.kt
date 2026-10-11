class SenderManager {
    fun validateQRFormat( textQr: String ): String? {
        val regexValid = Regex("^product:[1-9][0-9]*$")
        if (!regexValid.matches(textQr)) {
            return null
        }

        val id = textQr.substringAfter("product:")

        return id;
    }
}