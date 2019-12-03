# Country Phone Input

A simple and customizable country phone number input flutter package

## Getting Started

### Avaliable Parameters

| Parameter                     | Datatype          |    Initial Value     |
|-------------------------------|-------------------|----------------------|
| enableSearch                  | bool              |   true                |
| hintText                      | String            |   ''                  |
| focusNode                     | FocusNode         |   null                |
| onInputChanged                | Function          |   null                |
| textFieldController           | TextEditingController | TextEditingController() |
| initialCountryIsoCode         | String            | ''    |
| initialPhoneNumberE164        | String            | ''    |



### Example

```dart
PhoneInput(
    enableSearch: false,
    hintText: 'Phone Number',
    onInputChanged: (PhoneNumber phoneNumber) {
        // get formatted phone number
        print(phoneNumber.toString());
    },
),
```

## Dependencies
* [libphonenumber](https://pub.dev/packages/libphonenumber)