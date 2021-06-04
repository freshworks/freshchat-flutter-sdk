class FreshchatUser {
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phone;
  String? _phoneCountryCode;
  String? _externalId;
  String? _restoreId;

  FreshchatUser(String? externalId, String? restoreId) {
    this._externalId = externalId;
    this._restoreId = restoreId;
  }

  String? getEmail() {
    return _email;
  }

  FreshchatUser setEmail(String? email) {
    this._email = email;
    return this;
  }

  String? getFirstName() {
    return _firstName;
  }

  FreshchatUser setFirstName(String? firstName) {
    this._firstName = firstName;
    return this;
  }

  String? getLastName() {
    return _lastName;
  }

  FreshchatUser setLastName(String? lastName) {
    this._lastName = lastName;
    return this;
  }

  String? getPhone() {
    return _phone;
  }

  FreshchatUser setPhone(String? phoneCountryCode, String? phone) {
    this._phoneCountryCode = phoneCountryCode;
    this._phone = phone;
    return this;
  }

  String? getPhoneCountryCode() {
    return _phoneCountryCode;
  }

  String? getExternalId() {
    return _externalId;
  }

  String? getRestoreId() {
    return _restoreId;
  }
}
