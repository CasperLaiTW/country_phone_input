import 'dart:convert';

import 'package:country_phone_input/models/country.dart';
import 'package:country_phone_input/models/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';

class PhoneInput extends StatefulWidget {
  final bool enableSearch;
  final String hintText;
  final FocusNode focusNode;
  final ValueChanged<PhoneNumber> onInputChanged;
  final TextEditingController textFieldController;
  final String initialCountryIsoCode;
  final String initialPhoneNumberE164;

  const PhoneInput({
    Key key,
    @required this.onInputChanged,
    this.enableSearch = true,
    this.hintText,
    this.focusNode,
    this.textFieldController,
    this.initialCountryIsoCode = 'US',
    this.initialPhoneNumberE164 = '',
  }) : super(key: key);

  @override
  _PhoneInputState createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _textFieldController;
  List<Country> _countries = [];
  Country _selected;

  @override
  void initState() {
    _textFieldController =
        widget.textFieldController ?? TextEditingController();
    this._loadJson().then((data) {
      setState(() {
        this._countries = data;
        this._selected = this
            ._countries
            .where((country) =>
                country.countryCode == widget.initialCountryIsoCode)
            .first;
        if (widget.initialPhoneNumberE164.isNotEmpty) {
          _handlePhoneNumberChange(widget.initialPhoneNumberE164);
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this._selected != null) {
      return Container(
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: FlatButton.icon(
                icon: Image.asset(
                  this._selected.flag,
                  width: 32,
                ),
                label: Text(this._selected.dailCode),
                onPressed: _showCountrySearch,
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: widget.hintText),
                  focusNode: widget.focusNode,
                  controller: _textFieldController,
                  onChanged: _handlePhoneNumberChange,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Container();
  }

  void _showCountrySearch() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          List<Widget> widgets = [];
          if (widget.enableSearch) {
            widgets.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Search'),
                controller: _searchController,
              ),
            ));
          }
          widgets.add(Expanded(
            child: ListView.builder(
              itemCount: this._filterCountries().length,
              itemBuilder: (BuildContext context, index) {
                Country country = this._filterCountries()[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(country.flag),
                  ),
                  title: new Text('${country.text}'),
                  onTap: () {
                    setState(() {
                      this._selected = country;
                      this._textFieldController.text = '';
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ));
          return Column(children: widgets);
        });
  }

  List<Country> _filterCountries() {
    final value = this._searchController.text.trim();

    if (value.isNotEmpty) {
      return this._countries.where((country) {
        return country.name.toLowerCase().contains(value.toLowerCase()) ||
            country.dailCode.contains(value);
      }).toList();
    }
    return this._countries;
  }

  Future<List<Country>> _loadJson() async {
    String list = await DefaultAssetBundle.of(context)
        .loadString('assets/phone/countries.json');
    var jsonData = json.decode(list) as List<dynamic>;

    var data = jsonData.map((data) {
      return Country(
        data['dial_code'],
        data['name'],
        data['code'],
        'assets/phone/flags/${data['code'].toLowerCase()}.png',
      );
    }).toList();

    return data;
  }

  Future<void> _handlePhoneNumberChange(String number) async {
    PhoneNumber phone = PhoneNumber(
        this._selected.dailCode, this._selected.countryCode, number);
    RegionInfo formatted = await phone.format();
    if (formatted != null && formatted.isoCode.isNotEmpty) {
      if (this._selected.countryCode != formatted.isoCode) {
        setState(() {
          this._selected = this._countries.firstWhere(
              (Country country) => country.countryCode == formatted.isoCode);
        });
      }
      if (formatted.formattedPhoneNumber.isNotEmpty) {
        String newNumber = formatted.formattedPhoneNumber;
        setState(() {
          this._textFieldController.value =
              this._textFieldController.value.copyWith(
                    text: newNumber,
                    selection: TextSelection(
                        baseOffset: newNumber.length,
                        extentOffset: newNumber.length),
                  );
        });
      }
    }

    widget.onInputChanged(phone);
  }
}
