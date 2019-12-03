import 'package:libphonenumber/libphonenumber.dart';

class PhoneNumber {
  final String dialCode;
  final String countryCode;
  final String phoneNumber;
  var formattedNumber = '';

  PhoneNumber(
    this.dialCode,
    this.countryCode,
    this.phoneNumber,
  );

  Future<String> parsed() async {
    if (this.phoneNumber.trim().isNotEmpty && this.countryCode.isNotEmpty) {
      try {
        return await PhoneNumberUtil.normalizePhoneNumber(
            phoneNumber: this.phoneNumber, isoCode: this.countryCode);
      } catch (error) {
        return null;
      }
    }

    return null;
  }

  Future<RegionInfo> format() async {
    if (this.phoneNumber.trim().isNotEmpty && this.countryCode.isNotEmpty) {
      try {
        RegionInfo _region = await PhoneNumberUtil.getRegionInfo(
            phoneNumber: this.phoneNumber, isoCode: this.countryCode);
        this.formattedNumber = _region.formattedPhoneNumber;
        return _region;
      } catch (error) {
        return null;
      }
    }
    return null;
  }

  Future<bool> validate() async {
    return await PhoneNumberUtil.isValidPhoneNumber(
        phoneNumber: this.phoneNumber, isoCode: this.countryCode);
  }

  @override
  String toString() {
    return this.formattedNumber;
  }
}
